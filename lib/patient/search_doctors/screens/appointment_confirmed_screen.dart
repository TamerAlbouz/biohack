import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/common/globals/globals.dart';
import 'package:medtalk/patient/search_doctors/bloc/setup_appointment_bloc.dart';
import 'package:medtalk/patient/search_doctors/widgets/appointments_details_card.dart';

import '../../../styles/colors.dart';
import '../../../styles/font.dart';
import '../../../styles/sizes.dart';

class AppointmentConfirmedScreen extends StatefulWidget {
  final SetupAppointmentState state;

  const AppointmentConfirmedScreen({super.key, required this.state});

  // route function
  static Route<void> route(SetupAppointmentState state) {
    return MaterialPageRoute<void>(
        builder: (_) => AppointmentConfirmedScreen(state: state));
  }

  @override
  State<AppointmentConfirmedScreen> createState() =>
      _AppointmentConfirmedScreenState();
}

class _AppointmentConfirmedScreenState extends State<AppointmentConfirmedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Set up animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: 48,
        elevation: 0,
        automaticallyImplyLeading: false,
        actionsPadding: const EdgeInsets.only(right: 20),
        actions: [
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.xmark,
              size: 26,
              color: Colors.grey,
            ),
            onPressed: () {
              AppGlobal.navigatorKey.currentState!.pop();
            },
          )
        ],
      ),
      body: Stack(
        children: [
          // Main content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: kPaddH20T20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tick animation (Lottie animation or custom animation)
                    // You would need to add your own animation asset
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
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
                              // Outer ring animation
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(seconds: 1),
                                builder: (context, value, child) {
                                  return SizedBox(
                                    height: 120,
                                    width: 120,
                                    child: CircularProgressIndicator(
                                      value: value,
                                      strokeWidth: 4,
                                      color: MyColors.primary,
                                      backgroundColor: Colors.grey.shade200,
                                    ),
                                  );
                                },
                              ),
                              // Check icon
                              const FaIcon(
                                FontAwesomeIcons.solidCircleCheck,
                                color: MyColors.primary,
                                size: 75.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Text content with animations
                    kGap20,
                    FadeTransition(
                      opacity: _animationController,
                      child: const Text(
                        'Appointment Successfully Booked',
                        style: TextStyle(
                          fontFamily: Font.family,
                          fontSize: Font.mediumLarge,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF263238),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    kGap10,
                    FadeTransition(
                      opacity: _animationController,
                      child: Text(
                        'We\'ve sent a confirmation email with all the details',
                        style: TextStyle(
                          fontFamily: Font.family,
                          fontSize: Font.small,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    kGap30,

                    // Appointment details card
                    _buildAppointmentDetailsCard(),

                    kGap20,

                    // Action buttons
                    _buildActionButtons(),

                    kGap40,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentDetailsCard() {
    return FadeTransition(
      opacity: _animationController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(_animationController),
        child: AppointmentsDetailsCard(state: widget.state),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    TextStyle? valueStyle,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: FaIcon(
              icon,
              size: 16,
              color: iconColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: Font.family,
                fontSize: 14.0,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: valueStyle ??
                  const TextStyle(
                    fontFamily: Font.family,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF263238),
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return FadeTransition(
      opacity: _animationController,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                AppGlobal.navigatorKey.currentState!.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
