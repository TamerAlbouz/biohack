part of 'doctor_bloc.dart';

abstract class PatientDoctorEvent extends Equatable {
  const PatientDoctorEvent();

  @override
  List<Object> get props => [];
}

class LoadPatientDoctors extends PatientDoctorEvent {
  final String patientId;

  const LoadPatientDoctors(this.patientId);

  @override
  List<Object> get props => [patientId];
}
