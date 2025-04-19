// chats_list_state.dart

import 'package:equatable/equatable.dart';
import 'package:medtalk/backend/chat/models/chat_room.dart';

abstract class ChatsListState extends Equatable {
  const ChatsListState();

  @override
  List<Object?> get props => [];
}

class ChatsListInitial extends ChatsListState {}

class ChatsListLoading extends ChatsListState {}

class ChatsListLoaded extends ChatsListState {
  final List<ChatRoom> chatRooms;

  const ChatsListLoaded({required this.chatRooms});

  @override
  List<Object?> get props => [chatRooms];
}

class ChatsListEmpty extends ChatsListState {}

class ChatsListError extends ChatsListState {
  final String error;

  const ChatsListError(this.error);

  @override
  List<Object?> get props => [error];
}
