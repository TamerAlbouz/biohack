// BLoC
import 'package:bloc/bloc.dart';
import 'package:medtalk/doctor/design/bloc/design_event.dart';
import 'package:medtalk/doctor/design/bloc/design_state.dart';

import '../models/design_models.dart';

class DesignBloc extends Bloc<DesignEvent, DesignState> {
  DesignBloc()
      : super(const DesignState(
          // Initialize with default services
          services: [
            DoctorService(
              id: '1',
              title: 'Consultation',
              duration: 30,
              price: 50,
              isOnline: true,
              isInPerson: true,
            ),
            DoctorService(
              id: '2',
              title: 'Treatment',
              duration: 60,
              price: 100,
              isInPerson: true,
              isHomeVisit: true,
              isOnline: true,
            ),
            DoctorService(
              id: '3',
              title: 'Checkup',
              duration: 15,
              price: 30,
              isOnline: true,
              isInPerson: true,
            ),
          ],
          // Initialize with default schedule
          schedule: {
            'Monday': WorkingHours(
              isWorking: true,
              startTime: '09:00 AM',
              endTime: '05:00 PM',
              breaks: [
                BreakTime(
                  title: 'Lunch Break',
                  startTime: '12:00 PM',
                  endTime: '01:00 PM',
                ),
              ],
            ),
            'Tuesday': WorkingHours(
              isWorking: true,
              startTime: '09:00 AM',
              endTime: '05:00 PM',
              breaks: [],
            ),
            'Wednesday': WorkingHours(
              isWorking: true,
              startTime: '09:00 AM',
              endTime: '05:00 PM',
              breaks: [],
            ),
            'Thursday': WorkingHours(
              isWorking: true,
              startTime: '09:00 AM',
              endTime: '05:00 PM',
              breaks: [],
            ),
            'Friday': WorkingHours(
              isWorking: true,
              startTime: '09:00 AM',
              endTime: '05:00 PM',
              breaks: [],
            ),
            'Saturday': WorkingHours(
              isWorking: false,
              startTime: '09:00 AM',
              endTime: '01:00 PM',
              breaks: [],
            ),
            'Sunday': WorkingHours(
              isWorking: false,
              startTime: '09:00 AM',
              endTime: '01:00 PM',
              breaks: [],
            ),
          },
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

  Future<void> _onLoadDoctorProfile(
    LoadDoctorProfile event,
    Emitter<DesignState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Here we would fetch doctor profile from API or repository
      // For now, we'll just simulate a delay
      await Future.delayed(const Duration(milliseconds: 500));

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

      for (final day in days) {
        // Default weekdays (Mon-Fri) as working days
        final isWeekday = days.indexOf(day) < 5;
        initialSchedule[day] = WorkingHours(
          isWorking: isWeekday,
          startTime: '09:00',
          endTime: '17:00',
          breaks: isWeekday
              ? [
                  const BreakTime(
                      title: 'Lunch Break',
                      startTime: '12:00',
                      endTime: '13:00')
                ]
              : [],
        );
      }

      // Update state with fetched profile (using default values for now)
      emit(state.copyWith(
        bio:
            'Board-certified physician with over 10 years of experience in general practice. Passionate about preventative care and patient education.',
        phone: '+1 123 456 7890',
        address: '1234 Clinic St, Portland, OR 97205',
        notes: 'Free parking available in the back',
        isLoading: false,
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
    final newService = DoctorService(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: event.title,
      duration: event.duration,
      price: event.price,
      isOnline: event.isOnline,
      isInPerson: event.isInPerson,
      isHomeVisit: event.isHomeVisit,
    );

    // Add to existing services
    final updatedServices = List<DoctorService>.from(state.services)
      ..add(newService);

    emit(state.copyWith(services: updatedServices));
  }

  Future<void> _onUpdateService(
    UpdateService event,
    Emitter<DesignState> emit,
  ) async {
    // Update existing service
    final List<DoctorService> updatedServices =
        state.services.map<DoctorService>((service) {
      if (service.id == event.id) {
        return service.copyWith(
          title: event.title,
          duration: event.duration,
          price: event.price,
          isOnline: event.isOnline,
          isInPerson: event.isInPerson,
          isHomeVisit: event.isHomeVisit,
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
    final updatedServices =
        state.services.where((service) => service.id != event.id).toList();

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
