import 'package:equatable/equatable.dart';

import '../models/design_models.dart';

// Events
abstract class DesignEvent extends Equatable {
  const DesignEvent();

  @override
  List<Object?> get props => [];
}

class LoadDoctorProfile extends DesignEvent {}

class SaveDoctorProfile extends DesignEvent {
  final String bio;
  final String phone;
  final String address;
  final String notes;
  final Map<String, WorkingHours> schedule;

  const SaveDoctorProfile({
    required this.bio,
    required this.phone,
    required this.address,
    required this.notes,
    required this.schedule,
  });

  @override
  List<Object> get props => [bio, phone, address, notes, schedule];
}

class LoadServices extends DesignEvent {}

class AddService extends DesignEvent {
  final String title;
  final int duration;
  final int price;
  final bool isOnline;
  final bool isInPerson;
  final bool isHomeVisit;

  const AddService({
    required this.title,
    required this.duration,
    required this.price,
    required this.isOnline,
    required this.isInPerson,
    required this.isHomeVisit,
  });

  @override
  List<Object> get props =>
      [title, duration, price, isOnline, isInPerson, isHomeVisit];
}

class UpdateService extends DesignEvent {
  final String id;
  final String title;
  final int duration;
  final int price;
  final bool isOnline;
  final bool isInPerson;
  final bool isHomeVisit;

  const UpdateService({
    required this.id,
    required this.title,
    required this.duration,
    required this.price,
    required this.isOnline,
    required this.isInPerson,
    required this.isHomeVisit,
  });

  @override
  List<Object> get props =>
      [id, title, duration, price, isOnline, isInPerson, isHomeVisit];
}

class DeleteService extends DesignEvent {
  final String id;

  const DeleteService(this.id);

  @override
  List<Object> get props => [id];
}

class UpdateAppointmentTypes extends DesignEvent {
  final bool offersInPerson;
  final bool offersOnline;
  final bool offersHomeVisit;

  const UpdateAppointmentTypes({
    required this.offersInPerson,
    required this.offersOnline,
    required this.offersHomeVisit,
  });

  @override
  List<Object> get props => [offersInPerson, offersOnline, offersHomeVisit];
}

class UpdateSchedule extends DesignEvent {
  final String dayOfWeek;
  final bool isWorking;
  final String startTime;
  final String endTime;
  final List<BreakTime> breaks;

  const UpdateSchedule({
    required this.dayOfWeek,
    required this.isWorking,
    required this.startTime,
    required this.endTime,
    required this.breaks,
  });

  @override
  List<Object> get props => [dayOfWeek, isWorking, startTime, endTime, breaks];
}

class UpdateSettings extends DesignEvent {
  final String advanceNotice;
  final String bookingWindow;
  final bool autoConfirm;
  final bool sendReminders;
  final List<String> reminderTimes;
  final List<String> paymentMethods;
  final String cancellationPolicy;

  const UpdateSettings({
    required this.advanceNotice,
    required this.bookingWindow,
    required this.autoConfirm,
    required this.sendReminders,
    required this.reminderTimes,
    required this.paymentMethods,
    required this.cancellationPolicy,
  });

  @override
  List<Object> get props => [
        advanceNotice,
        bookingWindow,
        autoConfirm,
        sendReminders,
        reminderTimes,
        paymentMethods,
        cancellationPolicy,
      ];
}
