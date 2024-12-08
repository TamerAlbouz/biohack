import 'package:backend/backend.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../models/selection_item.dart';

part 'setup_appointment_event.dart';
part 'setup_appointment_state.dart';

class SetupAppointmentBloc
    extends Bloc<SetupAppointmentEvent, SetupAppointmentState> {
  bool reBuild = false;

  SetupAppointmentBloc({
    required IMailRepository mailRepository,
  })  : _mailRepository = mailRepository,
        super(const SetupAppointmentState()) {
    on<ToggleRebuild>((event, emit) async {
      reBuild = !reBuild;

      emit(SetupAppointmentState(
          reBuild: reBuild,
          serviceTypes: const ['Treatment', 'Consultation', 'Checkup']));
    });
    on<LoadServiceTypes>(_onLoadServiceTypes);
    on<UpdateServiceType>(_onUpdateServiceType);
    on<UpdateAppointmentDate>(_onUpdateAppointmentDate);
    on<UpdateAppointmentType>(_onUpdateAppointmentType);
    on<UpdatePaymentType>(_onUpdatePaymentType);
    on<UpdateAppointmentTime>(_onUpdateAppointmentTime);
    on<BookAppointment>(_onBookAppointment);
  }

  final IMailRepository _mailRepository;

  Future<void> _onBookAppointment(
      BookAppointment event, Emitter<SetupAppointmentState> emit) async {
    // Simulate booking
    await _mailRepository.sendMail(
        to: "tameralbouz9@gmail.com",
        templateName: "appointment_confirmation",
        templateData: {
          "userName": "John Doe",
          "doctorName": "Dr. Smith",
          "specialties": "Family Medicine, Cardiology",
          "appointmentDate": "${state.appointmentDate}",
          "appointmentTime": "${state.appointmentTime}",
          "sessionLength": 30,
          "fee": state.selectedService!.price,
          "currency": "\$",
          "appName": "BioHack"
        });
  }

  void _onUpdatePaymentType(
      UpdatePaymentType event, Emitter<SetupAppointmentState> emit) {
    emit(state.copyWith(selectedPayment: event.paymentType));
  }

  void _onUpdateAppointmentType(
      UpdateAppointmentType event, Emitter<SetupAppointmentState> emit) {
    emit(state.copyWith(
        selectedAppointment: event.appointmentType,
        appointmentLocation: event.appointmentLocation));
  }

  void _onUpdateAppointmentDate(
      UpdateAppointmentDate event, Emitter<SetupAppointmentState> emit) {
    emit(state.copyWith(appointmentDate: event.date));
  }

  void _onUpdateServiceType(
      UpdateServiceType event, Emitter<SetupAppointmentState> emit) {
    emit(state.copyWith(selectedService: event.serviceType));
  }

  void _onUpdateAppointmentTime(
      UpdateAppointmentTime event, Emitter<SetupAppointmentState> emit) {
    emit(state.copyWith(appointmentTime: event.time));
  }

  void _onLoadServiceTypes(
      LoadServiceTypes event, Emitter<SetupAppointmentState> emit) async {
    // Simulate loading
    await Future.delayed(const Duration(seconds: 1));
  }
}
