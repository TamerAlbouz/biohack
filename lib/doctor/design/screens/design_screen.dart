import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medtalk/backend/doctor/models/doctor_work_times.dart';
import 'package:medtalk/backend/injectable.dart';
import 'package:medtalk/backend/services/models/service.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:medtalk/common/widgets/custom_input_field.dart';
import 'package:medtalk/common/widgets/dividers/section_divider.dart';
import 'package:medtalk/common/widgets/dummy/profile_picture.dart';
import 'package:medtalk/common/widgets/show_model_sheet.dart';
import 'package:medtalk/doctor/design/bloc/design_bloc.dart';
import 'package:medtalk/doctor/design/bloc/design_state.dart';
import 'package:medtalk/doctor/design/screens/service_editor.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/sizes.dart';
import 'package:medtalk/styles/styles/button.dart';
import 'package:medtalk/styles/styles/text.dart';

import '../../../common/widgets/themes/time_picker.dart';
import '../../../styles/font.dart';
import '../bloc/design_event.dart';
import 'location_picker_screen.dart';

class DesignScreen extends StatefulWidget {
  const DesignScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const DesignScreen(),
    );
  }

  @override
  State<DesignScreen> createState() => _DesignScreenState();
}

class _DesignScreenState extends State<DesignScreen>
    with TickerProviderStateMixin {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Change these declarations
  late final AnimationController _tabIndicatorAnimationController;
  late final Animation<double> _tabIndicatorPosition;

  // Add a Tween to control the animation
  late final Tween<double> _tabPositionTween;

  // Settings state variables
  int _advanceNotice = 24; // in hours
  int _bookingWindow = 12; // in weeks
  bool _autoConfirmation = true;
  bool _acceptCreditCard = true;
  bool _acceptCash = true;
  bool _acceptInsurance = false;
  int _cancellationPolicy = 24; // in hours
  // Add these to your state variables
  late LatLng _clinicLocation = const LatLng(45.521563, -122.677433);
  late GoogleMapController _mapController;

  int _selectedDayIndex = 0;
  final List<String> _workingDaysTitles = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  // Add this to your state variables in _DesignScreenState class
  final List<Map<String, String>> _qualifications = [
    {
      'title': 'MD, Stanford University School of Medicine',
      'subtitle': '2010 - 2014'
    },
    {'title': 'Residency, UCSF Medical Center', 'subtitle': '2014 - 2017'},
    {
      'title': 'Board Certification, American Board of Medical Specialties',
      'subtitle': '2018'
    },
  ];
  final Map<String, WorkingHours> _scheduleMap = {};
  int _slotDuration = 30; // in minutes
  int _bufferTime = 10; // in minutes

  late final PageController _pageController;
  int _currentPage = 0;
  bool _isPageChanging = false;
  late final AnimationController _animationController;

  // For scrolling behavior
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
// Initialize the Tween
    _tabPositionTween = Tween<double>(begin: 0, end: 0);

    // Initialize animation controller for tab indicator
    _tabIndicatorAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Create the animation using the Tween
    _tabIndicatorPosition = _tabPositionTween.animate(
      CurvedAnimation(
        parent: _tabIndicatorAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialize default schedule for all days
    for (final day in _workingDaysTitles) {
      // Weekdays (Mon-Fri) are working days by default
      final isWeekday = _workingDaysTitles.indexOf(day) < 5;
      _scheduleMap[day] = WorkingHours(
        isWorking: isWeekday,
        startTime: '09:00',
        endTime: '17:00',
        breaks: isWeekday
            ? [
                const BreakTime(
                    title: 'Lunch Break', startTime: '12:00', endTime: '13:00')
              ]
            : [],
      );
    }

    // Pre-fill with example data
    _bioController.text =
        'Board-certified physician with over 10 years of experience in general practice. Passionate about preventative care and patient education.';
    _phoneController.text = '+1 123 456 7890';
    _addressController.text = '1234 Clinic St, Portland, OR 97205';
    _notesController.text = 'Free parking available in the back';
  }

  // Helper methods to get current day's schedule settings
  bool get _isWorkingDay =>
      _scheduleMap[_workingDaysTitles[_selectedDayIndex]]?.isWorking ?? false;

  String get _startTime =>
      _scheduleMap[_workingDaysTitles[_selectedDayIndex]]?.startTime ?? '09:00';

  String get _endTime =>
      _scheduleMap[_workingDaysTitles[_selectedDayIndex]]?.endTime ?? '17:00';

  List<BreakTime> get _breaks =>
      _scheduleMap[_workingDaysTitles[_selectedDayIndex]]?.breaks ?? [];

  // Update the setters for these properties
  void _setWorkingDay(bool value) {
    final day = _workingDaysTitles[_selectedDayIndex];
    final current = _scheduleMap[day]!;
    setState(() {
      _scheduleMap[day] = WorkingHours(
        isWorking: value,
        startTime: current.startTime,
        endTime: current.endTime,
        breaks: current.breaks,
      );
    });
  }

  // Method to show location picker dialog

  // Method to show dialog and add qualification
  void _showAddQualificationDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController subtitleController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Add Qualification',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                    color: MyColors.textBlack,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Qualification Title',
                    hintText: 'e.g. MD, Harvard Medical School',
                    hintStyle: TextStyle(
                      color: MyColors.textGrey.withValues(alpha: 0.7),
                      fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: MyColors.primary, width: 2),
                    ),
                  ),
                ),
                kGap16,
                TextField(
                  controller: subtitleController,
                  style: const TextStyle(
                    fontSize: 15,
                    color: MyColors.textBlack,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Year/Time Period',
                    hintText: 'e.g. 2010 - 2014',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: MyColors.primary, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text('Add'),
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    _qualifications.add({
                      'title': titleController.text,
                      'subtitle': subtitleController.text,
                    });
                  });
                  Navigator.of(context).pop();

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Qualification added successfully'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _setStartTime(String value) {
    final day = _workingDaysTitles[_selectedDayIndex];
    final current = _scheduleMap[day]!;
    setState(() {
      _scheduleMap[day] = WorkingHours(
        isWorking: current.isWorking,
        startTime: value,
        endTime: current.endTime,
        breaks: current.breaks,
      );
    });
  }

  void _setEndTime(String value) {
    final day = _workingDaysTitles[_selectedDayIndex];
    final current = _scheduleMap[day]!;
    setState(() {
      _scheduleMap[day] = WorkingHours(
        isWorking: current.isWorking,
        startTime: current.startTime,
        endTime: value,
        breaks: current.breaks,
      );
    });
  }

  void _addBreak(BreakTime breakTime) {
    final day = _workingDaysTitles[_selectedDayIndex];
    final current = _scheduleMap[day]!;
    setState(() {
      _scheduleMap[day] = WorkingHours(
        isWorking: current.isWorking,
        startTime: current.startTime,
        endTime: current.endTime,
        breaks: [...current.breaks, breakTime],
      );
    });
  }

  void _deleteBreak(BreakTime breakItem) {
    final day = _workingDaysTitles[_selectedDayIndex];
    final current = _scheduleMap[day]!;
    setState(() {
      _scheduleMap[day] = WorkingHours(
        isWorking: current.isWorking,
        startTime: current.startTime,
        endTime: current.endTime,
        breaks: current.breaks
            .where((b) =>
                b.title != breakItem.title ||
                b.startTime != breakItem.startTime ||
                b.endTime != breakItem.endTime)
            .toList(),
      );
    });
  }

  void _animateToPage(int page) {
    // Don't change current page state immediately
    // Just track that we're animating
    setState(() {
      _isPageChanging = true;
    });

    // Perform the page change animation
    _pageController
        .animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    )
        .then((_) {
      // After animation completes, update the state
      setState(() {
        _currentPage = page;
        _isPageChanging = false;
      });

      // Only after page animation is complete, scroll to top
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabIndicatorAnimationController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _pageController.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DesignBloc>()..add(LoadDoctorProfile()),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        // Dismiss keyboard on tap outside
        child: Scaffold(
          backgroundColor: MyColors.background,
          body: BlocBuilder<DesignBloc, DesignState>(
            builder: (context, state) {
              return SafeArea(
                child: Column(
                  children: [
                    // Header with page title
                    _buildHeader(state),

                    kGap10,
                    // Navigation tabs with improved design
                    _buildNavTabs(),

                    // Main content
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        // Remove NeverScrollableScrollPhysics() to allow proper animation
                        // Or use a custom physics that only allows programmatic sliding:
                        physics: const BouncingScrollPhysics(),
                        onPageChanged: (index) {
                          // Let the animation finish before updating state
                          if (!_isPageChanging) {
                            setState(() {
                              _currentPage = index;
                            });
                          }
                        },
                        children: [
                          _buildProfilePage(context, state),
                          _buildServicesPage(context, state),
                          _buildSchedulePage(context, state),
                          _buildSettingsPage(context, state),
                        ],
                      ),
                    ),

                    // Save button - fixed at bottom
                    _buildSaveButton(context),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(DesignState state) {
    return Padding(
      padding: kPaddH20,
      child: Row(
        children: [
          Text(
            _getPageTitle(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: MyColors.textBlack,
            ),
          ),
          const Spacer(),
          // Progress indicator
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: MyColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit,
                  size: 14,
                  color: MyColors.primary,
                ),
                SizedBox(width: 6),
                Text(
                  'Editing',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: MyColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle() {
    switch (_currentPage) {
      case 0:
        return 'Doctor Profile';
      case 1:
        return 'Your Services';
      case 2:
        return 'Schedule';
      case 3:
        return 'Settings';
      default:
        return 'Profile Setup';
    }
  }

  IconData _getSaveIcon() {
    return _currentPage < 3 ? Icons.edit : Icons.check_circle;
  }

  Widget _buildNavTabs() {
    return Padding(
      padding: kPaddH20,
      child: Container(
        decoration: BoxDecoration(
          color: MyColors.blueGrey.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(6),
        child: Stack(
          children: [
            // Animated blue indicator that slides
            AnimatedBuilder(
              animation: _tabIndicatorAnimationController,
              builder: (context, child) {
                return Positioned(
                  left: _tabIndicatorPosition.value,
                  top: 0,
                  bottom: 0,
                  width: (MediaQuery.of(context).size.width - 40 - 12) / 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: MyColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: MyColors.primary.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
            // Tab buttons
            Row(
              children: [
                _buildNavTab(0, 'Profile', FontAwesomeIcons.userDoctor),
                _buildNavTab(1, 'Services', FontAwesomeIcons.kitMedical),
                _buildNavTab(2, 'Schedule', FontAwesomeIcons.calendar),
                _buildNavTab(3, 'Settings', FontAwesomeIcons.gear),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTab(int index, String title, IconData icon) {
    final bool isCurrentTab = _currentPage == index;
    final bool isTargetTab = ((_tabPositionTween.end ?? 0) /
                ((MediaQuery.of(context).size.width - 40 - 12) / 4))
            .round() ==
        index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isCurrentTab) {
            // Update the Tween values
            final tabWidth = (MediaQuery.of(context).size.width - 40 - 12) / 4;
            _tabPositionTween.begin = _tabPositionTween.end;
            _tabPositionTween.end = index * tabWidth;

            // Reset and start the animation
            _tabIndicatorAnimationController.reset();
            _tabIndicatorAnimationController.forward();

            // Navigate to the page
            _animateToPage(index);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _tabIndicatorAnimationController,
          builder: (context, child) {
            // Calculate color transition based on indicator position
            final tabWidth = (MediaQuery.of(context).size.width - 40 - 12) / 4;
            final indicatorCenter =
                _tabIndicatorPosition.value + (tabWidth / 2);
            final thisTabCenter = index * tabWidth + (tabWidth / 2);

            // Calculate distance as percentage (0.0 = centered on this tab, 1.0 = centered on next tab)
            final distancePercent =
                (indicatorCenter - thisTabCenter).abs() / tabWidth;
            final colorPercent =
                1.0 - (distancePercent > 1.0 ? 1.0 : distancePercent);

            final iconColor = Color.lerp(
                MyColors.primary.withValues(alpha: 0.7),
                Colors.white,
                colorPercent);

            final fontWeight =
                isTargetTab ? FontWeight.bold : FontWeight.normal;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    icon,
                    color: iconColor,
                    size: 16,
                  ),
                  kGap6,
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: iconColor,
                      fontWeight: fontWeight,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfilePage(BuildContext context, DesignState state) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: kPadd20,
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Profile card with shadow
              _buildProfileCard(),

              kGap20,

              // Biography section
              _buildSectionHeading('Biography'),
              kGap10,
              _buildTextArea(
                controller: _bioController,
                hintText: 'Tell patients about your experience and expertise',
                maxLines: 5,
              ),
              kGap24,

              // Qualifications section
              _buildSectionHeading('Qualifications & Experience'),
              kGap12,
// Replace the current qualifications section with this
              ...List.generate(_qualifications.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildQualificationItem(
                    _qualifications[index]['title']!,
                    _qualifications[index]['subtitle']!,
                    isEditable: true,
                  ),
                );
              }),

              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showAddQualificationDialog(context);
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Qualification',
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: Font.small)),
                  style: kElevatedButtonCommonStyleOutlined,
                ),
              ),

              kGap24,

              // Clinic details section
              _buildSectionHeading('Clinic Details'),
              kGap12,
              _buildMapContainer(),
              kGap16,

              // Contact information
              _buildContactFields(),

              kGap20,
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return CustomBase(
      child: Row(
        children: [
          // Profile image with border
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: MyColors.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: MyColors.primary.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const ProfilePicture(
              height: 80,
              width: 80,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dr. John Doe',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                kGap4,
                const Text(
                  'Dentist • 29 yrs • Male',
                  style: TextStyle(
                    color: MyColors.textGrey,
                    fontSize: 14,
                  ),
                ),
                kGap10,
                OutlinedButton.icon(
                  onPressed: () {
                    // Upload new photo
                  },
                  icon: const FaIcon(FontAwesomeIcons.camera,
                      size: 14, color: MyColors.primary),
                  label: const Text('Update Photo',
                      style: TextStyle(
                        fontSize: Font.small,
                        color: MyColors.primary,
                      )),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MyColors.primary,
                    side: const BorderSide(color: MyColors.primary),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(String title) {
    return Text(
      title,
      style: kSectionTitle,
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String hintText,
    required int maxLines,
  }) {
    return CustomBase(
      padding: kPadd0,
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontSize: 15,
          color: MyColors.textBlack,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: MyColors.textGrey.withValues(alpha: 0.7),
            fontSize: 15,
          ),
          contentPadding: const EdgeInsets.all(20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: MyColors.cardBackground,
        ),
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildMapContainer() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border:
            Border.all(color: MyColors.grey.withValues(alpha: 0.3), width: 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _clinicLocation,
                zoom: 14.0,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              markers: {
                Marker(
                  markerId: const MarkerId('clinic'),
                  position: _clinicLocation,
                  infoWindow: const InfoWindow(title: 'Your Clinic'),
                ),
              },
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              zoomControlsEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              myLocationButtonEnabled: false,
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: ElevatedButton.icon(
              onPressed: () async {
                // Navigate to location picker screen
                final LatLng? result = await Navigator.push<LatLng>(
                  context,
                  LocationPickerScreen.route(_clinicLocation),
                );

                // Update location if a result was returned
                if (result != null) {
                  setState(() {
                    _clinicLocation = result;
                  });

                  // Update map view
                  _mapController.animateCamera(
                    CameraUpdate.newLatLng(_clinicLocation),
                  );

                  if (mounted) {
                    // Show confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Clinic location updated'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.edit_location_alt, size: 16),
              label: const Text('Update Location',
                  style: TextStyle(
                      fontSize: Font.small, fontWeight: FontWeight.normal)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: MyColors.primary,
                elevation: 2,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactFields() {
    return Column(
      children: [
        _buildInputField(
          controller: _phoneController,
          icon: FontAwesomeIcons.phone,
          hint: 'Phone number',
          keyboardType: TextInputType.phone,
        ),
        kGap12,
        _buildInputField(
          controller: _addressController,
          icon: FontAwesomeIcons.mapLocation,
          hint: 'Clinic address',
          keyboardType: TextInputType.streetAddress,
        ),
        kGap12,
        _buildInputField(
          controller: _notesController,
          icon: FontAwesomeIcons.circleInfo,
          hint: 'Additional notes (parking, access, etc.)',
          keyboardType: TextInputType.text,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required TextInputType keyboardType,
  }) {
    return CustomInputField(
      controller: controller,
      keyboardType: keyboardType,
      hintText: hint,
      leadingWidget: FaIcon(icon, color: MyColors.primary, size: 20),
      onChanged: (String value) {},
    );
  }

  Widget _buildServicesPage(BuildContext context, DesignState state) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: kPadd20,
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Services illustration
              if (state.services.isEmpty) _buildServicesIllustration(),

              // Services list
              if (state.services.isNotEmpty) ...[
                const Text(
                  'Your patients can book these services',
                  style: TextStyle(
                    fontSize: 15,
                    color: MyColors.textGrey,
                  ),
                ),
                kGap16,
                CustomBase(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.services.length,
                    separatorBuilder: (context, index) =>
                        const SectionDivider(height: 20),
                    itemBuilder: (context, index) {
                      final service = state.services[index];
                      return _buildServiceItem(
                        context: context,
                        service: service,
                      );
                    },
                  ),
                ),
              ],

              kGap24,

              // Add service button - made more prominent
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton.icon(
                  onPressed: () {
                    _addNewService(context);
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(
                      state.services.isEmpty
                          ? 'Add Your First Service'
                          : 'Add Another Service',
                      style: const TextStyle(
                          fontWeight: FontWeight.normal, fontSize: Font.small)),
                  style: kElevatedButtonCommonStyleOutlined,
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesIllustration() {
    return Container(
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: MyColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: MyColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const FaIcon(
              FontAwesomeIcons.clipboardList,
              size: 48,
              color: MyColors.primary,
            ),
          ),
          kGap24,
          const Text(
            'No Services Added Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: MyColors.textBlack,
            ),
          ),
          kGap12,
          const Text(
            'Define the services you provide to your patients. Each service can have its own duration, price, and appointment type.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: MyColors.textGrey,
              height: 1.5,
            ),
          ),
          kGap12,
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              SizedBox(width: 8),
              Text('Define prices and duration',
                  style: TextStyle(fontSize: 14)),
            ],
          ),
          kGap8,
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              SizedBox(width: 8),
              Text('Offer online or in-person visits',
                  style: TextStyle(fontSize: 14)),
            ],
          ),
          kGap8,
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              SizedBox(width: 8),
              Text('Set up home visit options', style: TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem({
    required BuildContext context,
    required Service service,
  }) {
    return InkWell(
      onTap: () {
        _editService(context, service);
      },
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Service icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: MyColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const FaIcon(
                    FontAwesomeIcons.kitMedical,
                    color: MyColors.primary,
                    size: 20,
                  ),
                ),
                kGap16,

                // Service details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: MyColors.textBlack,
                        ),
                      ),
                      kGap4,
                      Text(
                        "${service.duration} mins",
                        style: const TextStyle(
                          fontSize: 14,
                          color: MyColors.textGrey,
                        ),
                      ),
                      // Description preview - only show if not empty
                      if (service.description.isNotEmpty) ...[
                        kGap4,
                        Text(
                          service.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: MyColors.textGrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Price and actions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "\$${service.price.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MyColors.primary,
                      ),
                    ),
                    kGap8,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pre-appointment instructions indicator
                        if (service.preAppointmentInstructions != null &&
                            service.preAppointmentInstructions!.isNotEmpty)
                          Tooltip(
                            message: 'Has pre-appointment instructions',
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const FaIcon(
                                FontAwesomeIcons.notesMedical,
                                color: Colors.amber,
                                size: 12,
                              ),
                            ),
                          ),

                        // Custom availability indicator
                        if (service.customAvailability != null)
                          Tooltip(
                            message: 'Has custom availability',
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const FaIcon(
                                FontAwesomeIcons.calendarDay,
                                color: Colors.blue,
                                size: 12,
                              ),
                            ),
                          ),

                        // Delete button
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red, size: 20),
                          onPressed: () =>
                              _showDeleteServiceDialog(context, service),
                          padding: EdgeInsets.zero,
                          visualDensity: const VisualDensity(
                            horizontal: -4,
                            vertical: -4,
                          ),
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            kGap10,

            // Service type tags
            Wrap(
              runSpacing: 6,
              spacing: 4,
              children: [
                if (service.isInPerson)
                  _buildServiceTypeTag(
                      FontAwesomeIcons.hospitalUser, 'In-Person'),
                if (service.isInPerson &&
                    (service.isOnline || service.isHomeVisit))
                  kGap8,
                if (service.isOnline)
                  _buildServiceTypeTag(FontAwesomeIcons.video, 'Online'),
                if (service.isOnline && service.isHomeVisit) kGap8,
                if (service.isHomeVisit)
                  _buildServiceTypeTag(FontAwesomeIcons.house, 'Home Visit'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteServiceDialog(BuildContext context, Service service) {
    // Store bloc reference before showing dialog
    final designBloc = context.read<DesignBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Delete Service',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black,
            ),
            children: [
              const TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(
                text: service.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '?'),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              foregroundColor: MyColors.textGrey,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Delete'),
            onPressed: () {
              Navigator.pop(dialogContext);
              designBloc.add(DeleteService(service.uid));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Service deleted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addNewService(BuildContext context) async {
    // Store bloc reference before async gap
    final designBloc = context.read<DesignBloc>();

    // Navigate to service editor and get result back
    final result = await Navigator.push<Service?>(
      context,
      ServiceEditorScreen.route(),
    );
    final Service? newService = result;

    // Check if state is still mounted and we have a service to add
    if (newService != null && context.mounted) {
      // Add service to state using stored bloc reference
      designBloc.add(AddService(
        title: newService.title,
        duration: newService.duration,
        price: newService.price,
        isOnline: newService.isOnline,
        isInPerson: newService.isInPerson,
        isHomeVisit: newService.isHomeVisit,
        description: newService.description,
        preAppointmentInstructions: newService.preAppointmentInstructions,
        customAvailability: newService.customAvailability,
      ));

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service added successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _editService(BuildContext context, Service service) async {
    // Store bloc reference before async gap
    final designBloc = context.read<DesignBloc>();

    // Navigate to service editor with existing service
    final result = await Navigator.push<Service?>(
      context,
      ServiceEditorScreen.route(service: service),
    );
    final Service? updatedService = result;

    // Check if state is still mounted and we have an updated service
    if (updatedService != null && context.mounted) {
      // Update service in state using stored bloc reference
      designBloc.add(UpdateService(
        id: updatedService.uid,
        title: updatedService.title,
        duration: updatedService.duration,
        price: updatedService.price,
        isOnline: updatedService.isOnline,
        isInPerson: updatedService.isInPerson,
        isHomeVisit: updatedService.isHomeVisit,
        description: updatedService.description,
        preAppointmentInstructions: updatedService.preAppointmentInstructions,
        customAvailability: updatedService.customAvailability,
      ));

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service updated successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildServiceTypeTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: MyColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MyColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            icon,
            size: 12,
            color: MyColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: MyColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulePage(BuildContext context, DesignState state) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: kPadd20,
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Day selector with improved design
              Container(
                decoration: BoxDecoration(
                  color: MyColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: kPaddH20V8,
                      child: Row(
                        children: [
                          const Text(
                            'Select Day',
                            style: kSectionTitle,
                          ),
                          const Spacer(),
                          // Working day toggle
                          Row(
                            children: [
                              Text(
                                _isWorkingDay ? 'Working Day' : 'Off Day',
                                style: TextStyle(
                                  fontSize: Font.extraSmall,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      _isWorkingDay ? Colors.green : Colors.red,
                                ),
                              ),
                              kGap8,
                              Switch(
                                value: _isWorkingDay,
                                onChanged: (value) {
                                  _setWorkingDay(value);
                                },
                                activeColor: Colors.green,
                                inactiveThumbColor: Colors.red.shade300,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildWeekDaySelector(),
                  ],
                ),
              ),

              kGap24,

              // Working hours section - only visible if it's a working day
              if (_isWorkingDay) ...[
                CustomBase(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeading('Working Hours'),
                      kGap16,
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimeSelector(
                              label: 'Start Time',
                              time: _startTime,
                              onTap: () => _selectTime(context, true),
                            ),
                          ),
                          kGap16,
                          Expanded(
                            child: _buildTimeSelector(
                              label: 'End Time',
                              time: _endTime,
                              onTap: () => _selectTime(context, false),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                kGap24,

                // Break times section
                CustomBase(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildSectionHeading('Break Times'),
                          const Spacer(),
                          OutlinedButton.icon(
                            onPressed: () => _showAddBreakDialog(context),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Break',
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: Font.small)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: MyColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: const BorderSide(
                                color: MyColors.primary,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                            ),
                          ),
                        ],
                      ),
                      kGap16,

                      // Break items list
                      if (_breaks.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          alignment: Alignment.center,
                          child: const Text(
                            'No breaks added yet',
                            style: TextStyle(
                              fontSize: 15,
                              color: MyColors.textGrey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else
                        Column(
                          children: _breaks.map((breakItem) {
                            return _buildBreakItem(breakItem);
                          }).toList(),
                        ),
                    ],
                  ),
                ),

                kGap24,

                // Time slot settings
                CustomBase(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeading('Time Slot Settings'),
                      kGap16,

                      // Slot duration
                      Row(
                        children: [
                          const Text(
                            'Default Slot Duration:',
                            style: TextStyle(
                              fontSize: 15,
                              color: MyColors.textGrey,
                            ),
                          ),
                          const Spacer(),
                          _buildSettingSelector(
                            value: getSlotDurationTime(),
                            onTap: () => _showSlotDurationPicker(context),
                          ),
                        ],
                      ),
                      kGap16,

                      // Buffer time
                      Row(
                        children: [
                          const Text(
                            'Buffer Between Appointments:',
                            style: TextStyle(
                              fontSize: 15,
                              color: MyColors.textGrey,
                            ),
                          ),
                          const Spacer(),
                          _buildSettingSelector(
                            value: _bufferTime == 0
                                ? 'No buffer'
                                : '$_bufferTime minutes',
                            onTap: () => _showBufferTimePicker(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                kGap24,

                // Available slots preview
                CustomBase(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeading('Available Slots Preview'),
                      // explain the meaning behind available slots and blocked slots
                      kGap8,
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 15,
                            color: MyColors.textGrey,
                          ),
                          children: [
                            TextSpan(text: 'An '),
                            TextSpan(
                              text: 'Available',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            TextSpan(
                                text:
                                    ' slot is a time slot that can be booked by patients.'),
                          ],
                        ),
                      ),
                      kGap8,
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 15,
                            color: MyColors.textGrey,
                          ),
                          children: [
                            TextSpan(text: 'A '),
                            TextSpan(
                              text: 'Blocked',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            TextSpan(
                                text:
                                    ' slot is a time slot that is not available for booking. This is affected by your working hours, breaks, and buffer time.'),
                          ],
                        ),
                      ),
                      kGap16,
                      _buildTimeSlotGrid(),
                    ],
                  ),
                ),
              ] else ...[
                // Not a working day message
                CustomBase(
                  padding: kPadd30,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.event_busy,
                          size: 48,
                          color: Colors.red.shade300,
                        ),
                      ),
                      kGap24,
                      const Text(
                        'Not a Working Day',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: MyColors.textBlack,
                        ),
                      ),
                      kGap12,
                      const Text(
                        'You have marked this day as unavailable. Toggle the switch above if you want to work on this day.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: MyColors.textGrey,
                          height: 1.5,
                        ),
                      ),
                      kGap24,
                      ElevatedButton.icon(
                        onPressed: () {
                          _setWorkingDay(true);
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Make This a Working Day'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              kGap20,
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekDaySelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final isSelected = _selectedDayIndex == index;
          final day = _workingDaysTitles[index];
          final isWorkingDay = _scheduleMap[day]?.isWorking ?? false;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDayIndex = index;
              });
            },
            child: Container(
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? MyColors.primary
                    : (isWorkingDay
                        ? MyColors.primary.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? MyColors.primary
                      : (isWorkingDay
                          ? MyColors.primary.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.3)),
                ),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : (isWorkingDay ? MyColors.primary : Colors.grey),
                    ),
                  ),
                  kGap4,
                  Icon(
                    isWorkingDay ? Icons.check_circle : Icons.cancel,
                    size: 12,
                    color: isSelected
                        ? Colors.white
                        : (isWorkingDay ? Colors.green : Colors.red.shade300),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required String time,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: MyColors.textGrey,
          ),
        ),
        kGap8,
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border:
                  Border.all(color: MyColors.primary.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
              color: MyColors.primary.withValues(alpha: 0.05),
            ),
            child: Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.clock,
                  color: MyColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 10),
                Text(
                  _formatTimeDisplay(time),
                  style: const TextStyle(
                    fontSize: 15,
                    color: MyColors.textBlack,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: MyColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreakItem(BreakTime breakItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MyColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MyColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const FaIcon(
            FontAwesomeIcons.mugSaucer,
            size: 16,
            color: MyColors.primary,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                breakItem.title!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: MyColors.textBlack,
                ),
              ),
              kGap4,
              Text(
                '${_formatTimeDisplay(breakItem.startTime)} - ${_formatTimeDisplay(breakItem.endTime)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: MyColors.textGrey,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => _deleteBreak(breakItem),
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSelector({
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: MyColors.primary.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
          color: MyColors.primary.withValues(alpha: 0.05),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: MyColors.primary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down,
                color: MyColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  void _showAddBreakDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    String startTime = '12:00';
    String endTime = '13:00';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                'Add Break',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      style: const TextStyle(
                        fontSize: 15,
                        color: MyColors.textBlack,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Break Title',
                        hintText: 'e.g. Lunch Break',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: MyColors.primary, width: 2),
                        ),
                      ),
                    ),
                    kGap16,
                    const Text(
                      'Start Time',
                      style: TextStyle(
                        color: MyColors.textGrey,
                        fontSize: 14,
                      ),
                    ),
                    kGap8,
                    InkWell(
                      onTap: () async {
                        // Parse current time
                        final timeParts = startTime.split(':');
                        final initialTime = TimeOfDay(
                          hour: int.parse(timeParts[0]),
                          minute: int.parse(timeParts[1]),
                        );

                        // Show time picker
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: initialTime,
                          builder: (context, child) {
                            return timePickerTheme(child);
                          },
                        );

                        if (pickedTime != null) {
                          setState(() {
                            final hour =
                                pickedTime.hour.toString().padLeft(2, '0');
                            final minute =
                                pickedTime.minute.toString().padLeft(2, '0');
                            startTime = '$hour:$minute';
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: MyColors.primary.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(12),
                          color: MyColors.primary.withValues(alpha: 0.05),
                        ),
                        child: Row(
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.clock,
                              color: MyColors.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _formatTimeDisplay(startTime),
                              style: const TextStyle(
                                fontSize: 15,
                                color: MyColors.textBlack,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down,
                                color: MyColors.primary),
                          ],
                        ),
                      ),
                    ),
                    kGap16,
                    const Text(
                      'End Time',
                      style: TextStyle(
                        color: MyColors.textGrey,
                        fontSize: 14,
                      ),
                    ),
                    kGap8,
                    InkWell(
                      onTap: () async {
                        // Parse current time
                        final timeParts = endTime.split(':');
                        final initialTime = TimeOfDay(
                          hour: int.parse(timeParts[0]),
                          minute: int.parse(timeParts[1]),
                        );

                        // Show time picker
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: initialTime,
                          builder: (context, child) {
                            return timePickerTheme(child);
                          },
                        );

                        if (pickedTime != null) {
                          setState(() {
                            final hour =
                                pickedTime.hour.toString().padLeft(2, '0');
                            final minute =
                                pickedTime.minute.toString().padLeft(2, '0');
                            endTime = '$hour:$minute';
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: MyColors.primary.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(12),
                          color: MyColors.primary.withValues(alpha: 0.05),
                        ),
                        child: Row(
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.clock,
                              color: MyColors.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _formatTimeDisplay(endTime),
                              style: const TextStyle(
                                fontSize: 15,
                                color: MyColors.textBlack,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down,
                                color: MyColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  child: const Text('Add'),
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      _addBreak(BreakTime(
                        title: titleController.text,
                        startTime: startTime,
                        endTime: endTime,
                      ));
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    // Parse current time
    final currentTime = isStartTime ? _startTime : _endTime;
    final timeParts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    // Show time picker
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return timePickerTheme(child);
      },
    );

    if (pickedTime != null) {
      final hour = pickedTime.hour.toString().padLeft(2, '0');
      final minute = pickedTime.minute.toString().padLeft(2, '0');
      final newTime = '$hour:$minute';

      if (isStartTime) {
        _setStartTime(newTime);
      } else {
        _setEndTime(newTime);
      }
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

  Widget _buildTimeSlotGrid() {
    // Calculate the total available time in minutes
    final startParts = _startTime.split(':');
    final endParts = _endTime.split(':');
    final startMinutes =
        int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

    // Calculate the number of slots
    final totalMinutes = endMinutes - startMinutes;
    final slotCount = totalMinutes ~/ (_slotDuration + _bufferTime);

    // Create the slots
    List<TimeOfDay> slots = [];
    for (int i = 0; i < slotCount; i++) {
      final slotStartMinutes = startMinutes + i * (_slotDuration + _bufferTime);
      final hour = slotStartMinutes ~/ 60;
      final minute = slotStartMinutes % 60;

      slots.add(TimeOfDay(hour: hour, minute: minute));
    }

    // If there are no slots, show a message
    if (slots.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.amber[700],
              size: 40,
            ),
            kGap16,
            const Text(
              'No available slots for the selected time range',
              style: TextStyle(
                fontSize: 15,
                color: MyColors.textGrey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Calculate number of active slots
    int activeSlots = 0;

    for (final slot in slots) {
      // Check if slot overlaps with any break
      bool isAvailable = true;
      final slotStartMinutes = slot.hour * 60 + slot.minute;
      final slotEndMinutes = slotStartMinutes + _slotDuration;

      for (final breakItem in _breaks) {
        final breakStartParts = breakItem.startTime.split(':');
        final breakEndParts = breakItem.endTime.split(':');

        final breakStartMinutes =
            int.parse(breakStartParts[0]) * 60 + int.parse(breakStartParts[1]);
        final breakEndMinutes =
            int.parse(breakEndParts[0]) * 60 + int.parse(breakEndParts[1]);

        if ((slotStartMinutes >= breakStartMinutes &&
                slotStartMinutes < breakEndMinutes) ||
            (slotEndMinutes > breakStartMinutes &&
                slotEndMinutes <= breakEndMinutes) ||
            (slotStartMinutes <= breakStartMinutes &&
                slotEndMinutes >= breakEndMinutes)) {
          isAvailable = false;
          break;
        }
      }

      if (isAvailable) {
        activeSlots++;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.event_available,
                      color: Colors.green, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$activeSlots available',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            kGap8,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.block, color: Colors.red, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${slots.length - activeSlots} blocked',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        kGap16,
        Container(
          constraints: const BoxConstraints(maxHeight: 400),
          child: GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: slots.length,
            itemBuilder: (context, index) {
              final slot = slots[index];

              // Check if slot overlaps with any break
              bool isAvailable = true;
              final slotStartMinutes = slot.hour * 60 + slot.minute;
              final slotEndMinutes = slotStartMinutes + _slotDuration;

              for (final breakItem in _breaks) {
                final breakStartParts = breakItem.startTime.split(':');
                final breakEndParts = breakItem.endTime.split(':');

                final breakStartMinutes = int.parse(breakStartParts[0]) * 60 +
                    int.parse(breakStartParts[1]);
                final breakEndMinutes = int.parse(breakEndParts[0]) * 60 +
                    int.parse(breakEndParts[1]);

                if ((slotStartMinutes >= breakStartMinutes &&
                        slotStartMinutes < breakEndMinutes) ||
                    (slotEndMinutes > breakStartMinutes &&
                        slotEndMinutes <= breakEndMinutes) ||
                    (slotStartMinutes <= breakStartMinutes &&
                        slotEndMinutes >= breakEndMinutes)) {
                  isAvailable = false;
                  break;
                }
              }

              // Format time for display
              final displayHour = slot.hour > 12
                  ? slot.hour - 12
                  : (slot.hour == 0 ? 12 : slot.hour);
              final amPm = slot.hour >= 12 ? "PM" : "AM";
              final minuteStr = slot.minute.toString().padLeft(2, '0');

              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isAvailable
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: isAvailable ? Colors.green : Colors.red.shade300),
                ),
                child: Text(
                  "$displayHour:$minuteStr $amPm",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isAvailable
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsPage(BuildContext context, DesignState state) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: kPadd20,
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Appointment Settings Card
              CustomBase(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeading('Appointment Settings'),
                    kGap20,

                    // Booking advance notice
                    _buildSettingItem(
                      icon: Icons.access_time,
                      title: 'Booking Advance Notice',
                      description:
                          'Minimum time before an appointment can be booked',
                      child: _buildSettingSelector(
                        value: getBookingAdvanceTime(),
                        onTap: () => _showBookingAdvancePicker(context),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1),
                    ),

                    // Booking window
                    _buildSettingItem(
                      icon: Icons.date_range,
                      title: 'Booking Window',
                      description:
                          'How far in advance patients can book appointments',
                      child: _buildSettingSelector(
                        value: getBookingWindowTime(),
                        onTap: () => _showBookingWindowPicker(context),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1),
                    ),

                    // Auto confirmation
                    _buildSettingItem(
                      icon: Icons.check_circle,
                      title: 'Auto Confirmation',
                      description:
                          'Automatically confirm appointments when booked',
                      child: Switch(
                        value: _autoConfirmation,
                        onChanged: (value) {
                          setState(() {
                            _autoConfirmation = value;
                          });
                        },
                        activeColor: MyColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              kGap24,

              // Payment Settings Card
              CustomBase(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeading('Payment Settings'),
                    kGap20,

                    // Payment methods
                    _buildSettingItem(
                      icon: Icons.credit_card,
                      title: 'Accepted Payment Methods',
                      description:
                          'Methods patients can use to pay for appointments',
                      child: const SizedBox(),
                    ),

                    // Payment methods checkboxes with improved design
                    Padding(
                      padding: const EdgeInsets.only(left: 40, top: 8),
                      child: Column(
                        children: [
                          _buildSettingsCheckbox(
                            title: 'Credit/Debit Card',
                            value: _acceptCreditCard,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _acceptCreditCard = value;
                                });
                              }
                            },
                          ),
                          _buildSettingsCheckbox(
                            title: 'Cash',
                            value: _acceptCash,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _acceptCash = value;
                                });
                              }
                            },
                          ),
                          _buildSettingsCheckbox(
                            title: 'Insurance',
                            value: _acceptInsurance,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _acceptInsurance = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1),
                    ),

                    // Cancellation policy
                    _buildSettingItem(
                      icon: Icons.event_busy,
                      title: 'Cancellation Policy',
                      description:
                          'Set your policy for appointment cancellations',
                      child: _buildSettingSelector(
                        value: getCancellationPolicyTime(),
                        onTap: () => _showCancellationPolicyPicker(context),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String description,
    required Widget child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          child: Icon(
            icon,
            size: 18,
            color: MyColors.primary,
          ),
        ),
        kGap16,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: MyColors.textBlack,
                ),
              ),
              kGap4,
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: MyColors.textGrey,
                ),
              ),
            ],
          ),
        ),
        if (child is! SizedBox) kGap16,
        child,
      ],
    );
  }

  Widget _buildSettingsCheckbox({
    required String title,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: value
                      ? MyColors.primary
                      : MyColors.textGrey.withValues(alpha: 0.5),
                  width: 2,
                ),
                color: value ? MyColors.primary : Colors.transparent,
              ),
              child: value
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: value ? MyColors.textBlack : MyColors.textGrey,
                fontWeight: value ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingAdvancePicker(BuildContext context) {
    final options = [
      {'value': 1, 'label': '1 hour'},
      {'value': 2, 'label': '2 hours'},
      {'value': 12, 'label': '12 hours'},
      {'value': 24, 'label': '1 day'},
      {'value': 48, 'label': '2 days'},
    ];

    showOptionsPicker(
      context,
      'Booking Advance Notice',
      options,
      _advanceNotice,
      (value) {
        setState(() {
          _advanceNotice = value;
        });
      },
    );
  }

  void _showBookingWindowPicker(BuildContext context) {
    final options = [
      {'value': 1, 'label': '1 week'},
      {'value': 2, 'label': '2 weeks'},
      {'value': 4, 'label': '1 month'},
      {'value': 12, 'label': '3 months'},
      {'value': 24, 'label': '6 months'},
    ];

    showOptionsPicker(
      context,
      'Booking Window',
      options,
      _bookingWindow,
      (value) {
        setState(() {
          _bookingWindow = value;
        });
      },
    );
  }

  void _showCancellationPolicyPicker(BuildContext context) {
    final options = [
      {'value': 0, 'label': 'No cancellations'},
      {'value': 1, 'label': '1 hour notice'},
      {'value': 3, 'label': '3 hours notice'},
      {'value': 6, 'label': '6 hours notice'},
      {'value': 12, 'label': '12 hours notice'},
      {'value': 24, 'label': '1 day notice'},
      {'value': 48, 'label': '2 days notice'},
    ];

    showOptionsPicker(
      context,
      'Cancellation Policy Notice',
      options,
      _cancellationPolicy,
      (value) {
        setState(() {
          _cancellationPolicy = value;
        });
      },
    );
  }

  void _showSlotDurationPicker(BuildContext context) {
    final options = [
      {'value': 15, 'label': '15 minutes'},
      {'value': 30, 'label': '30 minutes'},
      {'value': 45, 'label': '45 minutes'},
      {'value': 60, 'label': '1 hour'},
      {'value': 90, 'label': '1.5 hours'},
      {'value': 120, 'label': '2 hours'},
    ];

    showOptionsPicker(
      context,
      'Default Slot Duration',
      options,
      _slotDuration,
      (value) {
        setState(() {
          _slotDuration = value;
        });
      },
    );
  }

  void _showBufferTimePicker(BuildContext context) {
    final options = [
      {'value': 0, 'label': 'No buffer'},
      {'value': 5, 'label': '5 minutes'},
      {'value': 10, 'label': '10 minutes'},
      {'value': 15, 'label': '15 minutes'},
      {'value': 20, 'label': '20 minutes'},
      {'value': 25, 'label': '25 minutes'},
      {'value': 30, 'label': '30 minutes'},
    ];

    showOptionsPicker(
      context,
      'Buffer Between Appointments',
      options,
      _bufferTime,
      (value) {
        setState(() {
          _bufferTime = value;
        });
      },
    );
  }

  String getBookingAdvanceTime() {
    switch (_advanceNotice) {
      case 1:
        return '1 hour';
      case 2:
        return '2 hours';
      case 12:
        return '12 hours';
      case 24:
        return '1 day';
      case 48:
        return '2 days';
      default:
        return '$_advanceNotice hours';
    }
  }

  String getSlotDurationTime() {
    switch (_slotDuration) {
      case 15:
        return '15 minutes';
      case 30:
        return '30 minutes';
      case 45:
        return '45 minutes';
      case 60:
        return '1 hour';
      case 90:
        return '1.5 hours';
      case 120:
        return '2 hours';
      default:
        return '$_slotDuration minutes';
    }
  }

  String getBookingWindowTime() {
    switch (_bookingWindow) {
      case 1:
        return '1 week';
      case 2:
        return '2 weeks';
      case 4:
        return '1 month';
      case 12:
        return '3 months';
      case 24:
        return '6 months';
      default:
        return '$_bookingWindow weeks';
    }
  }

  String getCancellationPolicyTime() {
    if (_cancellationPolicy == 0) return 'No cancellations';
    switch (_cancellationPolicy) {
      case 1:
        return '1 hour notice';
      case 3:
        return '3 hours notice';
      case 6:
        return '6 hours notice';
      case 12:
        return '12 hours notice';
      case 24:
        return '1 day notice';
      case 48:
        return '2 days notice';
      default:
        return '$_cancellationPolicy hours notice';
    }
  }

  Widget _buildQualificationItem(String title, String subtitle,
      {required bool isEditable}) {
    return CustomBase(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: MyColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.school,
              color: MyColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    color: MyColors.textBlack,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                kGap4,
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: MyColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          if (isEditable) ...[
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: MyColors.primary),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            kGap8,
            IconButton(
              icon:
                  const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MyColors.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: MyColors.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Save profile changes
          context.read<DesignBloc>().add(SaveDoctorProfile(
                // Profile data
                bio: _bioController.text,
                phone: _phoneController.text,
                address: _addressController.text,
                notes: _notesController.text,

                // Schedule data
                schedule: _scheduleMap,
              ));

          // Show success animation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Profile and settings saved successfully',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      )),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(8),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: MyColors.primary.withValues(alpha: 0.4),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save),
            SizedBox(width: 8),
            Text(
              'Save Changes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
