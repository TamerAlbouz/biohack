import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'service.g.dart';

@JsonSerializable()
class Service {
  const Service({
    required this.uid,
    required this.title,
    this.description,
    required this.duration,
    required this.price,
    required this.isOnline,
    required this.isInPerson,
    required this.isHomeVisit,
    this.preAppointmentInstructions,
    this.customAvailability,
  });

  final String uid;
  final String title;
  final String? description;
  final int duration;
  final int price;
  final bool isOnline;
  final bool isInPerson;
  final bool isHomeVisit;
  final String? preAppointmentInstructions;
  final ServiceAvailability? customAvailability;

  factory Service.fromJson(Map<String, dynamic> json) =>
      _$ServiceFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceToJson(this);

  factory Service.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Service(
      uid: doc.id,
      title: data['title'] as String,
      description: data['description'] as String,
      duration: data['duration'] as int,
      price: data['price'] as int,
      isOnline: data['isOnline'] as bool,
      isInPerson: data['isInPerson'] as bool,
      isHomeVisit: data['isHomeVisit'] as bool,
      preAppointmentInstructions: data['preAppointmentInstructions'] as String?,
      customAvailability: data['customAvailability'] != null
          ? ServiceAvailability.fromJson(
              data['customAvailability'] as Map<String, dynamic>)
          : null,
    );
  }

  Service copyWith({
    String? uid,
    String? title,
    String? description,
    int? duration,
    int? price,
    bool? isOnline,
    bool? isInPerson,
    bool? isHomeVisit,
    String? preAppointmentInstructions,
    ServiceAvailability? customAvailability,
  }) {
    return Service(
      uid: uid ?? this.uid,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      isOnline: isOnline ?? this.isOnline,
      isInPerson: isInPerson ?? this.isInPerson,
      isHomeVisit: isHomeVisit ?? this.isHomeVisit,
      preAppointmentInstructions:
          preAppointmentInstructions ?? this.preAppointmentInstructions,
      customAvailability: customAvailability ?? this.customAvailability,
    );
  }

  List<Object?> get props => [
        uid,
        title,
        description,
        duration,
        price,
        isOnline,
        isInPerson,
        isHomeVisit,
        preAppointmentInstructions,
        customAvailability,
      ];
}

@JsonSerializable(explicitToJson: true)
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

  factory ServiceAvailability.fromJson(Map<String, dynamic> json) =>
      _$ServiceAvailabilityFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceAvailabilityToJson(this);

  @override
  List<Object> get props => [days, startTime, endTime];
}
