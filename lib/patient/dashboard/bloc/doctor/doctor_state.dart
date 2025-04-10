part of 'doctor_bloc.dart';

abstract class PatientDoctorState extends Equatable {
  const PatientDoctorState();

  @override
  List<Object> get props => [];
}

class PatientDoctorsInitial extends PatientDoctorState {}

class PatientDoctorsLoading extends PatientDoctorState {}

class PatientDoctorsLoaded extends PatientDoctorState {
  final List<Doctor> doctors;

  const PatientDoctorsLoaded(this.doctors);

  @override
  List<Object> get props => [doctors];
}

class PatientDoctorsError extends PatientDoctorState {
  final String message;

  const PatientDoctorsError(this.message);

  @override
  List<Object> get props => [message];
}
