import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:medtalk/backend/appointment/enums/appointment_status.dart';
import 'package:medtalk/backend/appointment/enums/appointment_type.dart';
import 'package:medtalk/backend/appointment/interfaces/appointment_interface.dart';
import 'package:medtalk/backend/appointment/models/appointment.dart';
import 'package:medtalk/backend/authentication/interfaces/auth_interface.dart';
import 'package:medtalk/backend/doctor/interfaces/doctor_interface.dart';
import 'package:medtalk/backend/doctor/models/doctor.dart';
import 'package:medtalk/backend/doctor/models/doctor_work_times.dart';
import 'package:medtalk/backend/mail/interfaces/mail_interface.dart';
import 'package:medtalk/backend/patient/interfaces/patient_interface.dart';
import 'package:medtalk/backend/patient/models/patient.dart';
import 'package:medtalk/backend/payment/enums/payment_type.dart';
import 'package:medtalk/backend/services/models/service.dart';

import '../models/search_doctors_models.dart';
import '../models/selection_item.dart';

part 'setup_appointment_event.dart';
part 'setup_appointment_state.dart';

@injectable
class SetupAppointmentBloc
    extends Bloc<SetupAppointmentEvent, SetupAppointmentState> {
  bool reBuild = false;

  SetupAppointmentBloc(
      this._mailRepository,
      this._appointmentRepository,
      this._authenticationRepository,
      this._doctorRepository,
      this._patientRepository,
      this.logger)
      : super(const SetupAppointmentState()) {
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
    on<ResetError>(_onResetError);
    on<SelectCreditCard>(_onSelectCreditCard);
    on<AddCreditCard>(_onAddCreditCard);
  }

  final IMailRepository _mailRepository;
  final IAppointmentRepository _appointmentRepository;
  final IAuthenticationRepository _authenticationRepository;
  final IDoctorRepository _doctorRepository;
  final IPatientRepository _patientRepository;
  final Logger logger;

  void _onSelectCreditCard(
      SelectCreditCard event, Emitter<SetupAppointmentState> emit) {
    emit(state.copyWith(
      selectedCardId: event.cardId,
      selectedPayment: PaymentType.creditCard,
    ));
  }

  void _onAddCreditCard(
      AddCreditCard event, Emitter<SetupAppointmentState> emit) {
    final updatedCards =
        List<SavedCreditCard>.from(state.savedCreditCards ?? []);
    updatedCards.add(event.card);

    emit(state.copyWith(
      savedCreditCards: updatedCards,
      selectedCardId: event.card.id, // Auto-select the new card
      selectedPayment: PaymentType.creditCard,
    ));
  }

  void _onToggleRebuild(
      ToggleRebuild event, Emitter<SetupAppointmentState> emit) {
    reBuild = !reBuild;
    emit(state.copyWith(reBuild: reBuild));
  }

  void _onToggleTermsAccepted(
      ToggleTermsAccepted event, Emitter<SetupAppointmentState> emit) {
    emit(state.copyWith(termsAccepted: event.value));
  }

  void _onResetError(ResetError event, Emitter<SetupAppointmentState> emit) {
    emit(state.copyWith(error: ''));
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
        isLoading: true,
        error: '',
      ));

      // Get credit cards and doctor details in parallel
      final results = await Future.wait([
        _patientRepository
            .getCreditCards(_authenticationRepository.currentUser.uid),
        _doctorRepository.getDoctor(event.doctorId),
      ]);

      final List<SavedCreditCard>? patientCreditCards =
          results[0] as List<SavedCreditCard>?;
      final Doctor? doctor = results[1] as Doctor?;

      if (doctor == null) {
        emit(state.copyWith(
          error: 'Doctor not found',
          isLoading: false,
        ));
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
        if (timeSlots != null) {
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
            workingHours[dayIndex] = WorkingHours(
              isWorking: true,
              startTime: timeSlots.startTime,
              endTime: timeSlots.endTime,
              breaks: timeSlots.breaks
                  .map((breakTime) => BreakTime(
                        startTime: breakTime.startTime.split('-')[0],
                        endTime: breakTime.endTime.split('-')[1],
                      ))
                  .toList(),
            );
          }
        }
      });

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

      // Get a more realistic date (next available day)
      DateTime suggestedDate = _getNextAvailableDate(availableDays);

      // Update state with doctor information
      emit(state.copyWith(
        doctorName: doctor.name,
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
        // Mock default slot duration
        appointmentDate: suggestedDate,
        bufferTime: 10,
        savedCreditCards: patientCreditCards,
        // Mock buffer time
        doctorServices: doctor.services,
        cancellationPolicy: 24,
        // Mock cancellation policy
        acceptsCash: true,
        // Mock payment methods
        acceptsCreditCard: true,
        acceptsInsurance: false,
        doctorReviews: reviews,
        isLoading: false,
      ));
    } catch (e) {
      logger.e('Error loading initial data: $e');
      emit(state.copyWith(
        error: 'Could not load doctor information: ${e.toString()}',
        isLoading: false,
      ));
    }
  }

  DateTime _getNextAvailableDate(List<bool> availableDays) {
    final now = DateTime.now();
    int dayOfWeek = now.weekday - 1; // 0 = Monday, 6 = Sunday

    // Find the next available day
    int daysToAdd = 0;
    for (int i = 0; i < 7; i++) {
      int checkDay = (dayOfWeek + i) % 7;
      if (availableDays[checkDay]) {
        daysToAdd = i;
        break;
      }
    }

    return now.add(Duration(days: daysToAdd));
  }

  Future<void> _onBookAppointment(
      BookAppointment event, Emitter<SetupAppointmentState> emit) async {
    // Validate required fields
    if (state.appointmentDate == null ||
        state.appointmentTime == null ||
        state.selectedService == null ||
        state.selectedAppointment == null ||
        state.selectedPayment == null) {
      emit(state.copyWith(
        error: 'Please complete all fields before booking',
      ));
      return;
    }

    try {
      // Set booking state to show progress indicator
      emit(state.copyWith(isBooking: true, error: ''));

      DateTime concatDateWithTime(DateTime date, TimeOfDay time) {
        return DateTime(
            date.year, date.month, date.day, time.hour, time.minute);
      }

      logger.i("Booking appointment");

      String buildCalendarLink({
        required String doctorName,
        required DateTime appointmentDate,
        required TimeOfDay appointmentTime,
        required String serviceName,
        required int durationMinutes,
        required String specialty,
      }) {
        // Create start and end DateTime objects
        final startDateTime = DateTime(
          appointmentDate.year,
          appointmentDate.month,
          appointmentDate.day,
          appointmentTime.hour,
          appointmentTime.minute,
        );

        final endDateTime =
            startDateTime.add(Duration(minutes: durationMinutes));

        // Format dates for Google Calendar (YYYYMMDDTHHmmssZ format)
        String formatDateTime(DateTime dt) {
          return '${dt.year}${dt.month.toString().padLeft(2, '0')}${dt.day.toString().padLeft(2, '0')}T'
              '${dt.hour.toString().padLeft(2, '0')}${dt.minute.toString().padLeft(2, '0')}00';
        }

        final formattedStart = formatDateTime(startDateTime);
        final formattedEnd = formatDateTime(endDateTime);

        // Create event text and details
        final eventText =
            Uri.encodeComponent('Appointment with Dr. $doctorName');
        final eventDetails = Uri.encodeComponent('$serviceName - $specialty');

        // Build the final URL
        return 'https://calendar.google.com/calendar/render?action=TEMPLATE&text=$eventText'
            '&dates=$formattedStart/$formattedEnd&details=$eventDetails';
      }

      var templateData = {
        // Basic template information
        "title":
            "Your Appointment with Dr. ${state.doctorName} has been booked",

        // User information mapped from your code
        "userName": _authenticationRepository.currentUser.name,

        // Appointment details
        "appointmentDate": "${state.appointmentDate}",
        // formatted from state.appointmentDate
        "appointmentTime": "${state.appointmentTime}",
        // formatted from state.appointmentTime

        // Service details
        "serviceName": state.selectedService!.title,
        // from state.selectedService
        "serviceDuration": "${state.selectedService!.value} minutes",
        // from state.selectedService
        "hasCustomHours": state.selectedServiceAvailability != null,
        // from state.selectedServiceAvailability

        // Doctor information
        "doctorName": state.doctorName,
        // from state.doctorName
        "specialties": state.specialty,
        // from state.specialty

        // Location and type information
        "appointmentType": state.selectedAppointment!.value,
        // from state.selectedAppointment
        "location": state.appointmentLocation,
        // from state.appointmentLocation

        // Payment information
        "paymentMethod": state.selectedPayment!.value,
        // from state.selectedPayment
        "price": state.selectedService!.price,
        // from state.selectedService
        "currency": "\$",

        // Interactive elements
        "calendarLink": buildCalendarLink(
          doctorName: state.doctorName ?? '',
          appointmentDate: state.appointmentDate!,
          appointmentTime: state.appointmentTime!,
          serviceName: state.selectedService!.title,
          durationMinutes: state.selectedService!.value is int
              ? state.selectedService!.value as int
              : state.defaultSlotDuration,
          specialty: state.specialty!,
        ),

        "supportEmail": "biohack@biohack.com",
        // example support email

        // Company information
        "companyName": "BioHack",
        // from appName
        "year": "2025"
        // current year
      };

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

        // Simulate network latency
        Future.delayed(const Duration(seconds: 2)),

        // Send email confirmation
        _mailRepository.sendMail(
          to: _authenticationRepository.currentUser.email,
          templateName: "appointment_confirmation",
          templateData: templateData,
        )
      ]);

      // Set booking complete to trigger navigation
      emit(state.copyWith(
        isBooking: false,
        bookingComplete: true,
      ));

      logger.i("Appointment booked successfully");
    } catch (e) {
      logger.e("Error booking appointment: $e");
      emit(state.copyWith(
        isBooking: false,
        error: 'Failed to book appointment: ${e.toString()}',
      ));
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
    emit(state.copyWith(
      appointmentDate: event.date,
      // Reset time when date changes
      appointmentTime: null,
    ));
  }

  void _onUpdateServiceType(
      UpdateServiceType event, Emitter<SetupAppointmentState> emit) {
    // Find the index of the selected service
    final serviceIndex = state.doctorServices.indexWhere(
      (Service service) => service.uid == event.serviceType.value,
    );

    // Check if service has custom availability
    ServiceAvailability? customAvailability;

    // This is where you would get the service's custom availability if it exists
    // For example, if fetching from backend:
    // final serviceAvailability = await _doctorRepository.getServiceAvailability(event.serviceType.value);
    // if (serviceAvailability != null) {
    //   customAvailability = ServiceAvailability(
    //     days: serviceAvailability.availableDays,
    //     startTime: serviceAvailability.startTime,
    //     endTime: serviceAvailability.endTime,
    //   );
    // }

    // For now, we'll just mock it for one of the services as an example
    if (event.serviceType.value == '3') {
      customAvailability = const ServiceAvailability(
        days: [true, true, false, true, true, false, false],
        // Only available on Mon, Tue, Thu, Fri
        startTime: '10:00',
        endTime: '16:00',
      );
    }

    // Find the next available date based on the service's availability
    final nextDate = _getNextAvailableDate(
      customAvailability?.days ?? state.doctorAvailableDays,
    );

    emit(state.copyWith(
      selectedService: event.serviceType,
      selectedServiceAvailability: customAvailability,
      serviceIndex: serviceIndex >= 0 ? serviceIndex : null,
      // Reset appointment type, date and time when service changes
      selectedAppointment: null,
      appointmentDate: nextDate,
      appointmentTime: null,
      appointmentLocation: '',
    ));
  }

  void _onUpdateAppointmentTime(
      UpdateAppointmentTime event, Emitter<SetupAppointmentState> emit) {
    emit(state.copyWith(appointmentTime: event.time));
  }
}
