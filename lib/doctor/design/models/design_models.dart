import 'package:equatable/equatable.dart';

// Update the DoctorService class to include new fields
class DoctorService extends Equatable {
  final String id;
  final String title;
  final String description;
  final int duration;
  final int price;
  final bool isOnline;
  final bool isInPerson;
  final bool isHomeVisit;
  final String? preAppointmentInstructions;
  final ServiceAvailability? availability;

  const DoctorService({
    required this.id,
    required this.title,
    this.description = '',
    required this.duration,
    required this.price,
    this.isOnline = false,
    this.isInPerson = true,
    this.isHomeVisit = false,
    this.preAppointmentInstructions = '',
    this.availability,
  });

  copyWith({
    String? id,
    String? title,
    String? description,
    int? duration,
    int? price,
    bool? isOnline,
    bool? isInPerson,
    bool? isHomeVisit,
    String? preAppointmentInstructions,
    ServiceAvailability? availability,
  }) {
    return DoctorService(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      isOnline: isOnline ?? this.isOnline,
      isInPerson: isInPerson ?? this.isInPerson,
      isHomeVisit: isHomeVisit ?? this.isHomeVisit,
      preAppointmentInstructions:
          preAppointmentInstructions ?? this.preAppointmentInstructions,
      availability: availability ?? this.availability,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        duration,
        price,
        isOnline,
        isInPerson,
        isHomeVisit,
        preAppointmentInstructions,
        availability,
      ];
}

// Add a new class for service availability
class ServiceAvailability extends Equatable {
  final List<bool>
      days; // List of 7 booleans for days of the week (Monday to Sunday)
  final String startTime; // Format: "09:00"
  final String endTime; // Format: "17:00"

  const ServiceAvailability({
    required this.days,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object> get props => [days, startTime, endTime];
}

class WorkingHours extends Equatable {
  final bool isWorking;
  final String startTime;
  final String endTime;
  final List<BreakTime> breaks;

  const WorkingHours({
    required this.isWorking,
    required this.startTime,
    required this.endTime,
    this.breaks = const [],
  });

  @override
  List<Object> get props => [isWorking, startTime, endTime, breaks];
}

class BreakTime extends Equatable {
  final String title;
  final String startTime;
  final String endTime;

  const BreakTime({
    required this.title,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object> get props => [title, startTime, endTime];
}

// Add a class for custom reminders
class CustomReminder {
  final String label;
  final int hours;

  CustomReminder({required this.label, required this.hours});
}
