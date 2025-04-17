// Events
part of 'doctor_profile_bloc.dart';

abstract class DoctorProfileEvent extends Equatable {
  const DoctorProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadDoctorProfile extends DoctorProfileEvent {
  final String doctorId;

  const LoadDoctorProfile(this.doctorId);

  @override
  List<Object?> get props => [doctorId];
}
