// chats_list_event.dart
import 'package:equatable/equatable.dart';

abstract class ChatsListEvent extends Equatable {
  const ChatsListEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatsList extends ChatsListEvent {
  final String currentUserId;

  const LoadChatsList(this.currentUserId);

  @override
  List<Object?> get props => [currentUserId];
}

class RefreshChatsList extends ChatsListEvent {
  final String currentUserId;

  const RefreshChatsList(this.currentUserId);

  @override
  List<Object?> get props => [currentUserId];
}
