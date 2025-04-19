import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:medtalk/backend/appointment/interfaces/appointment_interface.dart';
import 'package:medtalk/backend/appointment/models/appointment.dart';
import 'package:medtalk/backend/patient/interfaces/patient_interface.dart';
import 'package:medtalk/backend/patient/models/patient.dart';

import '../models/patients_models.dart';

part 'patient_details_event.dart';
part 'patient_details_state.dart';

@injectable
class PatientDetailsBloc
    extends Bloc<PatientDetailsEvent, PatientDetailsState> {
  final IPatientRepository patientRepository;
  final IAppointmentRepository appointmentRepository;
  final Logger logger;

  // In a real app, you'd also have message and document repositories

  PatientDetailsBloc(
    this.patientRepository,
    this.appointmentRepository,
    this.logger,
  ) : super(PatientDetailsInitial()) {
    on<LoadPatientDetails>(_onLoadPatientDetails);
  }

  Future<void> _onLoadPatientDetails(
    LoadPatientDetails event,
    Emitter<PatientDetailsState> emit,
  ) async {
    try {
      emit(PatientDetailsLoading());

      // Get patient details
      final patient = await patientRepository.getPatient(event.patientId);

      if (patient == null) {
        emit(PatientDetailsError('Patient not found'));
        return;
      }

      // Get patient's appointments
      final appointments =
          await appointmentRepository.getPatientAppointments(event.patientId);

      // Sort appointments by date (newest first)
      appointments
          .sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));

      // In a real app, you would fetch messages and documents here
      // For this example, we'll create mock data
      final messages = _createMockMessages(event.patientId);
      final documents = _createMockDocuments();

      emit(PatientDetailsLoaded(
        patient: patient,
        appointments: appointments,
        messages: messages,
        documents: documents,
      ));
    } catch (e) {
      logger.e('Error loading patient details: $e');
      emit(PatientDetailsError(e.toString()));
    }
  }

  List<Message> _createMockMessages(String patientId) {
    final now = DateTime.now();

    return [
      Message(
        id: '1',
        senderId: 'doctor-id',
        receiverId: patientId,
        content:
            'Good morning! How are you feeling after our last appointment?',
        timestamp: now.subtract(const Duration(days: 3, hours: 2)),
      ),
      Message(
        id: '2',
        senderId: patientId,
        receiverId: 'doctor-id',
        content:
            'Much better, thank you! The medication has helped with the pain.',
        timestamp: now.subtract(const Duration(days: 3, hours: 1)),
      ),
      Message(
        id: '3',
        senderId: 'doctor-id',
        receiverId: patientId,
        content: 'Great to hear! Have you experienced any side effects?',
        timestamp: now.subtract(const Duration(days: 3)),
      ),
      Message(
        id: '4',
        senderId: patientId,
        receiverId: 'doctor-id',
        content:
            'Just a bit of drowsiness in the morning, but it\'s manageable.',
        timestamp: now.subtract(const Duration(days: 2, hours: 12)),
      ),
      Message(
        id: '5',
        senderId: 'doctor-id',
        receiverId: patientId,
        content:
            'I\'ve attached the lab requisition for your next blood test. Please get this done before our next appointment.',
        timestamp: now.subtract(const Duration(days: 1, hours: 5)),
      ),
    ];
  }

  List<PatientDocument> _createMockDocuments() {
    final now = DateTime.now();

    return [
      PatientDocument(
        id: '1',
        title: 'Initial Consultation Notes',
        type: DocumentType.medicalRecord,
        uploadDate: now.subtract(const Duration(days: 60)),
        fileUrl: 'https://example.com/document1.pdf',
      ),
      PatientDocument(
        id: '2',
        title: 'Blood Test Results',
        type: DocumentType.labReport,
        uploadDate: now.subtract(const Duration(days: 45)),
        fileUrl: 'https://example.com/document2.pdf',
      ),
      PatientDocument(
        id: '3',
        title: 'Medication Prescription',
        type: DocumentType.prescription,
        uploadDate: now.subtract(const Duration(days: 30)),
        fileUrl: 'https://example.com/document3.pdf',
      ),
      PatientDocument(
        id: '4',
        title: 'Follow-up Examination',
        type: DocumentType.medicalRecord,
        uploadDate: now.subtract(const Duration(days: 15)),
        fileUrl: 'https://example.com/document4.pdf',
      ),
      PatientDocument(
        id: '5',
        title: 'X-Ray Report',
        type: DocumentType.labReport,
        uploadDate: now.subtract(const Duration(days: 7)),
        fileUrl: 'https://example.com/document5.pdf',
      ),
    ];
  }
}

// Message and Document classes are defined in patient_details_screen.dart for this example
