import 'package:flutter/material.dart';

class ServiceDetail {
  final String name;
  final int price;
  final String duration;
  final String availability;
  final String summary;
  final IconData icon;

  const ServiceDetail({
    required this.name,
    required this.price,
    required this.duration,
    required this.availability,
    required this.summary,
    required this.icon,
  });
}
