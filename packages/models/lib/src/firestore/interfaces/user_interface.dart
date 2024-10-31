import 'package:equatable/equatable.dart';
import 'package:models/models.dart';

/// User interface
///
/// [IUser.empty] represents an unauthenticated user.
abstract class IUser extends Equatable {
  const IUser();

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

  /// The current user's appointments.
  List<String>? get appointments;

  /// tokens FCM
  List<String>? get tokens;

  /// Payment IDs Payment records for the doctor.
  /// Example: {'transactionId': 'xyz123', 'amount': 100.0, 'currency': 'USD'}
  List<String>? get paymentIds;

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
    String? profilePictureUrl,
    DateTime? updatedAt,
    List<String>? appointments,
    bool? busy,
    String? biography,
    List<String>? tokens,
    List<String>? paymentIds,
  });

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

class _UserImpl extends IUser {
  const _UserImpl({
    required this.uid,
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
    this.biography,
  });

  @override
  final Role? role;

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
  final List<String>? appointments;

  @override
  final List<String>? tokens;

  @override
  final List<String>? paymentIds;

  @override
  final String? biography;

  @override
  IUser copyWith({
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
    return _UserImpl(
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

  factory _UserImpl.fromMap(String docId, Map<String, dynamic> data) {
    return _UserImpl(
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

  Map<String, dynamic> get toMap => {
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
