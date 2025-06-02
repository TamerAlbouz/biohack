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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.primaryColor,
        title: Text(
          'Appointments',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onBackground,
          ),
        ),
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
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.onBackground.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorColor: theme.primaryColor,
                    labelColor: theme.colorScheme.onBackground,
                    unselectedLabelColor:
                        theme.colorScheme.onBackground.withOpacity(0.6),
                    isScrollable: true,
                    dividerColor: Colors.transparent,
                    tabs: [
                      const BadgedTab(
                        text: 'Today',
                        icon: FontAwesomeIcons.calendarDay,
                      ),
                      BadgedTab(
                        text: 'Upcoming',
                        icon: FontAwesomeIcons.calendarPlus,
                        badgeCount: unviewedUpcomingCount,
                        badgeColor: theme.primaryColor,
                      ),
                      const BadgedTab(
                        text: 'Past',
                        icon: FontAwesomeIcons.clockRotateLeft,
                      ),
                      BadgedTab(
                        text: 'Missed',
                        icon: FontAwesomeIcons.calendarXmark,
                        badgeCount: unviewedMissedCount,
                        badgeColor: MyColors.cancel,
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
                    icon: FaIcon(
                      FontAwesomeIcons.filter,
                      size: 20,
                      color: hasActiveFilters
                          ? theme.primaryColor
                          : theme.colorScheme.onBackground,
                    ),
                    onPressed: () {
                      // Show enhanced filter dialog
                      _showEnhancedFilterDialog(context);
                    },
                  ),
                  if (hasActiveFilters)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
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
                backgroundColor: MyColors.cancel,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(10),
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
              return Center(
                child: CircularProgressIndicator(
                  color: theme.primaryColor,
                ),
              );
            case DoctorAppointmentsLoading():
              return Center(
                child: CircularProgressIndicator(
                  color: theme.primaryColor,
                ),
              );
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
              return Center(
                child: Text(
                  'Unexpected state',
                  style: theme.textTheme.bodyMedium,
                ),
              );
          }
        },
      ),
    );
  }

  void _showEnhancedFilterDialog(BuildContext context) {
    final theme = Theme.of(context);

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
            title: Text(
              'Filter Appointments',
              style: theme.textTheme.titleMedium,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range Section
                  Text(
                    'Date Range',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          icon: FaIcon(
                            FontAwesomeIcons.calendarDay,
                            size: 16,
                            color: theme.primaryColor,
                          ),
                          label: Text(
                            fromDate != null
                                ? DateFormat('MMM dd, yyyy').format(fromDate!)
                                : 'From Date',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: fromDate != null
                                  ? theme.colorScheme.onBackground
                                  : theme.colorScheme.onBackground
                                      .withOpacity(0.6),
                            ),
                          ),
                          onPressed: () async {
                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: fromDate ?? DateTime.now(),
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 365)),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
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
                          icon: FaIcon(
                            FontAwesomeIcons.calendarDay,
                            size: 16,
                            color: theme.primaryColor,
                          ),
                          label: Text(
                            toDate != null
                                ? DateFormat('MMM dd, yyyy').format(toDate!)
                                : 'To Date',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: toDate != null
                                  ? theme.colorScheme.onBackground
                                  : theme.colorScheme.onBackground
                                      .withOpacity(0.6),
                            ),
                          ),
                          onPressed: () async {
                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: toDate ?? DateTime.now(),
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 365)),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
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
                  Text(
                    'Status',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
                  Text(
                    'Patient Name',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: patientNameController,
                    decoration: InputDecoration(
                      hintText: 'Search by patient name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color:
                              theme.colorScheme.onBackground.withOpacity(0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color:
                              theme.colorScheme.onBackground.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: theme.primaryColor,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      hintStyle: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.5),
                      ),
                    ),
                    style: theme.textTheme.labelMedium,
                  ),

                  const SizedBox(height: 16),

                  // Service Name Filter
                  Text(
                    'Service',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: serviceNameController,
                    decoration: InputDecoration(
                      hintText: 'Search by service',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color:
                              theme.colorScheme.onBackground.withOpacity(0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color:
                              theme.colorScheme.onBackground.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: theme.primaryColor,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      hintStyle: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.5),
                      ),
                    ),
                    style: theme.textTheme.labelMedium,
                  ),

                  const SizedBox(height: 16),

                  // Location Filter
                  Text(
                    'Location',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                      hintText: 'Search by location',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color:
                              theme.colorScheme.onBackground.withOpacity(0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color:
                              theme.colorScheme.onBackground.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: theme.primaryColor,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      hintStyle: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.5),
                      ),
                    ),
                    style: theme.textTheme.labelMedium,
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
                style: TextButton.styleFrom(
                  foregroundColor: MyColors.cancel,
                ),
                child: Text(
                  'Reset',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: MyColors.cancel,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.onBackground,
                ),
                child: Text(
                  'Cancel',
                  style: theme.textTheme.labelMedium,
                ),
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
                  backgroundColor: theme.primaryColor,
                  foregroundColor: theme.colorScheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Apply',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: selected ? theme.primaryColor : theme.colorScheme.onBackground,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: theme.colorScheme.onBackground.withOpacity(0.05),
      selectedColor: theme.primaryColor.withOpacity(0.15),
      checkmarkColor: theme.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? theme.primaryColor : Colors.transparent,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    final theme = Theme.of(context);
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
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isMissed ? MyColors.cancel : theme.primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: (isMissed ? MyColors.cancel : theme.primaryColor)
                        .withOpacity(0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _handleJoinCall(BuildContext context, Appointment appointment) {
    final theme = Theme.of(context);

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
        SnackBar(
          content: Text(
            "You can only join calls within 10 minutes of the appointment time",
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: MyColors.cancel,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
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
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            FontAwesomeIcons.calendarXmark,
            size: 48,
            color: theme.colorScheme.onBackground.withOpacity(0.4),
          ),
          kGap20,
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
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
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            FontAwesomeIcons.circleExclamation,
            size: 48,
            color: MyColors.cancel.withOpacity(0.8),
          ),
          kGap20,
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: MyColors.cancel.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: MyColors.cancel.withOpacity(0.3),
              ),
            ),
            child: Text(
              'Error: $message',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: MyColors.cancel,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          kGap20,
          ElevatedButton.icon(
            onPressed: () {
              context
                  .read<DoctorAppointmentsBloc>()
                  .add(LoadDoctorAppointments());
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
