import 'package:backend/backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/agora/screens/call.dart';
import 'package:medtalk/common/globals/globals.dart';
import 'package:medtalk/common/widgets/cards/appointment_card.dart';
import 'package:medtalk/common/widgets/dividers/section_divider.dart';
import 'package:medtalk/doctor/appointments/models/appointment_card.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/font.dart';
import 'package:medtalk/styles/sizes.dart';

import '../bloc/doctor_appointments_bloc.dart';

class DoctorAppointmentsScreen extends StatelessWidget {
  const DoctorAppointmentsScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
        builder: (_) => const DoctorAppointmentsScreen());
  }

  @override
  Widget build(BuildContext context) {
    return const DoctorAppointmentsView();
  }
}

class DoctorAppointmentsView extends StatefulWidget {
  const DoctorAppointmentsView({super.key});

  @override
  State<DoctorAppointmentsView> createState() => _DoctorAppointmentsViewState();
}

class _DoctorAppointmentsViewState extends State<DoctorAppointmentsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.background,
        foregroundColor: MyColors.primary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: BlocBuilder<DoctorAppointmentsBloc, DoctorAppointmentsState>(
            builder: (context, state) {
              int unviewedCount = 0;
              if (state is DoctorAppointmentsLoaded) {
                unviewedCount = state.unviewedAppointmentsCount;
              }

              return Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor: MyColors.primary,
                    tabs: [
                      const _BadgedTab(
                        text: 'Today',
                      ),
                      _BadgedTab(
                        text: 'Upcoming',
                        badgeCount: unviewedCount,
                        badgeColor: MyColors.primary,
                      ),
                    ],
                    onTap: (index) {
                      // If tapping on "Upcoming" tab and there are unviewed appointments, clear the badge
                      if (index == 1 && unviewedCount > 0) {
                        context
                            .read<DoctorAppointmentsBloc>()
                            .add(ClearAllViewedBadges());
                      }
                    },
                  ));
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.filter),
            onPressed: () {
              // Show filter dialog
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: BlocConsumer<DoctorAppointmentsBloc, DoctorAppointmentsState>(
        listener: (context, state) {
          if (state is DoctorAppointmentsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          switch (state) {
            case DoctorAppointmentsInitial():
              context
                  .read<DoctorAppointmentsBloc>()
                  .add(LoadDoctorAppointments());
              return const Center(child: CircularProgressIndicator());
            case DoctorAppointmentsLoading():
              return const Center(child: CircularProgressIndicator());
            case DoctorAppointmentsLoaded():
              return TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(), // Add smooth physics
                children: [
                  // Today's Appointments Tab with fade transition
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _AppointmentsListView(
                      appointments: state.todayAppointments,
                      emptyMessage: "No appointments scheduled for today",
                    ),
                  ),
                  // Upcoming Appointments Tab with fade transition
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _AppointmentsListView(
                      appointments: state.upcomingAppointments,
                      emptyMessage: "No upcoming appointments",
                    ),
                  ),
                ],
              );
            case DoctorAppointmentsError():
              return _AppointmentsError(message: state.message);
            default:
              return const Center(child: Text('Unexpected state'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Refresh appointments
          context.read<DoctorAppointmentsBloc>().add(LoadDoctorAppointments());
        },
        backgroundColor: MyColors.primary,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    // Show date range filter dialog
    showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: MyColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    ).then((dateRange) {
      if (dateRange != null && context.mounted) {
        context.read<DoctorAppointmentsBloc>().add(
              FilterDoctorAppointments(
                fromDate: dateRange.start,
                toDate: dateRange.end,
              ),
            );
      }
    });
  }
}

// The rest of the widget classes remain the same...
class _AppointmentsListView extends StatelessWidget {
  final List<AppointmentPatientCard> appointments;
  final String emptyMessage;

