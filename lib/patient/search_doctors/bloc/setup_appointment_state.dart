part of 'setup_appointment_bloc.dart';

final class SetupAppointmentState extends Equatable {
  final bool reBuild;
  final String specialty;
  final String doctorId;
  final DateTime? appointmentDate;
  final TimeOfDay appointmentTime;
  final SelectionItem? selectedService;
  final AppointmentType? selectedAppointment;
  final String appointmentLocation;
  final String selectedPayment;
  final String errorMessage;

  const SetupAppointmentState(
      {this.reBuild = false,
      this.specialty = '',
      this.appointmentDate,
      this.doctorId = '',
      this.appointmentTime = const TimeOfDay(hour: 0, minute: 0),
      this.appointmentLocation = '',
      this.selectedService,
      this.selectedAppointment,
      this.selectedPayment = '',
      this.errorMessage = ''});

  SetupAppointmentState copyWith({
    bool? reBuild,
    String? specialty,
    String? doctorId,
    DateTime? appointmentDate,
    TimeOfDay? appointmentTime,
    String? appointmentLocation,
    SelectionItem? selectedService,
    AppointmentType? selectedAppointment,
    String? selectedPayment,
    String? errorMessage,
  }) {
    return SetupAppointmentState(
      reBuild: reBuild ?? this.reBuild,
      doctorId: doctorId ?? this.doctorId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentLocation: appointmentLocation ?? this.appointmentLocation,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      selectedService: selectedService ?? this.selectedService,
      selectedAppointment: selectedAppointment ?? this.selectedAppointment,
      selectedPayment: selectedPayment ?? this.selectedPayment,
      specialty: specialty ?? this.specialty,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        reBuild,
        doctorId,
        specialty,
        appointmentDate,
        appointmentTime,
        appointmentLocation,
        selectedService,
        selectedAppointment,
        selectedPayment,
        errorMessage
      ];
}
