import 'dart:math';

import 'package:backend/backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/app/bloc/auth/route_bloc.dart';
import 'package:medtalk/doctor/appointments/bloc/doctor_appointments_bloc.dart';
import 'package:medtalk/doctor/dashboard/screens/doctor_dashboard_screen.dart';
import 'package:medtalk/doctor/design/screens/design_screen.dart';
import 'package:medtalk/doctor/patients/screens/patients_screen.dart';
import 'package:medtalk/styles/styles/button.dart';
import 'package:medtalk/styles/styles/text.dart';
import 'package:p_logger/p_logger.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/widgets/custom_bottom_navbar.dart';
import '../../../styles/colors.dart';
import '../../../styles/font.dart';
import '../../../styles/sizes.dart';
import '../../appointments/screens/appointments_screen.dart';
import '../../dashboard/bloc/doctor_dashboard_bloc.dart';
import '../../patients/bloc/patients_list_bloc.dart';
import '../../stats/bloc/statistics_bloc.dart';
import '../../stats/screens/statistics_screen.dart';
import '../cubit/navigation_doctor_cubit.dart';
import '../enums/navbar_screen_items_doctor.dart';

class NavigationDoctorScreen extends StatelessWidget {
  const NavigationDoctorScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
        builder: (_) => const NavigationDoctorScreen());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationDoctorCubit>(
            create: (context) => NavigationDoctorCubit(
                  doctorRepo: getIt<IDoctorRepository>(),
                  authRepo: getIt<IAuthenticationRepository>(),
                )),
        BlocProvider<DoctorAppointmentsBloc>(
            create: (context) => DoctorAppointmentsBloc(
                  getIt<IAppointmentRepository>(),
                  context.read<IAuthenticationRepository>(),
                  getIt<IPatientRepository>(),
                )..add(LoadDoctorAppointments())),
        BlocProvider<DoctorDashboardBloc>(
            create: (context) => DoctorDashboardBloc(
                  getIt<IAuthenticationRepository>(),
                  getIt<IAppointmentRepository>(),
                  getIt<IPatientRepository>(),
                )),
        BlocProvider<DoctorStatsBloc>(
            create: (context) => DoctorStatsBloc(
                  getIt<IAuthenticationRepository>(),
                  getIt<IAppointmentRepository>(),
                  getIt<IPatientRepository>(),
                )),
        BlocProvider<PatientsBloc>(
            create: (context) => PatientsBloc(
                  getIt<IAuthenticationRepository>(),
                  getIt<IPatientRepository>(),
                  getIt<IAppointmentRepository>(),
                )),
      ],
      child: const NavigationPatientView(),
    );
  }
}

class NavigationPatientView extends StatefulWidget {
  const NavigationPatientView({super.key});

  @override
  State<NavigationPatientView> createState() => _NavigationPatientViewState();
}

class _NavigationPatientViewState extends State<NavigationPatientView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationDoctorCubit, NavigationDoctorState>(
        builder: (context, state) {
      if (state.isLoading) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      // Check if the doctor is active
      if (!state.isActive) {
        // If not active, show the inactive screen
        return DoctorInactiveScreen(
          message: state.inactiveMessage,
        );
      }

      return Scaffold(
        body: Stack(
          children: [
            const _Body(),
            if (!state.isActive)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.pending_actions,
                            size: 48,
                            color: Colors.orange,
                          ),
                          kGap16,
                          Text(
                            state.inactiveMessage,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          kGap8,
                          Text(
                            'You will be able to access all features once your account is approved.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar:
            CustomBottomNavBar<NavigationDoctorCubit, NavigationDoctorState>(
          items: const [
            BottomNavigationBarItem(
              activeIcon: Icon(FontAwesomeIcons.heartPulse),
              icon: Icon(FontAwesomeIcons.heart),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(FontAwesomeIcons.solidCalendar),
              icon: Icon(FontAwesomeIcons.calendar),
              label: 'Appoint.',
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(FontAwesomeIcons.solidChartBar),
              icon: Icon(FontAwesomeIcons.chartBar),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.design_services, size: 27),
              icon: Icon(Icons.design_services_outlined, size: 27),
              label: 'Design',
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.people_alt, size: 27),
              icon: Icon(Icons.people_alt_outlined, size: 27),
              label: 'Patients',
            ),
          ],
          onTap: _onItemTapped,
        ),
      );
    });
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        BlocProvider.of<NavigationDoctorCubit>(context)
            .getCurrentNavbarItem(NavbarScreenItemsDoctor.dashboard);
        break;
      case 1:
        BlocProvider.of<NavigationDoctorCubit>(context)
            .getCurrentNavbarItem(NavbarScreenItemsDoctor.appointments);
        break;
      case 2:
        BlocProvider.of<NavigationDoctorCubit>(context)
            .getCurrentNavbarItem(NavbarScreenItemsDoctor.stats);
        break;
      case 3:
        BlocProvider.of<NavigationDoctorCubit>(context)
            .getCurrentNavbarItem(NavbarScreenItemsDoctor.design);
        break;
      case 4:
        BlocProvider.of<NavigationDoctorCubit>(context)
            .getCurrentNavbarItem(NavbarScreenItemsDoctor.patients);
        break;
      default:
        BlocProvider.of<NavigationDoctorCubit>(context)
            .getCurrentNavbarItem(NavbarScreenItemsDoctor.dashboard);
        break;
    }
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationDoctorCubit, NavigationDoctorState>(
        builder: (context, state) {
      switch (state.navbarItem) {
        case NavbarScreenItemsDoctor.dashboard:
          return const DoctorDashboardScreen();
        case NavbarScreenItemsDoctor.appointments:
          return const DoctorAppointmentsScreen();
        case NavbarScreenItemsDoctor.stats:
          return const DoctorStatsScreen();
        case NavbarScreenItemsDoctor.design:
          return const DesignScreen();
        case NavbarScreenItemsDoctor.patients:
          return const PatientsScreen();
      }
    });
  }
}

