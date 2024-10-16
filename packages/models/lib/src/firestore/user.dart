import 'package:equatable/equatable.dart';

/// User model
///
/// [User.empty] represents an unauthenticated user.
class User extends Equatable {
  /// {@macro user}
  const User(
      {required this.uid,
      required this.role,
      required this.email,
      required this.name,
      required this.busy,
      this.profilePictureUrl,
      this.createdAt,
      this.updatedAt,
      this.appointments,
      this.tokens,
      this.paymentIds,
      this.biography});

  /// The current user's role.
  final String role;

  /// The current user's profile picture.
  final String? profilePictureUrl;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  /// The current user's email address.
  final String email;

  /// The current user's id.
  final String uid;

  /// The current user's name (display name).
  final String name;

  /// The current state of the user in a video call.
  final bool busy;

  /// The current user's appointments.
  final List<String>? appointments;

  /// tokens FCM
  final List<String>? tokens;

  /// Empty user which represents an unauthenticated user.
  static const empty =
      User(uid: '', email: '', name: '', role: '', busy: false);

  /// Payment IDs Payment records for the doctor.
  /// Example: {'transactionId': 'xyz123', 'amount': 100.0, 'currency': 'USD'}
  final List<String>? paymentIds;

  /// Biography of the user.
  final String? biography;

  /// Returns a new [User] with updated fields.
  User copyWith({
    String? email,
    String? uid,
    String? name,
    String? role,
    String? profilePictureUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? appointments,
    bool? busy,
    List<String>? tokens,
    List<String>? paymentIds,
    String? biography,
  }) {
    return User(
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
      biography: biography ?? this.biography,
    );
  }

  /// Converts a [Map<String, dynamic>] to a [User].
  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      uid: data['uid'],
      email: data['email'],
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

  /// Converts a [User] to a [Map<String, dynamic>].
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
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
        biography,
      ];
}
