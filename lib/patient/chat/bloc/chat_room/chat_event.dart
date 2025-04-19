// chat_event.dart

import 'package:equatable/equatable.dart';
import 'package:medtalk/backend/chat/models/chat_message.dart';

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

class LoadMoreMessages extends ChatEvent {
  final String chatRoomId;
  final DateTime oldestMessageTimestamp;

  const LoadMoreMessages(
      {required this.chatRoomId, required this.oldestMessageTimestamp});
}
