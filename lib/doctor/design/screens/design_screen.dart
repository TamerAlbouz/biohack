import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:medtalk/common/widgets/dividers/card_divider.dart';
import 'package:medtalk/common/widgets/dummy/profile_picture.dart';
import 'package:medtalk/doctor/design/bloc/design_bloc.dart';
import 'package:medtalk/doctor/design/bloc/design_state.dart';
import 'package:medtalk/doctor/design/screens/service_editor.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/font.dart';
import 'package:medtalk/styles/sizes.dart';
import 'package:medtalk/styles/styles/button.dart';
import 'package:medtalk/styles/styles/text.dart';

import '../../../common/widgets/themes/time_picker.dart';
import '../bloc/design_event.dart';
import '../models/design_models.dart';

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

class _DesignScreenState extends State<DesignScreen> {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Settings state variables
  int _advanceNotice = 24; // in hours
  int _bookingWindow = 12; // in weeks
  bool _autoConfirmation = true;
  bool _acceptCreditCard = true;
  bool _acceptCash = true;
  bool _acceptInsurance = false;
  int _cancellationPolicy = 24; // in hours

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
  final Map<String, WorkingHours> _scheduleMap = {};
  int _slotDuration = 30; // in minutes
  int _bufferTime = 10; // in minutes

  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

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

