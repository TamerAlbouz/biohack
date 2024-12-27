import 'package:flutter/material.dart';

import '../../../styles/colors.dart';
import '../../../styles/font.dart';
import '../../../styles/sizes.dart';

class CustomStepperControls extends StatefulWidget {
  final Function? onCanceled;
  final CustomStepperController controller;
  final bool darkMode;

  const CustomStepperControls({
    super.key,
    required this.controller,
    this.onCanceled,
    this.darkMode = false,
  });

  @override
  State<CustomStepperControls> createState() => _CustomStepperControlsState();
}

class _CustomStepperControlsState extends State<CustomStepperControls> {
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
    // Define colors based on dark mode
    final activeColor = widget.darkMode ? MyColors.white : MyColors.primary;
    final inactiveColor =
        widget.darkMode ? MyColors.accentBlue : Colors.grey[400];
    final textColor = widget.darkMode ? Colors.white : Colors.black54;
    final disabledTextColor =
        widget.darkMode ? Colors.grey[200] : Colors.grey[200];

    return SafeArea(
      child: Container(
        padding: kPaddH20V10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
                onTap: widget.controller.currentStep > 0
                    ? widget.controller.goToPreviousStep
                    : null,
                child: Container(
                  padding: kPaddH10V8,
                  width: 110,
                  decoration: BoxDecoration(
                    color: widget.controller.currentStep > 0
                        ? activeColor
                        : inactiveColor,
                    borderRadius: kRadius8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back_ios,
                        size: 15,
                        color: widget.controller.currentStep > 0
                            ? (widget.darkMode
                                ? MyColors.primary
                                : MyColors.white)
                            : disabledTextColor,
                      ),
                      Text(
                        'Previous',
                        style: TextStyle(
                          fontSize: Font.smallExtra,
                          color: widget.controller.currentStep > 0
                              ? (widget.darkMode
                                  ? MyColors.primary
                                  : MyColors.white)
                              : disabledTextColor,
                        ),
                      ),
                    ],
                  ),
                )),
            // Step Indicator
            Text(
              '${widget.controller.currentStep + 1} of ${widget.controller.completedSteps.length}',
              style: TextStyle(
                fontSize: Font.small,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            if (widget.controller.currentStep <
                widget.controller.completedSteps.length - 1)
              GestureDetector(
                onTap: (widget.controller
                            .completedSteps[widget.controller.currentStep]) &&
                        widget.controller.currentStep <
                            widget.controller.completedSteps.length - 1
                    ? () => widget.controller
                        .goToNextStep(delay: const Duration(milliseconds: 0))
                    : null,
                child: Container(
                  alignment: Alignment.center,
                  width: 110,
                  padding: kPaddH10V8,
                  decoration: BoxDecoration(
                    color: (widget.controller.completedSteps[
                                widget.controller.currentStep]) &&
                            widget.controller.currentStep <
                                widget.controller.completedSteps.length - 1
                        ? activeColor
                        : inactiveColor,
                    borderRadius: kRadius8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Next',
                        style: TextStyle(
                          fontSize: Font.smallExtra,
                          color: (widget.controller.completedSteps[
                                      widget.controller.currentStep]) &&
                                  widget.controller.currentStep <
                                      widget.controller.completedSteps.length -
                                          1
                              ? (widget.darkMode
                                  ? MyColors.primary
                                  : MyColors.white)
                              : disabledTextColor,
                        ),
                      ),
                      kGap8,
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                        color: (widget.controller.completedSteps[
                                    widget.controller.currentStep]) &&
                                widget.controller.currentStep <
                                    widget.controller.completedSteps.length - 1
                            ? (widget.darkMode
                                ? MyColors.primary
                                : MyColors.white)
                            : disabledTextColor,
                      ),
                    ],
                  ),
                ),
              ),
            // Next Button
            if (!(widget.controller.currentStep <
                widget.controller.completedSteps.length - 1))
              const SizedBox(
                width: 110,
              ),
          ],
        ),
      ),
    );
  }
}

class CustomStepperController extends ChangeNotifier {
  int _currentStep = 0;
  final List<bool> _completedSteps;
  final List<bool> _canSkipSteps;

  // have a dictionary of steps for the result of each step
  final Map<int, dynamic> _stepResults = {};

  CustomStepperController({List<bool>? canSkipSteps, int stepCount = 5})
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

  void markStepIncomplete() {
    if (currentStep >= 0 && currentStep < _completedSteps.length) {
      _completedSteps[currentStep] = false;
      notifyListeners();
    }
  }
}

class CustomStepper extends StatefulWidget {
  final CustomStepperController controller;
  final List<Widget> steps;

  const CustomStepper(
      {super.key, required this.controller, required this.steps});

  @override
  State<CustomStepper> createState() => CustomStepperState();
}

class CustomStepperState extends State<CustomStepper>
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
    return SlideTransition(
      position: _slideAnimation,
      child: widget.steps[widget.controller.currentStep],
    );
  }
}
