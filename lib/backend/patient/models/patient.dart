import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:medtalk/backend/extensions/timestamp_converter.dart';

import '../../authentication/enums/role.dart';
import '../../user/models/user.dart';

part 'patient.g.dart';

@JsonSerializable(explicitToJson: true, converters: [
  TimestampConverter(),
])
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
    super.tokens,
    super.biography,
    this.medicalRecords,
    this.recentDoctors,
    super.sex,
    this.dateOfBirth,
    this.bloodType,
    this.weight,
    this.height,
    this.savedCreditCards,
  });

  /// IDs or references to medical records.
  final List<String>? medicalRecords;

  /// List of recent doctors. MAX 3
  final List<String>? recentDoctors;

  /// The current user's date of birth.
  @TimestampConverter()
  final Timestamp? dateOfBirth;

  /// The current user's blood type.
  final String? bloodType;

  /// The current user's weight.
  final double? weight;

  /// The current user's height.
  final double? height;

  /// Selected saved credit cards
  final List<SavedCreditCard>? savedCreditCards;

  /// Returns a new [Patient] with updated fields.
  @override
  Patient copyWith({
    String? email,
    String? name,
    bool? firstTime,
    String? profilePictureUrl,
    Timestamp? updatedAt,
    bool? busy,
    String? biography,
    List<String>? tokens,
    List<String>? medicalRecords,
    List<String>? recentDoctors,
    String? sex,
    Timestamp? dateOfBirth,
    String? bloodType,
    double? weight,
    double? height,
    List<SavedCreditCard>? savedCreditCards,
  }) {
    return Patient(
      email: email ?? this.email,
      uid: uid,
      name: name ?? this.name,
      role: Role.patient,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      busy: busy ?? this.busy,
      tokens: tokens ?? this.tokens,
      medicalRecords: medicalRecords ?? this.medicalRecords,
      recentDoctors: recentDoctors ?? this.recentDoctors,
      sex: sex ?? this.sex,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodType: bloodType ?? this.bloodType,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      biography: biography ?? this.biography,
      savedCreditCards: savedCreditCards ?? this.savedCreditCards,
    );
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
        busy,
        tokens,
        medicalRecords,
        recentDoctors,
        sex,
        dateOfBirth,
        bloodType,
        weight,
        height,
        biography,
        savedCreditCards,
      ];

  factory Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PatientToJson(this);
}

@JsonSerializable()
class SavedCreditCard {
  final String id;
  final String cardNumber; // Last 4 digits only
  final String cardholderName;
  final String expiryDate;
  final String cardType; // Visa, Mastercard, etc.
  final bool isDefault;

  SavedCreditCard({
    required this.id,
    required this.cardNumber,
    required this.cardholderName,
    required this.expiryDate,
    required this.cardType,
    this.isDefault = false,
  });

  factory SavedCreditCard.fromJson(Map<String, dynamic> json) =>
      _$SavedCreditCardFromJson(json);

  Map<String, dynamic> toJson() => _$SavedCreditCardToJson(this);
}
