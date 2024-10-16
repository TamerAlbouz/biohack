import '../../models.dart';

class Patient extends User {
  const Patient({
    required super.email,
    required super.uid,
    required super.name,
    required super.role,
    required super.busy,
    super.profilePictureUrl,
    super.createdAt,
    super.updatedAt,
    super.appointments,
    super.tokens,
    super.paymentIds,
    super.biography,
    this.medicalRecords,
    this.recentDoctors,
    this.sex,
    this.age,
    this.bloodType,
    this.weight,
    this.height,
  });

  /// IDs or references to medical records.
  final List<String>? medicalRecords;

  /// List of recent doctors. MAX 3
  final List<String>? recentDoctors;

  /// The current user's sex.
  final String? sex;

  /// The current user's age.
  final int? age;

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
    String? uid,
    String? name,
    String? role,
    String? profilePictureUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? appointments,
    bool? busy,
    String? biography,
    List<String>? tokens,
    List<String>? paymentIds,
    List<String>? medicalRecords,
    List<String>? recentDoctors,
    String? sex,
    int? age,
    String? bloodType,
    double? weight,
    double? height,
  }) {
    return Patient(
      email: email ?? this.email,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      role: role ?? this.role,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      appointments: appointments ?? this.appointments,
      busy: busy ?? this.busy,
      tokens: tokens ?? this.tokens,
      paymentIds: paymentIds ?? this.paymentIds,
      medicalRecords: medicalRecords ?? this.medicalRecords,
      recentDoctors: recentDoctors ?? this.recentDoctors,
      sex: sex ?? this.sex,
      age: age ?? this.age,
      bloodType: bloodType ?? this.bloodType,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      biography: biography ?? this.biography,
    );
  }

  /// Converts a [Map<String, dynamic>] to a [Patient].
  factory Patient.fromMap(Map<String, dynamic> data) {
    return Patient(
      email: data['email'],
      uid: data['uid'],
      name: data['name'],
      role: data['role'],
      profilePictureUrl: data['profilePictureUrl'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      appointments: data['appointments'],
      busy: data['busy'],
      tokens: data['tokens'],
      paymentIds: data['paymentIds'],
      biography: data['biography'],
      medicalRecords: data['medicalRecords'],
      recentDoctors: data['recentDoctors'],
      sex: data['sex'],
      age: data['age'],
      bloodType: data['bloodType'],
      weight: data['weight'],
      height: data['height'],
    );
  }

  /// Converts a [Patient] to a [Map<String, dynamic>].
  @override
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'uid': uid,
      'name': name,
      'role': role,
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
      'age': age,
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
        age,
        bloodType,
        weight,
        height,
        biography,
      ];
}
