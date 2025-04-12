import 'package:backend/backend.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/common/globals/globals.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:medtalk/common/widgets/custom_input_field.dart';
import 'package:medtalk/patient/search_doctors/bloc/setup_appointment_bloc.dart';
import 'package:medtalk/patient/search_doctors/screens/appointment_confirmed_screen.dart';
import 'package:medtalk/patient/search_doctors/screens/setup_appointments/widgets/improved_date_time.dart';
import 'package:medtalk/patient/search_doctors/screens/setup_appointments/widgets/improved_doctor_profile.dart';
import 'package:medtalk/patient/search_doctors/screens/setup_appointments/widgets/improved_service_selection.dart';
import 'package:medtalk/patient/search_doctors/screens/setup_appointments/widgets/improved_stepper_header.dart';
import 'package:medtalk/patient/search_doctors/screens/setup_appointments/widgets/improved_summary.dart';
import 'package:medtalk/patient/search_doctors/screens/setup_appointments/widgets/utils.dart';
import 'package:medtalk/styles/styles/button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/widgets/dummy/profile_picture.dart';
import '../../../../doctor/design/models/design_models.dart';
import '../../../../styles/colors.dart';
import '../../../../styles/font.dart';
import '../../../../styles/sizes.dart';
import '../../../../styles/styles/text.dart';
import '../../models/search_doctors_models.dart';
import '../../models/selection_item.dart';

class SetupAppointmentScreen extends StatefulWidget {
  const SetupAppointmentScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
  });

  final String doctorId;
  final String doctorName;
  final String specialty;

  static Route<void> route({
    required String doctorId,
    required doctorName,
    required String specialty,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => SetupAppointmentScreen(
        doctorId: doctorId,
        doctorName: doctorName,
        specialty: specialty,
      ),
    );
  }

  @override
  State<SetupAppointmentScreen> createState() => _SetupAppointmentScreenState();
}

class _SetupAppointmentScreenState extends State<SetupAppointmentScreen> {
  bool _isBookingFlow = false;
  int _currentStep = 0;
  final int _totalSteps = 5; // Changed from 4 to 5
  final List<String> _stepTitles = [
    'Service Type',
    'Appointment Type',
    'Date & Time',
    'Payment Type', // New step
    'Review', // Renamed from "Payment & Review"
  ];

  final PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startBookingFlow() {
    setState(() {
      _isBookingFlow = true;
      _currentStep = 0;
    });
  }