  @override
  void dispose() {
    _bioController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DesignBloc()..add(LoadDoctorProfile()),
      child: Scaffold(
        body: CustomBase(
          roundCorners: false,
          child: BlocBuilder<DesignBloc, DesignState>(
            builder: (context, state) {
              return Padding(
                padding: kPaddT40,
                child: Column(
                  children: [
                    // Navigation tabs
                    Container(
                      margin: kPaddB15,
                      decoration: BoxDecoration(
                        color: MyColors.blueGrey,
                        borderRadius: kRadius12,
                      ),
                      child: Row(
                        children: [
                          _buildNavTab(
                              0, 'Profile', FontAwesomeIcons.userDoctor),
                          _buildNavTab(
                              1, 'Services', FontAwesomeIcons.kitMedical),
                          _buildNavTab(
                              2, 'Schedule', FontAwesomeIcons.calendar),
                          _buildNavTab(3, 'Settings', FontAwesomeIcons.gear),
                        ],
                      ),
                    ),

                    // Main content
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        children: [
                          _buildProfilePage(context, state),
                          _buildServicesPage(context, state),
                          _buildSchedulePage(context, state),
                          _buildSettingsPage(context, state),
                        ],
                      ),
                    ),

                    // Save button
                    Padding(
                      padding: kPaddT15,
                      child: ElevatedButton(
                        // Update the SaveDoctorProfile event call in the Save button's onPressed callback
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
                                // slotDuration: _slotDuration,
                                // bufferTime: _bufferTime,
                                //
                                // // Settings data
                                // advanceNotice: _advanceNotice,
                                // bookingWindow: _bookingWindow,
                                // autoConfirmation: _autoConfirmation,
                                // sendReminders: _sendReminders,
                                // reminder24h: _reminder24h,
                                // reminder1h: _reminder1h,
                                // customReminders: _customReminders,
                                // acceptCreditCard: _acceptCreditCard,
                                // acceptCash: _acceptCash,
                                // acceptInsurance: _acceptInsurance,
                                // cancellationPolicy: _cancellationPolicy,
                              ));

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Profile and settings saved successfully')),
                          );
                        },
                        style: kElevatedButtonCommonStyle,
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavTab(int index, String title, IconData icon) {
    bool isSelected = _currentPage == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Container(
          padding: kPaddT12B8,
          decoration: BoxDecoration(
            color: isSelected ? MyColors.primary : Colors.transparent,
            borderRadius: kRadius12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                icon,
                color: isSelected
                    ? Colors.white
                    : MyColors.primary.withValues(alpha: 0.7),
                size: 16,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: Font.extraSmall,
                  color: isSelected
                      ? Colors.white
                      : MyColors.primary.withValues(alpha: 0.7),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePage(BuildContext context, DesignState state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          kGap4,
          Row(
            children: [
              const ProfilePicture(
                height: 70,
                width: 70,
              ),
              kGap16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      // state.patient.name ?? 'Unknown Doctor',
                      'Dr. John Doe',
                      style: TextStyle(
                        fontSize: Font.mediumSmall,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      // '${state.patient.speciality} • ${_calculateAge(state.patient.dateOfBirth)} yrs • ${state.patient.sex}',
                      'Dentist • 29 yrs • Male',
                      style: TextStyle(
                        color: MyColors.textGrey,
                        fontSize: Font.extraSmall,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Upload new photo
                      },
                      icon: const FaIcon(FontAwesomeIcons.camera,
                          size: 14, color: MyColors.primary),
                      label: const Text('Update Photo',
                          style: TextStyle(
                              fontSize: Font.extraSmall,
                              color: MyColors.primary)),
                      style: OutlinedButton.styleFrom(
                        padding: kPaddH10V4,
                        minimumSize: Size.zero,
                        side: const BorderSide(
                          color: MyColors.primary,
                        ),
                        textStyle: const TextStyle(
                            fontSize: Font.extraSmall, color: MyColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const CardDivider(),

          // Biography
          const Text('Biography', style: kSectionTitle),
          kGap10,
          TextField(
            controller: _bioController,
            style: const TextStyle(
              fontSize: Font.small,
              color: MyColors.textBlack,
            ),
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: MyColors.softStroke,
                ),
                borderRadius: kRadius6,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: MyColors.primary,
                ),
                borderRadius: kRadius6,
              ),
              border: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: MyColors.softStroke,
                ),
                borderRadius: kRadius6,
              ),
              hintText: 'Tell patients about your experience and expertise',
              contentPadding: kPadd10,
              hintStyle: const TextStyle(
                color: MyColors.textGrey,
                fontSize: Font.small,
              ),
            ),
            maxLines: 5,
          ),
          kGap8,

          const CardDivider(),

          // Qualifications
          const Text('Qualifications & Experience', style: kSectionTitle),
          kGap10,
          _buildQualificationItem(
            'MD, Stanford University School of Medicine',
            '2010 - 2014',
            isEditable: true,
          ),
          kGap10,
          _buildQualificationItem(
            'Residency, UCSF Medical Center',
            '2014 - 2017',
            isEditable: true,
          ),
          kGap10,
          _buildQualificationItem(
            'Board Certification, American Board of Medical Specialties',
            '2018',
            isEditable: true,
          ),
          kGap14,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  // Add new qualification
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add Qualification',
                    style: TextStyle(
                      fontSize: Font.small,
                      color: MyColors.primary,
                    )),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: MyColors.primary,
                  elevation: 0,
                  side: const BorderSide(
                    color: MyColors.primary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: kRadius10,
                  ),
                ),
              ),
            ],
          ),

          const CardDivider(),

          // Clinic details
          const Text('Clinic Details', style: kSectionTitle),
          kGap14,

          // Map location
          Container(
            height: 175,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: MyColors.grey, width: 1.5),
              borderRadius: kRadius10,
            ),
            child: ClipRRect(
              borderRadius: kRadius10,
              child: Stack(
                children: [
                  const GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(45.521563, -122.677433),
                      zoom: 14.0,
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Update map location
                      },
                      icon: const Icon(Icons.edit_location_alt, size: 16),
                      label: const Text('Update'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: MyColors.primary,
                        padding: kPaddH8V4,
                        textStyle: const TextStyle(fontSize: Font.extraSmall),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          kGap10,

          // Phone
          TextField(
            style: const TextStyle(
              fontSize: Font.small,
              color: MyColors.textBlack,
            ),
            controller: _phoneController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: kPaddH10V8,
              hintText: 'Phone number',
              hintStyle: TextStyle(
                color: MyColors.textGrey,
                fontSize: Font.small,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 15),
                child: FaIcon(
                  FontAwesomeIcons.phone,
                  color: MyColors.primary,
                  size: 16,
                ),
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 40),
            ),
          ),
          kGap10,

          // Address
          TextField(
            style: const TextStyle(
              fontSize: Font.small,
              color: MyColors.textBlack,
            ),
            controller: _addressController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: kPaddH10V8,
              hintText: 'Clinic address',
              hintStyle: TextStyle(
                color: MyColors.textGrey,
                fontSize: Font.small,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 15),
                child: FaIcon(
                  FontAwesomeIcons.mapLocation,
                  color: MyColors.primary,
                  size: 16,
                ),
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 40),
            ),
          ),
          kGap10,

