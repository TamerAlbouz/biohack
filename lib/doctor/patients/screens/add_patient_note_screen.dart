import 'package:backend/backend.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:medtalk/common/widgets/rows/cancel_confirm.dart';
import 'package:medtalk/common/widgets/toggle.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/font.dart';
import 'package:medtalk/styles/sizes.dart';

class AddPatientNoteScreen extends StatefulWidget {
  final Patient patient;

  const AddPatientNoteScreen({
    super.key,
    required this.patient,
  });

  static Route<void> route(Patient patient) {
    return MaterialPageRoute<void>(
      builder: (_) => AddPatientNoteScreen(patient: patient),
    );
  }

  @override
  State<AddPatientNoteScreen> createState() => _AddPatientNoteScreenState();
}

class _AddPatientNoteScreenState extends State<AddPatientNoteScreen> {
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPublic = true; // Whether note should be visible to patient
  String _selectedCategory = 'General'; // Default category

  // List of note categories
  final List<String> _categories = [
    'General',
    'Diagnosis',
    'Treatment',
    'Medication',
    'Follow-up',
    'Lab Results',
    'Consultation',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medical Note'),
        backgroundColor: MyColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: kPadd20,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient info header
              CustomBase(
                shadow: false,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: MyColors.primary.withOpacity(0.2),
                      child: Text(
                        _getInitials(widget.patient.name ?? 'Unknown'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: MyColors.primary,
                        ),
                      ),
                    ),
                    kGap16,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.patient.name ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: Font.mediumSmall,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          kGap4,
                          RichText(
                            text: TextSpan(
                              children: [
                                const WidgetSpan(
                                  child: FaIcon(
                                    FontAwesomeIcons.solidCalendar,
                                    size: 12,
                                    color: MyColors.subtitleDark,
                                  ),
                                  alignment: PlaceholderAlignment.middle,
                                ),
                                const WidgetSpan(
                                  child: SizedBox(width: 5),
                                ),
                                TextSpan(
                                  text:
                                      'Adding note: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
                                  style: const TextStyle(
                                    fontSize: Font.extraSmall,
                                    color: MyColors.subtitleDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              kGap20,

              // Category selection
              const Text(
                'Note Category',
                style: TextStyle(
                  fontSize: Font.small,
                  fontWeight: FontWeight.bold,
                ),
              ),
              kGap8,
              InkWell(
                onTap: () {
                  _showSlotDurationPicker(context);
                },
                child: CustomBase(
                  shadow: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCategory,
                        style: const TextStyle(
                          fontSize: Font.small,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, size: 24),
                    ],
                  ),
                ),
              ),
              kGap20,

              // Note content
              const Text(
                'Note Content',
                style: TextStyle(
                  fontSize: Font.small,
                  fontWeight: FontWeight.bold,
                ),
              ),
              kGap8,
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTemplateButton(
                        'Progress is within expected parameters.'),
                    kGap8,
                    _buildTemplateButton(
                        'Patient reports improvement in symptoms.'),
                    kGap8,
                    _buildTemplateButton('Follow-up recommended in 2 weeks.'),
                    kGap8,
                    _buildTemplateButton('Medication dosage adjusted.'),
                  ],
                ),
              ),
              kGap16,
              CustomBase(
                shadow: false,
                child: TextFormField(
                  controller: _noteController,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    hintText: 'Enter detailed note here...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: MyColors.subtitleDark,
                      fontSize: Font.small,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: Font.small,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter note content';
                    }
                    return null;
                  },
                ),
              ),
              kGap16,
              Toggle(
                title: 'Private Note',
                subtitle: 'Not visible to patient',
                onChanged: (bool value) {
                  setState(() {
                    _isPublic = !value;
                  });
                },
                isEnabled: !_isPublic,
              ),
              kGap30,

              CancelConfirm(onConfirm: _saveNote, confirmText: 'Save Note'),
              kGap20,
            ],
          ),
        ),
      ),
    );
  }

  void _showSlotDurationPicker(BuildContext context) {
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
          height: 470,
          padding: kPadd16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Note Category',
                style: TextStyle(
                  fontSize: Font.medium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              kGap10,
              Expanded(
                child: ListView(
                  children: [
                    _buildSlotDurationOption(
                      context,
                      'General',
                    ),
                    line,
                    _buildSlotDurationOption(
                      context,
                      'Diagnosis',
                    ),
                    line,
                    _buildSlotDurationOption(
                      context,
                      'Treatment',
                    ),
                    line,
                    _buildSlotDurationOption(
                      context,
                      'Medication',
                    ),
                    line,
                    _buildSlotDurationOption(
                      context,
                      'Follow-up',
                    ),
                    line,
                    _buildSlotDurationOption(
                      context,
                      'Lab Results',
                    ),
                    line,
                    _buildSlotDurationOption(
                      context,
                      'Consultation',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSlotDurationOption(BuildContext context, String label) {
    bool isSelected = _selectedCategory == label;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = label;
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

  void _saveNote() {
    if (_formKey.currentState?.validate() ?? false) {
      final note = _noteController.text.trim();

      if (note.isNotEmpty) {
        // Add note to patient record using BLoC
        // This would be the actual implementation to save the note
        // context.read<PatientDetailsBloc>().add(
        //   AddPatientNote(
        //     patientId: widget.patient.id!,
        //     note: note,
        //     category: _selectedCategory,
        //     isPublic: _isPublic,
        //   ),
        // );

        // For now, just show success and pop
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note added successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop();
      }
    }
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Medical Notes'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Guidelines:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Font.small,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• Be specific and accurate in your documentation\n'
              '• Use objective language\n'
              '• Include dates and timestamps\n'
              '• Document patient responses to treatment\n'
              '• Note any advice or instructions given\n',
              style: TextStyle(
                fontSize: Font.small,
              ),
            ),
            Text(
              'Privacy:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Font.small,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Private notes are not visible to patients but remain part of their medical record.',
              style: TextStyle(
                fontSize: Font.small,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateButton(String template) {
    return InkWell(
      onTap: () {
        final currentText = _noteController.text;
        if (currentText.isEmpty) {
          _noteController.text = template;
        } else {
          _noteController.text = '$currentText\n$template';
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: MyColors.cardBackground,
          borderRadius: kRadius20,
        ),
        child: Text(
          template,
          style: const TextStyle(
            fontSize: Font.extraSmall,
            color: MyColors.subtitleDark,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    } else {
      return name[0];
    }
  }
}
