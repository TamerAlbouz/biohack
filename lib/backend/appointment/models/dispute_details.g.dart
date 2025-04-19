// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispute_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DisputeDetails _$DisputeDetailsFromJson(Map<String, dynamic> json) =>
    DisputeDetails(
      raisedBy: json['raisedBy'] as String?,
      reason: json['reason'] as String?,
      reviewedByAdmin: json['reviewedByAdmin'] as bool? ?? false,
      adminResolution: json['adminResolution'] as String?,
    );

Map<String, dynamic> _$DisputeDetailsToJson(DisputeDetails instance) =>
    <String, dynamic>{
      'raisedBy': instance.raisedBy,
      'reason': instance.reason,
      'reviewedByAdmin': instance.reviewedByAdmin,
      'adminResolution': instance.adminResolution,
    };
