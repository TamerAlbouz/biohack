// chat_bloc.dart
import 'package:backend/backend.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:p_logger/p_logger.dart';

import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final IChatRepository _chatRepository;

  ChatBloc(this._chatRepository) : super(ChatInitial()) {
    on<InitializeChatRoom>(_onInitializeChatRoom);
    on<SendMessage>(_onSendMessage);
    on<LoadMoreMessages>(_onLoadChatMessages);
  }

  Future<void> _onInitializeChatRoom(
      InitializeChatRoom event, Emitter<ChatState> emit) async {
    try {
      logger.i('Initializing chat room for user ${event.currentUserId}');
      emit(ChatRoomLoading());

      // Create or get existing chat room
      final chatRoomId = await _chatRepository.createChatRoom(
          event.currentUserId, event.otherUserId);

      // Immediately load messages
      final messagesStream = _chatRepository.getMessages(chatRoomId);

      logger.i('Chat room initialized for user ${event.currentUserId}');
      emit(ChatRoomLoaded(chatRoomId: chatRoomId, messages: messagesStream));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
      SendMessage event, Emitter<ChatState> emit) async {
    try {
      logger.i('Sending message');
      // Send message
      await _chatRepository.sendMessage(event.chatRoomId, event.message);
      logger.i('Message sent');
    } catch (e) {
      logger.e('Error sending message: $e');
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onLoadChatMessages(
      LoadMoreMessages event, Emitter<ChatState> emit) async {
    try {
      logger.i('Loading chat messages for chat room ${event.chatRoomId}');

      // get last document
      final lastDocument = await _chatRepository.getLastDocument(
          event.oldestMessageTimestamp, event.chatRoomId);

      // Load messages previously cached
      final messagesStream = _chatRepository.getMessages(event.chatRoomId,
          lastDocument: lastDocument);

      logger.i('Chat messages loaded for chat room ${event.chatRoomId}');

      emit(ChatRoomLoaded(
          chatRoomId: event.chatRoomId, messages: messagesStream));
    } catch (e) {
      logger.e('Error loading chat messages: $e');
      emit(ChatError(e.toString()));
    }
  }
}
