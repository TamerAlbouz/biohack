import 'package:backend/backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/common/widgets/dividers/section_divider.dart';
import 'package:medtalk/common/widgets/dropdown/custom_complex_dropdown.dart';
import 'package:medtalk/common/widgets/inifinite_list_view.dart';
import 'package:medtalk/patient/search_doctors/bloc/search_doctors_bloc.dart';
import 'package:medtalk/patient/search_doctors/screens/setup_appointment_screen.dart';
import 'package:medtalk/styles/sizes.dart';

import '../../../common/globals/globals.dart';
import '../../../common/widgets/cards/doctor_card.dart';
import '../../../common/widgets/custom_input_field.dart';
import '../../../styles/colors.dart';
import '../../../styles/font.dart';

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
                    return const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  // Show error message when in error state
                  if (state is SearchDoctorsError) {
                    return Expanded(
                      child: Center(child: Text(state.message)),
                    );
                  }

                  // Show the list when doctors are loaded
                  return InfiniteScrollListView(
                    controller: _infiniteScrollController,
                    isLoading: _isLoading,
                    hasReachedMax:
                        !_hasMoreData, // Note: the property is inverted in your implementation
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
                              doctorId: doctor.uid ?? '',
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
          'Search Doctors',
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: Font.sectionTitleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'Find the right doctor for you',
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: Font.small,
            color: MyColors.subtitleDark,
          ),
        ),
        const SectionDivider(),
        kGap10,
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
              color: MyColors.primary),
        ),
        kGap10,
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
          icon:
              const FaIcon(FontAwesomeIcons.calendar, color: MyColors.primary),
        ),
        kGap20,
        CustomInputField(
          hintText: 'Search by name',
          onChanged: (value) {},
          keyboardType: TextInputType.text,
          errorText: null,
          height: 50,
          borderRadius: kRadiusAll,
        ),
        kGap10,
        const SectionDivider(),
        kGap10,
      ],
    );
  }

  Widget _buildCollapsedHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomInputField(
            hintText: 'Search by name',
            onChanged: (value) {},
            keyboardType: TextInputType.text,
            errorText: null,
            borderRadius: kRadiusAll,
          ),
        ),
        kGap10,
        Container(
          decoration: BoxDecoration(
            color: MyColors.primary.withOpacity(0.2),
            borderRadius: kRadiusAll,
          ),
          child: IconButton(
            icon: const FaIcon(FontAwesomeIcons.stethoscope,
                color: MyColors.primary),
            onPressed: () {
              // Show specialty dropdown
            },
          ),
        ),
        kGap10,
        Container(
          decoration: BoxDecoration(
            color: MyColors.primary.withOpacity(0.2),
            borderRadius: kRadiusAll,
          ),
          child: IconButton(
            icon: const FaIcon(FontAwesomeIcons.calendar,
                color: MyColors.primary),
            onPressed: () {
              // Show date dropdown
            },
          ),
        ),
      ],
    );
  }
}
