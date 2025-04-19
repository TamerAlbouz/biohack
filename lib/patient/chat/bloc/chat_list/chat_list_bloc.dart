// chats_list_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:medtalk/backend/chat/interfaces/chat_interface.dart';

import 'chat_list_event.dart';
import 'chat_list_state.dart';

@injectable
class ChatsListBloc extends Bloc<ChatsListEvent, ChatsListState> {
  final IChatRepository _chatRepository;
  final Logger logger;

  ChatsListBloc(this._chatRepository, this.logger) : super(ChatsListInitial()) {
    on<LoadChatsList>(_onLoadChatsList);
    on<RefreshChatsList>(_onRefreshChatsList);
  }

  Future<void> _onLoadChatsList(
      LoadChatsList event, Emitter<ChatsListState> emit) async {
    try {
      logger.i('Loading chat rooms for user ${event.currentUserId}');
      emit(ChatsListLoading());

      final chatRooms =
          await _chatRepository.getUserChatRooms(event.currentUserId);

      if (chatRooms.isEmpty) {
        logger.i('No chat rooms found for user ${event.currentUserId}');
        emit(ChatsListEmpty());
      } else {
        logger.i('Chat rooms loaded for user ${event.currentUserId}');
        // Sort chat rooms by last message time, most recent first
        chatRooms
            .sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
        emit(ChatsListLoaded(chatRooms: chatRooms));
      }
    } catch (e) {
      logger.e('Error loading chat rooms: $e');
      emit(ChatsListError(e.toString()));
    }
  }

  Future<void> _onRefreshChatsList(
      RefreshChatsList event, Emitter<ChatsListState> emit) async {
    await _onLoadChatsList(LoadChatsList(event.currentUserId), emit);
  }
}
