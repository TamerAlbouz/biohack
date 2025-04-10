import 'package:backend/backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/common/globals/globals.dart';
import 'package:medtalk/common/widgets/radio/split_radio_group.dart';
import 'package:medtalk/patient/search_doctors/bloc/setup_appointment_bloc.dart';
import 'package:medtalk/patient/search_doctors/screens/appointment_confirmed_screen.dart';
import 'package:medtalk/patient/search_doctors/widgets/date_navigator.dart';
import 'package:medtalk/styles/sizes.dart';

import '../../../common/widgets/base/custom_base.dart';
import '../../../common/widgets/dividers/card_divider.dart';
import '../../../common/widgets/dummy/profile_picture.dart';
import '../../../common/widgets/pageview/custom_page_view.dart';
import '../../../doctor/design/models/design_models.dart';
import '../../../styles/colors.dart';
import '../../../styles/font.dart';
import '../../../styles/styles/button.dart';
import '../../../styles/styles/text.dart';
import '../models/selection_item.dart';
import '../widgets/selection_group.dart';
import '../widgets/services_widget.dart';

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
  bool reBuild = false;
  Color unselectedColor = MyColors.primary;
  late final CustomStepperController _stepperController;

  @override
  void initState() {
    super.initState();
    _stepperController = CustomStepperController(canSkipSteps: [
      false,
      false,
      false,
      false,
      true,
    ]);
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
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          title: const Text('Set-Up Appointment', style: kAppBarText),
          automaticallyImplyLeading: true,
        ),
        body: Padding(
          padding: kPaddT15,
          child: CustomBase(
            child: BlocBuilder<SetupAppointmentBloc, SetupAppointmentState>(
              builder: (context, state) {
                final bool showNewWidgets = state.reBuild;

                // reset stepper controller
                if (!showNewWidgets) {
                  _stepperController.reset();
                }

                return Column(
                  children: [
                    // Scrollable section
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: _DoctorProfile(
                              doctorName: widget.doctorName,
                              specialty: widget.specialty,
                            ),
                          ),
                          const SliverToBoxAdapter(child: CardDivider()),
                          SliverToBoxAdapter(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              layoutBuilder: (currentChild, previousChildren) {
                                return Stack(
                                  children: <Widget>[
                                    ...previousChildren,
                                    if (currentChild != null) currentChild,
                                  ],
                                );
                              },
                              switchInCurve: Curves.easeIn,
                              switchOutCurve: Curves.easeOut,
                              // Switch animation duration
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                    opacity: animation, child: child);
                              },
                              child: showNewWidgets
                                  ? CustomStepper(
                                      controller: _stepperController,
                                      steps: [
                                        _ChooseServiceType(
                                          controller: _stepperController,
                                        ),
                                        _ChooseAppointmentType(
                                          controller: _stepperController,
                                        ),
                                        _ChooseAppointmentDate(
                                          controller: _stepperController,
                                        ),
                                        _ChoosePaymentType(
                                          controller: _stepperController,
                                        ),
                                        _Summary(
                                          controller: _stepperController,
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        _Biography(doctorId: widget.doctorId),
                                        const CardDivider(),
                                        Services(doctorId: widget.doctorId),
                                        const CardDivider(),
                                        _ClinicLocation(
                                            doctorId: widget.doctorId),
                                        const CardDivider(),
                                        _ClinicDetails(
                                            doctorId: widget.doctorId),
                                        const CardDivider(),
                                        const _PatientReviewsScreen(),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showNewWidgets)
                      // Stepper buttons should always be at the bottom
                      CustomStepperControls(
                        onCanceled: () => context
                            .read<SetupAppointmentBloc>()
                            .add(ToggleRebuild()),
                        controller: _stepperController,
                      ),
                    if (!showNewWidgets)
                      // Book appointment button
                      const _BookAppointmentButton(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Biography extends StatelessWidget {
  final String doctorId;

  const _Biography({required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SetupAppointmentBloc, SetupAppointmentState>(
      builder: (context, state) {
        final String biography =
            state.doctorBiography ?? 'Loading doctor information...';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Biography',
              style: kSectionTitle,
            ),
            kGap10,
            Text(
              biography,
              style: kServiceCardText.copyWith(
                color: MyColors.black,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChooseServiceType extends StatelessWidget {
  final CustomStepperController controller;

  const _ChooseServiceType({required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SetupAppointmentBloc, SetupAppointmentState>(
      builder: (context, state) {
        if (state.doctorServices.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Service Type',
              style: kSectionTitle,
            ),
            kGap20,
            SelectionGroup(
              selectedIndex: controller.getStepResult(controller.currentStep),
              items: state.doctorServices.map((service) {
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
                  hasOnline: service.isOnline,
                  hasInPerson: service.isInPerson,
                  hasHomeVisit: service.isHomeVisit,
                  preAppointmentInstructions:
                      service.preAppointmentInstructions,
                );
              }).toList(),
              onSelected: (item, index) {
                context
                    .read<SetupAppointmentBloc>()
                    .add(UpdateServiceType(item));
                controller.updateStepResult(controller.currentStep, index);
                controller.markStepComplete();
              },
            ),
          ],
        );
      },
    );
  }
}

class _ChooseAppointmentType extends StatelessWidget {
  final CustomStepperController controller;

  const _ChooseAppointmentType({required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SetupAppointmentBloc, SetupAppointmentState>(
      builder: (context, state) {
        if (state.selectedService == null) {
          return const Center(
            child: Text('Please go back and select a service first.'),
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
          // Fallback if no appointment types are available
          return const Center(
            child: Text('No appointment types available for this service.'),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Appointment Type',
              style: kSectionTitle,
            ),
            kGap20,

            // Show pre-appointment instructions if available
            if (state.selectedService!.preAppointmentInstructions?.isNotEmpty ??
                false) ...[
              Container(
                padding: kPadd10,
                decoration: BoxDecoration(
                  color: MyColors.blueGrey.withValues(alpha: 0.1),
                  borderRadius: kRadius10,
                  border: Border.all(
                      color: MyColors.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.circleInfo,
                          color: MyColors.primary,
                          size: 16,
                        ),
                        kGap8,
                        Text(
                          'Pre-appointment Instructions',
                          style: TextStyle(
                            fontSize: Font.small,
                            fontWeight: FontWeight.bold,
                            color: MyColors.primary,
                          ),
                        ),
                      ],
                    ),
                    kGap8,
                    Text(
                      state.selectedService!.preAppointmentInstructions ?? '',
                      style: const TextStyle(
                        fontSize: Font.small,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              kGap20,
            ],

            SelectionGroup(
              selectedIndex: controller.getStepResult(controller.currentStep),
              items: appointmentTypes,
              onSelected: (item, index) {
                context.read<SetupAppointmentBloc>().add(UpdateAppointmentType(
                      item.value as AppointmentType,
                      item.subtitle,
                    ));
                controller.updateStepResult(controller.currentStep, index);
                controller.markStepComplete();
              },
            ),
          ],
        );
      },
    );
  }
}

class _ChooseAppointmentDate extends StatefulWidget {
  final CustomStepperController controller;

  const _ChooseAppointmentDate({required this.controller});

  @override
  State<_ChooseAppointmentDate> createState() => _ChooseAppointmentDateState();
}

class _ChooseAppointmentDateState extends State<_ChooseAppointmentDate> {
  Color unselectedColor = MyColors.selectionCardEmpty;
  Color unselectedTextColor = MyColors.textBlack;
  Color borderColor = MyColors.grey;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SetupAppointmentBloc, SetupAppointmentState>(
      builder: (context, state) {
        if (state.selectedService == null ||
            state.selectedAppointment == null) {
          return const Center(
            child: Text(
                'Please go back and select a service and appointment type first.'),
          );
        }

        // Get available days based on doctor's schedule and service availability
        List<bool> availableDays = state.doctorAvailableDays;

        // Check if service has custom availability
        if (state.selectedServiceAvailability != null) {
          // Override with service-specific availability
          availableDays = state.selectedServiceAvailability!.days;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Appointment Date',
              style: kSectionTitle,
            ),
            kGap20,
            EnhancedDateNavigationWidget(
              selectedDate: state.appointmentDate,
              onDateChanged: (date) {
                context
                    .read<SetupAppointmentBloc>()
                    .add(UpdateAppointmentDate(date));
              },
              availableDays: availableDays,
            ),

            // Available time slots
            if (state.appointmentDate != null) ...[
              kGap10,
              _buildTimeSlots(context, state, availableDays),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTimeSlots(BuildContext context, SetupAppointmentState state,
      List<bool> availableDays) {
    // Check if the selected date is available
    final selectedDay =
        state.appointmentDate!.weekday - 1; // 0 = Monday, 6 = Sunday
    if (!availableDays[selectedDay]) {
      return Container(
        padding: kPadd20,
        decoration: BoxDecoration(
          color: MyColors.blueGrey.withValues(alpha: 0.1),
          borderRadius: kRadius10,
        ),
        child: const Column(
          children: [
            FaIcon(
              FontAwesomeIcons.calendarXmark,
              color: Colors.grey,
              size: 30,
            ),
            kGap10,
            Text(
              'The doctor is not available on this day.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Font.small,
                color: Colors.grey,
              ),
            ),
            kGap10,
            Text(
              'Please select another date.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Font.small,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Get working hours for the selected day
    String startTime = state.doctorWorkingHours[selectedDay].startTime;
    String endTime = state.doctorWorkingHours[selectedDay].endTime;
    List<BreakTime> breaks = state.doctorWorkingHours[selectedDay].breaks;

    // Check if service has custom hours
    if (state.selectedServiceAvailability != null) {
      // Override with service-specific hours
      startTime = state.selectedServiceAvailability!.startTime;
      endTime = state.selectedServiceAvailability!.endTime;
    }

    // Generate time slots based on working hours, breaks, slot duration, and buffer time
    List<String> availableSlots = _generateTimeSlots(
      startTime,
      endTime,
      breaks,
      state.selectedService!.value is int
          ? state.selectedService!.value as int
          : state.defaultSlotDuration,
      state.bufferTime,
    );

    if (availableSlots.isEmpty) {
      return Container(
        padding: kPadd20,
        decoration: BoxDecoration(
          color: MyColors.blueGrey.withValues(alpha: 0.1),
          borderRadius: kRadius10,
        ),
        child: const Column(
          children: [
            FaIcon(
              FontAwesomeIcons.calendarXmark,
              color: Colors.grey,
              size: 30,
            ),
            kGap10,
            Text(
              'No available time slots for this date.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Font.small,
                color: Colors.grey,
              ),
            ),
            kGap10,
            Text(
              'Please select another date.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Font.small,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Divide into AM and PM slots
    List<String> amSlots = [];
    List<String> pmSlots = [];

    for (String slot in availableSlots) {
      final hour = int.parse(slot.split(':')[0]);
      if (hour < 12) {
        amSlots.add(slot);
      } else {
        pmSlots.add(slot);
      }
    }

    return EnhancedTimeSlotSelector(
      amOptions: amSlots,
      pmOptions: pmSlots,
      selectedIndex:
          widget.controller.getStepResult(widget.controller.currentStep),
      onSelected: (selected) {
        setState(() {
          unselectedColor =
              selected ? MyColors.primary : MyColors.selectionCardEmpty;
        });
      },
      onChanged: (value, index) {
        // Parse the time
        final parts = value.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        setState(() {
          context.read<SetupAppointmentBloc>().add(
              UpdateAppointmentTime(TimeOfDay(hour: hour, minute: minute)));
          unselectedColor = MyColors.selectionCardEmpty;
          widget.controller.updateStepResult(
            widget.controller.currentStep,
            index,
          );
          widget.controller.markStepComplete();
        });
      },
    );
  }

  List<String> _generateTimeSlots(String startTime, String endTime,
      List<BreakTime> breaks, int slotDuration, int bufferTime) {
    List<String> slots = [];

    // Parse start and end times
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');

    int startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    int endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

    // Calculate total slots
    int currentMinute = startMinutes;
    while (currentMinute + slotDuration <= endMinutes) {
      final slotHour = currentMinute ~/ 60;
      final slotMinute = currentMinute % 60;

      final slotEndMinute = currentMinute + slotDuration;

      // Check if slot overlaps with any break
      bool overlapsBreak = false;
      for (final breakTime in breaks) {
        final breakStartParts = breakTime.startTime.split(':');
        final breakEndParts = breakTime.endTime.split(':');

        int breakStartMinutes =
            int.parse(breakStartParts[0]) * 60 + int.parse(breakStartParts[1]);
        int breakEndMinutes =
            int.parse(breakEndParts[0]) * 60 + int.parse(breakEndParts[1]);

        // Check for overlap
        if ((currentMinute >= breakStartMinutes &&
                currentMinute < breakEndMinutes) ||
            (slotEndMinute > breakStartMinutes &&
                slotEndMinute <= breakEndMinutes) ||
            (currentMinute <= breakStartMinutes &&
                slotEndMinute >= breakEndMinutes)) {
          overlapsBreak = true;
          break;
        }
      }

      if (!overlapsBreak) {
        // Format the time
        final hour = slotHour.toString().padLeft(2, '0');
        final minute = slotMinute.toString().padLeft(2, '0');
        slots.add('$hour:$minute');
      }

      // Move to next slot
      currentMinute += slotDuration + bufferTime;
    }

    return slots;
  }
}

class _ChoosePaymentType extends StatelessWidget {
  final CustomStepperController controller;

  const _ChoosePaymentType({required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SetupAppointmentBloc, SetupAppointmentState>(
      builder: (context, state) {
        List<SelectionItem> paymentOptions = [];

        if (state.acceptsCash) {
          paymentOptions.add(SelectionItem(
            title: 'Cash',
            subtitle: 'Pay at the clinic',
          ));
        }

        if (state.acceptsCreditCard) {
          paymentOptions.add(SelectionItem(
            title: 'Credit Card',
            subtitle: 'Pay online',
          ));
        }

        if (state.acceptsInsurance) {
          paymentOptions.add(SelectionItem(
            title: 'Insurance',
            subtitle: 'Use your insurance',
          ));
        }

        if (paymentOptions.isEmpty) {
          // Fallback if no payment methods are configured
          paymentOptions = [
            SelectionItem(
              title: 'Cash',
              subtitle: 'Pay at the clinic',
            ),
            SelectionItem(
              title: 'Credit Card',
              subtitle: 'Pay online',
            ),
          ];
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Payment Type',
              style: kSectionTitle,
            ),
            kGap20,
            SelectionGroup(
                selectedIndex: controller.getStepResult(controller.currentStep),
                items: paymentOptions,
                onSelected: (item, index) {
                  context
                      .read<SetupAppointmentBloc>()
                      .add(UpdatePaymentType(item.title));
                  controller.updateStepResult(controller.currentStep, index);
                  controller.markStepComplete();
                }),
            // Only show add card button if credit card is accepted
            if (state.acceptsCreditCard) ...[
              kGap10,
              ElevatedButton(
                onPressed: () {},
                style: kElevatedButtonAddCardStyle,
                child: const Text(
                  'Add Card',
                ),
              ),
            ],

            // Show cancellation policy if available
            if (state.cancellationPolicy > 0) ...[
              kGap20,
              Container(
                padding: kPadd10,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: kRadius10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.circleExclamation,
                      color: Colors.orange,
                      size: 18,
                    ),
                    kGap10,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cancellation Policy',
                            style: TextStyle(
                              fontSize: Font.small,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatCancellationPolicy(state.cancellationPolicy),
                            style: const TextStyle(
                              fontSize: Font.small,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  String _formatCancellationPolicy(int hours) {
    if (hours == 0) {
      return 'No cancellations allowed.';
    } else if (hours < 24) {
      return 'Free cancellation up to $hours hours before the appointment.';
    } else {
      final days = hours ~/ 24;
      return 'Free cancellation up to $days ${days == 1 ? 'day' : 'days'} before the appointment.';
    }
  }
}

class _Summary extends StatelessWidget {
  final CustomStepperController controller;

  const _Summary({required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SetupAppointmentBloc, SetupAppointmentState>(
      builder: (context, state) {
        if (state.appointmentDate == null ||
            state.appointmentTime == null ||
            state.selectedService == null ||
            state.selectedAppointment == null ||
            state.selectedPayment.isEmpty) {
          return const Center(
            child: Text('Please complete all previous steps.'),
          );
        }

        final DateFormat dateFormat = DateFormat('EEEE, MMMM d, yyyy');
        final TimeOfDay time = state.appointmentTime!;
        final SelectionItem service = state.selectedService!;
        final String appointmentType = state.selectedAppointment!.value;
        final String appointmentLocation = state.appointmentLocation;
        final String paymentType = state.selectedPayment;

        // Format time for display
        final String formattedTime = time.format(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and subtitle
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Appointment Summary',
                  style: kSectionTitle,
                ),
                Text(
                  'Please review your appointment details',
                  style: TextStyle(
                    fontSize: Font.small,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            kGap24,

            // Appointment details card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: kRadius16,
              ),
              child: Column(
                children: [
                  // Date and time section with gradient header
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          MyColors.primary,
                          MyColors.primary.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    padding: kPadd16,
                    child: Row(
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.calendarCheck,
                          color: Colors.white,
                          size: 24,
                        ),
                        kGap12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Date & Time',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Font.mediumSmall,
                                ),
                              ),
                              Text(
                                '${dateFormat.format(state.appointmentDate!)} • $formattedTime',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: Font.small,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Service details
                  Padding(
                    padding: kPadd16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service section
                        _buildInfoRow(
                          icon: FontAwesomeIcons.kitMedical,
                          title: 'Service',
                          value: service.title,
                        ),
                        kGap16,

                        // Duration section
                        _buildInfoRow(
                          icon: FontAwesomeIcons.clock,
                          title: 'Duration',
                          value: service.subtitle,
                        ),
                        kGap16,

                        // Divider
                        Container(
                          height: 1,
                          color: Colors.grey[200],
                          margin: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        kGap8,

                        // Appointment type section
                        _buildInfoRow(
                          icon: _getAppointmentTypeIcon(appointmentType),
                          title: 'Appointment Type',
                          value: appointmentType,
                        ),
                        kGap16,

                        // Location section
                        _buildInfoRow(
                          icon: FontAwesomeIcons.locationDot,
                          title: 'Location',
                          value: appointmentLocation,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            kGap12,

            // Payment section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: kRadius16,
              ),
              padding: kPadd16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment header
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: MyColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: FaIcon(
                            FontAwesomeIcons.creditCard,
                            size: 18,
                            color: MyColors.primary,
                          ),
                        ),
                      ),
                      kGap12,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Payment Method',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Font.mediumSmall,
                              color: MyColors.textBlack,
                            ),
                          ),
                          Text(
                            paymentType,
                            style: TextStyle(
                              fontSize: Font.small,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        '\$${service.price}',
                        style: const TextStyle(
                          fontFamily: Font.family,
                          color: MyColors.primary,
                          fontSize: Font.large,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            kGap20,

            // Payment notice
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: kRadius12,
                border: Border.all(color: Colors.blue[100]!),
              ),
              padding: kPadd16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.circleInfo,
                    color: Colors.blue,
                    size: 18,
                  ),
                  kGap12,
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: Font.family,
                          fontSize: Font.small,
                          color: Colors.blue[800],
                        ),
                        children: [
                          TextSpan(
                            text: 'Note: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          TextSpan(
                            text: 'You will ',
                            style: TextStyle(
                              color: Colors.blue[800],
                            ),
                          ),
                          TextSpan(
                            text: 'NOT',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          TextSpan(
                            text:
                                ' be charged until the consultation is completed. If the meeting was canceled or not conducted, no charge will be made.',
                            style: TextStyle(
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Terms and conditions
            Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: kRadius12,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: state.termsAccepted,
                      onChanged: (value) {
                        context
                            .read<SetupAppointmentBloc>()
                            .add(ToggleTermsAccepted(value ?? false));
                      },
                      activeColor: MyColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  kGap10,
                  const Text(
                    'I agree to the ',
                    style: TextStyle(
                      fontFamily: Font.family,
                      fontSize: Font.small,
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {},
                    child: const Text(
                      'Terms and Conditions',
                      style: TextStyle(
                        fontFamily: Font.family,
                        color: MyColors.primary,
                        fontSize: Font.small,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Pay button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 10, bottom: 8),
              child: ElevatedButton.icon(
                onPressed: state.termsAccepted
                    ? () {
                        context
                            .read<SetupAppointmentBloc>()
                            .add(BookAppointment());
                        AppGlobal.navigatorKey.currentState!.pushAndRemoveUntil(
                          AppointmentConfirmedScreen.route(),
                          (route) => route.isFirst,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: kRadius12,
                  ),
                  elevation: 0,
                ),
                icon: const FaIcon(
                  FontAwesomeIcons.circleCheck,
                  size: 18,
                ),
                label: const Text(
                  'Confirm Appointment',
                  style: TextStyle(
                    fontFamily: Font.family,
                    fontSize: Font.mediumSmall,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: MyColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: FaIcon(
              icon,
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
                title,
                style: TextStyle(
                  fontSize: Font.small,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: Font.family,
                  fontSize: Font.mediumSmall,
                  fontWeight: FontWeight.w500,
                  color: MyColors.textBlack,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getAppointmentTypeIcon(String appointmentType) {
    switch (appointmentType.toLowerCase()) {
      case 'online':
        return FontAwesomeIcons.video;
      case 'in person':
        return FontAwesomeIcons.hospitalUser;
      case 'home visit':
        return FontAwesomeIcons.house;
      default:
        return FontAwesomeIcons.userDoctor;
    }
  }
}

class _PayButton extends StatelessWidget {
  const _PayButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SetupAppointmentBloc, SetupAppointmentState>(
      builder: (context, state) {
        return Container(
          padding: kPaddT40,
          child: ElevatedButton.icon(
            onPressed: state.termsAccepted
                ? () {
                    context.read<SetupAppointmentBloc>().add(BookAppointment());
                    AppGlobal.navigatorKey.currentState!.pushAndRemoveUntil(
                      AppointmentConfirmedScreen.route(),
                      (route) => route.isFirst,
                    );
                  }
                : null,
            style: kElevatedButtonCommonStyle,
            icon: const FaIcon(
              FontAwesomeIcons.circleCheck,
              size: 18,
            ),
            label: const Padding(
              padding: kPaddB2,
              child: Text(
                'Pay',
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BookAppointmentButton extends StatelessWidget {
  const _BookAppointmentButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: kPaddV12,
      child: ElevatedButton(
        onPressed: () {
          context.read<SetupAppointmentBloc>().add(ToggleRebuild());
        },
        style: kElevatedButtonCommonStyle,
        child: const Text(
          'Book Appointment',
        ),
      ),
    );
  }
}

class _PatientReviewsScreen extends StatelessWidget {
  const _PatientReviewsScreen();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SetupAppointmentBloc, SetupAppointmentState>(
      builder: (context, state) {
        if (state.doctorReviews.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Patient Reviews',
                    style: kSectionTitle,
                  ),
                ],
              ),
              kGap10,
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
              ),
            ],
          );
        }

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
                TextButton(
                  style: TextButton.styleFrom(
                    padding: kPadd0,
                    minimumSize: const Size(0, 0),
                    alignment: Alignment.centerRight,
                  ),
                  onPressed: null,
                  child: TextButton(
                    onPressed: () {
                      // navigate to all reviews screen
                    },
                    child: const Text(
                      'View All',
                      style: kButtonHint,
                    ),
                  ),
                ),
              ],
            ),
            kGap10,
            SizedBox(
              height: 175,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: state.doctorReviews.length > 2
                    ? 2
                    : state.doctorReviews.length,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => kGap14,
                itemBuilder: (context, index) {
                  final review = state.doctorReviews[index];
                  return _ReviewCard(
                    author: review.author,
                    review: review.text,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String author;
  final String review;

  const _ReviewCard({
    required this.author,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const ProfilePicture(
              width: 30,
              height: 30,
            ),
            kGap10,
            Text(
              author,
              style: kServiceCardText.copyWith(
                color: MyColors.textBlack,
                fontWeight: FontWeight.normal,
              ),
            ),
            kGap10,
            // flag
            const FaIcon(
              FontAwesomeIcons.solidFlag,
              color: MyColors.buttonRed,
              size: 14,
            ),
          ],
        ),
        kGap10,
        Text(
          review,
          style: kServiceCardText.copyWith(
            color: MyColors.textGrey,
            fontSize: Font.extraSmall,
          ),
        ),
      ],
    );
  }
}

class _ClinicDetails extends StatelessWidget {
  final String doctorId;

  const _ClinicDetails({required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SetupAppointmentBloc, SetupAppointmentState>(
      builder: (context, state) {
        final String phone = state.doctorPhone ?? 'Loading phone...';
        final String address = state.doctorAddress ?? 'Loading address...';
        final String notes = state.doctorNotes ?? '';

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
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
                  width: 25,
                  height: 25,
                  padding: kPadd4,
                  alignment: Alignment.center,
                  child: const FaIcon(
                    FontAwesomeIcons.phone,
                    color: MyColors.primary,
                    size: 14,
                  ),
                ),
                kGap10,
                Text(
                  phone,
                  style: kServiceClinicDetails,
                ),
              ],
            ),
            kGap10,
            Row(
              children: [
                Container(
                  width: 25,
                  height: 25,
                  padding: kPadd4,
                  decoration: BoxDecoration(
                    color: MyColors.primary.withValues(alpha: 0.25),
                    borderRadius: kRadiusAll,
                  ),
                  alignment: Alignment.center,
                  child: const FaIcon(
                    FontAwesomeIcons.mapLocation,
                    color: MyColors.primary,
                    size: 14,
                  ),
                ),
                kGap10,
                Expanded(
                  child: Text(
                    address,
                    style: kServiceClinicDetails,
                  ),
                ),
              ],
            ),
            if (notes.isNotEmpty) ...[
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
                    width: 25,
                    height: 25,
                    alignment: Alignment.center,
                    child: const FaIcon(
                      FontAwesomeIcons.circleInfo,
                      color: MyColors.primary,
                      size: 14,
                    ),
                  ),
                  kGap10,
                  Expanded(
                    child: Text(
                      notes,
                      style: kServiceClinicDetails,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ClinicLocation extends StatefulWidget {
  final String doctorId;

  const _ClinicLocation({required this.doctorId});

  @override
  State<_ClinicLocation> createState() => _ClinicLocationState();
}

class _ClinicLocationState extends State<_ClinicLocation> {
  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SetupAppointmentBloc, SetupAppointmentState>(
      builder: (context, state) {
        final latLng =
            state.doctorLocation ?? const LatLng(45.521563, -122.677433);
        final address = state.doctorAddress ?? 'Loading address...';

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
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
                      position: latLng,
                      infoWindow: InfoWindow(
                        title: 'Clinic',
                        snippet: address,
                      ),
                    ),
                  },
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: latLng,
                    zoom: 11.0,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DoctorProfile extends StatelessWidget {
  final String doctorName;
  final String specialty;

  const _DoctorProfile({
    required this.doctorName,
    required this.specialty,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      // space between
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const ProfilePicture(width: 50, height: 50),
        kGap20,
        _DoctorInfo(
          name: doctorName,
          specialty: specialty,
        ),
        const Spacer(),
        // faicon right arrow
        const FaIcon(
          FontAwesomeIcons.upRightFromSquare,
          color: Colors.black,
          size: 20,
        ),
      ],
    );
  }
}

class _DoctorInfo extends StatelessWidget {
  final String name;
  final String specialty;

  const _DoctorInfo({
    required this.name,
    required this.specialty,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: Font.medium,
            color: MyColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          specialty,
          style: const TextStyle(
            fontSize: Font.extraSmall,
            color: MyColors.textGrey,
          ),
        ),
      ],
    );
  }
}
