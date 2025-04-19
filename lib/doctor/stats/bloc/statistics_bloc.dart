import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:medtalk/backend/appointment/enums/appointment_status.dart';
import 'package:medtalk/backend/appointment/interfaces/appointment_interface.dart';
import 'package:medtalk/backend/authentication/interfaces/auth_interface.dart';
import 'package:medtalk/backend/patient/interfaces/patient_interface.dart';
import 'package:medtalk/backend/patient/models/patient.dart';

import '../models/statistics_models.dart';

part 'statistics_event.dart';
part 'statistics_state.dart';

@injectable
class DoctorStatsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final IAuthenticationRepository _authRepository;
  final IAppointmentRepository _appointmentRepository;
  final IPatientRepository _patientRepository;
  final Logger logger;

  DoctorStatsBloc(this._authRepository, this._appointmentRepository,
      this._patientRepository, this.logger)
      : super(StatisticsInitial()) {
    on<LoadDoctorStats>(_onLoadDoctorStats);
  }

  Future<void> _onLoadDoctorStats(
    LoadDoctorStats event,
    Emitter<StatisticsState> emit,
  ) async {
    try {
      emit(StatisticsLoading());

      // Get current doctor ID
      final currentUser = _authRepository.currentUser;

      // Get time range based on selected period
      final DateTime fromDate = _getFromDate(event.period);
      final DateTime toDate = DateTime.now();

      // Get previous period for comparison
      final DateTime prevFromDate =
          _getPreviousPeriodStart(fromDate, event.period);

      // Get all doctor's appointments and filter by date range
      final allAppointments =
          await _appointmentRepository.getDoctorAppointments(currentUser.uid);

      // Filter appointments for current period
      final appointments = allAppointments
          .where((appointment) =>
              appointment.appointmentDate.isAfter(fromDate) &&
              appointment.appointmentDate.isBefore(toDate))
          .toList();

      // Filter appointments for previous period
      final previousAppointments = allAppointments
          .where((appointment) =>
              appointment.appointmentDate.isAfter(prevFromDate) &&
              appointment.appointmentDate.isBefore(fromDate))
          .toList();

      // Get unique patient IDs from all appointments
      final patientIds =
          allAppointments.map((a) => a.patientId).toSet().toList();

      // Fetch patient details for all patient IDs
      final patientMap = <String, Patient>{};
      for (final patientId in patientIds) {
        final patient = await _patientRepository.getPatient(patientId);
        if (patient != null) {
          patientMap[patientId] = patient;
        }
      }

      // Create a list of patients
      final patients = patientMap.values.toList();

      // Calculate statistics
      final totalAppointments = appointments.length;
      final prevTotalAppointments = previousAppointments.length;

      // Calculate appointment change percentage
      final appointmentChange = prevTotalAppointments > 0
          ? ((totalAppointments - prevTotalAppointments) /
                  prevTotalAppointments) *
              100
          : 0.0;

      // Calculate completed appointments
      final completedAppointments = appointments
          .where((a) => a.status == AppointmentStatus.completed)
          .length;

      final previousCompletedAppointments = previousAppointments
          .where((a) => a.status == AppointmentStatus.completed)
          .length;

      // Calculate completion rate
      final completionRate = totalAppointments > 0
          ? (completedAppointments / totalAppointments) * 100
          : 0.0;

      final prevCompletionRate = prevTotalAppointments > 0
          ? (previousCompletedAppointments / prevTotalAppointments) * 100
          : 0.0;

      // Calculate completion rate change
      final completionRateChange =
          prevCompletionRate > 0 ? completionRate - prevCompletionRate : 0.0;

      // Get scheduled appointments
      final scheduledAppointments = appointments
          .where((a) => a.status == AppointmentStatus.scheduled)
          .length;

      // Get canceled appointments
      final canceledAppointments = appointments
          .where((a) => a.status == AppointmentStatus.cancelled)
          .length;

      // Get no-show appointments
      final noShowAppointments = appointments
          .where((a) => a.status == AppointmentStatus.missed)
          .length;

      // Calculate average appointment duration
      final totalDuration = appointments
          .map((a) => a.duration ?? 30)
          .fold<int>(0, (sum, duration) => sum + duration);

      final averageDuration =
          totalAppointments > 0 ? totalDuration / totalAppointments : 0.0;

      // Find min and max durations
      final durations = appointments.map((a) => a.duration ?? 30).toList();
      final shortestDuration =
          durations.isNotEmpty ? durations.reduce((a, b) => a < b ? a : b) : 0;
      final longestDuration =
          durations.isNotEmpty ? durations.reduce((a, b) => a > b ? a : b) : 0;

      // Find most common duration
      final durationCounts = <int, int>{};
      for (final duration in durations) {
        durationCounts[duration] = (durationCounts[duration] ?? 0) + 1;
      }

      int mostCommonDuration = 30;
      int maxCount = 0;

      durationCounts.forEach((duration, count) {
        if (count > maxCount) {
          maxCount = count;
          mostCommonDuration = duration;
        }
      });

      // Calculate revenue
      final revenue = appointments
          .map((a) => a.fee)
          .fold<double>(0, (sum, fee) => sum + fee);

      final prevRevenue = previousAppointments
          .map((a) => a.fee)
          .fold<double>(0, (sum, fee) => sum + fee);

      // Calculate revenue change
      final revenueChange =
          prevRevenue > 0 ? ((revenue - prevRevenue) / prevRevenue) * 100 : 0.0;

      // Calculate top services
      final serviceStats = <String, ServiceStats>{};

      for (final appointment in appointments) {
        final serviceName = appointment.serviceName;
        final existingService = serviceStats[serviceName];

        if (existingService == null) {
          serviceStats[serviceName] = ServiceStats(
            name: serviceName,
            count: 1,
            revenue: appointment.fee,
          );
        } else {
          serviceStats[serviceName] = ServiceStats(
            name: serviceName,
            count: existingService.count + 1,
            revenue: existingService.revenue + appointment.fee,
          );
        }
      }

      final topServices = serviceStats.values.toList()
        ..sort((a, b) => b.revenue.compareTo(a.revenue));

      // Calculate busiest days
      final dayCounts = <String, int>{
        'Monday': 0,
        'Tuesday': 0,
        'Wednesday': 0,
        'Thursday': 0,
        'Friday': 0,
        'Saturday': 0,
        'Sunday': 0,
      };

      for (final appointment in appointments) {
        final date = appointment.appointmentDate;
        final day = _getDayName(date.weekday);
        dayCounts[day] = (dayCounts[day] ?? 0) + 1;
      }

      final busiestDays = <DayStats>[];

      dayCounts.forEach((day, count) {
        final percentage =
            totalAppointments > 0 ? (count / totalAppointments) * 100 : 0.0;

        busiestDays.add(DayStats(
          day: day,
          count: count,
          percentage: percentage,
        ));
      });

      busiestDays.sort((a, b) => b.count.compareTo(a.count));

      // Get cancellation reasons
      final cancelReasons = <String, int>{};

      for (final appointment in appointments) {
        if (appointment.status == AppointmentStatus.cancelled) {
          const reason = 'Not specified';
          cancelReasons[reason] = (cancelReasons[reason] ?? 0) + 1;
        }
      }

      final cancellationReasons = <CancellationReason>[];

      cancelReasons.forEach((reason, count) {
        final percentage = canceledAppointments > 0
            ? (count / canceledAppointments) * 100
            : 0.0;

        cancellationReasons.add(CancellationReason(
          reason: reason,
          count: count,
          percentage: percentage,
        ));
      });

      cancellationReasons.sort((a, b) => b.count.compareTo(a.count));

      // Count new patients in the selected period
      final patientFirstAppointments = <String, DateTime>{};

      for (final appointment in allAppointments) {
        final patientId = appointment.patientId;
        final appointmentDate = appointment.appointmentDate;

        if (!patientFirstAppointments.containsKey(patientId) ||
            appointmentDate.isBefore(patientFirstAppointments[patientId]!)) {
          patientFirstAppointments[patientId] = appointmentDate;
        }
      }

      final newPatients = patientFirstAppointments.values
          .where((date) => date.isAfter(fromDate) && date.isBefore(toDate))
          .length;

      final prevNewPatients = patientFirstAppointments.values
          .where(
              (date) => date.isAfter(prevFromDate) && date.isBefore(fromDate))
          .length;

      // Calculate new patients change
      final newPatientsChange = prevNewPatients > 0
          ? ((newPatients - prevNewPatients) / prevNewPatients) * 100
          : 0.0;

      // Calculate patient retention rate
      final returningPatientIds = <String>{};

      for (final appointment in appointments) {
        final firstAppointmentDate =
            patientFirstAppointments[appointment.patientId];

        // If the patient's first appointment was before this period
        if (firstAppointmentDate != null &&
            firstAppointmentDate.isBefore(fromDate)) {
          returningPatientIds.add(appointment.patientId);
        }
      }

      final totalOldPatients = patientFirstAppointments.values
          .where((date) => date.isBefore(fromDate))
          .length;

      final patientRetentionRate = totalOldPatients > 0
          ? (returningPatientIds.length / totalOldPatients) * 100
          : 0.0;

      // Calculate average visits per patient
      final patientVisitCounts = <String, int>{};

      for (final appointment in appointments) {
        final patientId = appointment.patientId;
        patientVisitCounts[patientId] =
            (patientVisitCounts[patientId] ?? 0) + 1;
      }

      final totalPatients = patientVisitCounts.length;

      final averageVisitsPerPatient =
          totalPatients > 0 ? totalAppointments / totalPatients : 0.0;

      // Create mock rating values (since we don't have reviews)
      double patientSatisfactionRating = 4.8; // Default mock value

      const ratings = RatingDistribution(
        oneStar: 1,
        twoStars: 2,
        threeStars: 5,
        fourStars: 15,
        fiveStars: 40,
      );

      // Calculate referral sources (simplified mock data)
      final referralSources = <ReferralSource>[
        ReferralSource(
          source: 'Direct',
          count: patients.isNotEmpty ? (patients.length * 0.4).round() : 10,
          percentage: 40.0,
        ),
        ReferralSource(
          source: 'Doctor Referral',
          count: patients.isNotEmpty ? (patients.length * 0.3).round() : 8,
          percentage: 30.0,
        ),
        ReferralSource(
          source: 'Insurance',
          count: patients.isNotEmpty ? (patients.length * 0.2).round() : 5,
          percentage: 20.0,
        ),
        ReferralSource(
          source: 'Website',
          count: patients.isNotEmpty ? (patients.length * 0.1).round() : 2,
          percentage: 10.0,
        ),
      ];

      // Emit loaded state with all calculated statistics
      emit(StatisticsLoaded(
        period: event.period,
        totalAppointments: totalAppointments,
        appointmentChange: appointmentChange,
        completedAppointments: completedAppointments,
        scheduledAppointments: scheduledAppointments,
        canceledAppointments: canceledAppointments,
        noShowAppointments: noShowAppointments,
        completionRate: completionRate,
        completionRateChange: completionRateChange,
        averageDuration: averageDuration.round(),
        shortestDuration: shortestDuration,
        longestDuration: longestDuration,
        mostCommonDuration: mostCommonDuration,
        revenue: revenue,
        revenueChange: revenueChange,
        topServices: topServices,
        busiestDays: busiestDays,
        cancellationReasons: cancellationReasons,
        totalPatients: patients.length,
        newPatients: newPatients,
        newPatientsChange: newPatientsChange,
        patientRetentionRate: patientRetentionRate,
        averageVisitsPerPatient: averageVisitsPerPatient,
        patientSatisfactionRating: patientSatisfactionRating,
        ratings: ratings,
        referralSources: referralSources,
      ));
    } catch (e) {
      logger.e('Error loading doctor statistics: $e');
      emit(StatisticsError(e.toString()));
    }
  }

  DateTime _getFromDate(StatsPeriod period) {
    final now = DateTime.now();

    switch (period) {
      case StatsPeriod.week:
        // Start of current week (Sunday)
        return DateTime(now.year, now.month, now.day - now.weekday);

      case StatsPeriod.month:
        // Start of current month
        return DateTime(now.year, now.month, 1);

      case StatsPeriod.quarter:
        // Start of current quarter
        final quarterMonth = (now.month - 1) ~/ 3 * 3 + 1;
        return DateTime(now.year, quarterMonth, 1);

      case StatsPeriod.year:
        // Start of current year
        return DateTime(now.year, 1, 1);

      case StatsPeriod.allTime:
        // Start of previous year (arbitrary start point)
        return DateTime(now.year - 3, 1, 1);
    }
  }

  DateTime _getPreviousPeriodStart(DateTime fromDate, StatsPeriod period) {
    switch (period) {
      case StatsPeriod.week:
        // Previous week
        return fromDate.subtract(const Duration(days: 7));

      case StatsPeriod.month:
        // Previous month
        if (fromDate.month == 1) {
          return DateTime(fromDate.year - 1, 12, 1);
        } else {
          return DateTime(fromDate.year, fromDate.month - 1, 1);
        }

      case StatsPeriod.quarter:
        // Previous quarter
        if (fromDate.month <= 3) {
          return DateTime(fromDate.year - 1, 10, 1);
        } else {
          return DateTime(fromDate.year, fromDate.month - 3, 1);
        }

      case StatsPeriod.year:
        // Previous year
        return DateTime(fromDate.year - 1, 1, 1);

      case StatsPeriod.allTime:
        // No previous period for all time
        return fromDate;
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }
}
