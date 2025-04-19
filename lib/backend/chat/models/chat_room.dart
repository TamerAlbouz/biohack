import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime lastMessageTime;
  final String? lastMessage;

  ChatRoom({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.lastMessageTime,
    this.lastMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user1Id': user1Id,
      'user2Id': user2Id,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastMessage': lastMessage,
    };
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['id'],
      user1Id: map['user1Id'],
      user2Id: map['user2Id'],
      lastMessageTime: map['lastMessageTime']?.toDate(),
      lastMessage: map['lastMessage'],
    );
  }
}
