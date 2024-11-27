// chat_event.dart
import 'package:backend/backend.dart';
import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class InitializeChatRoom extends ChatEvent {
  final String currentUserId;
  final String otherUserId;

  const InitializeChatRoom(
      {required this.currentUserId, required this.otherUserId});

  @override
  List<Object?> get props => [currentUserId, otherUserId];
}

class SendMessage extends ChatEvent {
  final String chatRoomId;
  final ChatMessage message;

  const SendMessage({required this.chatRoomId, required this.message});

  @override
  List<Object?> get props => [chatRoomId, message];
}

class LoadChatMessages extends ChatEvent {
  final String chatRoomId;

  const LoadChatMessages(this.chatRoomId);

  @override
  List<Object?> get props => [chatRoomId];
}
