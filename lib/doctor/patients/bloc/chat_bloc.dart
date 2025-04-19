import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../models/patients_models.dart';

part 'chat_event.dart';
part 'chat_state.dart';

@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  static const uuid = Uuid();

  ChatBloc() : super(ChatInitial()) {
    on<LoadChatHistory>(_onLoadChatHistory);
    on<SendMessage>(_onSendMessage);
    on<ReceiveMessage>(_onReceiveMessage);
  }

  Future<void> _onLoadChatHistory(
    LoadChatHistory event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      // In a real app, fetch messages from repository
      // final messages = await messageRepository.getChatHistory(patientId);

      // For demonstration purposes, use dummy data
      final messages = _getDummyMessages(event.patientId);

      emit(ChatHistoryLoaded(messages: messages));
    } catch (e) {
      emit(ChatError(message: 'Failed to load chat history: $e'));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatHistoryLoaded) {
      final currentMessages = (state as ChatHistoryLoaded).messages;
      try {
        final List<Message> updatedMessages = List.from(currentMessages);

        // Process attachments first if any
        if (event.attachments.isNotEmpty) {
          for (final attachment in event.attachments) {
            // In a real app, upload file to server
            // final uploadResult = await documentRepository.uploadFile(
            //   patientId: event.patientId,
            //   filePath: attachment.filePath,
            //   fileName: attachment.fileName,
            //   fileType: attachment.fileType,
            // );

            // Create document in patient's documents
            final documentId = uuid.v4();

            // Create message with attachment
            final attachmentMessage = Message(
              id: uuid.v4(),
              content: event.content.isNotEmpty
                  ? event.content
                  : 'Shared a file: ${attachment.fileName}',
              senderId: 'doctor_id',
              // In real app, use actual doctor ID
              receiverId: event.patientId,
              timestamp: DateTime.now(),
              isRead: false,
              attachmentUrl: 'file://${attachment.filePath}',
              // In real app, use server URL
              attachmentType: attachment.fileType,
              attachmentName: attachment.fileName,
            );

            updatedMessages.add(attachmentMessage);

            emit(ChatFileSent(
              messages: updatedMessages,
              fileName: attachment.fileName,
              documentId: documentId,
            ));
          }
        } else if (event.content.isNotEmpty) {
          // Text-only message
          final message = Message(
            id: uuid.v4(),
            content: event.content,
            senderId: 'doctor_id',
            // In real app, use actual doctor ID
            receiverId: event.patientId,
            timestamp: DateTime.now(),
            isRead: false,
          );

          // In a real app, send message through repository
          // await messageRepository.sendMessage(message);

          updatedMessages.add(message);
          emit(ChatMessageSent(messages: updatedMessages));
        }
      } catch (e) {
        emit(ChatError(message: 'Failed to send message: $e'));
        // Restore previous state
        emit(ChatHistoryLoaded(messages: currentMessages));
      }
    }
  }

  void _onReceiveMessage(
    ReceiveMessage event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatHistoryLoaded) {
      final currentMessages = (state as ChatHistoryLoaded).messages;
      final updatedMessages = List<Message>.from(currentMessages)
        ..add(event.message);

      emit(ChatHistoryLoaded(messages: updatedMessages));
    }
  }

  // For demonstration purposes only
  List<Message> _getDummyMessages(String patientId) {
    return [
      Message(
        id: '1',
        content: 'Hello Dr. Smith, I have a question about my medication.',
        senderId: patientId,
        receiverId: 'doctor_id',
        timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
        isRead: true,
      ),
      Message(
        id: '2',
        content: 'Of course, what would you like to know?',
        senderId: 'doctor_id',
        receiverId: patientId,
        timestamp: DateTime.now()
            .subtract(const Duration(days: 2, hours: 4, minutes: 45)),
        isRead: true,
      ),
      Message(
        id: '3',
        content:
            'I\'ve been experiencing some side effects like dizziness and nausea.',
        senderId: patientId,
        receiverId: 'doctor_id',
        timestamp: DateTime.now()
            .subtract(const Duration(days: 2, hours: 4, minutes: 30)),
        isRead: true,
      ),
      Message(
        id: '4',
        content: 'I\'m sharing my recent blood test results as well.',
        senderId: patientId,
        receiverId: 'doctor_id',
        timestamp: DateTime.now()
            .subtract(const Duration(days: 2, hours: 4, minutes: 28)),
        isRead: true,
        attachmentUrl: 'file://dummy/path/blood_test.pdf',
        attachmentType: 'document',
        attachmentName: 'blood_test.pdf',
      ),
      Message(
        id: '5',
        content:
            'Thank you for sharing. I\'ll review the results and adjust your medication if needed. For the dizziness, try taking the medication after meals and with plenty of water.',
        senderId: 'doctor_id',
        receiverId: patientId,
        timestamp: DateTime.now()
            .subtract(const Duration(days: 2, hours: 3, minutes: 50)),
        isRead: true,
      ),
      Message(
        id: '6',
        content: 'Here\'s the updated prescription for you.',
        senderId: 'doctor_id',
        receiverId: patientId,
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
        isRead: true,
        attachmentUrl: 'file://dummy/path/new_prescription.pdf',
        attachmentType: 'document',
        attachmentName: 'new_prescription.pdf',
      ),
      Message(
        id: '7',
        content: 'Thank you, Doctor. I\'ll follow your advice.',
        senderId: patientId,
        receiverId: 'doctor_id',
        timestamp: DateTime.now()
            .subtract(const Duration(days: 1, hours: 5, minutes: 30)),
        isRead: true,
      ),
    ];
  }
}
