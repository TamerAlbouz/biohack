import 'package:dotted_line/dotted_line.dart';
import 'package:faker/faker.dart' hide Color;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/common/widgets/radio/split_radio_group.dart';
import 'package:medtalk/patient/search_doctors/bloc/setup_appointment_bloc.dart';
import 'package:medtalk/patient/search_doctors/widgets/date_navigator.dart';
import 'package:medtalk/patient/search_doctors/widgets/summary_entry.dart';
import 'package:medtalk/styles/sizes.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../common/widgets/base/custom_base.dart';
import '../../../common/widgets/dividers/card_divider.dart';
import '../../../common/widgets/dummy/profile_picture.dart';
import '../../../styles/colors.dart';
import '../../../styles/font.dart';
import '../../../styles/styles/button.dart';
import '../../../styles/styles/text.dart';
import '../models/selection_item.dart';
import '../widgets/selection_group.dart';
import '../widgets/services_widget.dart';

class SetupAppointmentScreen extends StatefulWidget {
  const SetupAppointmentScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
        builder: (_) => const SetupAppointmentScreen());
  }

  @override
  State<SetupAppointmentScreen> createState() => _SetupAppointmentScreenState();
}

class _SetupAppointmentScreenState extends State<SetupAppointmentScreen> {
  bool reBuild = false;
  Color unselectedColor = MyColors.blue;
  late final _CustomStepperController _stepperController;

