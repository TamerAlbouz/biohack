import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:medtalk/backend/patient/models/patient.dart';

enum StatsPeriod { week, month, quarter, year, allTime }

// Rating distribution model
class RatingDistribution extends Equatable {
  final int oneStar;
  final int twoStars;
  final int threeStars;
  final int fourStars;
  final int fiveStars;

  const RatingDistribution({
    required this.oneStar,
    required this.twoStars,
    required this.threeStars,
    required this.fourStars,
    required this.fiveStars,
  });

  int get total => oneStar + twoStars + threeStars + fourStars + fiveStars;

  @override
  List<Object?> get props =>
      [oneStar, twoStars, threeStars, fourStars, fiveStars];
}

// Service model for top services
class ServiceStats extends Equatable {
  final String name;
  final int count;
  final int revenue;

  const ServiceStats({
    required this.name,
    required this.count,
    required this.revenue,
  });

  @override
  List<Object?> get props => [name, count, revenue];
}

// Day model for busiest days
class DayStats extends Equatable {
  final String day;
  final int count;
  final double percentage;

  const DayStats({
    required this.day,
    required this.count,
    required this.percentage,
  });

  @override
  List<Object?> get props => [day, count, percentage];
}

// Cancellation reason model
class CancellationReason extends Equatable {
  final String reason;
  final int count;
  final double percentage;

  const CancellationReason({
    required this.reason,
    required this.count,
    required this.percentage,
  });

  @override
  List<Object?> get props => [reason, count, percentage];
}

// Referral source model
class ReferralSource extends Equatable {
  final String source;
  final int count;
  final double percentage;

  const ReferralSource({
    required this.source,
    required this.count,
    required this.percentage,
  });

  @override
  List<Object?> get props => [source, count, percentage];
}

// Extended Patient model with last visit date
extension PatientExtension on Patient {
  DateTime? get lastVisit =>
      null; // This would normally come from your Patient model
}

// Helper class for monthly revenue data
class MonthlyRevenue {
  final String month;
  final double revenue;

  MonthlyRevenue({
    required this.month,
    required this.revenue,
  });
}

// Helper class for appointment type revenue data
class TypeRevenue {
  final String type;
  final double revenue;
  final Color color;

  TypeRevenue({
    required this.type,
    required this.revenue,
    required this.color,
  });
}