  void _goToNextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
        _pageController.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _pageController.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    } else {
      // At first step, exit booking flow
      setState(() {
        _isBookingFlow = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SetupAppointmentBloc(
        mailRepository: getIt<IMailRepository>(),
        appointmentRepository: getIt<IAppointmentRepository>(),
        authenticationRepository: getIt<IAuthenticationRepository>(),
        doctorRepository: getIt<IDoctorRepository>(),
      )..add(LoadInitialData(
          widget.doctorId,
          widget.specialty,
        )),
      child: BlocConsumer<SetupAppointmentBloc, SetupAppointmentState>(
        listener: (context, state) {
          // Handle navigation on successful booking
          if (state.bookingComplete) {
            AppGlobal.navigatorKey.currentState!.pushAndRemoveUntil(
              AppointmentConfirmedScreen.route(state),
              (route) => route.isFirst,
            );
          }

          // Handle errors
          if (state.error.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<SetupAppointmentBloc>().add(
                        LoadInitialData(widget.doctorId, widget.specialty));
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: MyColors.background,
            appBar: AppBar(
              elevation: 0,
              toolbarHeight: kToolbarHeight,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              backgroundColor: MyColors.cardBackground,
              title: Text(
                _isBookingFlow ? 'Book Appointment' : 'Doctor Profile',
                style: const TextStyle(
                  color: MyColors.textBlack,
                  fontSize: Font.mediumSmall,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  _isBookingFlow && _currentStep > 0
                      ? Icons.arrow_back_ios_new
                      : Icons.arrow_back,
                  color: MyColors.textBlack,
                ),
                onPressed: () {
                  if (_isBookingFlow) {
                    _goToPreviousStep();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
              bottom: _isBookingFlow
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(8),
                      child: SizedBox(
                        width: double.infinity,
                        height: 4,
                        child: Row(
                          children: List.generate(
                            _totalSteps,
                            (index) => Expanded(
                              child: Container(
                                color: index <= _currentStep
                                    ? MyColors.primary
                                    : Colors.grey[300],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
            body: state.isLoading
                ? _buildLoadingState()
                : SafeArea(
                    child: _isBookingFlow
                        ? _buildBookingFlow(context, state)
                        : _buildDoctorInfoView(context, state),
                  ),
            bottomNavigationBar: _isBookingFlow
                ? _buildBookingNavigationBar(context, state)
                : _buildBookAppointmentButton(context),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: kPaddH20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          kGap20,

          // Doctor profile skeleton
          _buildDoctorProfileSkeleton(),

          kGap30,

          // Biography skeleton
          _buildBiographySkeleton(),

          kGap30,

          // Services skeleton
          _buildServicesSkeleton(),

          kGap20,

          // Location skeleton
          _buildLocationSkeleton(),

          kGap30,

          // Clinic details skeleton
          _buildClinicDetailsSkeleton(),

          kGap30,

          _buildPatientReviewsSkeleton(),

          kGap80,
        ],
      ),
    );
  }

  Widget _buildDoctorProfileSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MyColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Profile picture skeleton
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(14),
            ),
          ),

          kGap16,

          // Doctor info skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name skeleton
                Container(
                  width: 150,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                kGap8,

                // Specialty skeleton
                Container(
                  width: 100,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                kGap8,

                // Reviews skeleton
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),

          // Arrow icon skeleton
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiographySkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title skeleton
        Container(
          width: 100,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        kGap16,

        // Biography paragraph skeletons

        CustomBase(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < 3; i++) ...[
                Container(
                  width: double.infinity,
                  height: 14,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
              Container(
                width: MediaQuery.of(AppGlobal.navigatorKey.currentContext!)
                        .size
                        .width *
                    0.7,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title skeleton
        Container(
          width: 100,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        kGap16,

        // Service cards skeleton
        for (int i = 0; i < 2; i++) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MyColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Service title skeleton
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 150,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),

                        kGap8,

                        // Service duration skeleton
                        Container(
                          width: 80,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),

                    // Price skeleton
                    Container(
                      width: 60,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),

                kGap12,

                // Service tags skeleton
                Row(
                  children: [
                    for (int j = 0; j < 2; j++) ...[
                      Container(
                        width: 80,
                        height: 24,
                        margin: EdgeInsets.only(right: j < 1 ? 4 : 0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ],
                ),

                kGap12,

                // Description skeleton
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title skeleton
        Container(
          width: 100,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        kGap14,

        // Map skeleton
        Container(
          height: 175,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: Center(
            child: FaIcon(
              FontAwesomeIcons.mapLocationDot,
              color: Colors.grey[400],
              size: 40,
            ),
          ),
        ),

        kGap10,

        // Address skeleton
        Row(
          children: [
            // Icon skeleton
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            kGap8,

            // Address text skeleton
            Expanded(
              child: Container(
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            // Directions button skeleton
            Container(
              width: 100,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClinicDetailsSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title skeleton
        Container(
          width: 120,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        kGap14,

        // Phone number skeleton
        Row(
          children: [
            // Icon skeleton
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            kGap10,

            // Phone number text skeleton
            Container(
              width: 120,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            const Spacer(),

            // Call button skeleton
            Container(
              width: 80,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPatientReviewsSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with "View All" skeleton
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Section title skeleton
            Container(
              width: 120,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // View all button skeleton
            Container(
              width: 60,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),

        kGap14,

        // Review card skeletons
        for (int i = 0; i < 2; i++) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MyColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar skeleton
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                    ),

                    kGap10,

                    // Name and date skeleton
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          kGap4,
                          Container(
                            width: 80,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                kGap10,

                // Review text skeleton
                for (int j = 0; j < 2; j++) ...[
                  Container(
                    width: double.infinity,
                    height: 14,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],

                Container(
                  width: MediaQuery.of(AppGlobal.navigatorKey.currentContext!)
                          .size
                          .width *
                      0.5,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Doctor profile and info view
  Widget _buildDoctorInfoView(
      BuildContext context, SetupAppointmentState state) {
    return Padding(
      padding: kPaddH20,
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: kGap20,
          ),
          // Doctor profile header
          SliverToBoxAdapter(
            child: ImprovedDoctorProfile(
              doctorName: widget.doctorName,
              specialty: widget.specialty,
              reviewCount: state.doctorReviews.length,
              onViewProfileTap: () {
                // show bottom sheet with info such as qualificans and age and ...
              },
            ),
          ),

          const SliverToBoxAdapter(
            child: kGap30,
          ),

          // Biography section
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Biography',
                  style: kSectionTitle,
                ),
                kGap16,
                CustomBase(
                  child: Text(
                    state.doctorBiography ?? 'No biography available.',
                    style: const TextStyle(
                      fontSize: Font.small,
                      color: MyColors.textBlack,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(
            child: kGap30,
          ),

          // Services section
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Services',
                  style: kSectionTitle,
                ),
                kGap16,
                ...state.doctorServices.map((service) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildServiceCard(service),
                  );
                }),
              ],
            ),
          ),

          const SliverToBoxAdapter(
            child: kGap20,
          ),

          // Clinic Location
          SliverToBoxAdapter(
            child: _buildClinicLocation(state),
          ),

          const SliverToBoxAdapter(
            child: kGap30,
          ),

          // Clinic Details
          SliverToBoxAdapter(
            child: _buildClinicDetails(state),
          ),

          const SliverToBoxAdapter(
            child: kGap30,
          ),

          // Patient Reviews
          SliverToBoxAdapter(
            child: _buildPatientReviews(state),
          ),

          // Extra space at bottom for better scrolling
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(DoctorService service) {
    String durationText = '';
    if (service.duration < 60) {
      durationText = '${service.duration} mins';
    } else if (service.duration == 60) {
      durationText = '1 hr';
    } else {
      final hours = service.duration ~/ 60;
      final minutes = service.duration % 60;
      if (minutes == 0) {
        durationText = '$hours hrs';
      } else {
        durationText = '$hours hr $minutes mins';
      }
    }

    // Check if this service has custom availability
    bool hasCustomAvailability =
        service.id == '3'; // This is mocked in the bloc for service id '3'

    return CustomBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: const TextStyle(
                        fontSize: Font.mediumSmall,
                        fontWeight: FontWeight.bold,
                        color: MyColors.textBlack,
                      ),
                    ),
                    kGap4,
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: MyColors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.clock,
                                size: 12,
                                color: MyColors.textGrey,
                              ),
                              kGap4,
                              Text(
                                durationText,
                                style: const TextStyle(
                                  fontSize: Font.extraSmall,
                                  fontWeight: FontWeight.w500,
                                  color: MyColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Show custom availability indicator if applicable
                        if (hasCustomAvailability)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple[100],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.calendarDay,
                                    size: 12,
                                    color: Colors.purple[800],
                                  ),
                                  kGap4,
                                  Text(
                                    'Custom Hours',
                                    style: TextStyle(
                                      fontSize: Font.extraSmall,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.purple[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: MyColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '\$${service.price}',
                  style: const TextStyle(
                    fontSize: Font.small,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          // Appointment type tags
          kGap8,
          Row(
            children: [
              if (service.isInPerson)
                _buildServiceTag(
                  'In-person',
                  FontAwesomeIcons.hospitalUser,
                  MyColors.primary,
                ),
              if (service.isOnline)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: _buildServiceTag(
                    'Online',
                    FontAwesomeIcons.video,
                    MyColors.primary,
                  ),
                ),
              if (service.isHomeVisit)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: _buildServiceTag(
                    'Home Visit',
                    FontAwesomeIcons.house,
                    MyColors.primary,
                  ),
                ),
            ],
          ),

          // Service description
          if (service.description.isNotEmpty) ...[
            kGap12,
            Text(
              service.description,
              style: TextStyle(
                fontSize: Font.small,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Pre-appointment instructions
          if (service.preAppointmentInstructions != null &&
              service.preAppointmentInstructions!.isNotEmpty) ...[
            kGap12,
            InkWell(
              onTap: () {
                // Show full instructions in a dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.circleInfo,
                          color: Colors.blue,
                          size: 20,
                        ),
                        kGap10,
                        Text('Pre-appointment Inst.',
                            style: TextStyle(
                              fontSize: Font.mediumSmall,
                              fontWeight: FontWeight.bold,
                              color: MyColors.textBlack,
                            )),
                      ],
                    ),
                    content: Text(service.preAppointmentInstructions!,
                        style: const TextStyle(
                          fontSize: Font.smallExtra,
                          color: MyColors.textBlack,
                        )),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.circleInfo,
                      color: Colors.blue,
                      size: 14,
                    ),
                    kGap6,
                    Flexible(
                      child: Text(
                        'Pre-appointment instructions available',
                        style: TextStyle(
                          fontSize: Font.extraSmall,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    kGap6,
                    FaIcon(
                      FontAwesomeIcons.angleRight,
                      color: Colors.blue[700],
                      size: 12,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceTag(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            icon,
            size: 12,
            color: color,
          ),
          kGap4,
          Text(
            text,
            style: TextStyle(
              fontSize: Font.extraSmall,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicLocation(SetupAppointmentState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: kSectionTitle,
        ),
        kGap14,
        CustomBase(
          padding: kPadd0,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: MyColors.grey, width: 1.5),
                  borderRadius: kRadius10,
                  color: Colors.grey[300],
                ),
                height: 175,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: kRadius10,
                  child: GoogleMap(
                    // disable dragging
                    scrollGesturesEnabled: false,
                    // initial location
                    markers: {
                      Marker(
                        markerId: const MarkerId('clinic'),
                        position: state.doctorLocation ??
                            const LatLng(45.521563, -122.677433),
                        infoWindow: InfoWindow(
                          title: 'Clinic',
                          snippet: state.doctorAddress,
                        ),
                      ),
                    },
                    initialCameraPosition: CameraPosition(
                      target: state.doctorLocation ??
                          const LatLng(45.521563, -122.677433),
                      zoom: 14.0,
                    ),
                  ),
                ),
              ),
              kGap4,
              Padding(
                padding: kPaddH10V4,
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: MyColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.mapLocation,
                        color: MyColors.primary,
                        size: 16,
                      ),
                    ),
                    kGap8,
                    Expanded(
                      child: Text(
                        state.doctorAddress ?? 'Address not available',
                        style: const TextStyle(
                          fontSize: Font.small,
                          color: MyColors.textBlack,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Open in Maps app
                        final url =
                            'https://www.google.com/maps/search/?api=1&query=${state.doctorLocation?.latitude},${state.doctorLocation?.longitude}';
                        launchUrl(Uri.parse(url));
                      },
                      visualDensity: VisualDensity.compact,
                      icon: const FaIcon(
                        FontAwesomeIcons.locationArrow,
                        size: 14,
                        color: MyColors.primary,
                      ),
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: MyColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClinicDetails(SetupAppointmentState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Clinic Details',
          style: kSectionTitle,
        ),
        kGap16,
        CustomBase(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: MyColors.primary.withValues(alpha: 0.25),
                      borderRadius: kRadiusAll,
                    ),
                    width: 30,
                    height: 30,
                    padding: kPadd4,
                    alignment: Alignment.center,
                    child: const FaIcon(
                      FontAwesomeIcons.phone,
                      color: MyColors.primary,
                      size: 16,
                    ),
                  ),
                  kGap10,
                  Text(
                    state.doctorPhone ?? 'Phone not available',
                    style: const TextStyle(
                      fontSize: Font.small,
                      color: MyColors.textBlack,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      // Call the doctor - would add implementation
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.phone,
                      size: 14,
                      color: MyColors.primary,
                    ),
                    label: const Text(
                      'Call',
                      style: TextStyle(
                        fontSize: Font.small,
                        color: MyColors.primary,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: MyColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
              if (state.doctorNotes?.isNotEmpty ?? false) ...[
                kGap10,
                // extra notes
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: kPadd4,
                      decoration: BoxDecoration(
                        color: MyColors.primary.withValues(alpha: 0.25),
                        borderRadius: kRadiusAll,
                      ),
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      child: const FaIcon(
                        FontAwesomeIcons.circleInfo,
                        color: MyColors.primary,
                        size: 16,
                      ),
                    ),
                    kGap10,
                    Expanded(
                      child: Text(
                        state.doctorNotes!,
                        style: const TextStyle(
                          fontSize: Font.small,
                          color: MyColors.textBlack,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showCardSelectionBottomSheet(
      SetupAppointmentBloc setupAppointmentBloc) {
    final state = setupAppointmentBloc.state;
    final savedCards = state.savedCreditCards ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        decoration: const BoxDecoration(
          color: MyColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[500],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            const Padding(
              padding: kPaddH20V10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: Font.mediumSmall,
                      fontWeight: FontWeight.bold,
                      color: MyColors.textBlack,
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            const Divider(height: 1),

            // Cards list or empty state
            // Card list
            Expanded(
              child: savedCards.isEmpty
                  ? _buildEmptyCreditCardState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shrinkWrap: true,
                      itemCount: savedCards.length,
                      itemBuilder: (context, index) => _buildCreditCardItem(
                          savedCards[index],
                          bottomSheetContext,
                          setupAppointmentBloc),
                    ),
            ),

            // Add new card button - always shown at the bottom
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(bottomSheetContext);
                  _showAddCardDialog(setupAppointmentBloc);
                },
                style: kElevatedButtonCommonStyle,
                icon: const FaIcon(FontAwesomeIcons.creditCard, size: 16),
                label: const Text(
                  'Add New Card',
                  style: TextStyle(
                    fontSize: Font.mediumSmall,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            kGap20,
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardItem(
      SavedCreditCard card,
      BuildContext bottomSheetContext,
      SetupAppointmentBloc setupAppointmentBloc) {
    // Get card icon and color based on card type
    IconData cardIcon;
    Color cardColor;

    final bool isSelected =
        setupAppointmentBloc.state.selectedCardId == card.id;

    switch (card.cardType.toLowerCase()) {
      case 'visa':
        cardIcon = FontAwesomeIcons.ccVisa;
        cardColor = Colors.blue[700]!;
        break;
      case 'mastercard':
        cardIcon = FontAwesomeIcons.ccMastercard;
        cardColor = Colors.orange[800]!;
        break;
      case 'amex':
      case 'american express':
        cardIcon = FontAwesomeIcons.ccAmex;
        cardColor = Colors.indigo[600]!;
        break;
      case 'discover':
        cardIcon = FontAwesomeIcons.ccDiscover;
        cardColor = Colors.red[700]!;
        break;
      default:
        cardIcon = FontAwesomeIcons.creditCard;
        cardColor = Colors.grey[700]!;
    }

    return InkWell(
      onTap: () {
        // Use the passed bloc to update the selection
        setupAppointmentBloc.add(SelectCreditCard(card.id));
        Navigator.pop(bottomSheetContext);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? MyColors.primary.withValues(alpha: 0.1)
              : MyColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? MyColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Card design - more visually appealing representation of the card
            Container(
              width: 80,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cardColor,
                    cardColor.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: cardColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FaIcon(
                    cardIcon,
                    size: 16,
                    color: Colors.white,
                  ),
                  Text(
                    card.cardNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            kGap16,

            // Card details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        card.cardType,
                        style: TextStyle(
                          fontSize: Font.mediumSmall,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? MyColors.primary
                              : MyColors.textBlack,
                        ),
                      ),
                      if (card.isDefault) ...[
                        kGap8,
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: MyColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Default',
                            style: TextStyle(
                              fontSize: Font.extraSmall,
                              fontWeight: FontWeight.bold,
                              color: MyColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  kGap4,
                  Text(
                    '•••• •••• •••• ${card.cardNumber}',
                    style: TextStyle(
                      fontSize: Font.small,
                      color: isSelected
                          ? MyColors.primary.withValues(alpha: 0.8)
                          : MyColors.textGrey,
                    ),
                  ),
                  kGap2,
                  Row(
                    children: [
                      Text(
                        'Expires ${card.expiryDate}',
                        style: TextStyle(
                          fontSize: Font.extraSmall,
                          color: isSelected
                              ? MyColors.primary.withValues(alpha: 0.8)
                              : MyColors.textGrey,
                        ),
                      ),
                      kGap8,
                      Text(
                        card.cardholderName,
                        style: TextStyle(
                          fontSize: Font.extraSmall,
                          color: isSelected
                              ? MyColors.primary.withValues(alpha: 0.8)
                              : MyColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Selection indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? MyColors.primary : Colors.white,
                border: Border.all(
                  color: isSelected ? MyColors.primary : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: FaIcon(
                        FontAwesomeIcons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

// Enhanced empty state design
  Widget _buildEmptyCreditCardState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: MyColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: -0.2,
                      child: Container(
                        width: 60,
                        height: 40,
                        decoration: BoxDecoration(
                          color: MyColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    FaIcon(
                      FontAwesomeIcons.creditCard,
                      size: 32,
                      color: MyColors.primary.withValues(alpha: 0.8),
                    ),
                    Positioned(
                      right: 20,
                      bottom: 35,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent[400],
                          shape: BoxShape.circle,
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.plus,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            kGap20,
            const Text(
              'No saved cards',
              style: TextStyle(
                fontSize: Font.mediumSmall,
                fontWeight: FontWeight.bold,
                color: MyColors.textBlack,
              ),
            ),
            kGap12,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Add a credit card to make secure payments for your medical appointments',
                style: TextStyle(
                  fontSize: Font.small,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            kGap20,
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.security,
                size: 30,
                color: Colors.blue[800],
              ),
            ),
            kGap12,
            Text(
              'Your payment info is secure',
              style: TextStyle(
                fontSize: Font.small,
                color: Colors.blue[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

// Enhanced Add Card UI
  void _showAddCardDialog(SetupAppointmentBloc setupAppointmentBloc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 10,
        ),
        decoration: const BoxDecoration(
          color: MyColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add New Card',
                    style: TextStyle(
                      fontSize: Font.mediumSmall,
                      fontWeight: FontWeight.bold,
                      color: MyColors.textBlack,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    icon: const Icon(Icons.close),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),

              kGap20,

              // Card number field
              const Text(
                'Card Number',
                style: TextStyle(
                  fontSize: Font.small,
                  fontWeight: FontWeight.bold,
                  color: MyColors.textBlack,
                ),
              ),
              kGap8,
              CustomInputField(
                keyboardType: TextInputType.number,
                hintText: '1234 5678 9012 3456',
                onChanged: (String) {},
              ),

              kGap16,

              // Card holder name
              const Text(
                'Cardholder Name',
                style: TextStyle(
                  fontSize: Font.small,
                  fontWeight: FontWeight.bold,
                  color: MyColors.textBlack,
                ),
              ),
              kGap8,
              CustomInputField(
                hintText: 'Name as appears on card',
                keyboardType: TextInputType.name,
                onChanged: (String) {},
              ),

              kGap16,

              // Expiry and CVV
              Row(
                children: [
                  // Expiry date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Expiry Date',
                          style: TextStyle(
                            fontSize: Font.small,
                            fontWeight: FontWeight.bold,
                            color: MyColors.textBlack,
                          ),
                        ),
                        kGap8,
                        CustomInputField(
                          keyboardType: TextInputType.number,
                          hintText: 'MM/YY',
                          onChanged: (String) {},
                        ),
                      ],
                    ),
                  ),

                  kGap12,

                  // CVV
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CVV',
                          style: TextStyle(
                            fontSize: Font.small,
                            fontWeight: FontWeight.bold,
                            color: MyColors.textBlack,
                          ),
                        ),
                        kGap8,
                        CustomInputField(
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          hintText: '123',
                          onChanged: (String) {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              kGap24,

              // Add card button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final newCard = SavedCreditCard(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      cardNumber: '1234',
                      cardholderName: 'John Smith',
                      expiryDate: '12/25',
                      cardType: 'Visa',
                    );

                    // Use the passed bloc
                    setupAppointmentBloc.add(AddCreditCard(newCard));
                    Navigator.pop(dialogContext);
                  },
                  style: kElevatedButtonCommonStyle,
                  child: const Text(
                    'Add Card',
                    style: TextStyle(
                      fontSize: Font.mediumSmall,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              kGap20,

              // Security note
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.shieldHalved,
                    size: 14,
                    color: Colors.grey[700],
                  ),
                  kGap8,
                  Text(
                    'Your payment information is secure and encrypted',
                    style: TextStyle(
                      fontSize: Font.extraSmall,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientReviews(SetupAppointmentState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Patient Reviews',
              style: kSectionTitle,
            ),
            if (state.doctorReviews.length > 2)
              TextButton(
                onPressed: () {
                  // View all reviews
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: Font.small,
                    color: MyColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        kGap14,
        if (state.doctorReviews.isEmpty)
          Container(
            height: 100,
            padding: kPadd20,
            decoration: BoxDecoration(
              color: MyColors.blueGrey.withValues(alpha: 0.1),
              borderRadius: kRadius10,
            ),
            child: const Center(
              child: Text(
                'No reviews yet.',
                style: TextStyle(
                  fontSize: Font.small,
                  color: Colors.grey,
                ),
              ),
            ),
          )
        else
          Column(
            children: [
              if (state.doctorReviews.isNotEmpty)
                _buildReviewCard(state.doctorReviews.first),
              if (state.doctorReviews.length > 1) ...[
                kGap12,
                _buildReviewCard(state.doctorReviews.elementAt(1)),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildReviewCard(PatientReview review) {
    return CustomBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ProfilePicture(
                width: 36,
                height: 36,
              ),
              kGap10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.author,
                      style: const TextStyle(
                        fontSize: Font.small,
                        fontWeight: FontWeight.bold,
                        color: MyColors.textBlack,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy').format(review.date),
                      style: TextStyle(
                        fontSize: Font.extraSmall,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          kGap10,
          Text(
            review.text,
            style: TextStyle(
              fontSize: Font.small,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // Booking flow related widgets
  Widget _buildBookingFlow(BuildContext context, SetupAppointmentState state) {
    return Column(
      children: [
        // Stepper header
        ImprovedStepperHeader(
          currentStep: _currentStep,
          totalSteps: _totalSteps,
          stepTitles: _stepTitles,
        ),

        // Main content area
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Page 1: Choose Service Type
              _buildServiceTypePage(context, state),

              // Page 2: Choose Appointment Type
              _buildAppointmentTypePage(context, state),

              // Page 3: Choose Date and Time
              _buildDateTimePage(context, state),

              // Page 4: Choose Payment Type (new)
              _buildPaymentTypePage(context, state),

              // Page 4: Review and Confirm
              _buildSummaryPage(context, state),
            ],
          ),
        ),
      ],
    );
  }

  // Add the new payment type page builder:
  Widget _buildPaymentTypePage(
      BuildContext context, SetupAppointmentState state) {
    if (state.selectedService == null ||
        state.selectedAppointment == null ||
        state.appointmentDate == null ||
        state.appointmentTime == null) {
      return _buildErrorWithBackButton(
        'Missing information',
        'Please go back and complete previous steps first.',
      );
    }

    // Get available payment methods
    List<SelectionItem> paymentOptions = [];

    if (state.acceptsCash) {
      paymentOptions.add(SelectionItem(
        title: 'Cash',
        subtitle: 'Pay at the clinic',
        value: PaymentType.cash,
      ));
    }

    if (state.acceptsCreditCard) {
      paymentOptions.add(SelectionItem(
        title: 'Credit Card',
        subtitle: 'Pay securely online',
        value: PaymentType.creditCard,
      ));
    }

    if (state.acceptsInsurance) {
      paymentOptions.add(SelectionItem(
        title: 'Insurance',
        subtitle: 'Use your health insurance',
        value: PaymentType.insurance,
      ));
    }

    // Add a default payment option if none are available
    if (paymentOptions.isEmpty) {
      paymentOptions.add(SelectionItem(
        title: 'Cash',
        subtitle: 'Pay at the clinic',
        value: PaymentType.cash,
      ));
    }

    final setupAppointmentBloc = context.read<SetupAppointmentBloc>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Appointment details summary
          CustomBase(
            child: Column(
              children: [
                // Service info
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: MyColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: FaIcon(
                          FontAwesomeIcons.kitMedical,
                          size: 16,
                          color: MyColors.primary,
                        ),
                      ),
                    ),
                    kGap12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.selectedService!.title,
                            style: const TextStyle(
                              fontSize: Font.mediumSmall,
                              fontWeight: FontWeight.bold,
                              color: MyColors.textBlack,
                            ),
                          ),
                          Text(
                            state.selectedService!.subtitle,
                            style: TextStyle(
                              fontSize: Font.small,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: MyColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '\$${state.selectedService!.price}',
                        style: const TextStyle(
                          fontSize: Font.small,
                          fontWeight: FontWeight.bold,
                          color: MyColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                kGap12,
                const Divider(height: 1, thickness: 1),
                kGap12,
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: MyColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: FaIcon(
                          _getAppointmentTypeIcon(state.selectedAppointment!),
                          size: 16,
                          color: MyColors.primary,
                        ),
                      ),
                    ),
                    kGap12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.selectedAppointment!.value,
                            style: const TextStyle(
                              fontSize: Font.mediumSmall,
                              fontWeight: FontWeight.bold,
                              color: MyColors.textBlack,
                            ),
                          ),
                          Text(
                            state.appointmentLocation,
                            style: const TextStyle(
                              fontSize: Font.small,
                              color: MyColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                kGap12,
                const Divider(height: 1, thickness: 1),
                kGap12,
                // Date and time row
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: MyColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: FaIcon(
                          FontAwesomeIcons.calendarDay,
                          size: 16,
                          color: MyColors.primary,
                        ),
                      ),
                    ),
                    kGap12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Date & Time',
                            style: TextStyle(
                              fontSize: Font.mediumSmall,
                              fontWeight: FontWeight.bold,
                              color: MyColors.textBlack,
                            ),
                          ),
                          Text(
                            '${DateFormat('EEE, MMM d, yyyy').format(state.appointmentDate!)} at ${state.appointmentTime!.format(context)}',
                            style: const TextStyle(
                              fontSize: Font.small,
                              color: MyColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          kGap24,

          const Text(
            'Choose Payment Method',
            style: TextStyle(
              fontSize: Font.mediumSmall,
              fontWeight: FontWeight.bold,
              color: MyColors.textBlack,
            ),
          ),

          Text(
            'Select how you would like to pay for this appointment',
            style: TextStyle(
              fontSize: Font.small,
              color: Colors.grey[600],
            ),
          ),

          kGap20,

          // Payment options
          ...paymentOptions.map((option) {
            final bool isSelected = state.selectedPayment == option.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  // Check if this is the credit card option
                  if (option.value == PaymentType.creditCard) {
                    // Pass the bloc to the bottom sheet
                    _showCardSelectionBottomSheet(setupAppointmentBloc);
                  } else {
                    // For other payment methods, use the already captured bloc
                    setupAppointmentBloc
                        .add(UpdatePaymentType(option.value as PaymentType));
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: kPadd20,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? MyColors.primary.withValues(alpha: 0.05)
                        : MyColors.cardBackground,
                    borderRadius: kRadius16,
                    border: Border.all(
                      color: isSelected ? MyColors.primary : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: MyColors.primary.withValues(alpha: 0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? MyColors.primary.withValues(alpha: 0.1)
                              : MyColors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: FaIcon(
                            _getPaymentTypeIcon(option.title),
                            color: isSelected
                                ? MyColors.primary
                                : MyColors.textGrey,
                            size: 24,
                          ),
                        ),
                      ),
                      kGap16,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.title,
                              style: TextStyle(
                                fontSize: Font.mediumSmall,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? MyColors.primary
                                    : MyColors.textBlack,
                              ),
                            ),
                            kGap4,
                            Text(
                              option.subtitle,
                              style: TextStyle(
                                fontSize: Font.small,
                                color: isSelected
                                    ? MyColors.primary
                                    : MyColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? MyColors.primary : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? MyColors.primary
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: isSelected
                            ? const Center(
                                child: FaIcon(
                                  FontAwesomeIcons.check,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Add helper method for payment icons
  IconData _getPaymentTypeIcon(String paymentType) {
    switch (paymentType.toLowerCase()) {
      case 'cash':
        return FontAwesomeIcons.moneyBill;
      case 'credit card':
        return FontAwesomeIcons.creditCard;
      case 'insurance':
        return FontAwesomeIcons.fileInvoice;
      default:
        return FontAwesomeIcons.wallet;
    }
  }

  Widget _buildServiceTypePage(
      BuildContext context, SetupAppointmentState state) {
    if (state.doctorServices.isEmpty) {
      return const ServiceLoadingSkeleton();
    }

    final List<SelectionItem> services = state.doctorServices.map((service) {
      String durationText = '';
      if (service.duration < 60) {
        durationText = '${service.duration} mins';
      } else if (service.duration == 60) {
        durationText = '1 hr';
      } else {
        final hours = service.duration ~/ 60;
        final minutes = service.duration % 60;
        if (minutes == 0) {
          durationText = '$hours hrs';
        } else {
          durationText = '$hours hr $minutes mins';
        }
      }

      return SelectionItem(
        title: service.title,
        subtitle: durationText,
        price: service.price,
        value: service.id,
        description: service.description,
        hasInPerson: service.isInPerson,
        hasOnline: service.isOnline,
        hasHomeVisit: service.isHomeVisit,
        preAppointmentInstructions: service.preAppointmentInstructions,
      );
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor summary
          CustomBase(
            child: Row(
              children: [
                const ProfilePicture(width: 50, height: 50),
                kGap16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.doctorName,
                        style: const TextStyle(
                          fontSize: Font.mediumSmall,
                          fontWeight: FontWeight.bold,
                          color: MyColors.primary,
                        ),
                      ),
                      Text(
                        widget.specialty,
                        style: TextStyle(
                          fontSize: Font.small,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          kGap24,

          // Main title
          const Text(
            'Select a Service',
            style: TextStyle(
              fontSize: Font.mediumSmall,
              fontWeight: FontWeight.bold,
              color: MyColors.textBlack,
            ),
          ),
          const Text(
            'Choose the type of consultation you need',
            style: TextStyle(
              fontSize: Font.small,
              color: MyColors.textGrey,
            ),
          ),
          kGap20,

          // Service selection
          ImprovedServiceSelection(
            services: services,
            selectedIndex: state.serviceIndex,
            onSelected: (service, index) {
              context
                  .read<SetupAppointmentBloc>()
                  .add(UpdateServiceType(service));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentTypePage(
      BuildContext context, SetupAppointmentState state) {
    if (state.selectedService == null) {
      return _buildErrorWithBackButton(
        'Please select a service first.',
        'Go back and select a service to continue.',
      );
    }

    // Filter appointment types based on selected service
    List<SelectionItem> appointmentTypes = [];

    if (state.selectedService!.hasInPerson) {
      appointmentTypes.add(SelectionItem(
        title: "In Person",
        subtitle: state.doctorAddress ?? 'Clinic',
        value: AppointmentType.inPerson,
      ));
    }

    if (state.selectedService!.hasOnline) {
      appointmentTypes.add(SelectionItem(
        title: "Online",
        subtitle: 'Video Call',
        value: AppointmentType.online,
      ));
    }

    if (state.selectedService!.hasHomeVisit) {
      appointmentTypes.add(SelectionItem(
        title: "Home Visit",
        subtitle: 'Your Home',
        value: AppointmentType.homeVisit,
      ));
    }

    if (appointmentTypes.isEmpty) {
      return _buildErrorWithBackButton(
        'No appointment types available',
        'This service doesn\'t have any available appointment types. Please select a different service.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomBase(
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: MyColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.kitMedical,
                      size: 16,
                      color: MyColors.primary,
                    ),
                  ),
                ),
                kGap12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.selectedService!.title,
                        style: const TextStyle(
                          fontSize: Font.mediumSmall,
                          fontWeight: FontWeight.bold,
                          color: MyColors.textBlack,
                        ),
                      ),
                      Text(
                        state.selectedService!.subtitle,
                        style: TextStyle(
                          fontSize: Font.small,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MyColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '\$${state.selectedService!.price}',
                    style: const TextStyle(
                      fontSize: Font.small,
                      fontWeight: FontWeight.bold,
                      color: MyColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          kGap24,

          const Text(
            'How would you like your appointment?',
            style: TextStyle(
              fontSize: Font.mediumSmall,
              fontWeight: FontWeight.bold,
              color: MyColors.textBlack,
            ),
          ),

          Text(
            'Select the appointment type that works best for you',
            style: TextStyle(
              fontSize: Font.small,
              color: Colors.grey[600],
            ),
          ),

          kGap20,

          // Pre-appointment instructions if available
          if (state.selectedService!.preAppointmentInstructions?.isNotEmpty ??
              false) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      shape: BoxShape.circle,
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.circleInfo,
                      color: Colors.blue,
                      size: 16,
                    ),
                  ),
                  kGap12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pre-appointment Instructions:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: Font.small,
                            color: Colors.blue,
                          ),
                        ),
                        kGap4,
                        Text(
                          state.selectedService!.preAppointmentInstructions ??
                              '',
                          style: TextStyle(
                            fontSize: Font.small,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            kGap24,
          ],

          // Appointment type selection
          ...appointmentTypes.map((item) {
            final bool isSelected = state.selectedAppointment == item.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  context
                      .read<SetupAppointmentBloc>()
                      .add(UpdateAppointmentType(
                        item.value as AppointmentType,
                        item.subtitle,
                      ));
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: kPadd20,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? MyColors.primary.withValues(alpha: 0.05)
                        : MyColors.cardBackground,
                    borderRadius: kRadius16,
                    border: Border.all(
                      color: isSelected ? MyColors.primary : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: MyColors.primary.withValues(alpha: 0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? MyColors.primary.withValues(alpha: 0.1)
                              : MyColors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: FaIcon(
                            _getAppointmentTypeIcon(
                                item.value as AppointmentType),
                            color: isSelected
                                ? MyColors.primary
                                : MyColors.textGrey,
                            size: 24,
                          ),
                        ),
                      ),
                      kGap16,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: Font.mediumSmall,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? MyColors.primary
                                    : MyColors.textBlack,
                              ),
                            ),
                            kGap4,
                            Text(
                              item.subtitle,
                              style: TextStyle(
                                fontSize: Font.small,
                                color: isSelected
                                    ? MyColors.primary
                                    : MyColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? MyColors.primary : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? MyColors.primary
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: isSelected
                            ? const Center(
                                child: FaIcon(
                                  FontAwesomeIcons.check,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDateTimePage(BuildContext context, SetupAppointmentState state) {
    if (state.selectedService == null || state.selectedAppointment == null) {
      return _buildErrorWithBackButton(
        'Missing information',
        'Please go back and complete previous steps first.',
      );
    }

    // Get the correct availability - use service-specific if available, otherwise use doctor's default
    final List<bool> availableDays =
        state.selectedServiceAvailability?.days ?? state.doctorAvailableDays;
    final List<WorkingHours> workingHours = List.of(state.doctorWorkingHours);

    // If there's custom service availability, override the working hours for each applicable day
    if (state.selectedServiceAvailability != null) {
      final customStart = state.selectedServiceAvailability!.startTime;
      final customEnd = state.selectedServiceAvailability!.endTime;

      // Modify working hours for each day that's available in the custom schedule
      for (int i = 0; i < availableDays.length; i++) {
        if (availableDays[i]) {
          // Create new working hours with custom time range
          workingHours[i] = WorkingHours(
            isWorking: true,
            startTime: customStart,
            endTime: customEnd,
            breaks: workingHours[i].breaks, // Keep existing breaks
          );
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomBase(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: MyColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: FaIcon(
                          FontAwesomeIcons.kitMedical,
                          size: 16,
                          color: MyColors.primary,
                        ),
                      ),
                    ),
                    kGap12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.selectedService!.title,
                            style: const TextStyle(
                              fontSize: Font.mediumSmall,
                              fontWeight: FontWeight.bold,
                              color: MyColors.textBlack,
                            ),
                          ),
                          Text(
                            state.selectedService!.subtitle,
                            style: TextStyle(
                              fontSize: Font.small,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: MyColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '\$${state.selectedService!.price}',
                        style: const TextStyle(
                          fontSize: Font.small,
                          fontWeight: FontWeight.bold,
                          color: MyColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                kGap12,
                const Divider(height: 1, thickness: 1),
                kGap12,
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: MyColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: FaIcon(
                          _getAppointmentTypeIcon(state.selectedAppointment!),
                          size: 16,
                          color: MyColors.primary,
                        ),
                      ),
                    ),
                    kGap12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.selectedAppointment!.value,
                            style: const TextStyle(
                              fontSize: Font.mediumSmall,
                              fontWeight: FontWeight.bold,
                              color: MyColors.textBlack,
                            ),
                          ),
                          Text(
                            state.appointmentLocation,
                            style: const TextStyle(
                              fontSize: Font.small,
                              color: MyColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          kGap24,

          const Text(
            'Select Date & Time',
            style: TextStyle(
              fontSize: Font.mediumSmall,
              fontWeight: FontWeight.bold,
              color: MyColors.textBlack,
            ),
          ),

          Text(
            'Choose when you would like to schedule your appointment',
            style: TextStyle(
              fontSize: Font.small,
              color: Colors.grey[600],
            ),
          ),

          kGap20,

          // Date and time selection - pass the correct availability
          ImprovedDateTimeSelection(
            selectedDate: state.appointmentDate,
            selectedTime: state.appointmentTime,
            availableDays: availableDays,
            // Use service-specific days if available
            onDateChanged: (date) {
              context
                  .read<SetupAppointmentBloc>()
                  .add(UpdateAppointmentDate(date));
            },
            onTimeChanged: (time, index) {
              context
                  .read<SetupAppointmentBloc>()
                  .add(UpdateAppointmentTime(time));
            },
            doctorWorkingHours: workingHours,
            // Use modified working hours
            serviceDuration: state.selectedService!.value is int
                ? state.selectedService!.value as int
                : state.defaultSlotDuration,
            bufferTime: state.bufferTime,

            // Add indicator if using custom availability
            hasCustomAvailability: state.selectedServiceAvailability != null,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPage(BuildContext context, SetupAppointmentState state) {
    if (state.appointmentDate == null ||
        state.appointmentTime == null ||
        state.selectedService == null ||
        state.selectedAppointment == null ||
        state.selectedPayment == null) {
      return _buildErrorWithBackButton(
        'Incomplete information',
        'Please go back and complete all previous steps first.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ImprovedSummaryScreen(
        state: state,
        onConfirm: () {
          context.read<SetupAppointmentBloc>().add(BookAppointment());
        },
        onTermsChanged: (value) {
          context.read<SetupAppointmentBloc>().add(ToggleTermsAccepted(value));
        },
      ),
    );
  }

  Widget _buildErrorWithBackButton(String title, String message) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: EmptyStateWidget(
          title: title,
          message: message,
          icon: FontAwesomeIcons.circleExclamation,
          actionButton: ElevatedButton.icon(
            onPressed: _goToPreviousStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const FaIcon(
              FontAwesomeIcons.arrowLeft,
              size: 16,
            ),
            label: const Text('Go Back'),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingNavigationBar(
      BuildContext context, SetupAppointmentState state) {
    bool canProceed = false;

    // Determine if user can proceed based on current step
    switch (_currentStep) {
      case 0:
        canProceed = state.selectedService != null;
        break;
      case 1:
        canProceed = state.selectedAppointment != null;
        break;
      case 2:
        canProceed =
            state.appointmentDate != null && state.appointmentTime != null;
        break;
      case 3:
        canProceed = state.selectedPayment != null;
        break;
      case 4:
        canProceed = state.termsAccepted;
        break;
    }

    final isLastStep = _currentStep == _totalSteps - 1;

    return Container(
      padding: kPadd16,
      decoration: BoxDecoration(
        color: MyColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add terms checkbox only on the last step (summary page)
            if (isLastStep) ...[
              Row(
                children: [
                  Checkbox(
                    value: state.termsAccepted,
                    activeColor: MyColors.primary,
                    onChanged: (value) {
                      context
                          .read<SetupAppointmentBloc>()
                          .add(ToggleTermsAccepted(value ?? false));
                    },
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: Font.family,
                          fontSize: Font.small,
                          color: MyColors.textBlack,
                        ),
                        children: [
                          const TextSpan(
                            text: 'I have read and agree to the ',
                          ),
                          TextSpan(
                            text: 'Terms of Service',
                            style: const TextStyle(
                              color: MyColors.primary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Show terms of service
                              },
                          ),
                          const TextSpan(
                            text: ' and ',
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
                              color: MyColors.primary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Show privacy policy
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              kGap12,
            ],
            // Buttons row
            Row(
              children: [
                // Back button
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: _goToPreviousStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.grey.withValues(alpha: 0.2),
                      foregroundColor: MyColors.textGrey,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      disabledBackgroundColor:
                          MyColors.grey.withValues(alpha: 0.2),
                      disabledForegroundColor: MyColors.textGrey,
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        fontSize: Font.mediumSmall,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // Spacer between buttons
                kGap12,

                // Continue or Confirm button
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: canProceed
                        ? isLastStep
                            ? () {
                                context
                                    .read<SetupAppointmentBloc>()
                                    .add(BookAppointment());
                              }
                            : _goToNextStep
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      disabledBackgroundColor:
                          MyColors.grey.withValues(alpha: 0.2),
                      disabledForegroundColor: MyColors.textGrey,
                    ),
                    child: state.isBooking
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isLastStep ? 'Confirm Appointment' : 'Continue',
                            style: const TextStyle(
                              fontFamily: Font.family,
                              fontSize: Font.mediumSmall,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookAppointmentButton(BuildContext context) {
    return Container(
      padding: kPadd16,
      decoration: BoxDecoration(
        color: MyColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: _startBookingFlow,
          style: ElevatedButton.styleFrom(
            backgroundColor: MyColors.primary,
            foregroundColor: Colors.white,
            padding: kPaddV12,
            shape: RoundedRectangleBorder(
              borderRadius: kRadius12,
            ),
            elevation: 0,
          ),
          icon: const FaIcon(
            FontAwesomeIcons.calendarPlus,
            size: 16,
          ),
          label: const Text(
            'Book Appointment',
            style: TextStyle(
              fontFamily: Font.family,
              fontSize: Font.mediumSmall,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getAppointmentTypeIcon(AppointmentType appointmentType) {
    switch (appointmentType) {
      case AppointmentType.online:
        return FontAwesomeIcons.video;
      case AppointmentType.inPerson:
        return FontAwesomeIcons.hospitalUser;
      case AppointmentType.homeVisit:
        return FontAwesomeIcons.house;
    }
  }
}
