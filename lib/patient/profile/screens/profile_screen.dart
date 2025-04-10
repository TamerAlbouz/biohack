import 'package:backend/backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:medtalk/common/widgets/common_error_widget.dart';
import 'package:medtalk/styles/colors.dart';

import '../../../styles/font.dart';
import '../../../styles/sizes.dart';
import '../bloc/patient_profile_bloc.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _isEditing = false;
  final TextEditingController _biographyController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String? _selectedBloodType;
  String? _selectedSex;
  DateTime? _selectedDob;

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];
  final List<String> _sexOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _biographyController.dispose();
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _toggleEditMode(PatientProfileLoaded state) {
    if (_isEditing) {
      // Save changes
      context.read<PatientProfileBloc>().add(UpdatePatientProfile(
            name: _nameController.text,
            biography: _biographyController.text,
            bloodType: _selectedBloodType,
            height: _heightController.text.isNotEmpty
                ? double.parse(_heightController.text)
                : null,
            weight: _weightController.text.isNotEmpty
                ? double.parse(_weightController.text)
                : null,
            sex: _selectedSex,
            dateOfBirth: _selectedDob,
          ));
    } else {
      // Enter edit mode, populate controllers
      _nameController.text = state.patient.name ?? '';
      _biographyController.text = state.patient.biography ?? '';
      _heightController.text = state.patient.height?.toString() ?? '';
      _weightController.text = state.patient.weight?.toString() ?? '';
      _selectedBloodType = state.patient.bloodType;
      _selectedSex = state.patient.sex;
      _selectedDob = state.patient.dateOfBirth;
    }

    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PatientProfileBloc, PatientProfileState>(
        builder: (context, state) {
          if (state is PatientProfileLoading ||
              state is PatientProfileInitial) {
            return _buildLoadingState();
          }

          if (state is PatientProfileError) {
            return CommonErrorWidget(
                onRetry: () => context.read<PatientProfileBloc>().add(
                    LoadPatientProfile(
                        getIt<IAuthenticationRepository>().currentUser.uid)));
          }

          state as PatientProfileLoaded;
          return _buildProfileTab(state);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Loading your profile...", style: TextStyle(color: Colors.grey))
        ],
      ),
    );
  }

  Widget _buildProfileTab(PatientProfileLoaded state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Health Metrics",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_isEditing)
                    const Expanded(
                      child: Text(
                        " (Tap to edit)",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
              kGap12,
              CustomBase(
                shadow: false,
                child: Padding(
                  padding: kPaddV12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHealthMetric(
                        "Blood Type",
                        state.patient.bloodType ?? "Unknown",
                        "blood-type",
                        _isEditing ? () => _showBloodTypeSelector() : null,
                      ),
                      _buildHealthMetric(
                        "Height",
                        _isEditing
                            ? null
                            : "${state.patient.height ?? '--'} cm",
                        "height",
                        null,
                        editController: _isEditing ? _heightController : null,
                        keyboardType: TextInputType.number,
                        suffix: _isEditing ? "cm" : null,
                      ),
                      _buildHealthMetric(
                        "Weight",
                        _isEditing
                            ? null
                            : "${state.patient.weight ?? '--'} kg",
                        "weight",
                        null,
                        editController: _isEditing ? _weightController : null,
                        keyboardType: TextInputType.number,
                        suffix: _isEditing ? "kg" : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          kGap20,

          // Basic info card
          _buildInfoCard(
            "Personal Information",
            [
              _buildEditableField(
                "Full Name",
                _isEditing ? null : state.patient.name ?? "Not provided",
                Icons.person,
                controller: _nameController,
                isEditing: _isEditing,
              ),
              _buildEditableField(
                "Date of Birth",
                _isEditing
                    ? null
                    : (_selectedDob != null
                        ? DateFormat('MMMM d, yyyy').format(_selectedDob!)
                        : "Not provided"),
                Icons.cake,
                isEditing: _isEditing,
                onTap: _isEditing ? () => _selectDate(context) : null,
                suffixIcon: _isEditing ? Icons.calendar_today : null,
              ),
              _buildEditableField(
                "Gender",
                _isEditing ? null : state.patient.sex ?? "Not provided",
                Icons.wc,
                isEditing: _isEditing,
                isDropdown: _isEditing,
                dropdownItems: _sexOptions,
                selectedValue: _selectedSex,
                onDropdownChanged: (value) {
                  setState(() {
                    _selectedSex = value;
                  });
                },
              ),
              _buildEditableField(
                "Age",
                "${_calculateAge(state.patient.dateOfBirth)} years",
                Icons.timelapse,
                isEditable: false,
              ),
            ],
          ),

          kGap20,

          // Biography card
          _buildInfoCard(
            "Biography",
            [
              if (_isEditing)
                TextFormField(
                  controller: _biographyController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Tell us about yourself...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: MyColors.primary),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    state.patient.biography ?? "No biography provided.",
                    style: const TextStyle(
                      fontSize: Font.small,
                      height: 1.5,
                    ),
                  ),
                ),
            ],
          ),

          kGap20,

          // Action buttons
          _buildInfoCard(
            "Account Settings",
            [
              _buildActionButton(
                "Appointment History",
                FontAwesomeIcons.clockRotateLeft,
                onTap: () {},
              ),
              _buildActionButton(
                "Payment Methods",
                FontAwesomeIcons.creditCard,
                onTap: () {},
              ),
              _buildActionButton(
                "Payment History",
                FontAwesomeIcons.fileInvoiceDollar,
                onTap: () {},
              ),
              _buildActionButton(
                "Contact Support",
                FontAwesomeIcons.headset,
                onTap: () {},
              ),
              _buildActionButton(
                "Terms & Conditions",
                FontAwesomeIcons.fileContract,
                onTap: () {},
                showDivider: false,
              ),
            ],
          ),

          kGap24,

          Center(
            child: TextButton.icon(
              onPressed: () {
                // Handle sign out
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                "Sign Out",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),

          kGap40,
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MyColors.textBlack,
          ),
        ),
        kGap12,
        CustomBase(
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [...children],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField(
    String label,
    String? value,
    IconData icon, {
    bool isEditable = true,
    bool isEditing = false,
    TextEditingController? controller,
    VoidCallback? onTap,
    IconData? suffixIcon,
    bool isDropdown = false,
    List<String>? dropdownItems,
    String? selectedValue,
    void Function(String?)? onDropdownChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          kGap8,
          if (isEditing && isEditable)
            if (isDropdown && dropdownItems != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedValue,
                    hint: const Text("Select"),
                    items: dropdownItems.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: onDropdownChanged,
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: onTap,
                child: AbsorbPointer(
                  absorbing: onTap != null,
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      prefixIcon: Icon(icon, color: Colors.grey),
                      suffixIcon: suffixIcon != null
                          ? Icon(suffixIcon, color: MyColors.primary)
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: MyColors.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: isEditable ? Colors.grey.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value ?? "Not provided",
                      style: TextStyle(
                        fontSize: 16,
                        color: value != null ? MyColors.textBlack : Colors.grey,
                      ),
                    ),
                  ),
                  if (isEditable && !isEditing)
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: MyColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  void _showBloodTypeSelector() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Blood Type"),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: _bloodTypes.length,
              itemBuilder: (context, index) {
                final bloodType = _bloodTypes[index];
                final bool isSelected = bloodType == _selectedBloodType;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedBloodType = bloodType;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? MyColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? MyColors.primary
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        bloodType,
                        style: TextStyle(
                          color: isSelected ? Colors.white : MyColors.textBlack,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHealthMetric(
    String label,
    String? value,
    String type,
    VoidCallback? onTap, {
    TextEditingController? editController,
    TextInputType? keyboardType,
    String? suffix,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getMetricColor(type).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  _getMetricIcon(type),
                  color: _getMetricColor(type),
                  size: 24,
                ),
              ),
            ),
            kGap12,
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            kGap8,
            if (editController != null)
              SizedBox(
                height: 40,
                child: TextFormField(
                  controller: editController,
                  keyboardType: keyboardType,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    border: const OutlineInputBorder(),
                    suffixText: suffix,
                    isDense: true,
                  ),
                ),
              )
            else
              Text(
                value ?? "--",
                style: const TextStyle(
                  fontSize: Font.smallExtra,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Color _getMetricColor(String type) {
    switch (type) {
      case 'blood-type':
        return Colors.red;
      case 'height':
        return Colors.green;
      case 'weight':
        return Colors.blue;
      default:
        return MyColors.primary;
    }
  }

  IconData _getMetricIcon(String type) {
    switch (type) {
      case 'blood-type':
        return FontAwesomeIcons.droplet;
      case 'height':
        return FontAwesomeIcons.rulerVertical;
      case 'weight':
        return FontAwesomeIcons.weightScale;
      default:
        return FontAwesomeIcons.plus;
    }
  }

  Widget _buildActionButton(
    String title,
    IconData icon, {
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: MyColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: FaIcon(
                      icon,
                      color: MyColors.primary,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        if (showDivider) const Divider(height: 1, thickness: 1),
      ],
    );
  }

  int _calculateAge(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    final age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      return age - 1;
    }
    return age;
  }
}
