import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'service.g.dart';

@JsonSerializable()
class Service {
  const Service({
    required this.id,
    required this.doctorId,
    required this.name,
    required this.description,
    required this.duration,
    required this.price,
  });

  final String id;
  final String doctorId;
  final String name;
  final String description;
  final int duration; // in minutes
  final double price;

  factory Service.fromJson(Map<String, dynamic> json) =>
      _$ServiceFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceToJson(this);

  factory Service.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Service(
      id: doc.id,
      doctorId: data['doctorId'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      duration: data['duration'] as int,
      price: (data['price'] as num).toDouble(),
    );
  }

  Service copyWith({
    String? id,
    String? doctorId,
    String? name,
    String? description,
    int? duration,
    double? price,
  }) {
    return Service(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      name: name ?? this.name,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      price: price ?? this.price,
    );
  }
}
