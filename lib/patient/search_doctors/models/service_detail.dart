import 'package:backend/backend.dart';

class ServiceDetail {
  final String name;
  final int price;
  final String duration;
  final List<AppointmentType> availability;
  final String summary;

  const ServiceDetail({
    required this.name,
    required this.price,
    required this.duration,
    required this.availability,
    required this.summary,
  });
}