  const _AppointmentsListView({
    required this.appointments,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return _EmptyStateMessage(message: emptyMessage);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DoctorAppointmentsBloc>().add(LoadDoctorAppointments());
      },
      child: ListView.separated(
        padding: kPaddH20V14,
        itemCount: appointments.length,
        separatorBuilder: (context, index) => kGap14,
        itemBuilder: (context, index) {
          final appointmentPCard = appointments[index];
          return _AppointmentItem(appointmentPatientCard: appointmentPCard);
        },
      ),
    );
  }
}

class _AppointmentItem extends StatelessWidget {
  final AppointmentPatientCard appointmentPatientCard;

  const _AppointmentItem({required this.appointmentPatientCard});

  @override
  Widget build(BuildContext context) {
    final appointment = appointmentPatientCard.appointment;

    final isUpcoming = appointment.appointmentDate.isAfter(DateTime.now());
    final statusColor = _getStatusColor(appointment.status);

    // Check if this appointment has been viewed
    bool isViewed = true;
    final state = context.watch<DoctorAppointmentsBloc>().state;
    if (state is DoctorAppointmentsLoaded) {
      isViewed = state.isAppointmentViewed(appointment.appointmentId ?? '');
    }

    bool isAppointmentReady(bool isUpcoming) {
      if (isUpcoming) return false;

      return true;
    }

    return Stack(
      children: [
        AppointmentWidget(
          date: DateFormat('MMM dd, yyyy').format(appointment.appointmentDate),
          time: DateFormat('h:mm a').format(appointment.appointmentDate),
          location: appointment.location ?? "Online Consultation",
          specialty: appointment.specialty,
          name: appointmentPatientCard.patient.name!,
          service: appointment.serviceName,
          fee: appointment.fee.toString(),
          isReady: isAppointmentReady(isUpcoming),
          onJoinCall: () {
            _handleJoinCall(context, appointment);
          },
          onCardTap: () {
            // Mark as viewed when clicked
            context.read<DoctorAppointmentsBloc>().add(
                  MarkAppointmentViewed(
                      appointmentId: appointment.appointmentId ?? ''),
                );
            _showAppointmentDetails(context, appointmentPatientCard);
          },
        ),

        // Show a badge for unviewed upcoming appointments
        if (!isViewed && isUpcoming)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }

  Color _getStatusColor(AppointmentStatus? status) {
    switch (status) {
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.canceled:
        return Colors.red;
      case AppointmentStatus.inProgress:
        return Colors.orange;
      default:
        return MyColors.primary;
    }
  }

  void _handleJoinCall(BuildContext context, Appointment appointment) {
    // Check if appointment is active (within 10 minutes of start time)
    final now = DateTime.now();
    final startWindow =
        appointment.appointmentDate.subtract(const Duration(minutes: 10));
    final endWindow = appointment.appointmentDate
        .add(Duration(minutes: appointment.duration ?? 30));

    if (now.isAfter(startWindow) && now.isBefore(endWindow)) {
      AppGlobal.navigatorKey.currentState!.push(
        VideoCallScreen.route(),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "You can only join calls within 10 minutes of the appointment time"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAppointmentDetails(
      BuildContext context, AppointmentPatientCard appointmentPatientCard) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AppointmentDetailsSheet(
          appointmentPatientCard: appointmentPatientCard),
    );
  }
}

class _AppointmentDetailsSheet extends StatelessWidget {
  final AppointmentPatientCard appointmentPatientCard;

  const _AppointmentDetailsSheet({required this.appointmentPatientCard});

  @override
  Widget build(BuildContext context) {
    final appointment = appointmentPatientCard.appointment;

    return Container(
      padding: kPadd20,
      decoration: BoxDecoration(
        color: MyColors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          kGap20,
          const Text(
            'Appointment Details',
            style: TextStyle(
              fontSize: Font.mediumLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          kGap14,
          const SectionDivider(),
          kGap14,
          _DetailRow(
            icon: FontAwesomeIcons.user,
            title: 'Patient',
            value: appointmentPatientCard.patient.name ?? 'Unknown Patient',
          ),
          _DetailRow(
            icon: FontAwesomeIcons.calendar,
            title: 'Date',
            value: DateFormat('EEEE, MMM dd, yyyy')
                .format(appointment.appointmentDate),
          ),
          _DetailRow(
            icon: FontAwesomeIcons.clock,
            title: 'Time',
            value: DateFormat('h:mm a').format(appointment.appointmentDate),
          ),
          _DetailRow(
            icon: FontAwesomeIcons.stethoscope,
            title: 'Service',
            value: appointment.serviceName,
          ),
          _DetailRow(
            icon: FontAwesomeIcons.locationDot,
            title: 'Location',
            value: appointment.location ?? 'Online Consultation',
          ),
          _DetailRow(
            icon: FontAwesomeIcons.tag,
            title: 'Status',
            value: _capitalizeStatus(appointment.status),
          ),
          _DetailRow(
            icon: FontAwesomeIcons.dollarSign,
            title: 'Fee',
            value: '\$${appointment.fee}',
          ),
          kGap14,
          _DetailTextArea(
            icon: FontAwesomeIcons.comment,
            title: 'Patient Biography',
            value: appointmentPatientCard.patient.biography ?? 'No Biography',
          ),
          kGap20,
          if (_canJoinCall(appointment))
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  AppGlobal.navigatorKey.currentState!.push(
                    VideoCallScreen.route(),
                  );
                },
                icon: const FaIcon(FontAwesomeIcons.video),
                label: const Text('Join Call'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primary,
                  foregroundColor: Colors.white,
                  padding: kPaddV14,
                ),
              ),
            ),
          kGap14,
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close',
                  style: TextStyle(color: MyColors.primary)),
            ),
          ),
        ],
      ),
    );
  }

  bool _canJoinCall(Appointment appointment) {
    final now = DateTime.now();
    final startWindow =
        appointment.appointmentDate.subtract(const Duration(minutes: 10));
    final endWindow = appointment.appointmentDate
        .add(Duration(minutes: appointment.duration ?? 30));

    return now.isAfter(startWindow) && now.isBefore(endWindow);
  }

  String _capitalizeStatus(AppointmentStatus? status) {
    if (status == null) return "Scheduled";

    return status
        .toString()
        .split('.')
        .last
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}

