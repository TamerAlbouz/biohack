import 'package:backend/backend.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:p_logger/p_logger.dart';

import '../../../doctor/design/models/design_models.dart';
import '../models/search_doctors_models.dart';
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
    required IDoctorRepository doctorRepository,
  })  : _mailRepository = mailRepository,
        _appointmentRepository = appointmentRepository,
        _authenticationRepository = authenticationRepository,
        _doctorRepository = doctorRepository,
        super(const SetupAppointmentState()) {
    on<ToggleRebuild>(_onToggleRebuild);
    on<LoadInitialData>(_onLoadInitialData);
    on<UpdateServiceType>(_onUpdateServiceType);
    on<UpdateAppointmentDate>(_onUpdateAppointmentDate);
    on<UpdateAppointmentType>(_onUpdateAppointmentType);
    on<UpdatePaymentType>(_onUpdatePaymentType);
    on<UpdateAppointmentTime>(_onUpdateAppointmentTime);
    on<BookAppointment>(_onBookAppointment);
    on<UpdateDoctorInfo>(_onUpdateDoctorInfo);
    on<ToggleTermsAccepted>(_onToggleTermsAccepted);
  }

  final IMailRepository _mailRepository;
  final IAppointmentRepository _appointmentRepository;
  final IAuthenticationRepository _authenticationRepository;
  final IDoctorRepository _doctorRepository;

  void _onToggleRebuild(
      ToggleRebuild event, Emitter<SetupAppointmentState> emit) {
    reBuild = !reBuild;
    emit(state.copyWith(reBuild: reBuild));
  }

  void _onToggleTermsAccepted(
      ToggleTermsAccepted event, Emitter<SetupAppointmentState> emit) {
    emit(state.copyWith(termsAccepted: event.value));
  }

  void _onUpdateDoctorInfo(
      UpdateDoctorInfo event, Emitter<SetupAppointmentState> emit) {
    emit(state.copyWith(specialty: event.specialty, doctorId: event.doctorId));
  }

  Future<void> _onLoadInitialData(
      LoadInitialData event, Emitter<SetupAppointmentState> emit) async {
    try {
      emit(state.copyWith(
        doctorId: event.doctorId,
        specialty: event.specialty,
      ));

      // Get doctor details
      final doctor = await _doctorRepository.getDoctor(event.doctorId);

      if (doctor == null) {
        emit(state.copyWith(errorMessage: 'Doctor not found'));
        return;
      }

      // Build available days list based on doctor's schedule
      List<bool> availableDays = List.generate(7, (index) => false);
      List<WorkingHours> workingHours = List.generate(
        7,
        (index) => const WorkingHours(
          isWorking: false,
          startTime: '09:00',
          endTime: '17:00',
          breaks: [],
        ),
      );

      // Parse doctor's availability into working days/hours
      doctor.availability.forEach((day, timeSlots) {
        if (timeSlots != null && timeSlots.isNotEmpty) {
          // Get day index (0 = Monday, 6 = Sunday)
          int dayIndex;
          switch (day.toLowerCase()) {
            case 'monday':
              dayIndex = 0;
              break;
            case 'tuesday':
              dayIndex = 1;
              break;
            case 'wednesday':
              dayIndex = 2;
              break;
            case 'thursday':
              dayIndex = 3;
              break;
            case 'friday':
              dayIndex = 4;
              break;
            case 'saturday':
              dayIndex = 5;
              break;
            case 'sunday':
              dayIndex = 6;
              break;
            default:
              dayIndex = -1;
              break;
          }

          if (dayIndex >= 0) {
            availableDays[dayIndex] = true;

            // Parse start and end times
            if (timeSlots.length >= 2) {
              workingHours[dayIndex] = WorkingHours(
                isWorking: true,
                startTime: timeSlots[0],
                endTime: timeSlots.last,
                breaks: const [], // We don't have break information from doctor model
              );
            }
          }
        }
      });

      // Mock doctor services for now - in a real app, you'd fetch these from backend
      List<DoctorService> services = [
        const DoctorService(
          id: '1',
          title: 'General Consultation',
          description: 'Comprehensive health check with personalized advice',
          duration: 45,
          price: 100,
          isOnline: true,
          isInPerson: true,
          isHomeVisit: false,
          preAppointmentInstructions:
              'Please bring your medical records and a list of current medications.',
        ),
        const DoctorService(
          id: '2',
          title: 'Follow-up Visit',
          description: 'Review of treatment progress and adjustments',
          duration: 30,
          price: 75,
          isOnline: true,
          isInPerson: true,
          isHomeVisit: false,
          preAppointmentInstructions: null,
        ),
        const DoctorService(
          id: '3',
          title: 'Specialized Treatment',
          description: 'Advanced procedures specific to your condition',
          duration: 60,
          price: 150,
          isOnline: false,
          isInPerson: true,
          isHomeVisit: false,
          preAppointmentInstructions:
              'Please fast for 8 hours before the appointment.',
        ),
      ];

      // Mock reviews
      List<PatientReview> reviews = [
        PatientReview(
          author: 'John Smith',
          text:
              'Great doctor! Very knowledgeable and attentive. Highly recommend.',
          date: DateTime.now().subtract(const Duration(days: 5)),
        ),
        PatientReview(
          author: 'Emma Johnson',
          text:
              'Excellent care and professional service. Dr. ${doctor.name} took time to address all my concerns.',
          date: DateTime.now().subtract(const Duration(days: 15)),
        ),
      ];

      // Update state with doctor information
      emit(state.copyWith(
        doctorBiography: doctor.biography,
        doctorPhone: '+1 123 456 7890',
        // Mock phone since it's not in the doctor model
        doctorAddress: '1234 Clinic St, Portland, OR 97205',
        // Mock address
        doctorNotes: 'Free parking available in the back',
        // Mock notes
        doctorLocation: const LatLng(45.521563, -122.677433),
        // Mock location
        doctorWorkingHours: workingHours,
        doctorAvailableDays: availableDays,
        defaultSlotDuration: 30,
        appointmentDate: DateTime.now(),
        // Mock default slot duration
        bufferTime: 10,
        // Mock buffer time
        doctorServices: services,
        cancellationPolicy: 24,
        // Mock cancellation policy
        acceptsCash: true,
        // Mock payment methods
        acceptsCreditCard: true,
        acceptsInsurance: false,
        doctorReviews: reviews,
      ));
    } catch (e) {
      logger.e('Error loading initial data: $e');
      emit(state.copyWith(errorMessage: e.toString()));
    }
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
            status: AppointmentStatus.scheduled,
            appointmentDate: concatDateWithTime(
                state.appointmentDate!, state.appointmentTime!),
            doctorId: state.doctorId!,
            fee: state.selectedService!.price!.toInt(),
            appointmentType: state.selectedAppointment!,
            patientId: _authenticationRepository.currentUser.uid,
            serviceName: state.selectedService!.title,
            specialty: state.specialty!,
            duration: state.selectedService!.value is int
                ? state.selectedService!.value as int
                : state.defaultSlotDuration,
            location: state.appointmentLocation)),

        // Simulate booking
        // _mailRepository.sendMail(
        //     to: _authenticationRepository.currentUser.email,
        //     templateName: "appointment_confirmation",
        //     templateData: {
        //       "userName": _authenticationRepository.currentUser.name,
        //       "doctorName": "Dr. Smith",
        //       "specialties": "Family Medicine, Cardiology",
        //       "appointmentDate": "${state.appointmentDate}",
        //       "appointmentTime": "${state.appointmentTime}",
        //       "sessionLength": state.selectedService!.value is int
        //           ? state.selectedService!.value as int
        //           : state.defaultSlotDuration,
        //       "fee": state.selectedService!.price,
        //       "currency": "\$",
        //       "appName": "BioHack"
        //     })
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
    // Check if service has custom availability
    ServiceAvailability? customAvailability;

    // This is where you would get the service's custom availability if it exists
    // For now, we'll just mock it for one of the services as an example
    if (event.serviceType.value == '3') {
      customAvailability = const ServiceAvailability(
        days: [true, true, false, true, true, false, false],
        // Only available on Mon, Tue, Thu, Fri
        startTime: '10:00',
        endTime: '16:00',
      );
    }

    emit(state.copyWith(
      selectedService: event.serviceType,
      selectedServiceAvailability: customAvailability,
    ));
  }

  void _onUpdateAppointmentTime(
      UpdateAppointmentTime event, Emitter<SetupAppointmentState> emit) {
    emit(state.copyWith(appointmentTime: event.time));
  }
}
