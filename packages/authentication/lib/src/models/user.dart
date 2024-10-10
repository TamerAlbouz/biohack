import 'package:equatable/equatable.dart';

/// User model
///
/// [User.empty] represents an unauthenticated user.
class User extends Equatable {
  /// {@macro user}
  const User({
    required this.uid,
    this.role,
    this.profilePictureUrl,
    this.createdAt,
    this.updatedAt,
    this.doctorSpecialities,
    this.email,
    this.name,
  });

  // The current user's role.
  final String? role;

  // The current user's profile picture.
  final String? profilePictureUrl;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  // list of doctor specialities ids
  final List<String>? doctorSpecialities;

  /// The current user's email address.
  final String? email;

  /// The current user's id.
  final String uid;

  /// The current user's name (display name).
  final String? name;

  /// Empty user which represents an unauthenticated user.
  static const empty = User(uid: '');

  @override
  List<Object?> get props => [
        email,
        uid,
        name,
        role,
        profilePictureUrl,
        createdAt,
        updatedAt,
        doctorSpecialities
      ];
}