class _DetailTextArea extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailTextArea({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kPaddV6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FaIcon(
                icon,
                size: 16,
                color: MyColors.primary,
              ),
              kGap10,
              SizedBox(
                width: 180,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: Font.small,
                    color: MyColors.subtitleDark,
                  ),
                ),
              ),
            ],
          ),
          kGap10,
          Container(
            padding: kPadd10,
            decoration: BoxDecoration(
              color: MyColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: Font.small,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kPaddV6,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FaIcon(
            icon,
            size: 16,
            color: MyColors.primary,
          ),
          kGap10,
          SizedBox(
            width: 80,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: Font.small,
                color: MyColors.subtitleDark,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: Font.small,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateMessage extends StatelessWidget {
  final String message;

  const _EmptyStateMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FaIcon(
            FontAwesomeIcons.calendarXmark,
            size: 48,
            color: MyColors.subtitleDark,
          ),
          kGap20,
          Text(
            message,
            style: const TextStyle(
              fontSize: Font.medium,
              color: MyColors.subtitleDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AppointmentsError extends StatelessWidget {
  final String message;

  const _AppointmentsError({required this.message});

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
            onPressed: () {
              context
                  .read<DoctorAppointmentsBloc>()
                  .add(LoadDoctorAppointments());
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
  }
}

// Create a new widget for tabs with badges
class _BadgedTab extends StatelessWidget {
  final String text;
  final int badgeCount;
  final Color badgeColor;

  const _BadgedTab({
    required this.text,
    this.badgeCount = 0,
    this.badgeColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 8),
          Text(text),
          if (badgeCount > 0) ...[
            const SizedBox(width: 4),
            Container(
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Center(
                child: Text(
                  badgeCount > 99 ? '99+' : badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