          // Additional notes
          TextField(
            style: const TextStyle(
              fontSize: Font.small,
              color: MyColors.textBlack,
            ),
            controller: _notesController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: kPaddH10V8,
              hintText: 'Additional notes (parking, access, etc.)',
              hintStyle: TextStyle(
                color: MyColors.textGrey,
                fontSize: Font.small,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 15),
                child: FaIcon(
                  FontAwesomeIcons.circleInfo,
                  color: MyColors.primary,
                  size: 16,
                ),
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesPage(BuildContext context, DesignState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Your Services', style: kSectionTitle),
          ],
        ),
        kGap10,

        // Services list
        if (state.services.isEmpty)
          _buildEmptyServicesList()
        else
          Container(
            padding: kPaddH15T2B6,
            decoration: BoxDecoration(
              color: MyColors.cardBackground,
              borderRadius: kRadius12,
              border: Border.all(color: MyColors.softStroke),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              // Add this line
              itemCount: state.services.length,
              separatorBuilder: (context, index) => const DottedLine(
                direction: Axis.horizontal,
                lineLength: double.infinity,
                lineThickness: 1,
                dashLength: 4.0,
                dashColor: MyColors.softStroke,
              ),
              itemBuilder: (context, index) {
                final service = state.services[index];
                return _buildServiceItem(
                  context: context,
                  service: service,
                );
              },
            ),
          ),

        kGap10,

