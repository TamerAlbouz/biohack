part of 'setup_appointment_bloc.dart';

final class SetupAppointmentState extends Equatable {
  final bool reBuild;
  final String serviceType;
  final DateTime? appointmentDate;
  final TimeOfDay appointmentTime;
  final SelectionItem? selectedService;
  final String selectedAppointment;
  final String appointmentLocation;
  final String selectedPayment;
  final List<String> serviceTypes;

  const SetupAppointmentState(
      {this.reBuild = false,
      this.serviceTypes = const [],
      this.serviceType = '',
      this.appointmentDate,
      this.appointmentTime = const TimeOfDay(hour: 0, minute: 0),
      this.appointmentLocation = '',
      this.selectedService,
      this.selectedAppointment = '',
      this.selectedPayment = ''});

  SetupAppointmentState copyWith({
    bool? reBuild,
    String? serviceType,
    DateTime? appointmentDate,
    TimeOfDay? appointmentTime,
    String? appointmentLocation,
    SelectionItem? selectedService,
    String? selectedAppointment,
    String? selectedPayment,
    List<String>? serviceTypes,
  }) {
    return SetupAppointmentState(
      reBuild: reBuild ?? this.reBuild,
      serviceTypes: serviceTypes ?? this.serviceTypes,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentLocation: appointmentLocation ?? this.appointmentLocation,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      selectedService: selectedService ?? this.selectedService,
      selectedAppointment: selectedAppointment ?? this.selectedAppointment,
      selectedPayment: selectedPayment ?? this.selectedPayment,
      serviceType: serviceType ?? this.serviceType,
    );
  }

  @override
  List<Object?> get props => [
        reBuild,
        serviceTypes,
        serviceType,
        appointmentDate,
        appointmentTime,
        appointmentLocation,
        selectedService,
        selectedAppointment,
        selectedPayment
      ];
}
