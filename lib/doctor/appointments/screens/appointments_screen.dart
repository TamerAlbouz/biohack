import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/agora/screens/call.dart';
import 'package:medtalk/backend/appointment/enums/appointment_status.dart';
import 'package:medtalk/backend/appointment/models/appointment.dart';
import 'package:medtalk/common/globals/globals.dart';
import 'package:medtalk/common/widgets/cards/appointment_doctor_card.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/font.dart';
import 'package:medtalk/styles/sizes.dart';

import '../../../common/widgets/badged_tab.dart';
import '../bloc/doctor_appointments_bloc.dart';
import '../models/appointments_models.dart';

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
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Appointments'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: BlocBuilder<DoctorAppointmentsBloc, DoctorAppointmentsState>(
            builder: (context, state) {
              int unviewedUpcomingCount = 0;
              int unviewedMissedCount = 0;

              if (state is DoctorAppointmentsLoaded) {
                unviewedUpcomingCount = state.unviewedAppointmentsCount;
                unviewedMissedCount = state.unviewedMissedCount;
              }

              return Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: MyColors.softStroke,
                        width: 1,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorColor: MyColors.primary,
                    unselectedLabelColor: Colors.grey,
                    isScrollable: true,
                    tabs: [
                      const BadgedTab(
                        text: 'Today',
                        icon: FontAwesomeIcons.calendarDay,
                      ),
                      BadgedTab(
                        text: 'Upcoming',
                        icon: FontAwesomeIcons.calendarPlus,
                        badgeCount: unviewedUpcomingCount,
                        badgeColor: MyColors.primary,
                      ),
                      const BadgedTab(
                        text: 'Past',
                        icon: FontAwesomeIcons.clockRotateLeft,
                      ),
                      BadgedTab(
                        text: 'Missed',
                        icon: FontAwesomeIcons.calendarXmark,
                        badgeCount: unviewedMissedCount,
                        badgeColor: Colors.red,
                      ),
                    ],
                    onTap: (index) {
                      // Clear badge counts when tapping tabs
                      if (index == 1 && unviewedUpcomingCount > 0) {
                        context.read<DoctorAppointmentsBloc>().add(
                              ClearTabViewedBadges(
                                  tab: AppointmentTab.upcoming),
                            );
                      } else if (index == 3 && unviewedMissedCount > 0) {
                        context.read<DoctorAppointmentsBloc>().add(
                              ClearTabViewedBadges(tab: AppointmentTab.missed),
                            );
                      }
                    },
                  ));
            },
          ),
        ),
        actions: [
          BlocBuilder<DoctorAppointmentsBloc, DoctorAppointmentsState>(
            builder: (context, state) {
              bool hasActiveFilters = false;
              if (state is DoctorAppointmentsLoaded) {
                hasActiveFilters = state.filterCriteria.hasActiveFilters;
              }

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.filter),
                    onPressed: () {
                      // Show enhanced filter dialog
                      _showEnhancedFilterDialog(context);
                    },
                  ),
                  if (hasActiveFilters)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
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
                physics: const BouncingScrollPhysics(),
                children: [
                  // Today's Appointments Tab
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _AppointmentsListView(
                      appointments: state.todayAppointments,
                      emptyMessage: "No appointments scheduled for today",
                    ),
                  ),
                  // Upcoming Appointments Tab
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _AppointmentsListView(
                      appointments: state.upcomingAppointments,
                      emptyMessage: "No upcoming appointments",
                    ),
                  ),
                  // Past Appointments Tab
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _AppointmentsListView(
                      appointments: state.pastAppointments,
                      emptyMessage: "No past appointments",
                    ),
                  ),
                  // Missed Appointments Tab
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _AppointmentsListView(
                      appointments: state.missedAppointments,
                      emptyMessage: "No missed appointments",
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

  void _showEnhancedFilterDialog(BuildContext context) {
    // Get current filter criteria from state
    AppointmentFilterCriteria currentCriteria =
        const AppointmentFilterCriteria();
    if (context.read<DoctorAppointmentsBloc>().state
        is DoctorAppointmentsLoaded) {
      currentCriteria = (context.read<DoctorAppointmentsBloc>().state
              as DoctorAppointmentsLoaded)
          .filterCriteria;
    }

    // Create controllers for text inputs
    final patientNameController =
        TextEditingController(text: currentCriteria.patientNameFilter);
    final serviceNameController =
        TextEditingController(text: currentCriteria.serviceNameFilter);
    final locationController =
        TextEditingController(text: currentCriteria.locationFilter);

    // Track selected date range
    DateTime? fromDate = currentCriteria.fromDate;
    DateTime? toDate = currentCriteria.toDate;

    // Track selected status filters
    final selectedStatuses =
        currentCriteria.statusFilter?.toSet() ?? <AppointmentStatus>{};

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Filter Appointments'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range Section
                  const Text(
                    'Date Range',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            fromDate != null
                                ? DateFormat('MMM dd, yyyy').format(fromDate!)
                                : 'From Date',
                          ),
                          onPressed: () async {
                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: fromDate ?? DateTime.now(),
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 365)),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: MyColors.primary,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (selectedDate != null) {
                              setState(() {
                                fromDate = selectedDate;
                              });
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: TextButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            toDate != null
                                ? DateFormat('MMM dd, yyyy').format(toDate!)
                                : 'To Date',
                          ),
                          onPressed: () async {
                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: toDate ?? DateTime.now(),
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 365)),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: MyColors.primary,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (selectedDate != null) {
                              setState(() {
                                toDate = selectedDate;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Status Filter Section
                  const Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _FilterChip(
                        label: 'Scheduled',
                        selected: selectedStatuses
                            .contains(AppointmentStatus.scheduled),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedStatuses.add(AppointmentStatus.scheduled);
                            } else {
                              selectedStatuses
                                  .remove(AppointmentStatus.scheduled);
                            }
                          });
                        },
                      ),
                      _FilterChip(
                        label: 'In Progress',
                        selected: selectedStatuses
                            .contains(AppointmentStatus.inProgress),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedStatuses
                                  .add(AppointmentStatus.inProgress);
                            } else {
                              selectedStatuses
                                  .remove(AppointmentStatus.inProgress);
                            }
                          });
                        },
                      ),
                      _FilterChip(
                        label: 'Completed',
                        selected: selectedStatuses
                            .contains(AppointmentStatus.completed),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedStatuses.add(AppointmentStatus.completed);
                            } else {
                              selectedStatuses
                                  .remove(AppointmentStatus.completed);
                            }
                          });
                        },
                      ),
                      _FilterChip(
                        label: 'Canceled',
                        selected: selectedStatuses
                            .contains(AppointmentStatus.cancelled),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedStatuses.add(AppointmentStatus.cancelled);
                            } else {
                              selectedStatuses
                                  .remove(AppointmentStatus.cancelled);
                            }
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Patient Name Filter
                  const Text(
                    'Patient Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: patientNameController,
                    decoration: const InputDecoration(
                      hintText: 'Search by patient name',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Service Name Filter
                  const Text(
                    'Service',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: serviceNameController,
                    decoration: const InputDecoration(
                      hintText: 'Search by service',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Location Filter
                  const Text(
                    'Location',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      hintText: 'Search by location',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Reset all filters
                  context.read<DoctorAppointmentsBloc>().add(ResetFilters());
                  Navigator.pop(dialogContext);
                },
                child: const Text('Reset', style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Apply filter
                  final newFilterCriteria = AppointmentFilterCriteria(
                    fromDate: fromDate,
                    toDate: toDate,
                    statusFilter: selectedStatuses.isNotEmpty
                        ? selectedStatuses.toList()
                        : null,
                    patientNameFilter: patientNameController.text.isNotEmpty
                        ? patientNameController.text
                        : null,
                    serviceNameFilter: serviceNameController.text.isNotEmpty
                        ? serviceNameController.text
                        : null,
                    locationFilter: locationController.text.isNotEmpty
                        ? locationController.text
                        : null,
                  );

                  context.read<DoctorAppointmentsBloc>().add(
                        FilterAppointments(filterCriteria: newFilterCriteria),
                      );

                  Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Filter chip widget
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool) onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Colors.grey[200],
      selectedColor: MyColors.primary.withValues(alpha: 0.2),
      checkmarkColor: MyColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? MyColors.primary : Colors.transparent,
        ),
      ),
    );
  }
}

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
    final isPast = appointment.appointmentDate.isBefore(DateTime.now()) &&
        appointment.status != AppointmentStatus.cancelled;
    final isMissed = appointment.status == AppointmentStatus.cancelled;

    // Check if this appointment has been viewed
    bool isViewed = true;
    final state = context.watch<DoctorAppointmentsBloc>().state;
    if (state is DoctorAppointmentsLoaded) {
      isViewed = state.isAppointmentViewed(appointment.appointmentId ?? '');
    }

    bool isAppointmentReady() {
      if (isUpcoming) return false;
      if (isPast && appointment.status == AppointmentStatus.completed) {
        return false;
      }
      if (isMissed) return false;

      return true;
    }

    bool isAppointmentPastOrMissing() {
      if (isPast || isMissed) return false;

      return true;
    }

    return Stack(
      children: [
        AppointmentWidgetDoctor(
          appointmentDate: appointment.appointmentDate,
          location: appointment.location ?? "Online Consultation",
          specialty: appointment.specialty,
          name: appointmentPatientCard.patient.name!,
          serviceName: appointment.serviceName,
          fee: appointment.fee,
          isReady: isAppointmentReady(),
          status: appointment.status,
          showButton: isAppointmentPastOrMissing(),
          onJoinCall: () {
            _handleJoinCall(context, appointment);
          },
          onCardTap: () {
            // Mark as viewed when clicked
            context.read<DoctorAppointmentsBloc>().add(
                  MarkAppointmentViewed(
                      appointmentId: appointment.appointmentId ?? ''),
                );
          },
          onCancel: () {
            context.read<DoctorAppointmentsBloc>().add(
                  UpdateAppointmentStatus(
                    appointmentId: appointment.appointmentId ?? '',
                    newStatus: AppointmentStatus.cancelled,
                  ),
                );
          },
          isPast: isPast,
        ),

        // Show a badge for unviewed appointments
        if (!isViewed && (isUpcoming || isMissed))
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isMissed ? Colors.red : Colors.blue,
              ),
            ),
          ),
      ],
    );
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