  @override
  void initState() {
    super.initState();
    _stepperController = _CustomStepperController(canSkipSteps: [
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
      create: (context) => SetupAppointmentBloc(),
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
                          const SliverToBoxAdapter(
                            child: _DoctorProfile(),
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
                                  ? _CustomStepper(
                                      controller: _stepperController,
                                      steps: [
                                        _ChooseAppointmentDate(
                                          controller: _stepperController,
                                        ),
                                        _ChooseServiceType(
                                          controller: _stepperController,
                                        ),
                                        _ChooseAppointmentType(
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
                                  : const Column(
                                      children: [
                                        _Biography(),
                                        CardDivider(),
                                        Services(),
                                        CardDivider(),
                                        _ClinicLocation(),
                                        CardDivider(),
                                        _ClinicDetails(),
                                        CardDivider(),
                                        _PatientReviewsScreen(),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showNewWidgets)
                      // Stepper buttons should always be at the bottom
                      _CustomStepperControls(
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
  const _Biography();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Biography',
          style: kAppointmentSetupSectionTitle,
        ),
        kGap10,
        Text(
          'Dr. Marissa Doe is a dentist with over 10 years of experience. She is a member of the American Dental Association and has a passion for helping patients achieve their best smile.',
          style: kServiceCardText,
        ),
      ],
    );
  }
}

class _CustomStepperControls extends StatefulWidget {
  final _CustomStepperController controller;

  const _CustomStepperControls({required this.controller});

  @override
  State<_CustomStepperControls> createState() => _CustomStepperControlsState();
}

class _CustomStepperControlsState extends State<_CustomStepperControls> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {
      // Trigger rebuild whenever the controller notifies listeners
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        kGap20,
        const CardDivider(
          height: 0,
          padding: 0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: widget.controller.currentStep > 0
                    ? widget.controller.goToPreviousStep
                    : null,
                child: const Text('Previous',
                    style: TextStyle(fontSize: Font.mediumSmall)),
              ),
            ),
            TextButton(
              onPressed: () {
                // show are you sure dialog

                widget.controller.reset();
                context.read<SetupAppointmentBloc>().add(ToggleRebuild());
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: Font.mediumSmall,
                  color: MyColors.buttonRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              width: 100,
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: (widget.controller
                            .canSkipSteps[widget.controller.currentStep] ||
                        widget.controller
                            .completedSteps[widget.controller.currentStep])
                    ? widget.controller.goToNextStep
                    : null,
                child: (widget.controller.currentStep <
                        widget.controller.completedSteps.length - 1)
                    ? const Text('Next',
                        style: TextStyle(fontSize: Font.mediumSmall))
                    : const Text('',
                        style: TextStyle(fontSize: Font.mediumSmall)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CustomStepperController extends ChangeNotifier {
  int _currentStep = 0;
  final List<bool> _completedSteps;
  final List<bool> _canSkipSteps;

  // have a dictionary of steps for the result of each step
  final Map<int, dynamic> _stepResults = {};

  _CustomStepperController({List<bool>? canSkipSteps, int stepCount = 5})
      : _canSkipSteps = canSkipSteps ?? List.generate(stepCount, (_) => true),
        _completedSteps = List.generate(stepCount, (_) => false);

  int get currentStep => _currentStep;

  List<bool> get completedSteps => List.unmodifiable(_completedSteps);

  List<bool> get canSkipSteps => List.unmodifiable(_canSkipSteps);

  Map<int, dynamic> get stepResults => Map.unmodifiable(_stepResults);

  // add a result for a step
  void updateStepResult(int step, dynamic result) {
    _stepResults[step] = result;
  }

  // get the result of a step
  dynamic getStepResult(int step) {
    return _stepResults[step];
  }

  void reset() {
    _currentStep = 0;
    _completedSteps.fillRange(0, _completedSteps.length, false);
    notifyListeners();
  }

  /// Adds a delay before actually moving to the next step without using async/await.
  void goToNextStep({Duration delay = const Duration(milliseconds: 300)}) {
    // Schedule the step change after the specified delay
    Future.delayed(delay, () {
      if (_currentStep < _completedSteps.length - 1) {
        if (_canSkipSteps[_currentStep] || _completedSteps[_currentStep]) {
          _completedSteps[_currentStep] = true;
          _currentStep++;
          notifyListeners();
        }
      }
    });
  }

  void goToPreviousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void markStepComplete() {
    if (currentStep >= 0 && currentStep < _completedSteps.length) {
      _completedSteps[currentStep] = true;
      notifyListeners();
    }
  }
}

class _CustomStepper extends StatefulWidget {
  final _CustomStepperController controller;
  final List<Widget> steps;

  const _CustomStepper(
      {super.key, required this.controller, required this.steps});

  @override
  _CustomStepperState createState() => _CustomStepperState();
}

class _CustomStepperState extends State<_CustomStepper>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  int _previousStep = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuad,
    ));

    // Start the animation for the initial step
    _animationController.forward();

    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (widget.controller.currentStep != _previousStep) {
      // Determine slide direction based on step change
      final isForward = widget.controller.currentStep > _previousStep;

      _slideAnimation = Tween<Offset>(
        begin: Offset(isForward ? 1.0 : -1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuad,
      ));

      _animationController.reset();
      _animationController.forward();

      setState(() {
        _previousStep = widget.controller.currentStep;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Stepper indicator remains the same
        StepperHeader(
          currentStep: widget.controller.currentStep,
          completedSteps: widget.controller.completedSteps,
        ),
        kGap10,
        // Wrap the current step with SlideTransition
        SlideTransition(
          position: _slideAnimation,
          child: widget.steps[widget.controller.currentStep],
        ),
      ],
    );
  }
}

class StepperHeader extends StatefulWidget {
  final int currentStep;
  final List<bool> completedSteps;
  final bool showIcons;
  final MainAxisAlignment? mainAxisAlignment;

  const StepperHeader({
    super.key,
    required this.currentStep,
    required this.completedSteps,
    this.showIcons = false,
    this.mainAxisAlignment,
  });

  @override
  State<StepperHeader> createState() => _StepperHeaderState();
}

class _StepperHeaderState extends State<StepperHeader>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: widget.mainAxisAlignment ?? MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: List.generate(widget.completedSteps.length, (index) {
        final isActiveStep = index == widget.currentStep;
        final isCompleted = widget.completedSteps[index];

        return Padding(
          padding: const EdgeInsets.only(right: 10.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showIcons) ...[
                Icon(
                  Icons.check_circle,
                  color: isCompleted
                      ? Colors.green
                      : isActiveStep
                          ? Colors.blue
                          : Colors.grey,
                ),
                const SizedBox(width: 4.0),
              ],
              _buildStepText(index, isActiveStep),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepText(int index, bool isActiveStep) {
    final String fullText = _getStepTitle(index);

    if (!isActiveStep) {
      // If not active, show the pipe immediately (no animation).
      return const Text("|", style: TextStyle(color: Colors.grey));
    }

    // If active, we animate character-by-character fade-in with a smoother curve and longer duration.
    return TweenAnimationBuilder<double>(
      key: ValueKey('active_step_$index'),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
      // smoother easing
      builder: (context, value, child) {
        final int length = fullText.length;
        final double position = value * length;
        final int revealedChars = position.floor();
        final double partial = position - revealedChars;

        // If no characters are revealed and no partial fade, show just '|'.
        if (revealedChars == 0 && partial == 0) {
          return const Text("|", style: TextStyle(color: Colors.grey));
        }

        List<Widget> charWidgets = [];
        for (int i = 0; i < length; i++) {
          double charOpacity = 0.0;
          if (i < revealedChars) {
            // Fully revealed characters
            charOpacity = 1.0;
          } else if (i == revealedChars) {
            // Currently fading-in character
            charOpacity = partial;
          }
          // Characters beyond revealedChars remain 0.0 (invisible)

          if (charOpacity > 0.0) {
            charWidgets.add(
              Opacity(
                opacity: charOpacity,
                child: Text(fullText[i], style: kAppointmentSetupSectionTitle),
              ),
            );
          }
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: charWidgets,
        );
      },
    );
  }

  String _getStepTitle(int index) {
    switch (index) {
      case 0:
        return 'Date & Time';
      case 1:
        return 'Service Type';
      case 2:
        return 'Appointment Type';
      case 3:
        return 'Payment Type';
      case 4:
        return 'Summary';
      default:
        return 'Step ${index + 1}';
    }
  }
}

class _ChooseServiceType extends StatelessWidget {
  final _CustomStepperController controller;

  const _ChooseServiceType({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SelectionGroup(
      selectedIndex: controller.getStepResult(controller.currentStep),
      items: [
        SelectionItem(
          title: 'Treatment',
          subtitle: '1 hr',
          price: 100,
        ),
        SelectionItem(
          title: 'Consultation',
          subtitle: '30 mins',
          price: 50,
        ),
        SelectionItem(
          title: 'Checkup',
          subtitle: '15 mins',
          price: 30,
        ),
      ],
      onSelected: (item, index) {
        context.read<SetupAppointmentBloc>().add(UpdateServiceType(item));
        controller.updateStepResult(controller.currentStep, index);
        controller.markStepComplete();
        controller.goToNextStep();
      },
    );
  }
}

class _ChooseAppointmentType extends StatelessWidget {
  final _CustomStepperController controller;

  const _ChooseAppointmentType({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SelectionGroup(
        selectedIndex: controller.getStepResult(controller.currentStep),
        items: [
          SelectionItem(
            title: 'In-Person',
            subtitle: '1234 Clinic St, Portland, OR 97205',
          ),
          SelectionItem(
            title: 'Online',
            subtitle: 'Video Call',
          ),
        ],
        onSelected: (item, index) {
          context
              .read<SetupAppointmentBloc>()
              .add(UpdateAppointmentType(item.title, item.subtitle));
          controller.updateStepResult(controller.currentStep, index);
          controller.markStepComplete();
          controller.goToNextStep();
        });
  }
}

class _ChoosePaymentType extends StatelessWidget {
  final _CustomStepperController controller;

  const _ChoosePaymentType({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectionGroup(
            selectedIndex: controller.getStepResult(controller.currentStep),
            items: [
              SelectionItem(
                title: 'Cash',
                subtitle: 'Pay at the clinic',
              ),
              SelectionItem(
                title: 'Credit Card',
                subtitle: 'Pay online',
              ),
            ],
            onSelected: (item, index) {
              context
                  .read<SetupAppointmentBloc>()
                  .add(UpdatePaymentType(item.title));
              controller.updateStepResult(controller.currentStep, index);
              controller.markStepComplete();
              controller.goToNextStep();
            }),
        // add card button
        kGap10,
        ElevatedButton(
          onPressed: () {},
          style: kElevatedButtonAddCardStyle,
          child: const Text(
            'Add Card',
          ),
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  final _CustomStepperController controller;

  const _Summary({required this.controller});

  final double padding = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SetupAppointmentBloc, SetupAppointmentState>(
      builder: (context, state) {
        final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
        final TimeOfDay time = state.appointmentTime;
        final SelectionItem? service = state.selectedService;
        final String appointmentType = state.selectedAppointment;
        final String appointmentLocation = state.appointmentLocation;
        final String paymentType = state.selectedPayment;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // note warning rich text
            Container(
              decoration: BoxDecoration(
                color: MyColors.blueGrey,
                borderRadius: kRadius12,
              ),
              padding: kPadd10,
              child: RichText(
                text: TextSpan(
                  style: kServiceCardText,
                  children: [
                    const TextSpan(
                      text: 'Note: ',
                      style: TextStyle(
                        fontFamily: Font.family,
                        color: MyColors.redBright,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'You will ',
                      style: kServiceCardText.copyWith(
                        color: MyColors.textBlack,
                      ),
                    ),
                    const TextSpan(
                      text: 'NOT',
                      style: TextStyle(
                        fontFamily: Font.family,
                        color: MyColors.textBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          ' be charged until the consultation was completed. If the meeting was canceled or not conducted, no charge will be made.',
                      style: kServiceCardText.copyWith(
                        color: MyColors.textBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            kGap20,
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: false,
                    onChanged: (value) {},
                  ),
                ),
                kGap8,
                const Text(
                  'I agree to the ',
                  style: kServiceCardText,
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: kPadd0,
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Terms and Conditions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: MyColors.blue,
                      fontSize: Font.small,
                    ),
                  ),
                ),
              ],
            ),
            kGap10,
            Column(
              children: [
                Container(
                  padding: kPadd10,
                  decoration: BoxDecoration(
                    borderRadius: kRadius10,
                    color: MyColors.cardBackground,
                    border: Border.all(
                      color: MyColors.softStroke,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: kPadd8,
                        decoration: BoxDecoration(
                          color: MyColors.selectionAddCard,
                          borderRadius: kRadiusAll,
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.moneyBill,
                          size: 18,
                          color: MyColors.textGrey,
                        ),
                      ),
                      kGap10,
                      Text(
                        paymentType,
                        style: kServiceCardText.copyWith(
                          color: MyColors.textBlack,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${service?.price}',
                        style: const TextStyle(
                          fontFamily: Font.family,
                          color: MyColors.textBlack,
                          fontSize: Font.medium,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                kGap10,
                Container(
                  padding: kPadd10,
                  decoration: BoxDecoration(
                    borderRadius: kRadius10,
                    color: MyColors.cardBackground,
                    border: Border.all(
                      color: MyColors.softStroke,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      SummaryEntry(
                        title: 'Date',
                        value:
                            '${dateFormat.format(state.appointmentDate ?? DateTime.now())} • ${time.format(context) ?? ''}',
                      ),
                      kGap10,
                      // dotted divider
                      const DottedLine(
                        direction: Axis.horizontal,
                        lineLength: double.infinity,
                        lineThickness: 1,
                        dashLength: 4.0,
                        dashColor: MyColors.softStroke,
                      ),
                      kGap10,
                      SummaryEntry(
                        title: 'Service',
                        value: '${service?.title}',
                      ),
                      kGap10,
                      SummaryEntry(
                        title: 'Duration',
                        value: '${service?.subtitle}',
                      ),
                      kGap10,
                      const DottedLine(
                        direction: Axis.horizontal,
                        lineLength: double.infinity,
                        lineThickness: 1,
                        dashLength: 4.0,
                        dashColor: MyColors.softStroke,
                      ),
                      kGap10,
                      SummaryEntry(
                          title: "Appointment Type", value: appointmentType),
                      kGap10,
                      SummaryEntry(
                        title: 'Location',
                        value: appointmentLocation,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const _PayButton(),
          ],
        );
      },
    );
  }
}

class _PayButton extends StatelessWidget {
  const _PayButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: kPaddT15,
      child: ElevatedButton.icon(
        onPressed: () {
          // show payment dialog
        },
        style: kElevatedButtonBookAppointmentStyle,
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
  }
}

class _BookAppointmentButton extends StatelessWidget {
  const _BookAppointmentButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: kPaddT15,
      child: ElevatedButton(
        onPressed: () {
          context.read<SetupAppointmentBloc>().add(ToggleRebuild());
        },
        style: kElevatedButtonBookAppointmentStyle,
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
    final faker = Faker();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Patient Reviews',
              style: kAppointmentSetupSectionTitle,
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: kPadd0,
                minimumSize: const Size(0, 0),
                alignment: Alignment.centerRight,
              ),
              onPressed: null,
              child: const Text(
                '256',
                textAlign: TextAlign.right,
                style: kButtonHint,
              ),
            ),
          ],
        ),
        kGap10,
        SizedBox(
          height: 250,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: 8,
            separatorBuilder: (context, index) => kGap14,
            itemBuilder: (context, index) {
              return _ReviewCard(
                author: faker.person.name(),
                review: faker.lorem.sentence(),
              );
            },
          ),
        ),
      ],
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
  const _ClinicDetails();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Clinic Details',
          style: kAppointmentSetupSectionTitle,
        ),
        kGap14,
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: MyColors.selectionAddCard,
                borderRadius: kRadiusAll,
              ),
              width: 25,
              height: 25,
              padding: kPadd4,
              alignment: Alignment.center,
              child: const FaIcon(
                FontAwesomeIcons.phone,
                color: MyColors.textGrey,
                size: 14,
              ),
            ),
            kGap10,
            const Text(
              '+1 123 456 7890',
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
                color: MyColors.selectionAddCard,
                borderRadius: kRadiusAll,
              ),
              alignment: Alignment.center,
              child: const FaIcon(
                FontAwesomeIcons.mapLocation,
                color: MyColors.textGrey,
                size: 14,
              ),
            ),
            kGap10,
            const Text(
              '1234 Clinic St, Portland, OR 97205',
              style: kServiceClinicDetails,
            ),
          ],
        ),
        kGap10,
        // extra notes
        Row(
          children: [
            Container(
              padding: kPadd4,
              decoration: BoxDecoration(
                color: MyColors.selectionAddCard,
                borderRadius: kRadiusAll,
              ),
              width: 25,
              height: 25,
              alignment: Alignment.center,
              child: const FaIcon(
                FontAwesomeIcons.circleInfo,
                color: MyColors.textGrey,
                size: 14,
              ),
            ),
            kGap10,
            const Text(
              'Ask for Marwan Azzam',
              style: kServiceClinicDetails,
            ),
          ],
        ),
      ],
    );
  }
}

class _ClinicLocation extends StatefulWidget {
  const _ClinicLocation();

  @override
  State<_ClinicLocation> createState() => _ClinicLocationState();
}

class _ClinicLocationState extends State<_ClinicLocation> {
  late GoogleMapController mapController;
  bool _loading = true;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: kAppointmentSetupSectionTitle,
        ),
        kGap14,
        Skeletonizer(
          enabled: _loading,
          child: Skeleton.leaf(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: MyColors.grey, width: 1.5),
                borderRadius: kRadius10,
                color: Colors.grey[300],
              ),
              height: 150,
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
                      position: _center,
                      infoWindow: const InfoWindow(
                        title: 'Clinic',
                        snippet: '1234 Clinic St, Portland, OR 97205',
                      ),
                    ),
                  },
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 11.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChooseAppointmentDate extends StatefulWidget {
  final _CustomStepperController controller;

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        kGap10,
        DateNavigationWidget(
          selectedDate:
              context.read<SetupAppointmentBloc>().state.appointmentDate,
          onDateChanged: (date) {
            context
                .read<SetupAppointmentBloc>()
                .add(UpdateAppointmentDate(date));
          },
        ),
        kGap10,
        const CardDivider(),
        AmPmSplitRadioGroup(
          amOptions: const [
            '12:00',
            '01:00',
            '02:00',
            '03:00',
            '04:00',
            '05:00',
            '06:00',
            '07:00',
            '08:00',
            '09:00',
            '10:00',
            '11:00',
          ],
          pmOptions: const [
            '12:00',
            '01:00',
            '02:00',
            '03:00',
            '04:00',
            '05:00',
            '06:00',
            '07:00',
            '08:00',
            '09:00',
          ],
          decoration: BoxDecoration(
            color: MyColors.selectionCardEmpty,
            borderRadius: kRadius10,
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          selectedIndex:
              widget.controller.getStepResult(widget.controller.currentStep),
          contentPadding: kPaddH10V2,
          selectedColor: MyColors.blue,
          unselectedColor: unselectedColor,
          unselectedTextColor: MyColors.textGrey,
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: Font.extraSmall,
          ),
          onSelected: (selected) {
            setState(() {
              unselectedColor =
                  selected ? MyColors.blue : MyColors.selectionCardEmpty;
            });
            // if already selected, do not rebuild
          },
          onChanged: (value, index) {
            // split the time
            final time = value.split(':');
            var hour = int.parse(time[0]);
            final minute = int.parse(time[1]);

            setState(() {
              context.read<SetupAppointmentBloc>().add(
                  UpdateAppointmentTime(TimeOfDay(hour: hour, minute: minute)));
              unselectedColor = MyColors.selectionCardEmpty;
              widget.controller.updateStepResult(
                widget.controller.currentStep,
                index,
              );
              widget.controller.markStepComplete();
              widget.controller.goToNextStep();
            });
          },
        ),
      ],
    );
  }
}

class _DoctorProfile extends StatelessWidget {
  const _DoctorProfile();

  @override
  Widget build(BuildContext context) {
    return const Row(
      // space between
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ProfilePicture(width: 50, height: 50),
        kGap20,
        _DoctorInfo(
          name: "Dr. Marissa Doe",
          specialty: "Dentist",
        ),
        Spacer(),
        // faicon right arrow
        FaIcon(
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
            color: MyColors.blue,
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
