import 'package:json_annotation/json_annotation.dart';

part 'qualification.g.dart';

@JsonSerializable(explicitToJson: true)
class Qualification {
  final String title;
  final String yearRange;

  const Qualification({
    required this.title,
    required this.yearRange,
  });

  factory Qualification.fromJson(Map<String, dynamic> json) =>
      _$QualificationFromJson(json);

  Map<String, dynamic> toJson() => _$QualificationToJson(this);
}
