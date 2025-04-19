import 'package:equatable/equatable.dart';
import 'package:medtalk/backend/appointment/models/appointment.dart';
import 'package:medtalk/backend/patient/models/patient.dart';

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
