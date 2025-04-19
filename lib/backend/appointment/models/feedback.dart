import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'feedback.g.dart';

@JsonSerializable()
class FeedbackDetails extends Equatable {
  const FeedbackDetails({
    this.patientFeedback,
  });

  /// Feedback provided by the patient.
  final String? patientFeedback;

  /// Returns a new [FeedbackDetails] with updated fields.
  FeedbackDetails copyWith({
    String? patientFeedback,
  }) {
    return FeedbackDetails(
      patientFeedback: patientFeedback ?? this.patientFeedback,
    );
  }

  /// Converts a [Map<String, dynamic>] to a [FeedbackDetails].
  factory FeedbackDetails.fromMap(Map<String, dynamic> data) {
    return FeedbackDetails(
      patientFeedback: data['patientFeedback'],
    );
  }

  factory FeedbackDetails.fromJson(Map<String, dynamic> json) =>
      _$FeedbackDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$FeedbackDetailsToJson(this);

  /// Converts a [FeedbackDetails] to a [Map<String, dynamic>].
  Map<String, dynamic> toMap() {
    return {
      'patientFeedback': patientFeedback,
    };
  }

  @override
  List<Object?> get props => [
        patientFeedback,
      ];
}
