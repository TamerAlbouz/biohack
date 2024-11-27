// chat_state.dart
import 'package:backend/backend.dart';
import 'package:equatable/equatable.dart';

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

  const ChatRoomLoaded({required this.chatRoomId, required this.messages});

  ChatRoomLoaded copyWith({
    String? chatRoomId,
    Stream<List<ChatMessage>>? messages,
  }) {
    return ChatRoomLoaded(
      chatRoomId: chatRoomId ?? this.chatRoomId,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [chatRoomId, messages];
}

class ChatError extends ChatState {
  final String error;

  const ChatError(this.error);

  @override
  List<Object?> get props => [error];
}
