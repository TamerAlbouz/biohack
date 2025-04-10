import 'package:backend/backend.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/common/globals/globals.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:medtalk/patient/search_doctors/bloc/setup_appointment_bloc.dart';
import 'package:medtalk/patient/search_doctors/screens/appointment_confirmed_screen.dart';
import 'package:medtalk/patient/search_doctors/screens/setup_appointments/widgets/improved_date_time.dart';
import 'package:medtalk/patient/search_doctors/screens/setup_appointments/widgets/improved_doctor_profile.dart';
import 'package:medtalk/patient/search_doctors/screens/setup_appointments/widgets/improved_service_selection.dart';
import 'package:medtalk/patient/search_doctors/screens/setup_appointments/widgets/improved_stepper_header.dart';
import 'package:medtalk/patient/search_doctors/screens/setup_appointments/widgets/improved_summary.dart';
import 'package:medtalk/patient/search_doctors/screens/setup_appointments/widgets/utils.dart';
import 'package:p_logger/p_logger.dart';

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
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: MyColors.primary,
          ),
          kGap16,
          Text(
            'Loading doctor information...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: Font.small,
            ),
          ),
        ],
      ),
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
                // No need to toggle, we're already showing the full profile
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
                Text(
                  state.doctorBiography ?? 'No biography available.',
                  style: const TextStyle(
                    fontSize: Font.small,
                    color: MyColors.textBlack,
                    height: 1.5,
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
        kGap10,
        Row(
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
            TextButton.icon(
              onPressed: () {
                // Open in Maps app - would add implementation
              },
              icon: const FaIcon(
                FontAwesomeIcons.locationArrow,
                size: 14,
                color: MyColors.primary,
              ),
              label: const Text(
                'Directions',
                style: TextStyle(
                  fontSize: Font.small,
                  color: MyColors.primary,
                ),
              ),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: MyColors.primary),
                ),
              ),
            ),
          ],
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
        kGap14,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                  logger.f(
                      'Selected payment type: ${option.title} (${option.value})');
                  context
                      .read<SetupAppointmentBloc>()
                      .add(UpdatePaymentType(option.value as PaymentType));
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
