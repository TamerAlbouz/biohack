// chat_state.dart

import 'package:equatable/equatable.dart';
import 'package:medtalk/backend/chat/models/chat_message.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatRoomLoading extends ChatState {}

class ChatRoomLoaded extends ChatState {
  final String chatRoomId;
  final Stream<List<ChatMessage>> messages;

  const ChatRoomLoaded({
    required this.chatRoomId,
    required this.messages,
  });

  @override
  List<Object?> get props => [chatRoomId, messages];
}

class ChatError extends ChatState {
  final String error;

  const ChatError(this.error);

  @override
  List<Object?> get props => [error];
}
