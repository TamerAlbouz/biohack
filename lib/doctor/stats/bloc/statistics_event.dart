part of 'statistics_bloc.dart';

abstract class StatisticsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDoctorStats extends StatisticsEvent {
  final StatsPeriod period;

  LoadDoctorStats({this.period = StatsPeriod.month});

  @override
  List<Object?> get props => [period];
}
