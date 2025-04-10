import 'package:backend/backend.dart';
import 'package:equatable/equatable.dart';

class AppointmentPatientCard extends Equatable {
  final Appointment appointment;
  final Patient patient;

  const AppointmentPatientCard({
    required this.appointment,
    required this.patient,
  });

  @override
  List<Object> get props => [appointment, patient];
}
