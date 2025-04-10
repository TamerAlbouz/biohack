import 'package:backend/backend.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/agora/screens/call.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:medtalk/doctor/appointments/bloc/doctor_appointments_bloc.dart';
import 'package:medtalk/doctor/dashboard/bloc/doctor_dashboard_bloc.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/font.dart';
import 'package:medtalk/styles/sizes.dart';
import 'package:medtalk/styles/styles/text.dart';

import '../../../app/bloc/auth/route_bloc.dart';
import '../../../common/globals/globals.dart';
import '../../appointments/models/appointments_models.dart';
import '../widgets/metric_widgets.dart';

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
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DoctorDashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DoctorDashboardLoaded) {
              return _buildDashboardContent(context, state);
            }

            // Error state
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
                  const Text(
                    'Error loading dashboard data',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: Font.medium,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  kGap20,
                  ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<DoctorDashboardBloc>()
                          .add(LoadDashboardData());
                    },
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
          },
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
      BuildContext context, DoctorDashboardLoaded state) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: kPaddH20V14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section with doctor name
            _WelcomeSection(doctorName: state.doctorName),
            kGap20,

            // Today's appointments summary
            _TodayAppointmentsCard(),
            kGap20,

            // Next appointment section (if there's one today)
            BlocBuilder<DoctorAppointmentsBloc, DoctorAppointmentsState>(
              builder: (context, appointmentsState) {
                if (appointmentsState is DoctorAppointmentsLoaded &&
                    appointmentsState.todayAppointments.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _NextAppointmentCard(
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
          ],
        ),
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
            kGap20,
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
        // navigate to the auth screen
      },
      child: const Text('Logout',
          style: TextStyle(
            fontSize: Font.small,
            fontWeight: FontWeight.bold,
          )),
    );
  }
}

// The rest of the widget classes remain the same
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
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              greeting,
              style: const TextStyle(
                fontSize: Font.medium,
                color: MyColors.subtitleDark,
              ),
            ),
            const _LogoutButton(),
          ],
        ),
        Text(
          'Dr. $doctorName',
          style: const TextStyle(
            fontSize: Font.large,
            fontWeight: FontWeight.bold,
            color: MyColors.primary,
          ),
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

class _TodayAppointmentsCard extends StatelessWidget {
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

        return CustomBase(
          shadow: false,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s Schedule',
                      style: TextStyle(
                        fontSize: Font.medium,
                        fontWeight: FontWeight.bold,
                        color: MyColors.primary,
                      ),
                    ),
                    kGap6,
                    Text(
                      'You have $todayCount appointment${todayCount != 1 ? 's' : ''} today',
                      style: const TextStyle(
                        fontSize: Font.small,
                        color: MyColors.subtitleDark,
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
        );
      },
    );
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
              child: MetricCard(
                title: 'Total Patients',
                value: totalPatients.toString(),
                icon: FontAwesomeIcons.userGroup,
                color: Colors.blue,
              ),
            ),
            kGap10,
            Expanded(
              child: MetricCard(
                title: 'Appointments',
                value: totalAppointments.toString(),
                icon: FontAwesomeIcons.calendarDay,
                color: Colors.green,
              ),
            ),
          ],
        ),
        kGap10,
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Completion Rate',
                value: '${completionRate.toStringAsFixed(1)}%',
                icon: FontAwesomeIcons.chartLine,
                color: Colors.orange,
              ),
            ),
            kGap10,
            const Expanded(
              child: MetricCard(
                title: 'Revenue',
                value: '\$0.00',
                icon: FontAwesomeIcons.moneyBill,
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NextAppointmentCard extends StatelessWidget {
  final AppointmentPatientCard nextAppointment;

  const _NextAppointmentCard({required this.nextAppointment});

  @override
  Widget build(BuildContext context) {
    final appointment = nextAppointment.appointment;
    final patient = nextAppointment.patient;
    final appointmentTime = appointment.appointmentDate;

    // Calculate time remaining
    final now = DateTime.now();
    final difference = appointmentTime.difference(now);
    final timeRemaining = _formatTimeRemaining(difference);

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
                      color: MyColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      timeRemaining,
                      style: const TextStyle(
                        fontSize: Font.extraSmall,
                        fontWeight: FontWeight.bold,
                        color: MyColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              kGap10,
              const DottedLine(
                dashLength: 4,
                dashColor: MyColors.subtitleDark,
                lineThickness: 1,
                dashGapLength: 4,
              ),
              kGap10,
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
              kGap10,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: now.isAfter(appointmentTime
                              .subtract(const Duration(minutes: 10))) &&
                          now.isBefore(appointmentTime.add(
                              Duration(minutes: appointment.duration ?? 30)))
                      ? () {
                          AppGlobal.navigatorKey.currentState!.push(
                            VideoCallScreen.route(),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.primary,
                    foregroundColor: Colors.white,
                    padding: kPaddV10,
                  ),
                  child: const Text('Join Call',
                      style: TextStyle(
                        fontSize: Font.small,
                        fontWeight: FontWeight.bold,
                      )),
                ),
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

class _PatientListItem extends StatelessWidget {
  final Patient patient;

  const _PatientListItem({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: kPadd10,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: MyColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                patient.name?.substring(0, 1) ?? 'P',
                style: const TextStyle(
                  fontSize: Font.small,
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
                    fontSize: Font.small,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Last visit: N/A',
                  style: TextStyle(
                    fontSize: Font.extraSmall,
                    color: MyColors.subtitleDark,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.phone,
              size: 16,
              color: MyColors.primary,
            ),
            onPressed: () {
              // Call patient
            },
          ),
        ],
      ),
    );
  }
}
