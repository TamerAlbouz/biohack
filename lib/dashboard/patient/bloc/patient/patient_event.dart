part of 'patient_bloc.dart';

sealed class PatientEvent extends Equatable {
  const PatientEvent();
}

class LoadPatient extends PatientEvent {
  @override
  List<Object> get props => [];
}
