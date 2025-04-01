import 'package:json_annotation/json_annotation.dart';

import '../../authentication/enums/role.dart';
import '../../user/models/user.dart';

part 'patient.g.dart';

@JsonSerializable()
class Patient extends User {
  const Patient({
    required super.email,
    required super.uid,
    super.name,
    required super.role,
    super.busy,
    super.profilePictureUrl,
    super.createdAt,
    super.updatedAt,
    super.appointments,
    super.tokens,
    super.paymentIds,
    super.biography,
    this.medicalRecords,
    this.recentDoctors,
    super.sex,
    this.dateOfBirth,
    this.bloodType,
    this.weight,
    this.height,
  });

  /// IDs or references to medical records.
  final List<String>? medicalRecords;

  /// List of recent doctors. MAX 3
  final List<String>? recentDoctors;

  /// The current user's date of birth.
  final DateTime? dateOfBirth;

  /// The current user's blood type.
  final String? bloodType;

  /// The current user's weight.
  final double? weight;

  /// The current user's height.
  final double? height;

  /// Returns a new [Patient] with updated fields.
  @override
  Patient copyWith({
    String? email,
    String? name,
    bool? firstTime,
    String? profilePictureUrl,
    DateTime? updatedAt,
    List<String>? appointments,
    bool? busy,
    String? biography,
    List<String>? tokens,
    List<String>? paymentIds,
    List<String>? medicalRecords,
    List<String>? recentDoctors,
    String? sex,
    DateTime? dateOfBirth,
    String? bloodType,
    double? weight,
    double? height,
  }) {
    return Patient(
      email: email ?? this.email,
      uid: uid,
      name: name ?? this.name,
      role: Role.patient,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      appointments: appointments ?? this.appointments,
      busy: busy ?? this.busy,
      tokens: tokens ?? this.tokens,
      paymentIds: paymentIds ?? this.paymentIds,
      medicalRecords: medicalRecords ?? this.medicalRecords,
      recentDoctors: recentDoctors ?? this.recentDoctors,
      sex: sex ?? this.sex,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodType: bloodType ?? this.bloodType,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      biography: biography ?? this.biography,
    );
  }

  /// Converts a [Map<String, dynamic>] to a [Patient].
  factory Patient.fromMap(String docId, Map<String, dynamic> data) {
    return Patient(
      email: data['email'],
      uid: docId,
      name: data['name'],
      role: Role.values.byName(data['role']),
      profilePictureUrl: data['profilePictureUrl'],
      createdAt: data['createdAt'].toDate(),
      updatedAt: data['updatedAt']?.toDate(),
      appointments: data['appointments'] != null
          ? List<String>.from(data['appointments'])
          : [],
      busy: data['busy'],
      tokens: data['tokens'],
      paymentIds: data['paymentIds'],
      biography: data['biography'],
      medicalRecords: data['medicalRecords'],
      recentDoctors: data['recentDoctors'],
      sex: data['sex'],
      dateOfBirth: data['dateOfBirth']?.toDate(),
      bloodType: data['bloodType'],
      weight: data['weight'],
      height: data['height'],
    );
  }

  /// Converts a [Patient] to a [Map<String, dynamic>].
  Map<String, dynamic> get toMap {
    return {
      'email': email,
      'name': name,
      'role': role!.name,
      'profilePictureUrl': profilePictureUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'appointments': appointments,
      'busy': busy,
      'tokens': tokens,
      'paymentIds': paymentIds,
      'biography': biography,
      'medicalRecords': medicalRecords,
      'recentDoctors': recentDoctors,
      'sex': sex,
      'dateOfBirth': dateOfBirth,
      'bloodType': bloodType,
      'weight': weight,
      'height': height,
    };
  }

  @override
  List<Object?> get props => [
        email,
        uid,
        name,
        role,
        profilePictureUrl,
        createdAt,
        updatedAt,
        appointments,
        busy,
        tokens,
        paymentIds,
        medicalRecords,
        recentDoctors,
        sex,
        dateOfBirth,
        bloodType,
        weight,
        height,
        biography,
      ];

  factory Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PatientToJson(this);
}
