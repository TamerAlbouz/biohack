import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:models/models.dart';

part 'user.g.dart';

/// User model
///
/// [User.empty] represents an unauthenticated user.
@JsonSerializable()
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
      this.firstTime = true,
      this.emailVerified = false,
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

  /// First time user
  @override
  final bool? firstTime;

  /// Biography of the user.
  @override
  final String? biography;

  /// Email verification status
  final bool emailVerified;

  static const empty = User(
    uid: '',
    role: Role.unknown,
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
    bool? emailVerified,
    bool? busy,
    String? biography,
    List<String>? tokens,
    List<String>? paymentIds,
    bool? firstTime,
  }) {
    return User(
      firstTime: firstTime ?? this.firstTime,
      email: email ?? this.email,
      name: name ?? this.name,
      emailVerified: emailVerified ?? this.emailVerified,
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

  @override
  List<Object?> get props => [
        email,
        uid,
        firstTime,
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
        emailVerified,
      ];

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
