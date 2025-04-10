import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/common/widgets/dividers/card_divider.dart';
import 'package:medtalk/common/widgets/rows/cancel_confirm.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/font.dart';
import 'package:medtalk/styles/sizes.dart';
import 'package:uuid/uuid.dart';

import '../../../common/widgets/themes/time_picker.dart';
import '../../../common/widgets/toggle.dart';
import '../models/design_models.dart';

class ServiceEditorScreen extends StatefulWidget {
  final DoctorService? service; // Null for new service, populated for editing

  const ServiceEditorScreen({
    super.key,
    this.service,
  });

  static Route<DoctorService?> route({DoctorService? service}) {
    return MaterialPageRoute<DoctorService?>(
      builder: (_) => ServiceEditorScreen(service: service),
    );
  }

  @override
  State<ServiceEditorScreen> createState() => _ServiceEditorScreenState();
}

class _ServiceEditorScreenState extends State<ServiceEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _durationController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;

  // First, add these properties to the state class
  String _preAppointmentInstructions = '';
  bool _hasCustomAvailability = false;
  List<bool> _availableDays =
      List.generate(7, (_) => true); // All days available by default
  String _startTime = '09:00';
  String _endTime = '17:00';

  bool _isOnline = false;
  bool _isInPerson = true;
  bool _isHomeVisit = false;

  bool get _isEditing => widget.service != null;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data if editing
    _titleController = TextEditingController(text: widget.service?.title ?? '');
    _durationController =
        TextEditingController(text: widget.service?.duration.toString() ?? '');
    _priceController = TextEditingController(
      text: widget.service?.price.toString() ?? '',
    );
    _descriptionController =
        TextEditingController(text: widget.service?.description ?? '');

    if (_isEditing) {
      final service = widget.service!;

      // Initialize appointment types
      _isOnline = service.isOnline;
      _isInPerson = service.isInPerson;
      _isHomeVisit = service.isHomeVisit;

      // Initialize pre-appointment instructions
      _preAppointmentInstructions = service.preAppointmentInstructions ?? '';

      // Initialize availability settings
      if (service.availability != null) {
        _hasCustomAvailability = true;
        _availableDays = List.from(service.availability!.days);
        _startTime = service.availability!.startTime;
        _endTime = service.availability!.endTime;
      }

      // Format the duration text for display
      if (service.duration >= 60) {
        if (service.duration % 60 == 0) {
          // Full hours
          final hours = service.duration ~/ 60;
          _durationController.text = '$hours hour${hours > 1 ? 's' : ''}';
        } else if (service.duration == 90) {
          // Special case for 1.5 hours
          _durationController.text = '1.5 hours';
        } else {
          // Other minute values
          _durationController.text = '${service.duration} minutes';
        }
      } else {
        // Minutes only
        _durationController.text = '${service.duration} minutes';
      }
    } else {
      // Default values for new service
      _durationController.text = '';
      _priceController.text = '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.cardBackground,
      appBar: AppBar(
        backgroundColor: MyColors.cardBackground,
        foregroundColor: Colors.black,
        toolbarHeight: 40,
        title: Text(
          _isEditing ? 'Edit Service' : 'Add New Service',
          style: const TextStyle(
            fontSize: Font.medium,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: kPadd20,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Info Card
                _buildInfoCard(),
                kGap20,

                const CardDivider(),
                // Appointment Types Section
                _buildAppointmentTypesSection(),
                kGap20,

                const CardDivider(),
                // Additional Settings Section
                _buildAdditionalSettingsSection(),
                kGap40,

                // Save/Cancel Buttons
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Service Information',
          style: TextStyle(
            fontSize: Font.medium,
            fontWeight: FontWeight.bold,
            color: MyColors.textBlack,
          ),
        ),
        kGap20,

        TextFormField(
          controller: _titleController,
          style: const TextStyle(
            fontSize: Font.small,
            color: MyColors.textBlack,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: kRadius6),
            hintText: 'Enter service name',
            contentPadding: kPaddH10V8,
            hintStyle: const TextStyle(
              color: MyColors.textGrey,
              fontSize: Font.small,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 15),
              child: FaIcon(
                FontAwesomeIcons.kitMedical,
                color: MyColors.primary,
                size: 16,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 40),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a service name';
            }
            return null;
          },
        ),
        kGap10,

        TextFormField(
          controller: _descriptionController,
          style: const TextStyle(
            fontSize: Font.small,
            color: MyColors.textBlack,
          ),
          decoration: InputDecoration(
            hintText:
                'Brief description of what this service includes (Optional)',
            alignLabelWithHint: true,
            contentPadding: kPaddH10V8,
            hintStyle: const TextStyle(
              color: MyColors.textGrey,
              fontSize: Font.small,
              fontWeight: FontWeight.w400,
            ),
            border: OutlineInputBorder(borderRadius: kRadius6),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 15),
              child: FaIcon(
                FontAwesomeIcons.fileLines,
                color: MyColors.primary,
                size: 16,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 40),
          ),
          maxLines: 3,
        ),
        kGap10,

        // Duration and Price Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Duration Field - Dropdown with common options
            Expanded(
              child: TextFormField(
                controller: _durationController,
                readOnly: true,
                style: const TextStyle(
                  fontSize: Font.small,
                  color: MyColors.textBlack,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: kRadius6,
                  ),
                  contentPadding: kPaddH10V8,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: FaIcon(
                      FontAwesomeIcons.clock,
                      color: MyColors.primary,
                      size: 16,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 40),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  hintText: "Duration",
                  hintStyle: const TextStyle(
                    color: MyColors.textGrey,
                    fontSize: Font.small,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                onTap: () {
                  _showDurationPicker(context);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
            kGap16,

            Expanded(
              child: TextFormField(
                style: const TextStyle(
                  fontSize: Font.small,
                  color: MyColors.textBlack,
                ),
                controller: _priceController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: kRadius6,
                  ),
                  contentPadding: kPaddH10V8,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: FaIcon(
                      FontAwesomeIcons.dollarSign,
                      color: MyColors.primary,
                      size: 16,
                    ),
                  ),
                  hintText: 'Price',
                  hintStyle: const TextStyle(
                    color: MyColors.textGrey,
                    fontSize: Font.small,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 40),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Invalid price';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Add this method to your class
  void _showDurationPicker(BuildContext context) {
    const line = DottedLine(
      direction: Axis.horizontal,
      lineLength: double.infinity,
      lineThickness: 1,
      dashLength: 4.0,
      dashColor: MyColors.softStroke,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: MyColors.cardBackground,
      builder: (BuildContext context) {
        return Container(
          height: 400,
          padding: kPadd16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Duration',
                style: TextStyle(
                  fontSize: Font.medium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              kGap10,
              Expanded(
                child: ListView(
                  children: [
                    _buildDurationOption(context, '15', '15 minutes'),
                    line,
                    _buildDurationOption(context, '30', '30 minutes'),
                    line,
                    _buildDurationOption(context, '45', '45 minutes'),
                    line,
                    _buildDurationOption(context, '60', '1 hour'),
                    line,
                    _buildDurationOption(context, '90', '1.5 hours'),
                    line,
                    _buildDurationOption(context, '120', '2 hours'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDurationOption(
      BuildContext context, String value, String label) {
    bool isSelected = _durationController.text == label;

    return InkWell(
      onTap: () {
        setState(() {
          _durationController.text = label;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? MyColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: Font.medium,
                color: isSelected ? MyColors.primary : MyColors.textBlack,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: MyColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Appointment Types',
          style: TextStyle(
            fontSize: Font.medium,
            fontWeight: FontWeight.bold,
            color: MyColors.textBlack,
          ),
        ),
        const Text(
          'Select how this service can be delivered',
          style: TextStyle(
            fontSize: Font.small,
            color: MyColors.textGrey,
          ),
        ),
        kGap20,

        // In-Person Toggle
        Toggle(
          title: 'In-Person Appointments',
          subtitle: 'Patients visit your clinic',
          icon: FontAwesomeIcons.hospitalUser,
          isEnabled: _isInPerson,
          onChanged: (value) {
            setState(() {
              _isInPerson = value!;
              // Ensure at least one type is selected
              if (!_isInPerson && !_isOnline && !_isHomeVisit) {
                _isInPerson = true;
              }
            });
          },
        ),
        kGap16,
        const DottedLine(
          direction: Axis.horizontal,
          lineLength: double.infinity,
          lineThickness: 1,
          dashLength: 4.0,
          dashColor: MyColors.softStroke,
        ),
        kGap16,

        // Online Toggle
        Toggle(
          title: 'Online Appointments',
          subtitle: 'Video consultations',
          icon: FontAwesomeIcons.video,
          isEnabled: _isOnline,
          onChanged: (value) {
            setState(() {
              _isOnline = value!;
              // Ensure at least one type is selected
              if (!_isInPerson && !_isOnline && !_isHomeVisit) {
                _isOnline = true;
              }
            });
          },
        ),
        kGap16,
        const DottedLine(
          direction: Axis.horizontal,
          lineLength: double.infinity,
          lineThickness: 1,
          dashLength: 4.0,
          dashColor: MyColors.softStroke,
        ),
        kGap16,

        // Home Visit Toggle
        Toggle(
          title: 'Home Visits',
          subtitle: 'You travel to the patient',
          icon: FontAwesomeIcons.house,
          isEnabled: _isHomeVisit,
          onChanged: (value) {
            setState(() {
              _isHomeVisit = value!;
              // Ensure at least one type is selected
              if (!_isInPerson && !_isOnline && !_isHomeVisit) {
                _isHomeVisit = true;
              }
            });
          },
        ),
      ],
    );
  }

// Replace the _buildAdditionalSettingsSection method
  Widget _buildAdditionalSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Settings',
          style: TextStyle(
            fontSize: Font.medium,
            fontWeight: FontWeight.bold,
            color: MyColors.textBlack,
          ),
        ),
        kGap20,

        // Pre-appointment Instructions
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pre-appointment Instructions',
                    style: TextStyle(
                      fontSize: Font.small,
                      fontWeight: FontWeight.w500,
                      color: MyColors.textBlack,
                    ),
                  ),
                  Text(
                    _preAppointmentInstructions.isEmpty
                        ? 'Guidelines for patients before the appointment'
                        : _preAppointmentInstructions,
                    style: TextStyle(
                      fontSize: Font.extraSmall,
                      color: _preAppointmentInstructions.isEmpty
                          ? MyColors.textGrey
                          : MyColors.textBlack,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _showInstructionsDialog,
              icon: Icon(
                _preAppointmentInstructions.isEmpty
                    ? Icons.add_circle_outline
                    : Icons.edit,
                color: MyColors.primary,
              ),
            ),
          ],
        ),
        kGap16,
        const DottedLine(
          direction: Axis.horizontal,
          lineLength: double.infinity,
          lineThickness: 1,
          dashLength: 4.0,
          dashColor: MyColors.softStroke,
        ),
        kGap16,

        // Availability Settings
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Custom Availability',
                    style: TextStyle(
                      fontSize: Font.small,
                      fontWeight: FontWeight.w500,
                      color: MyColors.textBlack,
                    ),
                  ),
                  Text(
                    'Set specific days/times this service is available',
                    style: TextStyle(
                      fontSize: Font.extraSmall,
                      color: MyColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _hasCustomAvailability,
              onChanged: (value) {
                setState(() {
                  _hasCustomAvailability = value;
                });
              },
              activeColor: MyColors.primary,
            ),
          ],
        ),

        // Custom availability options
        if (_hasCustomAvailability) ...[
          kGap16,
          const Text(
            'Available Days',
            style: TextStyle(
              fontSize: Font.small,
              fontWeight: FontWeight.w500,
              color: MyColors.textBlack,
            ),
          ),
          kGap8,
          // Week days selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDayToggle('M', 0),
              _buildDayToggle('T', 1),
              _buildDayToggle('W', 2),
              _buildDayToggle('T', 3),
              _buildDayToggle('F', 4),
              _buildDayToggle('S', 5),
              _buildDayToggle('S', 6),
            ],
          ),
          kGap16,

          // Time range picker
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Start Time',
                      style: TextStyle(
                        fontSize: Font.small,
                        color: MyColors.textGrey,
                      ),
                    ),
                    kGap4,
                    InkWell(
                      onTap: () => _selectTime(context, true),
                      child: Container(
                        padding: kPaddH10V8,
                        decoration: BoxDecoration(
                          border: Border.all(color: MyColors.grey),
                          borderRadius: kRadius6,
                        ),
                        child: Row(
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.clock,
                              color: MyColors.primary,
                              size: 16,
                            ),
                            kGap10,
                            Text(
                              _formatTimeDisplay(_startTime),
                              style: const TextStyle(
                                fontSize: Font.small,
                                color: MyColors.textBlack,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down,
                                color: MyColors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              kGap16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'End Time',
                      style: TextStyle(
                        fontSize: Font.small,
                        color: MyColors.textGrey,
                      ),
                    ),
                    kGap4,
                    InkWell(
                      onTap: () => _selectTime(context, false),
                      child: Container(
                        padding: kPaddH10V8,
                        decoration: BoxDecoration(
                          border: Border.all(color: MyColors.grey),
                          borderRadius: kRadius6,
                        ),
                        child: Row(
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.clock,
                              color: MyColors.primary,
                              size: 16,
                            ),
                            kGap10,
                            Text(
                              _formatTimeDisplay(_endTime),
                              style: const TextStyle(
                                fontSize: Font.small,
                                color: MyColors.textBlack,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down,
                                color: MyColors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

// Helper method to build day toggle
  Widget _buildDayToggle(String dayLabel, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _availableDays[index] = !_availableDays[index];
        });
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _availableDays[index] ? MyColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _availableDays[index] ? MyColors.primary : MyColors.grey,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          dayLabel,
          style: TextStyle(
            fontSize: Font.small,
            fontWeight: FontWeight.bold,
            color: _availableDays[index] ? Colors.white : MyColors.textGrey,
          ),
        ),
      ),
    );
  }

// Method to show time picker
  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    // Parse current time
    final timeParts = (isStartTime ? _startTime : _endTime).split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
// Show time picker
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: isStartTime ? 'Select Start Time' : 'Select End Time',
      cancelText: 'Cancel',
      confirmText: 'OK',
      builder: (context, child) {
        return timePickerTheme(
          child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        final hour = pickedTime.hour.toString().padLeft(2, '0');
        final minute = pickedTime.minute.toString().padLeft(2, '0');
        if (isStartTime) {
          _startTime = '$hour:$minute';
        } else {
          _endTime = '$hour:$minute';
        }
      });
    }
  }

// Format time for display (convert 24h to 12h format with AM/PM)
  String _formatTimeDisplay(String time24h) {
    final timeParts = time24h.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = timeParts[1];

    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$hour12:$minute $period';
  }

// Method to show instructions dialog - Fixed version
  void _showInstructionsDialog() {
    // Create controller but DON'T dispose it in this method
    // It will be automatically disposed when the dialog is closed
    final TextEditingController instructionsController = TextEditingController(
      text: _preAppointmentInstructions,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: MyColors.cardBackground,
          title: const Text('Pre-appointment Instructions'),
          content: SizedBox(
            // Set a fixed width to prevent overflow
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Provide instructions for patients before their appointment',
                    style: TextStyle(
                      fontSize: Font.small,
                      color: MyColors.textGrey,
                    ),
                  ),
                  kGap10,
                  TextField(
                    controller: instructionsController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText:
                          'E.g., Bring medical records, Fast for 8 hours, etc.',
                      contentPadding: kPadd10,
                      hintStyle: TextStyle(
                        color: MyColors.textGrey,
                        fontSize: Font.small,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: Font.small,
                      color: MyColors.textBlack,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _preAppointmentInstructions = instructionsController.text;
                });
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: MyColors.primary,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    // Do NOT dispose the controller here!
    // Flutter will handle it when the dialog is closed
  }

  Widget _buildActionButtons(BuildContext context) {
    return CancelConfirm(
      onConfirm: _saveService,
      confirmText: _isEditing ? 'Update Service' : 'Create Service',
    );
  }

  // Update the _saveService method to include the new fields
  void _saveService() {
    if (_formKey.currentState!.validate()) {
      // Extract the numeric value from the duration text
      int duration;
      // Handle common formats like "15 minutes", "1 hour", "1.5 hours"
      String durationText = _durationController.text.toLowerCase();
      if (durationText.contains('hour')) {
        // Handle hour format
        if (durationText.contains('.5')) {
          // Handle 1.5 hours format
          duration = 90; // 90 minutes
        } else {
          // Handle "X hour" format
          duration = int.parse(durationText.split(' ')[0]) * 60;
        }
      } else {
        // Handle "X minutes" format
        duration = int.parse(durationText.split(' ')[0]);
      }

      // Create a ServiceAvailability object if custom availability is enabled
      ServiceAvailability? availability;
      if (_hasCustomAvailability) {
        availability = ServiceAvailability(
          days: _availableDays,
          startTime: _startTime,
          endTime: _endTime,
        );
      }

      final service = DoctorService(
        id: widget.service?.id ?? const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        duration: duration,
        price: int.parse(_priceController.text),
        isOnline: _isOnline,
        isInPerson: _isInPerson,
        isHomeVisit: _isHomeVisit,
        preAppointmentInstructions: _preAppointmentInstructions,
        availability: availability,
      );

      Navigator.pop(context, service);
    }
  }
}
