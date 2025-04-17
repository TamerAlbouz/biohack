import 'package:backend/backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:medtalk/common/widgets/common_error_widget.dart';
import 'package:medtalk/common/widgets/custom_input_field.dart';
import 'package:medtalk/patient/profile/screens/settings_screens.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/styles/button.dart';

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
  bool _isImageUploading = false;
  final TextEditingController _biographyController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _selectedBloodType;
  String? _selectedSex;
  DateTime? _selectedDob;
  late TabController _tabController;
  String? _profileImageUrl;

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
  final List<String> _sexOptions = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _biographyController.dispose();
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _addressController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _toggleEditMode(PatientProfileLoaded state) {
    if (_isEditing) {
      // Show confirmation dialog before saving
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Save Changes?"),
          content: const Text(
              "Are you sure you want to save these changes to your profile?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _saveChanges();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.primary,
              ),
              child: const Text("SAVE"),
            ),
          ],
        ),
      );
    } else {
      // Enter edit mode, populate controllers
      _nameController.text = state.patient.name ?? '';
      _biographyController.text = state.patient.biography ?? '';
      _heightController.text = state.patient.height?.toString() ?? '';
      _weightController.text = state.patient.weight?.toString() ?? '';
      // _addressController.text = state.patient.address ?? '';
      _selectedBloodType = state.patient.bloodType;
      _selectedSex = state.patient.sex;
      _selectedDob = state.patient.dateOfBirth;
      // _profileImageUrl = state.patient.profileImageUrl;

      setState(() {
        _isEditing = true;
      });
    }
  }

  bool _validateForm() {
    bool isValid = true;
    String? errorMessage;

    // Validate name
    if (_nameController.text.trim().isEmpty) {
      isValid = false;
      errorMessage = "Name cannot be empty";
    }

    // Validate height (if provided)
    if (_heightController.text.isNotEmpty) {
      try {
        final height = double.parse(_heightController.text);
        if (height <= 0 || height > 300) {
          // Reasonable height range in cm
          isValid = false;
          errorMessage = "Please enter a valid height (1-300 cm)";
        }
      } catch (e) {
        isValid = false;
        errorMessage = "Height must be a valid number";
      }
    }

    // Validate weight (if provided)
    if (_weightController.text.isNotEmpty) {
      try {
        final weight = double.parse(_weightController.text);
        if (weight <= 0 || weight > 500) {
          // Reasonable weight range in kg
          isValid = false;
          errorMessage = "Please enter a valid weight (1-500 kg)";
        }
      } catch (e) {
        isValid = false;
        errorMessage = "Weight must be a valid number";
      }
    }

    // Validate date of birth
    if (_selectedDob != null) {
      if (_selectedDob!.isAfter(DateTime.now())) {
        isValid = false;
        errorMessage = "Date of birth cannot be in the future";
      }
    }

    // Show error message if validation fails
    if (!isValid && errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    return isValid;
  }

  void _saveChanges() {
    // Validate form before saving
    if (!_validateForm()) {
      return;
    }

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
          // address: _addressController.text,
          // profileImageUrl: _profileImageUrl,
        ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile updated successfully"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {
      _isEditing = false;
    });
  }

  void _cancelEdit() {
    if (_isEditing) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Discard Changes?"),
          content: const Text("Any unsaved changes will be lost."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("KEEP EDITING"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isEditing = false;
                  _profileImageUrl = null; // Reset any unsaved image changes
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("DISCARD"),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      setState(() {
        _isImageUploading = true; // Show uploading state
      });

      // This would typically use image_picker package
      // final ImagePicker _picker = ImagePicker();
      // final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      // For now, show a dialog to simulate the process
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Profile Picture"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select source:"),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Simulate camera selection
                          _simulateImageUpload("camera");
                        },
                        icon: const Icon(Icons.camera_alt, size: 40),
                        color: MyColors.primary,
                      ),
                      const Text("Camera"),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Simulate gallery selection
                          _simulateImageUpload("gallery");
                        },
                        icon: const Icon(Icons.photo_library, size: 40),
                        color: MyColors.primary,
                      ),
                      const Text("Gallery"),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isImageUploading = false;
                });
              },
              child: const Text("CANCEL"),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _isImageUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error selecting image: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Method to simulate image upload process
  void _simulateImageUpload(String source) {
    // In a real app, this would upload the image to storage and get back a URL

    // Show progress
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text("Uploading image from $source..."),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Simulate network delay
    Future.delayed(const Duration(seconds: 2), () {
      // Set a dummy URL (in a real app, this would be the actual uploaded image URL)
      setState(() {
        _profileImageUrl =
            "https://example.com/profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg";
        _isImageUploading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile picture updated successfully"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
          return SafeArea(
            child: Column(
              children: [
                // Tab Bar
                TabBar(
                  controller: _tabController,
                  labelColor: MyColors.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: MyColors.primary,
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.person),
                          SizedBox(width: 6),
                          Text("Profile"),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.settings),
                          SizedBox(width: 6),
                          Text("Settings"),
                        ],
                      ),
                    ),
                  ],
                ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProfileTab(state),
                      _buildSettingsTab(state),
                    ],
                  ),
                ),
              ],
            ),
          );
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

  Widget _buildProfileHeader(PatientProfileLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: MyColors.primary, width: 2),
                ),
                child: _isImageUploading
                    ? CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        child: const CircularProgressIndicator(),
                      )
                    : CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!)
                            : null,
                        child: _profileImageUrl == null
                            ? Text(
                                _getInitials(state.patient.name),
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: MyColors.primary,
                                ),
                              )
                            : null,
                      ),
              ),
              if (_isEditing)
                Container(
                  decoration: const BoxDecoration(
                    color: MyColors.primary,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: _pickProfileImage,
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          kGap16,

          Text(
            state.patient.name ?? "Add your name",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cake,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                state.patient.dateOfBirth != null
                    ? "${_calculateAge(state.patient.dateOfBirth)} years"
                    : "Age not provided",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.wc,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                state.patient.sex ?? "Not specified",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          kGap16,
          // Edit button under profile picture
          ElevatedButton.icon(
            onPressed: () => _toggleEditMode(state),
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            label: Text(_isEditing ? "Save Profile" : "Edit Profile"),
            style: kElevatedButtonCommonStyle,
          ),
          // Cancel button if in edit mode
          if (_isEditing)
            TextButton(
              onPressed: _cancelEdit,
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
        ],
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return "?";

    final nameParts = name.split(" ");
    if (nameParts.length > 1) {
      return "${nameParts[0][0]}${nameParts[1][0]}";
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0];
    } else {
      return "?";
    }
  }

  Widget _buildHealthSummary(PatientProfileLoaded state) {
    return CustomBase(
      shadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Health Summary",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          kGap16,
          Row(
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
                _isEditing ? null : "${state.patient.height ?? '--'} cm",
                "height",
                null,
                editController: _isEditing ? _heightController : null,
                keyboardType: TextInputType.number,
                suffix: _isEditing ? "cm" : null,
              ),
              _buildHealthMetric(
                "Weight",
                _isEditing ? null : "${state.patient.weight ?? '--'} kg",
                "weight",
                null,
                editController: _isEditing ? _weightController : null,
                keyboardType: TextInputType.number,
                suffix: _isEditing ? "kg" : null,
              ),
              _buildHealthMetric(
                "BMI",
                _calculateBMI(state.patient.height, state.patient.weight),
                "bmi",
                null,
              ),
            ],
          ),
          if (!_isEditing)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Last updated: ${DateFormat('MMM d, yyyy').format(DateTime.now())}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _calculateBMI(double? height, double? weight) {
    if (height == null || weight == null || height <= 0) return "--";

    // Convert height from cm to m
    final heightInMeters = height / 100;
    final bmi = weight / (heightInMeters * heightInMeters);

    return bmi.toStringAsFixed(1);
  }

  Widget _buildProfileTab(PatientProfileLoaded state) {
    return SingleChildScrollView(
      padding: kPaddH20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(state),
          _buildHealthSummary(state),
          kGap24,

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
                "Sex",
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
            ],
          ),

          kGap24,

          // Contact info card
          _buildInfoCard(
            "Contact Information",
            [
              _buildEditableField(
                "Email Address",
                state.patient.email,
                Icons.email,
                isEditable: false,
                isEditing: _isEditing,
              ),
              _buildEditableField(
                "Address",
                _isEditing ? null : "Not provided",
                Icons.home,
                controller: _addressController,
                isEditing: _isEditing,
                keyboardType: TextInputType.streetAddress,
              ),
            ],
          ),

          kGap24,

          // Biography card
          _buildInfoCard(
            "About Me",
            [
              if (_isEditing)
                CustomInputField(
                  controller: _biographyController,
                  maxLines: 4,
                  height: 60,
                  color: Colors.grey.shade50,
                  hintText: "Tell us about yourself...",
                  keyboardType: TextInputType.multiline,
                  onChanged: (String value) {},
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

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(PatientProfileLoaded state) {
    return SingleChildScrollView(
      padding: kPaddH20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          kGap16,

          // Medical History Section
          _buildSettingsSection(
            "Medical Records",
            [
              _buildActionButton(
                "Appointment History",
                FontAwesomeIcons.clockRotateLeft,
                onTap: () {
                  // Navigate to appointment history
                },
              ),
              _buildActionButton(
                "Prescriptions",
                FontAwesomeIcons.prescription,
                onTap: () {
                  // Navigate to prescriptions
                },
              ),
              _buildActionButton(
                "Medical Reports",
                FontAwesomeIcons.fileWaveform,
                onTap: () {
                  // Navigate to medical reports
                },
                showDivider: false,
              ),
            ],
          ),

          kGap24,

          // Payments Section
          _buildSettingsSection(
            "Payments",
            [
              _buildActionButton(
                "Payment Methods",
                FontAwesomeIcons.creditCard,
                onTap: () {
                  // Navigate to payment methods
                },
              ),
              _buildActionButton(
                "Billing History",
                FontAwesomeIcons.fileInvoiceDollar,
                onTap: () {
                  // Navigate to billing history
                },
              ),
              _buildActionButton(
                "Insurance Information",
                FontAwesomeIcons.shieldHalved,
                onTap: () {
                  // Navigate to insurance info
                },
                showDivider: false,
              ),
            ],
          ),

          kGap24,

          // Help & Support
          _buildSettingsSection(
            "Help & Support",
            [
              _buildActionButton(
                "Contact Support",
                FontAwesomeIcons.headset,
                onTap: () {
                  // Navigate to contact support
                },
              ),
              _buildActionButton(
                "FAQs",
                FontAwesomeIcons.circleQuestion,
                onTap: () {
                  // Navigate to FAQs
                },
              ),
              _buildActionButton(
                "Terms & Conditions",
                FontAwesomeIcons.fileContract,
                onTap: () {
                  // Navigate to terms
                },
              ),
              _buildActionButton(
                "Privacy Policy",
                FontAwesomeIcons.userShield,
                onTap: () {
                  // Navigate to privacy policy
                },
                showDivider: false,
              ),
            ],
          ),

          kGap24,

          // Account Settings
          _buildSettingsSection(
            "Account Settings",
            [
              _buildActionButton(
                "Notifications",
                FontAwesomeIcons.bell,
                onTap: () => _editSettings('notifications'),
              ),
              _buildActionButton(
                "App Preferences",
                FontAwesomeIcons.sliders,
                onTap: () => _editSettings('preferences'),
              ),
              _buildActionButton(
                "Security",
                FontAwesomeIcons.lock,
                onTap: () => _editSettings('security'),
              ),
              _buildActionButton(
                "Sign Out",
                FontAwesomeIcons.rightFromBracket,
                onTap: () {
                  // Sign out functionality
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Sign Out"),
                      content: const Text("Are you sure you want to sign out?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("CANCEL"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Handle sign out
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text("SIGN OUT"),
                        ),
                      ],
                    ),
                  );
                },
                showDivider: false,
                iconColor: Colors.red,
                textColor: Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 40),

          // App Version
          Center(
            child: Column(
              children: [
                Text(
                  "MedTalk v1.0.2",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "© 2025 MedTalk Health, Inc.",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        kGap8,
        CustomBase(
          padding: kPaddH20V10,
          child: Column(
            children: [...children],
          ),
        ),
      ],
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
        kGap8,
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
    TextInputType? keyboardType,
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
                  color: Colors.grey.shade50,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedValue,
                    dropdownColor: Colors.white,
                    hint: const Text("Select"),
                    items: dropdownItems.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item,
                            style: const TextStyle(
                              fontSize: 16,
                              color: MyColors.textBlack,
                            )),
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
                  child: CustomInputField(
                    controller: controller,
                    keyboardType: keyboardType ?? TextInputType.text,
                    hintText: label,
                    color: Colors.grey.shade50,
                    onChanged: (String value) {},
                    leadingWidget: Icon(
                      icon,
                      size: 20,
                      color: Colors.grey,
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
        width: 75,
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
            kGap8,
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            if (editController != null)
              SizedBox(
                height: 40,
                child: CustomInputField(
                  controller: editController,
                  keyboardType: keyboardType ?? TextInputType.text,
                  hintText: label,
                  height: 35,
                  color: Colors.grey.shade50,
                  onChanged: (String value) {},
                ),
              )
            else
              Text(
                value ?? "--",
                style: const TextStyle(
                  fontSize: 16,
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
      case 'bmi':
        return Colors.purple;
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
      case 'bmi':
        return FontAwesomeIcons.chartPie;
      default:
        return FontAwesomeIcons.plus;
    }
  }

  Widget _buildActionButton(
    String title,
    IconData icon, {
    required VoidCallback onTap,
    bool showDivider = true,
    Color iconColor = MyColors.primary,
    Color? textColor,
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
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: FaIcon(
                      icon,
                      color: iconColor,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
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

  void _editSettings(String settingType) {
    switch (settingType) {
      case 'notifications':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NotificationSettingsScreen(),
          ),
        );
        break;
      case 'preferences':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AppPreferencesScreen(),
          ),
        );
        break;
      case 'security':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SecuritySettingsScreen(),
          ),
        );
        break;
      default:
        break;
    }
  }

  void _showSettingsEditor(String title, List<Widget> settings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                ...settings,
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("CANCEL"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Settings updated successfully"),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.primary,
                      ),
                      child: const Text("SAVE"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggleSetting(String label, bool initialValue) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool value = initialValue;
        return SwitchListTile(
          title: Text(label),
          value: value,
          onChanged: (newValue) {
            setState(() {
              value = newValue;
            });
          },
          activeColor: MyColors.primary,
        );
      },
    );
  }

  Widget _buildDropdownSetting(
      String label, String initialValue, List<String> options) {
    return StatefulBuilder(
      builder: (context, setState) {
        String value = initialValue;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: value,
                    items: options.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          value = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
