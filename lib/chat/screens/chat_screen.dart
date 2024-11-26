// chat_screen.dart
import 'package:backend/backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../bloc/chat_room/chat_bloc.dart';
import '../bloc/chat_room/chat_event.dart';
import '../bloc/chat_room/chat_state.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;

  const ChatScreen(
      {super.key, required this.currentUserId, required this.otherUserId});

  static Route<void> route(
          {required String currentUserId, required String otherUserId}) =>
      MaterialPageRoute(
          builder: (_) => ChatScreen(
              currentUserId: currentUserId, otherUserId: otherUserId));

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: BlocProvider(
        create: (context) => ChatBloc(getIt<IChatRepository>())
          ..add(InitializeChatRoom(
              currentUserId: widget.currentUserId,
              otherUserId: widget.otherUserId)),
        child: BlocConsumer<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state is ChatError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.error)));
            }
          },
          builder: (context, state) {
            if (state is ChatRoomLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ChatRoomLoaded) {
              return Column(
                children: [
                  // Messages List
                  Expanded(
                    child: StreamBuilder<List<ChatMessage>>(
                      stream: state.messages,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(
                              child: Text('Error loading messages'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(child: Text('No messages'));
                        }

                        final messages = snapshot.data!;
                        return ListView.builder(
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return ListTile(
                              title: Text(message.content),
                              subtitle: Text(
                                message.timestamp.toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                              trailing: message.senderId == widget.currentUserId
                                  ? const Icon(Icons.send, color: Colors.blue)
                                  : null,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  // Message Input
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              if (_messageController.text.trim().isNotEmpty) {
                                final message = ChatMessage(
                                  id: const Uuid().v4(),
                                  senderId: widget.currentUserId,
                                  content: _messageController.text.trim(),
                                  timestamp: DateTime.now(),
                                );

                                context.read<ChatBloc>().add(SendMessage(
                                    chatRoomId: state.chatRoomId,
                                    message: message));

                                _messageController.clear();
                              }
                            }),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const Center(child: Text('Something went wrong'));
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
