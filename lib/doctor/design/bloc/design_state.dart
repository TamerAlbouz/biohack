// State
import 'package:equatable/equatable.dart';

import '../models/design_models.dart';

class DesignState extends Equatable {
  final String bio;
  final String phone;
  final String address;
  final String notes;
  final List<DoctorService> services;
  final bool offersInPerson;
  final bool offersOnline;
  final bool offersHomeVisit;
  final Map<String, WorkingHours> schedule;
  final String advanceNotice;
  final String bookingWindow;
  final bool autoConfirm;
  final bool sendReminders;
  final List<String> reminderTimes;
  final List<String> paymentMethods;
  final String cancellationPolicy;
  final bool isLoading;
  final String? errorMessage;

  const DesignState({
    this.bio = '',
    this.phone = '',
    this.address = '',
    this.notes = '',
    this.services = const [],
    this.offersInPerson = true,
    this.offersOnline = true,
    this.offersHomeVisit = false,
    this.schedule = const {},
    this.advanceNotice = '24 hours',
    this.bookingWindow = '3 months',
    this.autoConfirm = true,
    this.sendReminders = true,
    this.reminderTimes = const ['24 hours before', '1 hour before'],
    this.paymentMethods = const ['Credit/Debit Card', 'Cash'],
    this.cancellationPolicy = '24 hours notice',
    this.isLoading = false,
    this.errorMessage,
  });

  DesignState copyWith({
    String? bio,
    String? phone,
    String? address,
    String? notes,
    List<DoctorService>? services,
    bool? offersInPerson,
    bool? offersOnline,
    bool? offersHomeVisit,
    Map<String, WorkingHours>? schedule,
    String? advanceNotice,
    String? bookingWindow,
    bool? autoConfirm,
    bool? sendReminders,
    List<String>? reminderTimes,
    List<String>? paymentMethods,
    String? cancellationPolicy,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DesignState(
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      services: services ?? this.services,
      offersInPerson: offersInPerson ?? this.offersInPerson,
      offersOnline: offersOnline ?? this.offersOnline,
      offersHomeVisit: offersHomeVisit ?? this.offersHomeVisit,
      schedule: schedule ?? this.schedule,
      advanceNotice: advanceNotice ?? this.advanceNotice,
      bookingWindow: bookingWindow ?? this.bookingWindow,
      autoConfirm: autoConfirm ?? this.autoConfirm,
      sendReminders: sendReminders ?? this.sendReminders,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        bio,
        phone,
        address,
        notes,
        services,
        offersInPerson,
        offersOnline,
        offersHomeVisit,
        schedule,
        advanceNotice,
        bookingWindow,
        autoConfirm,
        sendReminders,
        reminderTimes,
        paymentMethods,
        cancellationPolicy,
        isLoading,
        errorMessage,
      ];
}
