part of 'statistics_bloc.dart';

abstract class StatisticsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsLoaded extends StatisticsState {
  final StatsPeriod period;
  final int totalAppointments;
  final double appointmentChange;
  final int completedAppointments;
  final int scheduledAppointments;
  final int canceledAppointments;
  final int noShowAppointments;
  final double completionRate;
  final double completionRateChange;
  final int averageDuration;
  final int shortestDuration;
  final int longestDuration;
  final int mostCommonDuration;
  final double revenue;
  final double revenueChange;
  final List<ServiceStats> topServices;
  final List<DayStats> busiestDays;
  final List<CancellationReason> cancellationReasons;
  final int totalPatients;
  final int newPatients;
  final double newPatientsChange;
  final double patientRetentionRate;
  final double averageVisitsPerPatient;
  final double patientSatisfactionRating;
  final RatingDistribution ratings;
  final List<ReferralSource> referralSources;

  StatisticsLoaded({
    required this.period,
    required this.totalAppointments,
    required this.appointmentChange,
    required this.completedAppointments,
    required this.scheduledAppointments,
    required this.canceledAppointments,
    required this.noShowAppointments,
    required this.completionRate,
    required this.completionRateChange,
    required this.averageDuration,
    required this.shortestDuration,
    required this.longestDuration,
    required this.mostCommonDuration,
    required this.revenue,
    required this.revenueChange,
    required this.topServices,
    required this.busiestDays,
    required this.cancellationReasons,
    required this.totalPatients,
    required this.newPatients,
    required this.newPatientsChange,
    required this.patientRetentionRate,
    required this.averageVisitsPerPatient,
    required this.patientSatisfactionRating,
    required this.ratings,
    required this.referralSources,
  });

  @override
  List<Object?> get props => [
        period,
        totalAppointments,
        appointmentChange,
        completedAppointments,
        scheduledAppointments,
        canceledAppointments,
        noShowAppointments,
        completionRate,
        completionRateChange,
        averageDuration,
        shortestDuration,
        longestDuration,
        mostCommonDuration,
        revenue,
        revenueChange,
        topServices,
        busiestDays,
        cancellationReasons,
        totalPatients,
        newPatients,
        newPatientsChange,
        patientRetentionRate,
        averageVisitsPerPatient,
        patientSatisfactionRating,
        ratings,
        referralSources,
      ];
}

class StatisticsError extends StatisticsState {
  final String message;

  StatisticsError(this.message);

  @override
  List<Object> get props => [message];
}