        OutlinedButton.icon(
          onPressed: () {
            _addNewService(context);
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Service'),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: MyColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: kRadius10,
            ),
            side: const BorderSide(
              color: MyColors.primary,
            ),
            textStyle: const TextStyle(fontSize: Font.small),
            padding: kPaddH12V8,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyServicesList() {
    return Container(
      padding: kPadd30,
      decoration: BoxDecoration(
        color: MyColors.blueGrey.withValues(alpha: 0.3),
        borderRadius: kRadius12,
        border: Border.all(color: MyColors.softStroke),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.clipboardList,
            size: 48,
            color: MyColors.primary.withValues(alpha: 0.5),
          ),
          kGap16,
          const Text(
            'No Services Added Yet',
            style: TextStyle(
              fontSize: Font.medium,
              fontWeight: FontWeight.bold,
              color: MyColors.textBlack,
            ),
          ),
          kGap8,
          const Text(
            'Add your first service to start getting appointments',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Font.small,
              color: MyColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem({
    required BuildContext context,
    required DoctorService service,
  }) {
    return InkWell(
      onTap: () {
        _editService(context, service);
      },
      child: Container(
        padding: kPaddV10,
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: const TextStyle(
                        fontSize: Font.smallExtra,
                        color: MyColors.textBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    kGap4,
                    Text(
                      "${service.duration} mins",
                      style: const TextStyle(
                        fontSize: Font.extraSmall,
                        color: MyColors.textGrey,
                      ),
                    ),
                    kGap8,
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          if (service.isInPerson)
                            _buildServiceTypeTag(
                                FontAwesomeIcons.hospitalUser, 'In-Person'),
                          if (service.isInPerson &&
                              (service.isOnline || service.isHomeVisit))
                            kGap4,
                          if (service.isOnline)
                            _buildServiceTypeTag(
                                FontAwesomeIcons.video, 'Online'),
                          if (service.isOnline && service.isHomeVisit) kGap4,
                          if (service.isHomeVisit)
                            _buildServiceTypeTag(
                                FontAwesomeIcons.house, 'Home Visit'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "\$${service.price.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: Font.mediumSmall,
                        color: MyColors.textBlack,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: MyColors.blueGrey.withValues(alpha: 0.1),
                            borderRadius: kRadius6,
                          ),
                          child: Tooltip(
                            message: 'Delete service',
                            child: InkWell(
                              onTap: () {
                                // Store bloc reference before showing dialog
                                final designBloc = context.read<DesignBloc>();

                                showDialog(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    title: const Text(
                                      'Delete Service',
                                      style: TextStyle(
                                        fontSize: Font.medium,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontSize: Font.small,
                                          color: Colors.black,
                                        ),
                                        children: [
                                          const TextSpan(
                                              text:
                                                  'Are you sure you want to delete '),
                                          TextSpan(
                                            text: service.title,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const TextSpan(text: '?'),
                                        ],
                                      ),
                                    ),
                                    backgroundColor: MyColors.cardBackground,
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.delete_outline,
                                            size: 16),
                                        label: const Text('Delete'),
                                        onPressed: () {
                                          Navigator.pop(dialogContext);
                                          // Use the stored bloc reference instead of context.read
                                          designBloc
                                              .add(DeleteService(service.id));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('Service deleted')),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: MyColors.buttonRed,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(6),
                                bottomRight: Radius.circular(6),
                              ),
                              child: const Padding(
                                padding: kPaddH12V8,
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline,
                                        size: 16, color: MyColors.buttonRed),
                                    kGap4,
                                    Text(
                                      'Delete',
                                      style: TextStyle(
                                        fontSize: Font.extraSmall,
                                        color: MyColors.buttonRed,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Helper methods to handle async navigation
  Future<void> _addNewService(BuildContext context) async {
    // Store bloc reference before async gap
    final designBloc = context.read<DesignBloc>();

    // Navigate to service editor and get result back
    final result = await Navigator.push<DoctorService?>(
      context,
      ServiceEditorScreen.route(),
    );
    final DoctorService? newService = result;

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
      ));

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service added successfully')),
      );
    }
  }

  Future<void> _editService(BuildContext context, DoctorService service) async {
    // Store bloc reference before async gap
    final designBloc = context.read<DesignBloc>();

    // Navigate to service editor with existing service
    final result = await Navigator.push<DoctorService?>(
      context,
      ServiceEditorScreen.route(service: service),
    );
    final DoctorService? updatedService = result;

    // Check if state is still mounted and we have an updated service
    if (updatedService != null && context.mounted) {
      // Update service in state using stored bloc reference
      designBloc.add(UpdateService(
        id: updatedService.id,
        title: updatedService.title,
        duration: updatedService.duration,
        price: updatedService.price,
        isOnline: updatedService.isOnline,
        isInPerson: updatedService.isInPerson,
        isHomeVisit: updatedService.isHomeVisit,
      ));

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service updated successfully')),
      );
    }
  }

  Widget _buildServiceTypeTag(IconData icon, String text) {
    return Container(
      padding: kPaddH6V2,
      decoration: BoxDecoration(
        color: MyColors.primary.withValues(alpha: 0.1),
        borderRadius: kRadiusAll,
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
          kGap4,
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

// Replace the _buildSchedulePage method
  Widget _buildSchedulePage(BuildContext context, DesignState state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Schedule', style: kSectionTitle),
          kGap10,

          // Week view tabs
          Container(
            decoration: BoxDecoration(
              color: MyColors.blueGrey,
              borderRadius: kRadius6,
            ),
            child: Row(
              children: List.generate(7, (index) {
                return _buildDayTab(
                    _workingDaysTitles[index], _selectedDayIndex == index);
              }),
            ),
          ),
          kGap20,

          // Working hours
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Working Hours',
                style: TextStyle(
                  fontSize: Font.mediumSmall,
                  color: MyColors.textBlack,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: _isWorkingDay,
                onChanged: (value) {
                  _setWorkingDay(value);
                },
                activeColor: MyColors.primary,
              ),
            ],
          ),
          kGap10,

          // Time range - only visible if it's a working day
          if (_isWorkingDay)
            Row(
              children: [
                Expanded(
                  child: InkWell(
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
                ),
                const Padding(
                  padding: kPaddH8,
                  child: Text('to', style: TextStyle(color: MyColors.textGrey)),
                ),
                Expanded(
                  child: InkWell(
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
                ),
              ],
            ),

          if (_isWorkingDay) ...[
            kGap20,
            const DottedLine(
              direction: Axis.horizontal,
              lineLength: double.infinity,
              lineThickness: 1,
              dashLength: 4.0,
              dashColor: MyColors.softStroke,
            ),
            kGap20,

            // Break times
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Break Times',
                  style: TextStyle(
                    fontSize: Font.mediumSmall,
                    color: MyColors.textBlack,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showAddBreakDialog(context),
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add Break'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: kRadius10,
                    ),
                    side: const BorderSide(
                      color: MyColors.primary,
                    ),
                    backgroundColor: Colors.transparent,
                    foregroundColor: MyColors.primary,
                    textStyle: const TextStyle(fontSize: Font.extraSmall),
                    padding: kPaddH8V4,
                  ),
                ),
              ],
            ),
            kGap10,

            // Break items
            if (_breaks.isEmpty)
              const Padding(
                padding: kPaddV10,
                child: Text(
                  'No breaks added yet',
                  style: TextStyle(
                    fontSize: Font.small,
                    color: MyColors.textGrey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Column(
                children: _breaks.map((breakItem) {
                  return Padding(
                    padding: kPaddB10,
                    child: Container(
                      padding: kPaddH14,
                      decoration: BoxDecoration(
                        color: MyColors.cardBackground,
                        borderRadius: kRadius6,
                        border: Border.all(color: MyColors.softStroke),
                      ),
                      child: Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.mugSaucer,
                            size: 14,
                            color: MyColors.primary,
                          ),
                          kGap10,
                          Text(breakItem.title,
                              style: const TextStyle(
                                  fontSize: Font.small,
                                  color: MyColors.textBlack)),
                          const Spacer(),
                          Text(
                              '${_formatTimeDisplay(breakItem.startTime)} - ${_formatTimeDisplay(breakItem.endTime)}',
                              style: const TextStyle(
                                  fontSize: Font.small,
                                  color: MyColors.textGrey)),
                          kGap10,
                          IconButton(
                            onPressed: () => _deleteBreak(breakItem),
                            icon: const Icon(Icons.delete_outline,
                                size: 18, color: MyColors.buttonRed),
                            padding: kPadd0,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

            const CardDivider(),

            // Time slot settings
            const Text('Time Slot Settings', style: kSectionTitle),
            kGap10,

            // Slot duration
            Row(
              children: [
                const Text('Default Slot Duration:',
                    style: TextStyle(
                        fontSize: Font.small, color: MyColors.textGrey)),
                const Spacer(), // Add spacer to push dropdown to the right
                InkWell(
                  onTap: () => _showSlotDurationPicker(context),
                  child: Container(
                    padding: kPaddH10V4,
                    decoration: BoxDecoration(
                      border: Border.all(color: MyColors.grey),
                      borderRadius: kRadius6,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(getSlotDurationTime(),
                            style: const TextStyle(fontSize: Font.small)),
                        const Icon(Icons.arrow_drop_down, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            kGap10,

            // Buffer time
            Row(
              children: [
                const Text('Buffer Between Appointments:',
                    style: TextStyle(
                        fontSize: Font.small, color: MyColors.textGrey)),
                const Spacer(), // Add spacer to push dropdown to the right
                InkWell(
                  onTap: () => _showBufferTimePicker(context),
                  child: Container(
                    padding: kPaddH10V4,
                    decoration: BoxDecoration(
                      border: Border.all(color: MyColors.grey),
                      borderRadius: kRadius6,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            _bufferTime == 0
                                ? 'No buffer'
                                : '$_bufferTime minutes',
                            style: const TextStyle(fontSize: Font.small)),
                        const Icon(Icons.arrow_drop_down, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            kGap20,
            const DottedLine(
              direction: Axis.horizontal,
              lineLength: double.infinity,
              lineThickness: 1,
              dashLength: 4.0,
              dashColor: MyColors.softStroke,
            ),
            kGap20,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Available Slots Preview', style: kSectionTitle),
                kGap10,
                _buildTimeSlotGrid(),
                kGap10,
              ],
            ),
          ] else ...[
            // Not a working day message
            Container(
              margin: const EdgeInsets.symmetric(vertical: 30),
              padding: kPadd20,
              decoration: BoxDecoration(
                color: MyColors.blueGrey.withValues(alpha: 0.2),
                borderRadius: kRadius12,
                border: Border.all(color: MyColors.softStroke),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 48,
                    color: MyColors.textGrey.withValues(alpha: 0.7),
                  ),
                  kGap16,
                  const Text(
                    'Not a Working Day',
                    style: TextStyle(
                      fontSize: Font.medium,
                      fontWeight: FontWeight.bold,
                      color: MyColors.textBlack,
                    ),
                  ),
                  kGap8,
                  const Text(
                    'You have marked this day as unavailable. Toggle the switch above if you want to work on this day.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: Font.small,
                      color: MyColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

// Update the day tab selection method
  Widget _buildDayTab(String day, bool isSelected) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedDayIndex = _workingDaysTitles.indexOf(day);
          });
        },
        child: Container(
          padding: kPaddV8,
          decoration: BoxDecoration(
            color: isSelected ? MyColors.primary : Colors.transparent,
            borderRadius: kRadius6,
          ),
          alignment: Alignment.center,
          child: Text(
            day,
            style: TextStyle(
              fontSize: Font.small,
              color: isSelected
                  ? Colors.white
                  : MyColors.primary.withValues(alpha: 0.7),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

// Update _selectTime method
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

// Show dialog to add a break
// Update the _showAddBreakDialog method
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
              backgroundColor: MyColors.cardBackground,
              title: const Text('Add Break'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      style: const TextStyle(
                        fontSize: Font.small,
                        color: MyColors.textBlack,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Break Title',
                        hintStyle: TextStyle(
                          color: MyColors.textGrey,
                          fontSize: Font.small,
                          fontWeight: FontWeight.w400,
                        ),
                        labelStyle: TextStyle(
                          color: MyColors.textGrey,
                          fontSize: Font.small,
                        ),
                        hintText: 'e.g. Lunch Break',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    kGap16,
                    const Text('Start Time',
                        style: TextStyle(
                            color: MyColors.textGrey, fontSize: Font.small)),
                    kGap4,
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
                              _formatTimeDisplay(startTime),
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
                    kGap16,
                    const Text('End Time',
                        style: TextStyle(
                            color: MyColors.textGrey, fontSize: Font.small)),
                    kGap4,
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
                              _formatTimeDisplay(endTime),
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

  // Add this method to your class
  void _showBookingAdvancePicker(BuildContext context) {
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
                'Booking Advance Notice',
                style: TextStyle(
                  fontSize: Font.medium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              kGap10,
              Expanded(
                child: ListView(
                  children: [
                    _buildBookingAdvanceOption(context, 1, '1 hour'),
                    line,
                    _buildBookingAdvanceOption(context, 2, '2 hours'),
                    line,
                    _buildBookingAdvanceOption(context, 12, '12 hours'),
                    line,
                    _buildBookingAdvanceOption(context, 24, '1 day'),
                    line,
                    _buildBookingAdvanceOption(context, 48, '2 days'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBufferOption(BuildContext context, int value, String label) {
    bool isSelected = _bufferTime == value;

    return InkWell(
      onTap: () {
        setState(() {
          _bufferTime = value;
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

  Widget _buildCancellationPolicyOption(
      BuildContext context, int value, String label) {
    bool isSelected = _cancellationPolicy == value;

    return InkWell(
      onTap: () {
        setState(() {
          _cancellationPolicy = value;
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

  Widget _buildBookingWindowOption(
      BuildContext context, int value, String label) {
    bool isSelected = _bookingWindow == value;

    return InkWell(
      onTap: () {
        setState(() {
          _bookingWindow = value;
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

  Widget _buildBookingAdvanceOption(
      BuildContext context, int value, String label) {
    bool isSelected = _advanceNotice == value;

    return InkWell(
      onTap: () {
        setState(() {
          _advanceNotice = value;
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

  Widget _buildSlotDurationOption(
      BuildContext context, int value, String label) {
    bool isSelected = _slotDuration == value;

    return InkWell(
      onTap: () {
        setState(() {
          _slotDuration = value;
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

  // Add this method to your class
  void _showBookingWindowPicker(BuildContext context) {
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
                'Booking Window',
                style: TextStyle(
                  fontSize: Font.medium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              kGap10,
              Expanded(
                child: ListView(
                  children: [
                    _buildBookingWindowOption(context, 1, '1 week'),
                    line,
                    _buildBookingWindowOption(context, 2, '2 weeks'),
                    line,
                    _buildBookingWindowOption(context, 4, '1 month'),
                    line,
                    _buildBookingWindowOption(context, 12, '3 months'),
                    line,
                    _buildBookingWindowOption(context, 24, '6 months'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Add this method to your class
  void _showCancellationPolicyPicker(BuildContext context) {
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
          height: 450,
          padding: kPadd16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cancellation Policy Notice',
                style: TextStyle(
                  fontSize: Font.medium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              kGap10,
              Expanded(
                child: ListView(
                  children: [
                    _buildCancellationPolicyOption(
                        context, 0, 'No cancellations'),
                    line,
                    _buildCancellationPolicyOption(context, 1, '1 hour notice'),
                    line,
                    _buildCancellationPolicyOption(
                        context, 3, '3 hours notice'),
                    line,
                    _buildCancellationPolicyOption(
                        context, 6, '6 hours notice'),
                    line,
                    _buildCancellationPolicyOption(
                        context, 12, '12 hours notice'),
                    line,
                    _buildCancellationPolicyOption(context, 24, '1 day notice'),
                    line,
                    _buildCancellationPolicyOption(
                        context, 48, '2 days notice'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Add this method to your class
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
          height: 400,
          padding: kPadd16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Default Slot Duration',
                style: TextStyle(
                  fontSize: Font.medium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              kGap10,
              Expanded(
                child: ListView(
                  children: [
                    _buildSlotDurationOption(context, 15, '15 minutes'),
                    line,
                    _buildSlotDurationOption(context, 30, '30 minutes'),
                    line,
                    _buildSlotDurationOption(context, 45, '45 minutes'),
                    line,
                    _buildSlotDurationOption(context, 60, '1 hour'),
                    line,
                    _buildSlotDurationOption(context, 90, '1.5 hours'),
                    line,
                    _buildSlotDurationOption(context, 120, '2 hours'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Add this method to your class
  void _showBufferTimePicker(BuildContext context) {
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
          height: 450,
          padding: kPadd16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buffer Between Appointments',
                style: TextStyle(
                  fontSize: Font.medium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              kGap10,
              Expanded(
                child: ListView(
                  children: [
                    _buildBufferOption(context, 0, 'No buffer'),
                    line,
                    _buildBufferOption(context, 5, '5 minutes'),
                    line,
                    _buildBufferOption(context, 10, '10 minutes'),
                    line,
                    _buildBufferOption(context, 15, '15 minutes'),
                    line,
                    _buildBufferOption(context, 20, '20 minutes'),
                    line,
                    _buildBufferOption(context, 25, '25 minutes'),
                    line,
                    _buildBufferOption(context, 30, '30 minutes'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// Build time slot grid
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
      return const Center(
        child: Text(
          'No available slots for the selected time range',
          style: TextStyle(
            fontSize: Font.small,
            color: MyColors.textGrey,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    // Calculate rows needed (with 3 columns)
    (slots.length / 3).ceil();

    // calculate number of active slots
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

    // Don't limit the height, allow container to expand based on content
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total available slots: $activeSlots / ${slots.length}',
          style: const TextStyle(
            fontSize: Font.extraSmall,
            color: MyColors.textGrey,
          ),
        ),
        kGap10,
        Container(
          constraints: const BoxConstraints(maxHeight: 400),
          child: GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            // Use ClampingScrollPhysics to allow scrolling but prevent overscroll effect
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
                      ? MyColors.primary.withValues(alpha: 0.1)
                      : MyColors.grey.withValues(alpha: 0.1),
                  borderRadius: kRadius6,
                  border: Border.all(
                      color: isAvailable ? MyColors.primary : MyColors.grey),
                ),
                child: Text(
                  "$displayHour:$minuteStr $amPm",
                  style: TextStyle(
                    fontSize: Font.small,
                    color: isAvailable ? MyColors.primary : MyColors.grey,
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Appointment Settings', style: kSectionTitle),
          kGap20,

          // Booking advance notice
          _buildSettingItem(
            title: 'Booking Advance Notice',
            description: 'Minimum time before an appointment can be booked',
            child: InkWell(
              onTap: () => _showBookingAdvancePicker(context),
              child: Container(
                padding: kPaddH10V4,
                decoration: BoxDecoration(
                  border: Border.all(color: MyColors.grey),
                  borderRadius: kRadius6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(getBookingAdvanceTime(),
                        style: const TextStyle(fontSize: Font.small)),
                    const Icon(Icons.arrow_drop_down, size: 18),
                  ],
                ),
              ),
            ),
          ),

          kGap14,
          const DottedLine(
            direction: Axis.horizontal,
            lineLength: double.infinity,
            lineThickness: 1,
            dashLength: 4.0,
            dashColor: MyColors.softStroke,
          ),
          kGap14,

          // Booking window
          _buildSettingItem(
            title: 'Booking Window',
            description: 'How far in advance patients can book appointments',
            child: InkWell(
              onTap: () => _showBookingWindowPicker(context),
              child: Container(
                padding: kPaddH10V4,
                decoration: BoxDecoration(
                  border: Border.all(color: MyColors.grey),
                  borderRadius: kRadius6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(getBookingWindowTime(),
                        style: const TextStyle(fontSize: Font.small)),
                    const Icon(Icons.arrow_drop_down, size: 18),
                  ],
                ),
              ),
            ),
          ),

          kGap14,
          const DottedLine(
            direction: Axis.horizontal,
            lineLength: double.infinity,
            lineThickness: 1,
            dashLength: 4.0,
            dashColor: MyColors.softStroke,
          ),
          kGap14,

          // Auto confirmation
          _buildSettingItem(
            title: 'Auto Confirmation',
            description: 'Automatically confirm appointments when booked',
            child: _buildSettingsToggle(
              value: _autoConfirmation,
              onChanged: (value) {
                setState(() {
                  _autoConfirmation = value;
                });
              },
            ),
          ),

          kGap10,
          const CardDivider(),

          // Payment settings
          const Text('Payment Settings', style: kSectionTitle),
          kGap20,

          // Payment methods
          _buildSettingItem(
            title: 'Accepted Payment Methods',
            description: 'Methods patients can use to pay for appointments',
            child: const SizedBox(),
          ),

          kGap10,
          // Payment methods checkboxes
          Column(
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

          kGap14,
          const DottedLine(
            direction: Axis.horizontal,
            lineLength: double.infinity,
            lineThickness: 1,
            dashLength: 4.0,
            dashColor: MyColors.softStroke,
          ),
          kGap14,

          // Cancellation policy
          _buildSettingItem(
            title: 'Cancellation Policy',
            description: 'Set your policy for appointment cancellations',
            child: InkWell(
              onTap: () => _showCancellationPolicyPicker(context),
              child: Container(
                padding: kPaddH10V4,
                decoration: BoxDecoration(
                  border: Border.all(color: MyColors.grey),
                  borderRadius: kRadius6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(getCancellationPolicyTime(),
                        style: const TextStyle(fontSize: Font.small)),
                    const Icon(Icons.arrow_drop_down, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
    return Container(
      padding: kPadd10,
      decoration: BoxDecoration(
        color: MyColors.cardBackground,
        borderRadius: kRadius6,
        border: Border.all(color: MyColors.softStroke),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: Font.small,
                    color: MyColors.textBlack,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: Font.extraSmall,
                    color: MyColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          if (isEditable) ...[
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () {},
              padding: kPadd4,
              constraints: const BoxConstraints(),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 20, color: MyColors.buttonRed),
              onPressed: () {},
              padding: kPadd4,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: Font.small,
                  color: MyColors.textBlack,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: Font.extraSmall,
                  color: MyColors.textGrey,
                ),
              ),
            ],
          ),
        ),
        kGap30,
        child,
      ],
    );
  }

// Toggle widget for settings
  Widget _buildSettingsToggle({
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: MyColors.primary,
    );
  }

// Checkbox widget for settings
  Widget _buildSettingsCheckbox({
    required String title,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      activeColor: MyColors.primary,
      overlayColor:
          WidgetStateProperty.all(MyColors.primary.withValues(alpha: 0.1)),
      title: Text(title, style: const TextStyle(fontSize: Font.small)),
      contentPadding: kPadd0,
      dense: true,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

// Add this to the reminder schedule container to display custom reminders
}
