import 'package:backend/backend.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:p_logger/p_logger.dart';

import '../models/selection_item.dart';

part 'setup_appointment_event.dart';
part 'setup_appointment_state.dart';

class SetupAppointmentBloc
    extends Bloc<SetupAppointmentEvent, SetupAppointmentState> {
  bool reBuild = false;

  SetupAppointmentBloc({
    required IMailRepository mailRepository,
    required IAppointmentRepository appointmentRepository,
    required IAuthenticationRepository authenticationRepository,
  })  : _mailRepository = mailRepository,
        _appointmentRepository = appointmentRepository,
        _authenticationRepository = authenticationRepository,
        super(const SetupAppointmentState()) {
    on<ToggleRebuild>((event, emit) async {
      reBuild = !reBuild;

      emit(SetupAppointmentState(reBuild: reBuild));
    });
    on<LoadServiceTypes>(_onLoadServiceTypes);
    on<UpdateServiceType>(_onUpdateServiceType);
    on<UpdateAppointmentDate>(_onUpdateAppointmentDate);
    on<UpdateAppointmentType>(_onUpdateAppointmentType);
    on<UpdatePaymentType>(_onUpdatePaymentType);
    on<UpdateAppointmentTime>(_onUpdateAppointmentTime);
    on<BookAppointment>(_onBookAppointment);
    on<UpdateDoctorInfo>(_onUpdateDoctorInfo);
  }

  final IMailRepository _mailRepository;
  final IAppointmentRepository _appointmentRepository;
  final IAuthenticationRepository _authenticationRepository;

  void _onUpdateDoctorInfo(
      UpdateDoctorInfo event, Emitter<SetupAppointmentState> emit) {
    emit(state.copyWith(specialty: event.specialty, doctorId: event.doctorId));
  }

  Future<void> _onBookAppointment(
      BookAppointment event, Emitter<SetupAppointmentState> emit) async {
    try {
      DateTime concatDateWithTime(DateTime date, TimeOfDay time) {
        return DateTime(
            date.year, date.month, date.day, time.hour, time.minute);
      }

      logger.i("Booking appointment");
      await Future.wait([
        _appointmentRepository.createAppointment(Appointment(
            status: AppointmentStatus.initiated,
            appointmentDate: concatDateWithTime(
                state.appointmentDate!, state.appointmentTime),
            doctorId: state.doctorId,
            fee: state.selectedService!.price!,
            appointmentType: state.selectedAppointment!,
            patientId: _authenticationRepository.currentUser.uid,
            serviceName: state.selectedService!.title,
            specialty: state.specialty,
            duration: state.selectedService!.value! as int,
            location: state.appointmentLocation)),

        // Simulate booking
        _mailRepository.sendMail(
            to: _authenticationRepository.currentUser.email,
            templateName: "appointment_confirmation",
            templateData: {
              "userName": _authenticationRepository.currentUser.name,
              "doctorName": "Dr. Smith",
              "specialties": "Family Medicine, Cardiology",
              "appointmentDate": "${state.appointmentDate}",
              "appointmentTime": "${state.appointmentTime}",
              "sessionLength": 30,
              "fee": state.selectedService!.price,
              "currency": "\$",
              "appName": "BioHack"
            })
      ]);
      logger.i("Appointment booked");
    } catch (e) {
      logger.e(e);
      emit(state.copyWith(errorMessage: e.toString()));
    }
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
