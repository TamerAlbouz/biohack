import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/common/globals/globals.dart';

import '../../../styles/colors.dart';
import '../../../styles/font.dart';
import '../../../styles/sizes.dart';

class AppointmentConfirmedScreen extends StatefulWidget {
  const AppointmentConfirmedScreen({super.key});

  // route function
  static Route<void> route() {
    return MaterialPageRoute<void>(
        builder: (_) => const AppointmentConfirmedScreen());
  }

  @override
  State<AppointmentConfirmedScreen> createState() =>
      _AppointmentConfirmedScreenState();
}

class _AppointmentConfirmedScreenState extends State<AppointmentConfirmedScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Set up confetti controller
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _confettiController.play();

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
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
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
                padding: kPaddH24,
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
                          color: MyColors.buttonGreen.withValues(alpha: 0.1),
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
                                      color: MyColors.buttonGreen,
                                      backgroundColor: Colors.grey.shade200,
                                    ),
                                  );
                                },
                              ),
                              // Check icon
                              const FaIcon(
                                FontAwesomeIcons.solidCircleCheck,
                                color: MyColors.buttonGreen,
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

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              // straight up
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 20,
              minBlastForce: 10,
              emissionFrequency: 0.05,
              gravity: 0.2,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.pink,
                Colors.orange,
                Colors.lightBlue,
              ],
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
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Appointment header with date
              Container(
                width: double.infinity,
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
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.calendarDay,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Appointment Date',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Sept 20',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '10:30 AM',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Wednesday',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Appointment details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: FontAwesomeIcons.userDoctor,
                      title: 'Doctor',
                      value: 'Dr. Sarah Johnson',
                      iconColor: MyColors.primary,
                    ),
                    const SizedBox(height: 15),
                    _buildDetailRow(
                      icon: FontAwesomeIcons.kitMedical,
                      title: 'Service',
                      value: 'Eye Checkup',
                      iconColor: Colors.blue,
                    ),
                    const SizedBox(height: 15),
                    _buildDetailRow(
                      icon: FontAwesomeIcons.locationDot,
                      title: 'Location',
                      value: 'Central Medical Clinic',
                      iconColor: Colors.orange,
                    ),
                    const SizedBox(height: 15),
                    _buildDetailRow(
                      icon: FontAwesomeIcons.moneyBill,
                      title: 'Payment',
                      value: '\$100',
                      iconColor: Colors.green,
                      valueStyle: const TextStyle(
                        fontFamily: Font.family,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Divider(),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.circleInfo,
                          size: 16,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Please arrive 15 minutes before your appointment time',
                            style: TextStyle(
                              fontFamily: Font.family,
                              fontSize: 14.0,
                              color: Colors.grey[600],
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
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                AppGlobal.navigatorKey.currentState!.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.buttonGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
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
