import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:medtalk/backend/extensions/timestamp_converter.dart';

import '../../authentication/enums/role.dart';
import '../../authentication/models/user_interface.dart';

part 'user.g.dart';

/// User model
///
/// [User.empty] represents an unauthenticated user.
@JsonSerializable(explicitToJson: true, converters: [
  TimestampConverter(),
])
class User extends Equatable implements IUser {
  /// {@macro user}
  const User({
    required this.uid,
    this.role,
    this.sex,
    required this.email,
    this.name,
    this.busy = false,
    this.profilePictureUrl,
    this.createdAt,
    this.updatedAt,
    this.tokens,
    this.biography,
  });

  /// The sex of the user
  @override
  final String? sex;

  /// The current user's role.
  @override
  final Role? role;

  /// The current user's profile picture.
  @override
  final String? profilePictureUrl;

  @override
  @TimestampConverter()
  final Timestamp? createdAt;

  @override
  @TimestampConverter()
  final Timestamp? updatedAt;

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

  /// tokens FCM
  @override
  final List<String>? tokens;

  /// Biography of the user.
  @override
  final String? biography;

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
    String? sex,
    bool? firstTime,
    String? profilePictureUrl,
    Timestamp? updatedAt,
    bool? busy,
    String? biography,
    List<String>? tokens,
  }) {
    return User(
      email: email ?? this.email,
      name: name ?? this.name,
      sex: sex ?? this.sex,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      busy: busy ?? this.busy,
      biography: biography ?? this.biography,
      tokens: tokens ?? this.tokens,
      role: role,
      uid: uid,
    );
  }

  @override
  List<Object?> get props => [
        email,
        uid,
        name,
        role,
        profilePictureUrl,
        sex,
        createdAt,
        updatedAt,
        busy,
        tokens,
        biography,
      ];

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
