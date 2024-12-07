import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:p_logger/p_logger.dart';

import '../interfaces/chat_interface.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';

@LazySingleton(as: IChatRepository)
class ChatRepository implements IChatRepository {
  final FirebaseFirestore _firestore;
  late final CollectionReference _chatMessagesCollection;

  ChatRepository(this._firestore) {
    _chatMessagesCollection = _firestore.collection('chat_rooms');
  }

  @override
  Future<String> createChatRoom(String senderId, String receiverId) async {
    try {
      logger.i('Creating chat room for users $senderId and $receiverId');

      // Ensure chat rooms are consistent regardless of who initiates
      final sortedIds = [senderId, receiverId]..sort();
      final chatRoomId = sortedIds.join('_');

      final chatRoomRef = _chatMessagesCollection.doc(chatRoomId);

      await chatRoomRef.set({
        'user1Id': sortedIds[0],
        'user2Id': sortedIds[1],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessageTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      logger.i('Chat room created for users $senderId and $receiverId');
      return chatRoomId;
    } catch (e) {
      logger.e('Error creating chat room: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendMessage(String chatId, ChatMessage message) async {
    try {
      logger.i('Sending message');
      final messageRef =
          _chatMessagesCollection.doc(chatId).collection('messages').doc();

      // Set message with auto-generated ID
      await messageRef.set(message.toMap());

      // Update chat room's last message details
      await _chatMessagesCollection.doc(chatId).update({
        'lastMessage': message.content,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
      logger.i('Message sent');
    } catch (e) {
      logger.e('Error sending message: $e');
      rethrow;
    }
  }

  @override
  Stream<List<ChatMessage>> getMessages(
    String chatId, {
    DocumentSnapshot? lastDocument,
    int limit = 7,
  }) {
    try {
      Query query = _chatMessagesCollection
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(limit);

      // If a last document is provided, start after it for pagination
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final chatMessagesStream = query.snapshots().map((snapshot) {
        logger
            .w('Messages loaded from cache: ${snapshot.metadata.isFromCache}');
        return snapshot.docs
            .map((doc) =>
                ChatMessage.fromMap(doc.data() as Map<String, dynamic>))
            .toList()
            .reversed
            .toList();
      });

      return chatMessagesStream;
    } catch (e) {
      logger.e('Error loading chat messages: $e');
      rethrow;
    }
  }

  // Helper method to get the last document for the next page
  @override
  Future<DocumentSnapshot>? getLastDocument(
      DateTime lastMessage, String chatId) {
    // Assuming your ChatMessage has a corresponding Firestore document
    // You might need to adjust this based on your exact implementation
    return _chatMessagesCollection
        .doc(chatId)
        .collection('messages')
        .where('timestamp', isEqualTo: lastMessage)
        .limit(1)
        .get()
        .then((querySnapshot) => querySnapshot.docs.first);
  }

  @override
  Future<List<ChatRoom>> getUserChatRooms(String userId) async {
    try {
      // First query for rooms where user is user1Id
      final query1 = await _chatMessagesCollection
          .where('user1Id', isEqualTo: userId)
          .get();

      // Second query for rooms where user is user2Id
      final query2 = await _chatMessagesCollection
          .where('user2Id', isEqualTo: userId)
          .get();

      // Combine results from both queries
      final chatRooms = [...query1.docs, ...query2.docs]
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            if (data != null) {
              return ChatRoom.fromMap({...data, 'id': doc.id});
            }
            return null;
          })
          .where((chatRoom) => chatRoom != null)
          .cast<ChatRoom>()
          .toList();

      // Optionally, sort by last message time
      chatRooms.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

      return chatRooms;
    } catch (e) {
      logger.e('Error getting user chat rooms: $e');
      rethrow;
    }
  }
}
