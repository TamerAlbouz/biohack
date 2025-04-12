import 'package:backend/backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/common/widgets/common_error_widget.dart';
import 'package:medtalk/common/widgets/dividers/section_divider.dart';
import 'package:medtalk/common/widgets/dropdown/custom_complex_dropdown.dart';
import 'package:medtalk/common/widgets/inifinite_list_view.dart';
import 'package:medtalk/patient/search_doctors/bloc/search_doctors_bloc.dart';
import 'package:medtalk/patient/search_doctors/screens/setup_appointments/setup_appointment_screen.dart';
import 'package:medtalk/styles/sizes.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../common/globals/globals.dart';
import '../../../common/widgets/base/custom_base.dart';
import '../../../common/widgets/cards/doctor_card.dart';
import '../../../common/widgets/custom_input_field.dart';
import '../../../styles/colors.dart';
import '../../../styles/font.dart';
import '../../../styles/styles/text.dart';

class SearchDoctorsScreen extends StatefulWidget {
  const SearchDoctorsScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const SearchDoctorsScreen());
  }

  @override
  State<SearchDoctorsScreen> createState() => _SearchDoctorsScreenState();
}

class _SearchDoctorsScreenState extends State<SearchDoctorsScreen> {
  late SearchDoctorsBloc _searchDoctorsBloc;
  late InfiniteScrollController _infiniteScrollController;

  bool _isLoading = false;
  bool _hasMoreData = false;
  List<Doctor> _doctors = [];

