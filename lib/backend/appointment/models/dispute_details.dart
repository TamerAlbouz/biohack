import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dispute_details.g.dart';

@JsonSerializable()
class DisputeDetails extends Equatable {
  const DisputeDetails({
    this.raisedBy,
    this.reason,
    this.reviewedByAdmin = false,
    this.adminResolution,
  });

  /// Indicates who raised the dispute ('doctorId1' or 'patientId1').
  final String? raisedBy;

  /// Reason for raising the dispute.
  final String? reason;

  /// Indicates if the dispute is reviewed by the admin.
  final bool reviewedByAdmin;

  /// Resolution provided by the admin.
  final String? adminResolution;

  /// Returns a new [DisputeDetails] with updated fields.
  DisputeDetails copyWith({
    String? raisedBy,
    String? reason,
    bool? reviewedByAdmin,
    String? adminResolution,
  }) {
    return DisputeDetails(
      raisedBy: raisedBy ?? this.raisedBy,
      reason: reason ?? this.reason,
      reviewedByAdmin: reviewedByAdmin ?? this.reviewedByAdmin,
      adminResolution: adminResolution ?? this.adminResolution,
    );
  }

  /// Converts a [Map<String, dynamic>] to a [DisputeDetails].
  factory DisputeDetails.fromMap(Map<String, dynamic> data) {
    return DisputeDetails(
      raisedBy: data['raisedBy'],
      reason: data['reason'],
      reviewedByAdmin: data['reviewedByAdmin'],
      adminResolution: data['adminResolution'],
    );
  }

  /// Converts a [DisputeDetails] to a [Map<String, dynamic>].
  Map<String, dynamic> toMap() {
    return {
      'raisedBy': raisedBy,
      'reason': reason,
      'reviewedByAdmin': reviewedByAdmin,
      'adminResolution': adminResolution,
    };
  }

  factory DisputeDetails.fromJson(Map<String, dynamic> json) =>
      _$DisputeDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$DisputeDetailsToJson(this);

  @override
  List<Object?> get props => [
        raisedBy,
        reason,
        reviewedByAdmin,
        adminResolution,
      ];
}
