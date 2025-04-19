part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {}

class LoadChatHistory extends ChatEvent {
  final String patientId;

  LoadChatHistory({required this.patientId});

  @override
  List<Object> get props => [patientId];
}

class SendMessage extends ChatEvent {
  final String content;
  final String patientId;
  final List<FileAttachment> attachments;

  SendMessage({
    required this.content,
    required this.patientId,
    required this.attachments,
  });

  @override
  List<Object> get props => [content, patientId, attachments];
}

class ReceiveMessage extends ChatEvent {
  final Message message;

  ReceiveMessage({required this.message});

  @override
  List<Object> get props => [message];
}