class DoctorInactiveScreen extends StatefulWidget {
  final String? message;

  const DoctorInactiveScreen({
    super.key,
    this.message,
  });

  @override
  State<DoctorInactiveScreen> createState() => _DoctorInactiveScreenState();
}

class _DoctorInactiveScreenState extends State<DoctorInactiveScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _documentAnimation;
  late Animation<double> _checkmarkAnimation;
  late Animation<double> _pulseAnimation;

  bool _isRefreshDisabled = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _documentAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
      ),
    );

    _checkmarkAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeInOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: kPaddH20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                kGap30,
                _buildCustomAnimation(),
                kGap18,
                const Text(
                  'Verification in Progress',
                  style: TextStyle(
                    fontSize: Font.large,
                    fontWeight: FontWeight.bold,
                    color: MyColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                kGap8,
                Text(
                  widget.message ??
                      'Your account is currently under review. This helps us ensure the quality and safety of our platform.',
                  style: const TextStyle(
                    fontSize: Font.medium,
                  ),
                  textAlign: TextAlign.center,
                ),
                kGap16,
                _buildRefreshButton(context),
                kGap32,
                _buildStatusCard(context),
                kGap12,
                _buildFAQSection(context),
                kGap12,
                _buildSupportSection(context),
                kGap12,
                // sign out button
                TextButton(
                  onPressed: () {
                    // Sign out logic
                    BlocProvider.of<RouteBloc>(context)
                        .add(AuthLogoutPressed());
                  },
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: Font.medium,
                      color: MyColors.buttonRed,
                    ),
                  ),
                ),
                kGap40,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isRefreshDisabled
          ? null
          : () {
              // Refresh the status
              _refreshStatus(context);
            },
      icon: Icon(
        Icons.refresh,
        color: _isRefreshDisabled ? Colors.grey : Colors.white,
        size: 24,
      ),
      label:
          Text(_isRefreshDisabled ? 'Please wait a minute...' : 'Check Status'),
      style: kElevatedButtonCommonStyle,
    );
  }

  Widget _buildCustomAnimation() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SizedBox(
          height: 200,
          width: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer circle with pulse effect
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: MyColors.primary.withValues(alpha: 0.1),
                  ),
                ),
              ),

              // Inner circle
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: MyColors.primary.withValues(alpha: 0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),

              // Document icon with slight rotation
              Opacity(
                opacity: _documentAnimation.value,
                child: Transform.scale(
                  scale: _documentAnimation.value,
                  child: Transform.rotate(
                    angle: (0.05 * sin(_animationController.value * 3 * 3.14)),
                    // Subtle rocking animation
                    child: Container(
                      width: 80,
                      height: 100,
                      decoration: BoxDecoration(
                        color: MyColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: MyColors.primary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 4,
                            width: 50,
                            margin: const EdgeInsets.only(bottom: 8),
                            color: MyColors.primary.withValues(alpha: 0.4),
                          ),
                          Container(
                            height: 4,
                            width: 40,
                            margin: const EdgeInsets.only(bottom: 8),
                            color: MyColors.primary.withValues(alpha: 0.4),
                          ),
                          Container(
                            height: 4,
                            width: 50,
                            margin: const EdgeInsets.only(bottom: 8),
                            color: MyColors.primary.withValues(alpha: 0.4),
                          ),
                          Container(
                            height: 20,
                            width: 50,
                            decoration: BoxDecoration(
                              color: MyColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Hourglass with spin animation
              Positioned(
                right: 60,
                bottom: 60,
                child: Opacity(
                  opacity: _checkmarkAnimation.value,
                  child: Transform.scale(
                    scale: _checkmarkAnimation.value,
                    child: Transform.rotate(
                      angle: _animationController.value * 2 * 3.14159 * 0.2,
                      // Gentle rotation
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: MyColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: MyColors.primary.withValues(alpha: 0.4),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.hourglass_top,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.pending_actions,
                    color: Colors.orange,
                    size: 28,
                  ),
                ),
                kGap16,
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verification Status',
                        style: kSectionTitle,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Pending Approval',
                        style: TextStyle(
                          fontSize: Font.small,
                          fontWeight: FontWeight.normal,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            kGap20,
            _buildCustomProgressIndicator(context),
            kGap12,
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Received',
                    style: TextStyle(
                      fontSize: Font.small,
                      color: MyColors.green,
                    )),
                Text(
                  'Under review',
                  style: TextStyle(
                    fontSize: Font.small,
                    color: Colors.orange,
                  ),
                ),
                Text(
                  'Approved',
                  style: TextStyle(
                    fontSize: Font.small,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomProgressIndicator(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            children: [
              // First segment (completed)
              Container(
                width: MediaQuery.of(context).size.width * 0.25,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(3),
                    bottomLeft: Radius.circular(3),
                  ),
                ),
              ),
              // Second segment (in progress)
              Container(
                width: MediaQuery.of(context).size.width *
                    0.15 *
                    (0.5 + 0.5 * _pulseAnimation.value),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(3),
                    bottomRight: Radius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MyColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.question_answer,
                    color: MyColors.primary,
                    size: 24,
                  ),
                ),
                kGap12,
                const Text(
                  'Frequently Asked Questions',
                  style: kSectionTitle,
                ),
              ],
            ),
            kGap16,
            _buildFAQItem(
              context,
              'How long does verification take?',
              'Verification typically takes 2-3 business days depending on volume.',
            ),
            _buildFAQItem(
              context,
              'Why do I need to be verified?',
              'We verify all medical professionals to ensure the safety and quality of our platform.',
            ),
            _buildFAQItem(
              context,
              'What happens after verification?',
              'Once verified, you\'ll have full access to all platform features.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontSize: Font.mediumSmall,
        ),
      ),
      tilePadding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Text(
            answer,
            style: const TextStyle(
              fontSize: Font.small,
              color: MyColors.textBlack,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.support_agent,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                kGap12,
                const Text(
                  'Need Help?',
                  style: kSectionTitle,
                ),
              ],
            ),
            kGap12,
            const Text(
              'If you have any questions or need to update your information, our support team is here to help.',
              style: TextStyle(
                fontSize: Font.mediumSmall,
                color: MyColors.textBlack,
              ),
            ),
            kGap16,
            ElevatedButton.icon(
              onPressed: () {
                // Contact support logic
                _contactSupport(context);
              },
              icon: const Icon(Icons.email_outlined,
                  color: Colors.white, size: 24),
              label: const Text('Contact Support'),
              style: kElevatedButtonCommonStyle,
            ),
          ],
        ),
      ),
    );
  }

  void _refreshStatus(BuildContext context) {
    // If already disabled, show message
    if (_isRefreshDisabled) {
      return;
    }

    // Disable refresh for 1 minute
    setState(() {
      _isRefreshDisabled = true;
    });

    // Animation effect for refresh button
    _animationController.reset();
    _animationController.forward();

    // Call cubit to refresh the status
    BlocProvider.of<NavigationDoctorCubit>(context).checkDoctorActiveStatus();

    // Re-enable after 1 minute
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        setState(() {
          _isRefreshDisabled = false;
        });
      }
    });
  }

  void _contactSupport(BuildContext context) {
    // Manually encode the subject and body to avoid the "+" issue
    final String subject =
        Uri.encodeComponent('Doctor Verification Support Request');
    final String body = Uri.encodeComponent(
        'Hello BioHack Support Team,\n\nI am a doctor waiting for account verification. I would like to request information about my verification status.\n\nRegards,\n');

    // Construct the mailto URL manually
    final String emailUrl =
        'mailto:support@biohack.com?subject=$subject&body=$body';

    // Show feedback before launching
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening email client...'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Launch URL
    final Uri uri = Uri.parse(emailUrl);
    // Launch URL without using context in the callback
    launchUrl(uri).then((_) {}).catchError((error) {
      // This is just to catch errors, but we don't use context here
      logger.e('Error launching email client: $error');
    });
  }
}
