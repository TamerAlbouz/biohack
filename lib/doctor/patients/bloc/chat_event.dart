part of 'chat_bloc.dart';

abstract class ChatEvent {}

class LoadChatHistory extends ChatEvent {}

class SendMessage extends ChatEvent {
  final String content;
  final String patientId;
  final List<FileAttachment> attachments;

  SendMessage({
    required this.content,
    required this.patientId,
    required this.attachments,
  });
}

class ReceiveMessage extends ChatEvent {
  final Message message;

  ReceiveMessage({required this.message});
}
