// 1. First, create a timestamp_converter.dart file:

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// A JsonConverter for Firestore Timestamps
class TimestampConverter implements JsonConverter<Timestamp?, Object?> {
  const TimestampConverter();

  @override
  Timestamp? fromJson(Object? json) {
    if (json == null) {
      return null;
    }

    if (json is Map<String, dynamic>) {
      // Handle case where Timestamp is serialized as a map with seconds and nanoseconds
      final seconds = json['seconds'] as int?;
      final nanoseconds = json['nanoseconds'] as int?;

      if (seconds != null && nanoseconds != null) {
        return Timestamp(seconds, nanoseconds);
      }
    } else if (json is Timestamp) {
      // In case the json is already a Timestamp (can happen in some cases)
      return json;
    }

    return null;
  }

  @override
  Object? toJson(Timestamp? timestamp) {
    if (timestamp == null) {
      return null;
    }
    return {
      'seconds': timestamp.seconds,
      'nanoseconds': timestamp.nanoseconds,
    };
  }
}
