part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatHistoryLoaded extends ChatState {
  final List<Message> messages;

  ChatHistoryLoaded({required this.messages});

  @override
  List<Object?> get props => [messages];
}

class ChatMessageSent extends ChatHistoryLoaded {
  ChatMessageSent({required super.messages});
}

class ChatFileSent extends ChatHistoryLoaded {
  final String fileName;
  final String documentId;

  ChatFileSent({
    required super.messages,
    required this.fileName,
    required this.documentId,
  });

  @override
  List<Object?> get props => [messages, fileName, documentId];
}

class ChatError extends ChatState {
  final String message;

  ChatError({required this.message});

  @override
  List<Object?> get props => [message];
}
