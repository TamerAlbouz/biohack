// chats_list_screen.dart
import 'package:backend/backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtalk/common/globals/globals.dart';
import 'package:medtalk/styles/colors.dart';

import '../../../app/bloc/auth/route_bloc.dart';
import '../bloc/chat_list/chat_list_bloc.dart';
import '../bloc/chat_list/chat_list_event.dart';
import '../bloc/chat_list/chat_list_state.dart';
import 'chat_screen.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({
    super.key,
  });

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  // Method to get the other user's ID in the chat room
  String _getOtherUserId(ChatRoom chatRoom, String currentUserId) {
    return chatRoom.user1Id == currentUserId
        ? chatRoom.user2Id
        : chatRoom.user1Id;
  }

  // Method to navigate to chat screen
  void _navigateToChatScreen(ChatRoom chatRoom, String userId) {
    final otherUserId = _getOtherUserId(chatRoom, userId);

    AppGlobal.navigatorKey.currentState!.push(
      ChatScreen.route(
        currentUserId: userId,
        otherUserId: otherUserId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<ChatsListBloc, ChatsListState>(
        listener: (context, state) {
          if (state is ChatsListError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          if (state is ChatsListLoading || state is ChatsListInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChatsListEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline,
                      size: 100, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No chats yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Start a conversation with someone',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          if (state is ChatsListLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ChatsListBloc>().add(RefreshChatsList(
                    (context.read<RouteBloc>().state as AuthSuccess).user.uid));
              },
              child: ListView.builder(
                itemCount: state.chatRooms.length,
                itemBuilder: (context, index) {
                  final chatRoom = state.chatRooms[index];
                  final otherUserId = _getOtherUserId(
                      chatRoom,
                      (context.read<RouteBloc>().state as AuthSuccess)
                          .user
                          .uid);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: MyColors.blue,
                      // Placeholder for user avatar
                      child: Text(
                        otherUserId[0].toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      '$otherUserId',
                      // Replace with actual user name
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      style: const TextStyle(
                          color: MyColors.textGrey, fontSize: 14),
                      chatRoom.lastMessage ?? 'No messages yet',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      // Format timestamp
                      _formatTimestamp(chatRoom.lastMessageTime),
                      style: const TextStyle(
                          color: MyColors.textGrey, fontSize: 14),
                    ),
                    onTap: () => _navigateToChatScreen(
                        chatRoom,
                        (context.read<RouteBloc>().state as AuthSuccess)
                            .user
                            .uid),
                  );
                },
              ),
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }

  // Helper method to format timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inHours < 24) {
      // Within 24 hours, show time
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      // Within a week, show day
      return [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun'
      ][timestamp.weekday - 1];
    } else {
      // Older, show date
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
