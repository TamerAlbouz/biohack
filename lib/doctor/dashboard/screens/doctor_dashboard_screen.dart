import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/agora/screens/call.dart';
import 'package:medtalk/backend/patient/models/patient.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:medtalk/doctor/appointments/bloc/doctor_appointments_bloc.dart';
import 'package:medtalk/doctor/dashboard/bloc/doctor_dashboard_bloc.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/font.dart';
import 'package:medtalk/styles/sizes.dart';
import 'package:medtalk/styles/styles/text.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../app/bloc/auth/route_bloc.dart';
import '../../../backend/appointment/enums/appointment_status.dart';
import '../../../common/globals/globals.dart';
import '../../appointments/models/appointments_models.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
        builder: (_) => const DoctorDashboardScreen());
  }

  @override
  Widget build(BuildContext context) {
    return const DoctorDashboardView();
  }
}

class DoctorDashboardView extends StatelessWidget {
  const DoctorDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: MyColors.background,
        foregroundColor: MyColors.primary,
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.bell),
            onPressed: () {
              // Show notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<DoctorDashboardBloc>().add(LoadDashboardData());
          context.read<DoctorAppointmentsBloc>().add(LoadDoctorAppointments());
        },
        child: BlocConsumer<DoctorDashboardBloc, DoctorDashboardState>(
          listener: (context, state) {
            if (state is DoctorDashboardError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is DoctorDashboardInitial) {
              context.read<DoctorDashboardBloc>().add(LoadDashboardData());
              return _buildLoadingScreen();
            }

            if (state is DoctorDashboardLoading) {
              return _buildLoadingScreen();
            }

            if (state is DoctorDashboardLoaded) {
              return _buildDashboardContent(context, state);
            }

            // Error state
            return _DashboardError(
              message: 'Error loading dashboard data',
              onRetry: () {
                context.read<DoctorDashboardBloc>().add(LoadDashboardData());
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Skeletonizer(
      enabled: true,
      enableSwitchAnimation: true,
      switchAnimationConfig: const SwitchAnimationConfig(
        duration: Duration(milliseconds: 500),
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: kPaddH20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Skeleton welcome section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          height: 16, width: 120, color: Colors.grey[300]),
                      Container(
                          height: 24,
                          width: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: MyColors.primary),
                            borderRadius: kRadius10,
                          )),
                    ],
                  ),
                  kGap4,
                  Container(height: 24, width: 180, color: Colors.grey[300]),
                  kGap4,
                  Container(height: 14, width: 150, color: Colors.grey[300]),
                  kGap20,

                  // Skeleton today's appointments
                  Container(height: 20, width: 180, color: Colors.grey[300]),
                  kGap10,
                  const CustomBase(
                    shadow: false,
                    fixedHeight: 100,
                    child: Center(
                      child: Text(
                        'Loading appointments...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  kGap20,

                  // Skeleton next appointment
                  Container(height: 20, width: 160, color: Colors.grey[300]),
                  kGap10,
                  const CustomBase(
                    shadow: false,
                    fixedHeight: 150,
                    child: Center(
                      child: Text(
                        'Loading next appointment...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  kGap20,

                  // Skeleton metrics
                  Container(height: 20, width: 120, color: Colors.grey[300]),
                  kGap10,
                  const CustomBase(
                    shadow: false,
                    fixedHeight: 150,
                    child: Center(
                      child: Text(
                        'Loading metrics...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  kGap20,

                  // Skeleton recent patients
                  Container(height: 20, width: 160, color: Colors.grey[300]),
                  kGap10,
                  const CustomBase(
                    shadow: false,
                    fixedHeight: 130,
                    child: Center(
                      child: Text(
                        'Loading patients...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
      BuildContext context, DoctorDashboardLoaded state) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: kPaddH20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section with doctor name
            _WelcomeSection(doctorName: state.doctorName),
            kGap20,

            // Today's appointments summary
            _TodayAppointmentsSection(),
            kGap20,

            // Next appointment section (if there's one today)
            BlocBuilder<DoctorAppointmentsBloc, DoctorAppointmentsState>(
              builder: (context, appointmentsState) {
                if (appointmentsState is DoctorAppointmentsLoaded &&
                    appointmentsState.todayAppointments.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _NextAppointmentSection(
                        nextAppointment:
                            appointmentsState.todayAppointments.first,
                      ),
                      kGap20,
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Key metrics section
            _KeyMetricsSection(
              totalPatients: state.totalPatients,
              totalAppointments: state.totalAppointments,
              completionRate: state.completionRate,
            ),
            kGap20,

            // Appointments Summary section
            _AppointmentsSummarySection(),
            kGap20,
          ],
        ),
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  final String doctorName;

  const _WelcomeSection({required this.doctorName});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: Font.medium,
                    color: MyColors.subtitleDark,
                  ),
                ),
                Text(
                  'Dr. $doctorName',
                  style: const TextStyle(
                    fontSize: Font.large,
                    fontWeight: FontWeight.bold,
                    color: MyColors.primary,
                  ),
                ),
              ],
            ),
            const _LogoutButton(),
          ],
        ),
        Text(
          DateFormat('EEEE, MMM dd, yyyy').format(now),
          style: const TextStyle(
            fontSize: Font.small,
            color: MyColors.subtitleDark,
          ),
        ),
      ],
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

class _TodayAppointmentsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorAppointmentsBloc, DoctorAppointmentsState>(
      builder: (context, state) {
        int todayCount = 0;
        int upcomingCount = 0;

        if (state is DoctorAppointmentsLoaded) {
          todayCount = state.todayAppointments.length;
          upcomingCount = state.upcomingAppointments.length;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today\'s Schedule', style: kSectionTitle),
            kGap10,
            CustomBase(
              shadow: false,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$todayCount appointment${todayCount != 1 ? 's' : ''} today',
                          style: const TextStyle(
                            fontSize: Font.medium,
                            fontWeight: FontWeight.bold,
                            color: MyColors.primary,
                          ),
                        ),
                        kGap6,
                        Text(
                          '$upcomingCount upcoming in the next days',
                          style: const TextStyle(
                            fontSize: Font.small,
                            color: MyColors.subtitleDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: MyColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: kPadd10,
                    child: const FaIcon(
                      FontAwesomeIcons.calendarCheck,
                      size: 36,
                      color: MyColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NextAppointmentSection extends StatelessWidget {
  final AppointmentPatientCard nextAppointment;

  const _NextAppointmentSection({required this.nextAppointment});

  @override
  Widget build(BuildContext context) {
    final appointment = nextAppointment.appointment;
    final patient = nextAppointment.patient;
    final appointmentTime = appointment.appointmentDate;

    // Calculate time remaining
    final now = DateTime.now();
    final difference = appointmentTime.difference(now);
    final timeRemaining = _formatTimeRemaining(difference);
    final isCallReady = now
            .isAfter(appointmentTime.subtract(const Duration(minutes: 10))) &&
        now.isBefore(
            appointmentTime.add(Duration(minutes: appointment.duration ?? 30)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Next Appointment', style: kSectionTitle),
        kGap10,
        CustomBase(
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: MyColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        patient.name?.substring(0, 1) ?? 'P',
                        style: const TextStyle(
                          fontSize: Font.medium,
                          fontWeight: FontWeight.bold,
                          color: MyColors.primary,
                        ),
                      ),
                    ),
                  ),
                  kGap10,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name ?? 'Unknown Patient',
                          style: const TextStyle(
                            fontSize: Font.smallExtra,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          appointment.serviceName,
                          style: const TextStyle(
                            fontSize: Font.extraSmall,
                            color: MyColors.subtitleDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isCallReady
                          ? Colors.green.withOpacity(0.1)
                          : MyColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      timeRemaining,
                      style: TextStyle(
                        fontSize: Font.extraSmall,
                        fontWeight: FontWeight.bold,
                        color: isCallReady ? Colors.green : MyColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              kGap16,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.clock,
                        size: 14,
                        color: MyColors.subtitleDark,
                      ),
                      kGap6,
                      Text(
                        DateFormat('h:mm a').format(appointmentTime),
                        style: const TextStyle(
                          fontSize: Font.small,
                          color: MyColors.subtitleDark,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.locationDot,
                        size: 14,
                        color: MyColors.subtitleDark,
                      ),
                      kGap6,
                      Text(
                        appointment.location ?? 'Online',
                        style: const TextStyle(
                          fontSize: Font.small,
                          color: MyColors.subtitleDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              kGap16,
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isCallReady
                          ? () {
                              AppGlobal.navigatorKey.currentState!.push(
                                VideoCallScreen.route(),
                              );
                            }
                          : null,
                      icon: const FaIcon(FontAwesomeIcons.video, size: 14),
                      label: const Text('Join Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.primary,
                        foregroundColor: Colors.white,
                        padding: kPaddV10,
                      ),
                    ),
                  ),
                  kGap10,
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // View patient profile or record
                      },
                      icon: const FaIcon(FontAwesomeIcons.userPen, size: 14),
                      label: const Text('Patient Info'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: MyColors.primary,
                        side: const BorderSide(color: MyColors.primary),
                        padding: kPaddV10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTimeRemaining(Duration difference) {
    if (difference.isNegative) {
      // Appointment has already started
      final minutes = difference.inMinutes.abs();
      if (minutes < 60) {
        return 'Started ${minutes}m ago';
      } else {
        final hours = difference.inHours.abs();
        return 'Started ${hours}h ago';
      }
    } else {
      // Appointment is in the future
      if (difference.inMinutes < 60) {
        return 'In ${difference.inMinutes}m';
      } else if (difference.inHours < 24) {
        return 'In ${difference.inHours}h';
      } else {
        return 'In ${difference.inDays}d';
      }
    }
  }
}

class _KeyMetricsSection extends StatelessWidget {
  final int totalPatients;
  final int totalAppointments;
  final double completionRate;

  const _KeyMetricsSection({
    required this.totalPatients,
    required this.totalAppointments,
    required this.completionRate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Key Metrics', style: kSectionTitle),
        kGap10,
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Total Patients',
                value: totalPatients.toString(),
                icon: FontAwesomeIcons.userGroup,
                iconColor: MyColors.primary,
                trend: '+5%',
                trendPositive: true,
              ),
            ),
            kGap10,
            Expanded(
              child: _MetricCard(
                title: 'Appointments',
                value: totalAppointments.toString(),
                icon: FontAwesomeIcons.calendarDay,
                iconColor: Colors.green,
                trend: '+12%',
                trendPositive: true,
              ),
            ),
          ],
        ),
        kGap10,
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Completion Rate',
                value: '${completionRate.toStringAsFixed(1)}%',
                icon: FontAwesomeIcons.chartLine,
                iconColor: Colors.orange,
                trend: '+2.3%',
                trendPositive: true,
              ),
            ),
            kGap10,
            const Expanded(
              child: _MetricCard(
                title: 'Revenue',
                value: '\$0.00',
                icon: FontAwesomeIcons.moneyBill,
                iconColor: Colors.amber,
                trend: '0%',
                trendPositive: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String? trend;
  final bool trendPositive;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.trend,
    this.trendPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomBase(
      shadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(
                  icon,
                  color: iconColor,
                  size: 16,
                ),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: trendPositive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    trend!,
                    style: TextStyle(
                      color: trendPositive ? Colors.green : Colors.red,
                      fontSize: Font.extraSmall,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          kGap10,
          Text(
            value,
            style: const TextStyle(
              fontSize: Font.medium,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: Font.small,
              color: MyColors.subtitleDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentsSummarySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorAppointmentsBloc, DoctorAppointmentsState>(
      builder: (context, state) {
        if (state is! DoctorAppointmentsLoaded) {
          return const SizedBox.shrink();
        }

        // Count appointments by status
        int completed = 0;
        int scheduled = 0;
        int canceled = 0;

        // Process all appointments (today, upcoming, and past)
        for (final appointment in [
          ...state.todayAppointments,
          ...state.upcomingAppointments,
          ...state.pastAppointments,
        ]) {
          switch (appointment.appointment.status) {
            case AppointmentStatus.completed:
              completed++;
              break;
            case AppointmentStatus.cancelled:
              canceled++;
              break;
            default:
              scheduled++;
              break;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Appointments Summary', style: kSectionTitle),
            kGap10,
            CustomBase(
              shadow: false,
              child: Column(
                children: [
                  _AppointmentStatusBar(
                    total: completed + scheduled + canceled,
                    completed: completed,
                    scheduled: scheduled,
                    canceled: canceled,
                  ),
                  kGap16,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatusLegendItem(
                        color: Colors.green,
                        label: 'Completed',
                        count: completed,
                      ),
                      _StatusLegendItem(
                        color: MyColors.primary,
                        label: 'Scheduled',
                        count: scheduled,
                      ),
                      _StatusLegendItem(
                        color: Colors.red,
                        label: 'Canceled',
                        count: canceled,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AppointmentStatusBar extends StatelessWidget {
  final int total;
  final int completed;
  final int scheduled;
  final int canceled;

  const _AppointmentStatusBar({
    required this.total,
    required this.completed,
    required this.scheduled,
    required this.canceled,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate percentages
    final completedPercent = total > 0 ? completed / total : 0.0;
    final scheduledPercent = total > 0 ? scheduled / total : 0.0;
    final canceledPercent = total > 0 ? canceled / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 20,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[200],
          ),
          child: Row(
            children: [
              Expanded(
                flex: (completedPercent * 100).round(),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.horizontal(
                      left: const Radius.circular(10),
                      right: Radius.circular(
                        scheduledPercent <= 0 && canceledPercent <= 0 ? 10 : 0,
                      ),
                    ),
                    color: Colors.green,
                  ),
                ),
              ),
              Expanded(
                flex: (scheduledPercent * 100).round(),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(completedPercent <= 0 ? 10 : 0),
                      right: Radius.circular(canceledPercent <= 0 ? 10 : 0),
                    ),
                    color: MyColors.primary,
                  ),
                ),
              ),
              Expanded(
                flex: (canceledPercent * 100).round(),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(
                        completedPercent <= 0 && scheduledPercent <= 0 ? 10 : 0,
                      ),
                      right: const Radius.circular(10),
                    ),
                    color: Colors.red,
                  ),
                ),
              ),
              if (total == 0)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[300],
                    ),
                    child: const Center(
                      child: Text(
                        'No appointments',
                        style: TextStyle(
                          fontSize: Font.extraSmall,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _StatusLegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        kGap6,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: Font.extraSmall,
                color: Colors.grey,
              ),
            ),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: Font.small,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PatientCard extends StatelessWidget {
  final Patient patient;

  const _PatientCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    // Calculate age
    final now = DateTime.now();
    final age = now.year - (patient.dateOfBirth?.toDate().year ?? now.year);

    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 10),
      child: CustomBase(
        shadow: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MyColors.primary.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Text(
                  patient.name?.substring(0, 1) ?? 'P',
                  style: const TextStyle(
                    fontSize: Font.medium,
                    fontWeight: FontWeight.bold,
                    color: MyColors.primary,
                  ),
                ),
              ),
            ),
            kGap6,
            Text(
              patient.name ?? 'Unknown',
              style: const TextStyle(
                fontSize: Font.small,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            kGap4,
            Text(
              '${age.toString()} years old',
              style: const TextStyle(
                fontSize: Font.extraSmall,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: MyColors.background,
        foregroundColor: MyColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: kRadius10,
        ),
        side: const BorderSide(color: MyColors.primary),
        padding: kPaddH10V0,
      ),
      onPressed: () {
        context.read<RouteBloc>().add(AuthLogoutPressed());
      },
      child: const Text('Logout',
          style: TextStyle(
            fontSize: Font.small,
            fontWeight: FontWeight.bold,
          )),
    );
  }
}

class _DashboardError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            FontAwesomeIcons.circleExclamation,
            size: 48,
            color: Colors.red[300],
          ),
          kGap20,
          Text(
            'Error: $message',
            style: const TextStyle(
              color: Colors.red,
              fontSize: Font.medium,
            ),
            textAlign: TextAlign.center,
          ),
          kGap20,
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
