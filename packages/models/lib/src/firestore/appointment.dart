import 'package:equatable/equatable.dart';
import 'package:models/src/enums/appointment_state.dart';

class Appointment extends Equatable {
  const Appointment({
    required this.appointmentId,
    required this.doctorId,
    required this.patientId,
    required this.specialtyId,
    required this.appointmentStatus,
    required this.serviceId,
    required this.serviceName,
    required this.fee,
    required this.currency,
    required this.appointmentTime,
    required this.duration,
    this.sessionLength,
    this.isConfirmedDoneByPatient = false,
    this.isConfirmedDoneByDoctor = false,
    this.isPaymentHeldInEscrow = false,
    this.paymentId,
    this.disputeRaised = false,
    this.disputeDetails,
    this.callDetails,
    this.notifications,
    this.feedback,
    required this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier for the appointment.
  final String appointmentId;

  /// Unique identifier for the doctor.
  final String doctorId;

  /// Unique identifier for the patient.
  final String patientId;

  /// Unique identifier for the specialty.
  final String specialtyId;

  /// Status of the appointment ('confirmed', 'cancelled').
  final AppointmentState appointmentStatus;

  /// Unique identifier for the service.
  final String serviceId;

  /// Name of the service.
  final String serviceName;

  /// Fee for the service.
  final double fee;

  /// Currency of the fee.
  final String currency;

  /// Date and time of the appointment.
  final DateTime appointmentTime;

  /// Duration of the appointment in minutes.
  final int duration;

  /// Length of each session in minutes.
  final int? sessionLength;

  /// Indicates if the appointment is confirmed done by the patient.
  final bool isConfirmedDoneByPatient;

  /// Indicates if the appointment is confirmed done by the doctor.
  final bool isConfirmedDoneByDoctor;

  /// Indicates if the payment is held in escrow might be due to a dispute.
  final bool isPaymentHeldInEscrow;

  /// Unique identifier for the payment.
  final String? paymentId;

  /// Indicates if a dispute is raised for the appointment.
  final bool disputeRaised;

  /// Details of the dispute.
  final DisputeDetails? disputeDetails;

  /// Details of the call.
  final CallDetails? callDetails;

  /// Details of the notifications.
  final Notifications? notifications;

  /// Details of the feedback.
  final FeedbackDetails? feedback;

  /// Date and time when the appointment was created.
  final DateTime createdAt;

  /// Date and time when the appointment was last updated.
  final DateTime? updatedAt;

  /// Returns a new [Appointment] with updated fields.
  Appointment copyWith({
    String? appointmentId,
    String? doctorId,
    String? patientId,
    String? specialtyId,
    AppointmentState? appointmentStatus,
    String? serviceId,
    String? serviceName,
    double? fee,
    String? currency,
    DateTime? appointmentTime,
    int? duration,
    int? sessionLength,
    bool? isConfirmedDoneByPatient,
    bool? isConfirmedDoneByDoctor,
    bool? isPaymentHeldInEscrow,
    String? paymentId,
    bool? disputeRaised,
    DisputeDetails? disputeDetails,
    CallDetails? callDetails,
    Notifications? notifications,
    FeedbackDetails? feedback,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      appointmentId: appointmentId ?? this.appointmentId,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      specialtyId: specialtyId ?? this.specialtyId,
      appointmentStatus: appointmentStatus ?? this.appointmentStatus,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      fee: fee ?? this.fee,
      currency: currency ?? this.currency,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      duration: duration ?? this.duration,
      sessionLength: sessionLength ?? this.sessionLength,
      isConfirmedDoneByPatient:
          isConfirmedDoneByPatient ?? this.isConfirmedDoneByPatient,
      isConfirmedDoneByDoctor:
          isConfirmedDoneByDoctor ?? this.isConfirmedDoneByDoctor,
      isPaymentHeldInEscrow:
          isPaymentHeldInEscrow ?? this.isPaymentHeldInEscrow,
      paymentId: paymentId ?? this.paymentId,
      disputeRaised: disputeRaised ?? this.disputeRaised,
      disputeDetails: disputeDetails ?? this.disputeDetails,
      callDetails: callDetails ?? this.callDetails,
      notifications: notifications ?? this.notifications,
      feedback: feedback ?? this.feedback,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts a [Map<String, dynamic>] to an [Appointment].
  factory Appointment.fromMap(Map<String, dynamic> data) {
    return Appointment(
      appointmentId: data['appointmentId'],
      doctorId: data['doctorId'],
      patientId: data['patientId'],
      specialtyId: data['specialtyId'],
      appointmentStatus: data['status'],
      serviceId: data['serviceId'],
      serviceName: data['serviceName'],
      fee: data['fee'],
      currency: data['currency'],
      appointmentTime: DateTime.parse(data['appointmentTime']),
      duration: data['duration'],
      sessionLength: data['sessionLength'],
      isConfirmedDoneByPatient: data['isConfirmedDoneByPatient'],
      isConfirmedDoneByDoctor: data['isConfirmedDoneByDoctor'],
      isPaymentHeldInEscrow: data['isPaymentHeldInEscrow'],
      paymentId: data['paymentId'],
      disputeRaised: data['disputeRaised'],
      disputeDetails: data['disputeDetails'] != null
          ? DisputeDetails.fromMap(data['disputeDetails'])
          : null,
      callDetails: data['callDetails'] != null
          ? CallDetails.fromMap(data['callDetails'])
          : null,
      notifications: data['notifications'] != null
          ? Notifications.fromMap(data['notifications'])
          : null,
      feedback: data['feedback'] != null
          ? FeedbackDetails.fromMap(data['feedback'])
          : null,
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt:
          data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
    );
  }

  /// Converts an [Appointment] to a [Map<String, dynamic>].
  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'doctorId': doctorId,
      'patientId': patientId,
      'specialtyId': specialtyId,
      'status': appointmentStatus,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'fee': fee,
      'currency': currency,
      'appointmentTime': appointmentTime.toIso8601String(),
      'duration': duration,
      'sessionLength': sessionLength,
      'isConfirmedDoneByPatient': isConfirmedDoneByDoctor,
      'isConfirmedDoneByDoctor': isConfirmedDoneByDoctor,
      'isPaymentHeldInEscrow': isPaymentHeldInEscrow,
      'paymentId': paymentId,
      'disputeRaised': disputeRaised,
      'disputeDetails': disputeDetails?.toMap(),
      'callDetails': callDetails?.toMap(),
      'notifications': notifications?.toMap(),
      'feedback': feedback?.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        appointmentId,
        doctorId,
        patientId,
        specialtyId,
        appointmentStatus,
        serviceId,
        serviceName,
        fee,
        currency,
        appointmentTime,
        duration,
        sessionLength,
        isConfirmedDoneByPatient,
        isConfirmedDoneByDoctor,
        isPaymentHeldInEscrow,
        paymentId,
        disputeRaised,
        disputeDetails,
        callDetails,
        notifications,
        feedback,
        createdAt,
        updatedAt,
      ];
}

// Add other classes like DisputeDetails, CallDetails, Notifications, and FeedbackDetails as needed.
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

  @override
  List<Object?> get props => [
        raisedBy,
        reason,
        reviewedByAdmin,
        adminResolution,
      ];
}

class CallDetails extends Equatable {
  const CallDetails({
    this.isCallStarted = false,
    this.doctorJoinedAt,
    this.patientJoinedAt,
    this.callEndedAt,
  });

  /// Indicates if the call is started.
  final bool isCallStarted;

  /// Date and time when the doctor joined the call.
  final DateTime? doctorJoinedAt;

  /// Date and time when the patient joined the call.
  final DateTime? patientJoinedAt;

  /// Date and time when the call ended.
  final DateTime? callEndedAt;

  /// Returns a new [CallDetails] with updated fields.
  CallDetails copyWith({
    bool? isCallStarted,
    DateTime? doctorJoinedAt,
    DateTime? patientJoinedAt,
    DateTime? callEndedAt,
  }) {
    return CallDetails(
      isCallStarted: isCallStarted ?? this.isCallStarted,
      doctorJoinedAt: doctorJoinedAt ?? this.doctorJoinedAt,
      patientJoinedAt: patientJoinedAt ?? this.patientJoinedAt,
      callEndedAt: callEndedAt ?? this.callEndedAt,
    );
  }

  /// Converts a [Map<String, dynamic>] to a [CallDetails].
  factory CallDetails.fromMap(Map<String, dynamic> data) {
    return CallDetails(
      isCallStarted: data['isCallStarted'],
      doctorJoinedAt: data['doctorJoinedAt'] != null
          ? DateTime.parse(data['doctorJoinedAt'])
          : null,
      patientJoinedAt: data['patientJoinedAt'] != null
          ? DateTime.parse(data['patientJoinedAt'])
          : null,
      callEndedAt: data['callEndedAt'] != null
          ? DateTime.parse(data['callEndedAt'])
          : null,
    );
  }

  /// Converts a [CallDetails] to a [Map<String, dynamic>].
  Map<String, dynamic> toMap() {
    return {
      'isCallStarted': isCallStarted,
      'doctorJoinedAt': doctorJoinedAt?.toIso8601String(),
      'patientJoinedAt': patientJoinedAt?.toIso8601String(),
      'callEndedAt': callEndedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        isCallStarted,
        doctorJoinedAt,
        patientJoinedAt,
        callEndedAt,
      ];
}

class Notifications extends Equatable {
  const Notifications({
    this.reminderSentAt,
    this.notificationTokens = const [],
  });

  /// Date and time when the reminder was sent.
  final DateTime? reminderSentAt;

  /// List of notification tokens.
  final List<String> notificationTokens;

  /// Returns a new [Notifications] with updated fields.
  Notifications copyWith({
    DateTime? reminderSentAt,
    List<String>? notificationTokens,
  }) {
    return Notifications(
      reminderSentAt: reminderSentAt ?? this.reminderSentAt,
      notificationTokens: notificationTokens ?? this.notificationTokens,
    );
  }

  /// Converts a [Map<String, dynamic>] to a [Notifications].
  factory Notifications.fromMap(Map<String, dynamic> data) {
    return Notifications(
      reminderSentAt: data['reminderSentAt'] != null
          ? DateTime.parse(data['reminderSentAt'])
          : null,
      notificationTokens: List<String>.from(data['notificationTokens']),
    );
  }

  /// Converts a [Notifications] to a [Map<String, dynamic>].
  Map<String, dynamic> toMap() {
    return {
      'reminderSentAt': reminderSentAt?.toIso8601String(),
      'notificationTokens': notificationTokens,
    };
  }

  @override
  List<Object?> get props => [
        reminderSentAt,
        notificationTokens,
      ];
}

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
