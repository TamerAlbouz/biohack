part of 'setup_appointment_bloc.dart';

class SetupAppointmentState extends Equatable {
  final bool reBuild;
  final String error;
  final bool isLoading;
  final bool isBooking;
  final bool bookingComplete;
  final int? serviceIndex;

  final SelectionItem? selectedService;
  final AppointmentType? selectedAppointment;
  final DateTime? appointmentDate;
  final TimeOfDay? appointmentTime;
  final PaymentType? selectedPayment;
  final String appointmentLocation;
  final String? doctorId;
  final String? specialty;
  final bool termsAccepted;
  final int bookingAdvanceHours;
  final int bookingWindowDays;
  final String? doctorName;

  // Doctor Profile Information
  final String? doctorBiography;
  final String? doctorPhone;
  final String? doctorAddress;
  final String? doctorNotes;
  final LatLng? doctorLocation;

  final List<SavedCreditCard>? savedCreditCards;
  final String? selectedCardId;

  // Doctor Schedule Information
  final List<WorkingHours> doctorWorkingHours;
  final List<bool> doctorAvailableDays;
  final int defaultSlotDuration;
  final int bufferTime;

  // Doctor Service Information
  final List<Service> doctorServices;
  final ServiceAvailability? selectedServiceAvailability;

  // Doctor Settings
  final int cancellationPolicy;
  final bool acceptsCash;
  final bool acceptsCreditCard;
  final bool acceptsInsurance;

  // Doctor Reviews
  final List<PatientReview> doctorReviews;

  const SetupAppointmentState({
    this.reBuild = false,
    this.error = '',
    this.isLoading = true,
    this.isBooking = false,
    this.bookingComplete = false,
    this.serviceIndex,
    this.selectedService,
    this.selectedAppointment,
    this.appointmentDate,
    this.appointmentTime,
    this.selectedPayment,
    this.appointmentLocation = '',
    this.doctorId,
    this.specialty,
    this.termsAccepted = false,
    this.bookingAdvanceHours = 0,
    this.bookingWindowDays = 365,
    this.doctorName,

    // Doctor profile defaults
    this.doctorBiography,
    this.doctorPhone,
    this.doctorAddress,
    this.doctorNotes,
    this.doctorLocation,
    this.savedCreditCards = const [],
    this.selectedCardId,

    // Doctor schedule defaults
    this.doctorWorkingHours = const [],
    this.doctorAvailableDays = const [
      true,
      true,
      true,
      true,
      true,
      false,
      false
    ],
    this.defaultSlotDuration = 30,
    this.bufferTime = 10,

    // Doctor service defaults
    this.doctorServices = const [],
    this.selectedServiceAvailability,

    // Doctor settings defaults
    this.cancellationPolicy = 24,
    this.acceptsCash = true,
    this.acceptsCreditCard = true,
    this.acceptsInsurance = false,

    // Doctor reviews defaults
    this.doctorReviews = const [],
  });

  SetupAppointmentState copyWith({
    bool? reBuild,
    String? error,
    bool? isLoading,
    bool? isBooking,
    bool? bookingComplete,
    int? serviceIndex,
    SelectionItem? selectedService,
    AppointmentType? selectedAppointment,
    DateTime? appointmentDate,
    TimeOfDay? appointmentTime,
    PaymentType? selectedPayment,
    String? appointmentLocation,
    String? doctorId,
    String? specialty,
    bool? termsAccepted,
    int? bookingAdvanceHours,
    int? bookingWindowDays,
    String? doctorName,

    // Doctor profile
    String? doctorBiography,
    String? doctorPhone,
    String? doctorAddress,
    String? doctorNotes,
    LatLng? doctorLocation,
    List<SavedCreditCard>? savedCreditCards,
    String? selectedCardId,

    // Doctor schedule
    List<WorkingHours>? doctorWorkingHours,
    List<bool>? doctorAvailableDays,
    int? defaultSlotDuration,
    int? bufferTime,

    // Doctor service
    List<Service>? doctorServices,
    ServiceAvailability? selectedServiceAvailability,

    // Doctor settings
    int? cancellationPolicy,
    bool? acceptsCash,
    bool? acceptsCreditCard,
    bool? acceptsInsurance,

    // Doctor reviews
    List<PatientReview>? doctorReviews,
  }) {
    return SetupAppointmentState(
      reBuild: reBuild ?? this.reBuild,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      isBooking: isBooking ?? this.isBooking,
      bookingComplete: bookingComplete ?? this.bookingComplete,
      serviceIndex: serviceIndex ?? this.serviceIndex,

      selectedService: selectedService ?? this.selectedService,
      selectedAppointment: selectedAppointment ?? this.selectedAppointment,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      selectedPayment: selectedPayment ?? this.selectedPayment,
      appointmentLocation: appointmentLocation ?? this.appointmentLocation,
      doctorId: doctorId ?? this.doctorId,
      specialty: specialty ?? this.specialty,
      termsAccepted: termsAccepted ?? this.termsAccepted,

      bookingAdvanceHours: bookingAdvanceHours ?? this.bookingAdvanceHours,
      bookingWindowDays: bookingWindowDays ?? this.bookingWindowDays,
      doctorName: doctorName ?? this.doctorName,

      // Doctor profile
      doctorBiography: doctorBiography ?? this.doctorBiography,
      doctorPhone: doctorPhone ?? this.doctorPhone,
      doctorAddress: doctorAddress ?? this.doctorAddress,
      doctorNotes: doctorNotes ?? this.doctorNotes,
      doctorLocation: doctorLocation ?? this.doctorLocation,

      savedCreditCards: savedCreditCards ?? this.savedCreditCards,
      selectedCardId: selectedCardId ?? this.selectedCardId,

      // Doctor schedule
      doctorWorkingHours: doctorWorkingHours ?? this.doctorWorkingHours,
      doctorAvailableDays: doctorAvailableDays ?? this.doctorAvailableDays,
      defaultSlotDuration: defaultSlotDuration ?? this.defaultSlotDuration,
      bufferTime: bufferTime ?? this.bufferTime,

      // Doctor service
      doctorServices: doctorServices ?? this.doctorServices,
      selectedServiceAvailability:
          selectedServiceAvailability ?? this.selectedServiceAvailability,

      // Doctor settings
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      acceptsCash: acceptsCash ?? this.acceptsCash,
      acceptsCreditCard: acceptsCreditCard ?? this.acceptsCreditCard,
      acceptsInsurance: acceptsInsurance ?? this.acceptsInsurance,

      // Doctor reviews
      doctorReviews: doctorReviews ?? this.doctorReviews,
    );
  }

  @override
  List<Object?> get props => [
        reBuild,
        error,
        isLoading,
        isBooking,
        bookingComplete,
        serviceIndex,

        selectedService,
        selectedAppointment,
        appointmentDate,
        appointmentTime,
        selectedPayment,
        appointmentLocation,
        doctorId,
        specialty,
        termsAccepted,

        bookingAdvanceHours,
        bookingWindowDays,
        doctorName,

        // Doctor profile
        doctorBiography,
        doctorPhone,
        doctorAddress,
        doctorNotes,
        doctorLocation,

        savedCreditCards,
        selectedCardId,

        // Doctor schedule
        doctorWorkingHours,
        doctorAvailableDays,
        defaultSlotDuration,
        bufferTime,

        // Doctor service
        doctorServices,
        selectedServiceAvailability,

        // Doctor settings
        cancellationPolicy,
        acceptsCash,
        acceptsCreditCard,
        acceptsInsurance,

        // Doctor reviews
        doctorReviews,
      ];
}
