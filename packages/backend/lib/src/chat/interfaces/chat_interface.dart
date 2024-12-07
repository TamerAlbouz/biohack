import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_message.dart';
import '../models/chat_room.dart';

abstract class IChatRepository {
  Future<void> sendMessage(String chatId, ChatMessage message);

  Stream<List<ChatMessage>> getMessages(
    String chatId, {
    DocumentSnapshot? lastDocument,
    int limit = 7,
  });

  Future<DocumentSnapshot>? getLastDocument(
      DateTime lastMessage, String chatId);

  Future<String> createChatRoom(String senderId, String receiverId);

  Future<List<ChatRoom>> getUserChatRooms(String userId);
}
