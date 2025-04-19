import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notifications.g.dart';

@JsonSerializable()
class Notifications extends Equatable {
  const Notifications({
    this.reminderSentAt,
    this.notificationTokens = const [],
  });

  /// Date and time when the reminder was sent.
  final DateTime? reminderSentAt;

  /// List of notification tokens.
  final List<String> notificationTokens;

  /// Returns a new [Notifications] with updated fields.
  Notifications copyWith({
    DateTime? reminderSentAt,
    List<String>? notificationTokens,
  }) {
    return Notifications(
      reminderSentAt: reminderSentAt ?? this.reminderSentAt,
      notificationTokens: notificationTokens ?? this.notificationTokens,
    );
  }

  /// Converts a [Map<String, dynamic>] to a [Notifications].
  factory Notifications.fromMap(Map<String, dynamic> data) {
    return Notifications(
      reminderSentAt: data['reminderSentAt'] != null
          ? DateTime.parse(data['reminderSentAt'])
          : null,
      notificationTokens: List<String>.from(data['notificationTokens']),
    );
  }

  /// Converts a [Notifications] to a [Map<String, dynamic>].
  Map<String, dynamic> toMap() {
    return {
      'reminderSentAt': reminderSentAt?.toIso8601String(),
      'notificationTokens': notificationTokens,
    };
  }

  factory Notifications.fromJson(Map<String, dynamic> json) =>
      _$NotificationsFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationsToJson(this);

  @override
  List<Object?> get props => [
        reminderSentAt,
        notificationTokens,
      ];
}
