import 'package:equatable/equatable.dart';
import 'package:medtalk/backend/authentication/enums/role.dart';

/// User interface
///
/// [IUser.empty] represents an unauthenticated user.
abstract class IUser extends Equatable {
  const IUser();

  String? get sex;

  /// The current user's role.
  Role? get role;

  /// The current user's profile picture.
  String? get profilePictureUrl;

  DateTime? get createdAt;

  DateTime? get updatedAt;

  /// The current user's email address.
  String get email;

  /// The current user's id.
  String get uid;

  /// The current user's name (display name).
  String? get name;

  /// The current state of the user in a video call.
  bool get busy;

  /// tokens FCM
  List<String>? get tokens;

  /// Biography of the user.
  String? get biography;

  static const empty = _UserImpl(
    uid: '',
    email: '',
  );

  /// Returns a new [IUser] with updated fields.
  IUser copyWith({
    String? email,
    String? name,
    String? sex,
    String? profilePictureUrl,
    DateTime? updatedAt,
    bool? busy,
    String? biography,
    List<String>? tokens,
  });

  @override
  List<Object?> get props => [
        email,
        uid,
        name,
        role,
        sex,
        profilePictureUrl,
        createdAt,
        updatedAt,
        busy,
        tokens,
        biography,
      ];
}

class _UserImpl extends IUser {
  const _UserImpl({
    required this.uid,
    this.role,
    required this.email,
    this.name,
    this.busy = false,
    this.profilePictureUrl,
    this.sex,
    this.updatedAt,
    this.tokens,
    this.biography,
    this.createdAt,
  });

  @override
  final Role? role;

  @override
  final String? sex;

  @override
  final String? profilePictureUrl;

  @override
  final DateTime? createdAt;

  @override
  final DateTime? updatedAt;

  @override
  final String email;

  @override
  final String uid;

  @override
  final String? name;

  @override
  final bool busy;

  @override
  final List<String>? tokens;

  @override
  final String? biography;

  @override
  IUser copyWith({
    String? email,
    bool? firstTime,
    String? name,
    String? sex,
    String? profilePictureUrl,
    DateTime? updatedAt,
    bool? busy,
    String? biography,
    List<String>? tokens,
    DateTime? createdAt,
  }) {
    return _UserImpl(
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
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> get toMap => {
        'email': email,
        'name': name,
        'sex': sex,
        'role': role,
        'profilePictureUrl': profilePictureUrl,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'busy': busy,
        'tokens': tokens,
        'biography': biography,
      };
}
