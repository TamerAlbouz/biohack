// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notifications _$NotificationsFromJson(Map<String, dynamic> json) =>
    Notifications(
      reminderSentAt: json['reminderSentAt'] == null
          ? null
          : DateTime.parse(json['reminderSentAt'] as String),
      notificationTokens: (json['notificationTokens'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$NotificationsToJson(Notifications instance) =>
    <String, dynamic>{
      'reminderSentAt': instance.reminderSentAt?.toIso8601String(),
      'notificationTokens': instance.notificationTokens,
    };
