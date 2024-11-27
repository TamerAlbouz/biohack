import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../interfaces/chat_interface.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';

@LazySingleton(as: IChatRepository)
class ChatRepository implements IChatRepository {
  final FirebaseFirestore _firestore;
  late final CollectionReference _userCollection;

  ChatRepository(this._firestore) {
    _userCollection = _firestore.collection('chat_rooms');
  }

  @override
  Future<String> createChatRoom(String senderId, String receiverId) async {
    // Ensure chat rooms are consistent regardless of who initiates
    final sortedIds = [senderId, receiverId]..sort();
    final chatRoomId = sortedIds.join('_');

    final chatRoomRef = _firestore.collection('chat_rooms').doc(chatRoomId);

    await chatRoomRef.set({
      'user1Id': sortedIds[0],
      'user2Id': sortedIds[1],
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessageTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return chatRoomId;
  }

  @override
  Future<void> sendMessage(String chatId, ChatMessage message) async {
    final messageRef = _firestore
        .collection('chat_rooms')
        .doc(chatId)
        .collection('messages')
        .doc();

    // Set message with auto-generated ID
    await messageRef.set(message.toMap());

    // Update chat room's last message details
    await _firestore.collection('chat_rooms').doc(chatId).update({
      'lastMessage': message.content,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .limit(30) // Load only the most recent 20 messages
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data()))
            .toList());
  }

  @override
  Future<List<ChatRoom>> getUserChatRooms(String userId) async {
    // First query for rooms where user is user1Id
    final query1 = await _firestore
        .collection('chat_rooms')
        .where('user1Id', isEqualTo: userId)
        .get();

    // Second query for rooms where user is user2Id
    final query2 = await _firestore
        .collection('chat_rooms')
        .where('user2Id', isEqualTo: userId)
        .get();

    // Combine results from both queries
    final chatRooms = [...query1.docs, ...query2.docs]
        .map((doc) => ChatRoom.fromMap({...doc.data(), 'id': doc.id}))
        .toList();

    // Optionally, sort by last message time
    chatRooms.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

    return chatRooms;
  }
}
