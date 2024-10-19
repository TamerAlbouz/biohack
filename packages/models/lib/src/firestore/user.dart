import 'package:equatable/equatable.dart';
import 'package:models/models.dart';

/// User model
///
/// [User.empty] represents an unauthenticated user.
class User extends Equatable implements IUser {
  /// {@macro user}
  const User(
      {required this.uid,
      this.role,
      required this.email,
      this.name,
      this.busy = false,
      this.profilePictureUrl,
      this.createdAt,
      this.updatedAt,
      this.appointments,
      this.tokens,
      this.paymentIds,
      this.biography});

  /// The current user's role.
  @override
  final Role? role;

  /// The current user's profile picture.
  @override
  final String? profilePictureUrl;

  @override
  final DateTime? createdAt;

  @override
  final DateTime? updatedAt;

  /// The current user's email address.
  @override
  final String email;

  /// The current user's id.
  @override
  final String uid;

  /// The current user's name (display name).
  @override
  final String? name;

  /// The current state of the user in a video call.
  @override
  final bool busy;

  /// The current user's appointments.
  @override
  final List<String>? appointments;

  /// tokens FCM
  @override
  final List<String>? tokens;

  /// Payment IDs Payment records for the doctor.
  /// Example: {'transactionId': 'xyz123', 'amount': 100.0, 'currency': 'USD'}
  @override
  final List<String>? paymentIds;

  /// Biography of the user.
  @override
  final String? biography;

  static const empty = User(
    uid: '',
    role: Role.patient,
    email: '',
  );

  /// Returns a new [User] with updated fields.
  @override
  User copyWith({
    String? email,
    String? name,
    String? profilePictureUrl,
    DateTime? updatedAt,
    List<String>? appointments,
    bool? busy,
    String? biography,
    List<String>? tokens,
    List<String>? paymentIds,
  }) {
    return User(
      email: email ?? this.email,
      name: name ?? this.name,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      appointments: appointments ?? this.appointments,
      busy: busy ?? this.busy,
      biography: biography ?? this.biography,
      tokens: tokens ?? this.tokens,
      paymentIds: paymentIds ?? this.paymentIds,
      role: role,
      uid: uid,
    );
  }

  /// fromMap
  factory User.fromMap(String docId, Map<String, dynamic> data) {
    return User(
      email: data['email'],
      uid: docId,
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
        appointments,
        busy,
        tokens,
        paymentIds,
        biography,
      ];

  @override
  Map<String, dynamic> get toMap => {
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
      };
}
