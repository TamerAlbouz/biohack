import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:medtalk/backend/appointment/enums/appointment_status.dart';
import 'package:medtalk/backend/appointment/enums/appointment_type.dart';

part 'appointment.g.dart';

@JsonSerializable(explicitToJson: true)
class Appointment extends Equatable {
  const Appointment({
    this.appointmentId,
    required this.doctorId,
    required this.patientId,
    required this.specialty,
    required this.status,
    required this.serviceName,
    required this.fee,
    required this.appointmentDate,
    required this.duration,
    this.location,
    this.createdAt,
    required this.appointmentType,
    this.updatedAt,
  });

  /// Unique identifier for the appointment.
  final String? appointmentId;

  /// Unique identifier for the doctor.
  final String doctorId;

  /// Unique identifier for the patient.
  final String patientId;

  /// Unique identifier for the specialty.
  final String specialty;

  /// Status of the appointment ('confirmed', 'cancelled').
  final AppointmentStatus status;

  /// Name of the service.
  final String serviceName;

  /// Fee for the service.
  final int fee;

  /// Date and time of the appointment.
  final DateTime appointmentDate;

  /// Duration of the appointment in minutes.
  final int? duration;

  /// Date and time when the appointment was created.
  final DateTime? createdAt;

  /// Date and time when the appointment was last updated.
  final DateTime? updatedAt;

  /// If an appointment is online or in-person.
  final AppointmentType appointmentType;

  /// Location of the appointment.
  final String? location;

  /// Returns a new [Appointment] with updated fields.
  Appointment copyWith({
    AppointmentStatus? status,
    String? serviceName,
    int? fee,
    DateTime? appointmentDate,
    int? duration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      location: location,
      appointmentType: appointmentType,
      appointmentId: appointmentId,
      doctorId: doctorId,
      patientId: patientId,
      specialty: specialty,
      status: status ?? this.status,
      serviceName: serviceName ?? this.serviceName,
      fee: fee ?? this.fee,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts a [Map<String, dynamic>] to an [Appointment].
  factory Appointment.fromMap(String id, Map<String, dynamic> data) {
    return Appointment(
      appointmentId: id,
      doctorId: data['doctorId'],
      patientId: data['patientId'],
      location: data['location'] ?? "",
      specialty: data['specialty'] ?? "",
      status: AppointmentStatus.values.byName(data['status']),
      serviceName: data['serviceName'] ?? "",
      fee: int.parse(data['fee']?.toString() ?? '0'),
      appointmentDate: data['appointmentDate']?.toDate() ?? DateTime.now(),
      duration: int.parse(data['duration']?.toString() ?? '0'),
      appointmentType: AppointmentType.values.byName(data['appointmentType']),
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts an [Appointment] to a [Map<String, dynamic>].
  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'specialty': specialty,
      'status': status.name,
      'serviceName': serviceName,
      'appointmentType': appointmentType.name,
      'location': location,
      'fee': fee,
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'duration': duration,
      'createdAt': Timestamp.fromDate(createdAt ?? DateTime.now()),
      'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
    };
  }

  @override
  List<Object?> get props => [
        appointmentId,
        doctorId,
        patientId,
        specialty,
        status,
        serviceName,
        appointmentType,
        fee,
        appointmentDate,
        duration,
        location,
        createdAt,
        updatedAt,
      ];
}
