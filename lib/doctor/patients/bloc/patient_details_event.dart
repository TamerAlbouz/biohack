part of 'patient_details_bloc.dart';

abstract class PatientDetailsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPatientDetails extends PatientDetailsEvent {}
