// BLoC

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:medtalk/backend/authentication/interfaces/auth_interface.dart';
import 'package:medtalk/backend/doctor/interfaces/doctor_interface.dart';
import 'package:medtalk/backend/doctor/models/doctor.dart';
import 'package:medtalk/backend/doctor/models/doctor_work_times.dart';
import 'package:medtalk/backend/services/models/service.dart';
import 'package:medtalk/doctor/design/bloc/design_event.dart';
import 'package:medtalk/doctor/design/bloc/design_state.dart';

@injectable
class DesignBloc extends Bloc<DesignEvent, DesignState> {
  DesignBloc(
    this._authenticationRepository,
    this._doctorRepository,
    this.logger,
  ) : super(const DesignState(
          // Initialize with default services
          services: [],
          // Initialize with default schedule
          schedule: {},
        )) {
    on<LoadDoctorProfile>(_onLoadDoctorProfile);
    on<SaveDoctorProfile>(_onSaveDoctorProfile);
    on<AddService>(_onAddService);
    on<UpdateService>(_onUpdateService);
    on<DeleteService>(_onDeleteService);
    on<UpdateAppointmentTypes>(_onUpdateAppointmentTypes);
    on<UpdateSchedule>(_onUpdateSchedule);
    on<UpdateSettings>(_onUpdateSettings);
  }

  final IAuthenticationRepository _authenticationRepository;
  final IDoctorRepository _doctorRepository;
  final Logger logger;

  Future<void> _onLoadDoctorProfile(
    LoadDoctorProfile event,
    Emitter<DesignState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      var docId = _authenticationRepository.currentUser.uid;

      // Fetch doctor profile from repository
      final Doctor? doctorProfile = await _doctorRepository.getDoctor(docId);

      if (doctorProfile == null) {
        emit(state.copyWith(
          errorMessage: 'Doctor profile not found',
          isLoading: false,
        ));
        return;
      }

      // Initialize schedule with default values if empty
      Map<String, WorkingHours> initialSchedule = {};
      final List<String> days = [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun'
      ];

      if (doctorProfile.availability.isNotEmpty) {
        // Use existing availability if available
        initialSchedule =
            doctorProfile.availability.map((day, workAndBreakTimes) {
          // map the workTimes and breakTimes to WorkingHours
          return MapEntry(
              day,
              WorkingHours(
                isWorking: true,
                startTime: workAndBreakTimes?.startTime ?? '09:00',
                endTime: workAndBreakTimes?.endTime ?? '17:00',
                breaks: workAndBreakTimes?.breaks
                        .map((breakTime) => BreakTime(
                              startTime: workAndBreakTimes.startTime,
                              endTime: workAndBreakTimes.endTime,
                              title: breakTime.title,
                            ))
                        .toList() ??
                    [],
              ));
        });
      } else {
        // Initialize with default values
        for (final day in days) {
          initialSchedule[day] = const WorkingHours(
            isWorking: false,
            startTime: '09:00',
            endTime: '17:00',
            breaks: [],
          );
        }
      }

      // Update state with fetched profile (using default values for now)
      emit(state.copyWith(
        bio:
            'Board-certified physician with over 10 years of experience in general practice. Passionate about preventative care and patient education.',
        phone: '+1 123 456 7890',
        address: '1234 Clinic St, Portland, OR 97205',
        notes: 'Free parking available in the back',
        isLoading: false,
        services: doctorProfile.services ?? [],
        schedule: initialSchedule,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to load profile: ${e.toString()}',
        isLoading: false,
      ));
    }
  }

  Future<void> _onSaveDoctorProfile(
    SaveDoctorProfile event,
    Emitter<DesignState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Here we would save to API or repository
      // For now, just simulate a delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Update state with new values
      emit(state.copyWith(
        bio: event.bio,
        phone: event.phone,
        address: event.address,
        notes: event.notes,
        isLoading: false,
        schedule: event.schedule,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to save profile: ${e.toString()}',
        isLoading: false,
      ));
    }
  }

  Future<void> _onAddService(
    AddService event,
    Emitter<DesignState> emit,
  ) async {
    // Create new service
    final newService = Service(
      uid: DateTime.now().millisecondsSinceEpoch.toString(),
      title: event.title,
      duration: event.duration,
      price: event.price,
      isOnline: event.isOnline,
      isInPerson: event.isInPerson,
      isHomeVisit: event.isHomeVisit,
      customAvailability: event.customAvailability,
      description: event.description,
      preAppointmentInstructions: event.preAppointmentInstructions,
    );

    // Add to existing services
    final updatedServices = List<Service>.from(state.services)..add(newService);

    emit(state.copyWith(services: updatedServices));
  }

  Future<void> _onUpdateService(
    UpdateService event,
    Emitter<DesignState> emit,
  ) async {
    // Update existing service
    final List<Service> updatedServices =
        state.services.map<Service>((Service service) {
      if (service.uid == event.id) {
        return service.copyWith(
          title: event.title,
          duration: event.duration,
          price: event.price,
          isOnline: event.isOnline,
          isInPerson: event.isInPerson,
          isHomeVisit: event.isHomeVisit,
          customAvailability: service.customAvailability,
          description: service.description,
          preAppointmentInstructions: service.preAppointmentInstructions,
        );
      }
      return service;
    }).toList();

    emit(state.copyWith(services: updatedServices));
  }

  Future<void> _onDeleteService(
    DeleteService event,
    Emitter<DesignState> emit,
  ) async {
    // Remove service by ID
    final updatedServices = state.services
        .where((Service service) => service.uid != event.id)
        .toList();

    emit(state.copyWith(services: updatedServices));
  }

  Future<void> _onUpdateAppointmentTypes(
    UpdateAppointmentTypes event,
    Emitter<DesignState> emit,
  ) async {
    emit(state.copyWith(
      offersInPerson: event.offersInPerson,
      offersOnline: event.offersOnline,
      offersHomeVisit: event.offersHomeVisit,
    ));
  }

  Future<void> _onUpdateSchedule(
    UpdateSchedule event,
    Emitter<DesignState> emit,
  ) async {
    // Update schedule for specific day
    final updatedSchedule = Map<String, WorkingHours>.from(state.schedule);
    updatedSchedule[event.dayOfWeek] = WorkingHours(
      isWorking: event.isWorking,
      startTime: event.startTime,
      endTime: event.endTime,
      breaks: event.breaks,
    );

    emit(state.copyWith(schedule: updatedSchedule));
  }

  Future<void> _onUpdateSettings(
    UpdateSettings event,
    Emitter<DesignState> emit,
  ) async {
    emit(state.copyWith(
      advanceNotice: event.advanceNotice,
      bookingWindow: event.bookingWindow,
      autoConfirm: event.autoConfirm,
      sendReminders: event.sendReminders,
      reminderTimes: event.reminderTimes,
      paymentMethods: event.paymentMethods,
      cancellationPolicy: event.cancellationPolicy,
    ));
  }
}