  @override
  void initState() {
    super.initState();
    _searchDoctorsBloc = SearchDoctorsBloc(
      getIt<IDoctorRepository>(),
    )..add(SearchDoctorsLoad());
    _infiniteScrollController = InfiniteScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: kPaddH20,
          child: BlocProvider(
            create: (context) => _searchDoctorsBloc,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                BlocConsumer<SearchDoctorsBloc, SearchDoctorsState>(
                  listener: (context, state) {
                    // Update state for ANY SearchDoctorsLoaded state
                    if (state is SearchDoctorsLoaded) {
                      setState(() {
                        _doctors = state.doctors;
                        _isLoading = state.isLoadingMore;
                        _hasMoreData = state.hasMoreData;
                      });
                      // Only refresh the controller if it's still mounted
                      if (mounted) {
                        _infiniteScrollController.refresh();
                      }
                    }
                  },
                  builder: (context, state) {
                    // Show loading indicator when in initial or loading state
                    if (state is SearchDoctorsInitial ||
                        (state is SearchDoctorsLoading && _doctors.isEmpty)) {
                      return _buildLoadingState();
                    }

                    // Show error message when in error state
                    if (state is SearchDoctorsError) {
                      return CommonErrorWidget(onRetry: () {
                        _searchDoctorsBloc.add(SearchDoctorsLoad());
                      });
                    }

                    // Show the list when doctors are loaded
                    return InfiniteScrollListView(
                      controller: _infiniteScrollController,
                      isLoading: _isLoading,
                      hasReachedMax: !_hasMoreData,
                      items: _doctors,
                      onLoadMore: () {
                        context
                            .read<SearchDoctorsBloc>()
                            .add(SearchDoctorsLoadMore());
                      },
                      headerBuilder: (isCollapsed) => isCollapsed
                          ? _buildCollapsedHeader()
                          : _buildExpandedHeader(),
                      itemBuilder: (context, doctor) {
                        return DoctorCard(
                          name: doctor.name ?? 'Unknown Doctor',
                          specialty: doctor.specialties?.join(', ') ??
                              'General Practice',
                          availability:
                              calculateAvailability(doctor.availability),
                          timeSlots: doctor.availability.isNotEmpty
                              ? doctor.availability.values.firstWhere(
                                      (v) => v != null,
                                      orElse: () => []) ??
                                  []
                              : [],
                          onCardTap: () {
                            AppGlobal.navigatorKey.currentState?.push<void>(
                              SetupAppointmentScreen.route(
                                doctorId: doctor.uid,
                                doctorName: doctor.name ?? 'Unknown Doctor',
                                specialty: doctor.specialties?.join(', ') ??
                                    'General Practice',
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Expanded(
      child: Skeletonizer(
        enabled: true,
        enableSwitchAnimation: true,
        switchAnimationConfig: const SwitchAnimationConfig(
          duration: Duration(milliseconds: 500),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Skeleton search header
              Container(height: 24, width: 180, color: Colors.grey[300]),
              kGap4,
              Container(height: 16, width: 150, color: Colors.grey[300]),
              kGap28,
              // Skeleton dropdown filters
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(color: MyColors.primary),
                        borderRadius: kRadiusAll,
                        color: MyColors.cardBackground,
                      ),
                    ),
                  ),
                ],
              ),
              kGap10,
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                          border: Border.all(color: MyColors.primary),
                          borderRadius: kRadiusAll,
                          color: MyColors.cardBackground),
                    ),
                  ),
                ],
              ),
              kGap10,
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: MyColors.cardBackground,
                  borderRadius: kRadiusAll,
                ),
              ),
              kGap20,

              // dont forget the 'Available Doctors' text
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Doctors',
                    style: kSectionTitle,
                  ),
                  Text(
                    '0 found',
                    style: TextStyle(
                      fontSize: Font.small,
                      color: MyColors.primary,
                    ),
                  ),
                ],
              ),
              kGap20,

              const SectionDivider(),

              // Skeleton doctors
              for (int i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: CustomBase(
                    shadow: false,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            kGap10,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      height: 16,
                                      width: 150,
                                      color: Colors.grey[300]),
                                  kGap4,
                                  Container(
                                      height: 14,
                                      width: 100,
                                      color: Colors.grey[300]),
                                  kGap8,
                                  Container(
                                      height: 12,
                                      width: 120,
                                      color: Colors.grey[300]),
                                ],
                              ),
                            ),
                            Container(
                              width: 50,
                              height: 60,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: kRadius10,
                              ),
                            ),
                          ],
                        ),
                        kGap10,
                        const Divider(),
                        kGap10,
                        Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: kRadius10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Fixed availability calculation method
  String calculateAvailability(Map<String, List<String>?> map) {
    if (map.isEmpty) return 'No availability';

    final weekdayNames = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    final currentDay = DateTime.now().weekday;
    final currentDayName = weekdayNames[currentDay - 1];

    // Check if available today
    if (map.containsKey(currentDayName) &&
        map[currentDayName] != null &&
        map[currentDayName]!.isNotEmpty) {
      return 'Available Today';
    }

    // Check if available tomorrow
    final tomorrowIndex = currentDay % 7;
    final tomorrowDayName = weekdayNames[tomorrowIndex];

    if (map.containsKey(tomorrowDayName) &&
        map[tomorrowDayName] != null &&
        map[tomorrowDayName]!.isNotEmpty) {
      return 'Available Tomorrow';
    }

    // Find next available day
    for (final day in map.keys) {
      if (map[day] != null && map[day]!.isNotEmpty) {
        // Capitalize the day name
        return 'Available on ${day[0].toUpperCase()}${day.substring(1)}';
      }
    }

    return 'No availability';
  }

  Widget _buildExpandedHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Find a Doctor',
          style: TextStyle(
            fontSize: Font.medium,
            fontWeight: FontWeight.bold,
            color: MyColors.textBlack,
          ),
        ),
        const Text(
          "Select a doctor for your appointment",
          style: TextStyle(
            fontSize: Font.small,
            color: MyColors.subtitleDark,
          ),
        ),
        kGap20,

        // Specialty filter
        CustomComplexDropDown(
          title: 'Specialty',
          items: const [
            'Cardiology',
            'Dermatology',
            'Endocrinology',
            'Gastroenterology',
            'General Practice',
            'Geriatrics',
            'Hematology',
            'Infectious Disease',
            'Internal Medicine',
            'Nephrology',
            'Neurology',
            'Obstetrics and Gynecology',
            'Oncology',
            'Ophthalmology',
            'Orthopedics',
            'Otolaryngology',
            'Pediatrics',
            'Physical Medicine and Rehabilitation',
            'Plastic Surgery',
            'Podiatry',
            'Psychiatry',
            'Pulmonology',
            'Radiology',
            'Rheumatology',
            'Surgery',
            'Urology'
          ],
          onChanged: (value) {},
          borderRadius: kRadiusAll,
          defaultOption: "All Specialties",
          icon: const FaIcon(FontAwesomeIcons.stethoscope,
              color: MyColors.primary, size: 16),
        ),
        kGap10,

        // Availability filter
        CustomComplexDropDown(
          title: 'Availability',
          items: const [
            'Tomorrow, Oct 12',
            'Wednesday, Oct 13',
            'Thursday, Oct 14',
            'Friday, Oct 15',
            'Saturday, Oct 16',
            'Sunday, Oct 17',
            'Monday, Oct 18',
            'Tuesday, Oct 19',
            'Wednesday, Oct 20',
            'Thursday, Oct 21',
            'Friday, Oct 22',
            'Saturday, Oct 23',
            'Sunday, Oct 24',
            'Monday, Oct 25',
            'Tuesday, Oct 26',
            'Wednesday, Oct 27',
            'Thursday, Oct 28',
            'Friday, Oct 29',
          ],
          onChanged: (value) {},
          borderRadius: kRadiusAll,
          defaultOption: "Today, Oct 11",
          icon: const FaIcon(FontAwesomeIcons.calendar,
              color: MyColors.primary, size: 16),
        ),
        kGap10,

        // Search field
        CustomInputField(
          hintText: 'Search by name',
          onChanged: (value) {},
          keyboardType: TextInputType.text,
          errorText: null,
          height: 50,
          borderRadius: kRadiusAll,
          leadingWidget:
              const Icon(Icons.search, color: MyColors.primary, size: 20),
        ),
        kGap16,

        // Results section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available Doctors',
              style: kSectionTitle,
            ),
            Text(
              '${_doctors.length} found',
              style: const TextStyle(
                fontSize: Font.small,
                color: MyColors.primary,
              ),
            ),
          ],
        ),
        const SectionDivider(),
      ],
    );
  }

  Widget _buildCollapsedHeader() {
    return Padding(
      padding: kPaddH16V8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search field and filter buttons in a row
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: CustomInputField(
                  hintText: 'Search by name',
                  onChanged: (value) {},
                  keyboardType: TextInputType.text,
                  errorText: null,
                  borderRadius: kRadiusAll,
                  height: 50,
                  leadingWidget: const Icon(Icons.search,
                      color: MyColors.primary, size: 18),
                ),
              ),
              kGap8,
              _FilterIconButton(
                icon: const FaIcon(FontAwesomeIcons.stethoscope,
                    color: MyColors.primary, size: 16),
                onTap: () {
                  // Show specialty filter
                },
              ),
              kGap8,
              _FilterIconButton(
                icon: const FaIcon(FontAwesomeIcons.calendar,
                    color: MyColors.primary, size: 16),
                onTap: () {
                  // Show date filter
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 17) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }
}

class _FilterIconButton extends StatelessWidget {
  final FaIcon icon;
  final VoidCallback onTap;

  const _FilterIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MyColors.primary.withValues(alpha: 0.1),
        borderRadius: kRadiusAll,
      ),
      child: IconButton(
        icon: icon,
        onPressed: onTap,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
      ),
    );
  }
}
