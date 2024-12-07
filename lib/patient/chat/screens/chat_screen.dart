import 'package:backend/backend.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/font.dart';
import 'package:medtalk/styles/sizes.dart';
import 'package:p_logger/p_logger.dart';
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
  final ScrollController _scrollController = ScrollController();
  final _loadingCachedMessages = false;

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildMessageBubble(ChatMessage message, bool isCurrentUser) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: kPadd12,
        decoration: BoxDecoration(
          color: isCurrentUser ? MyColors.messageBubble : Colors.white,
          borderRadius: kRadius12,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        // add max width
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: const TextStyle(fontSize: 16, color: MyColors.textBlack),
            ),
            kGap4,
            Text(
              DateFormat('hh:mm a').format(message.timestamp),
              style:
                  TextStyle(fontSize: Font.extraTiny, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);

      if (pickedFile != null) {
        // Prepare message outside of BLoC context
        final message = ChatMessage(
          id: const Uuid().v4(),
          senderId: widget.currentUserId,
          content: 'Attachment: ${pickedFile.path}',
          timestamp: DateTime.now(),
        );

        // Use a method to send message safely
        _sendMessageSafely(message);
      }
    } catch (e) {
      // Show error using ScaffoldMessenger in the build method
      logger.e('Error picking image: $e');
      _showErrorMessage('Error picking image: $e');
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );

      if (result != null) {
        final message = ChatMessage(
          id: const Uuid().v4(),
          senderId: widget.currentUserId,
          content: 'Document: ${result.files.single.name}',
          timestamp: DateTime.now(),
        );

        // Use a method to send message safely
        _sendMessageSafely(message);
      }
    } catch (e) {
      // Show error using ScaffoldMessenger in the build method
      _showErrorMessage('Error picking document: $e');
    }
  }

// Safe method to send message
  void _sendMessageSafely(ChatMessage message) {
    // Ensure we're in a loaded state before sending
    final currentState = context.read<ChatBloc>().state;
    if (currentState is ChatRoomLoaded) {
      context.read<ChatBloc>().add(SendMessage(
            chatRoomId: currentState.chatRoomId,
            message: message,
          ));
    }
  }

// Method to show error message
  void _showErrorMessage(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

// Utility method to build attachment options
  Widget _buildAttachmentOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: MyColors.lightBlue,
              child: Icon(icon, color: MyColors.white, size: 30),
            ),
            kGap10,
            Text(label,
                style: const TextStyle(
                  fontFamily: Font.family,
                  fontSize: Font.small,
                  color: MyColors.textBlack,
                )),
          ],
        ),
      ),
    );
  }

  void _showAttachmentBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Attach',
                style: TextStyle(
                  fontFamily: Font.family,
                  fontSize: Font.medium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              kGap20,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(
                    context,
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildAttachmentOption(
                    context,
                    icon: Icons.photo,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  _buildAttachmentOption(
                    context,
                    icon: Icons.insert_drive_file,
                    label: 'Document',
                    onTap: () {
                      Navigator.pop(context);
                      _pickDocument();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.cardBackground,
      appBar: AppBar(
        toolbarHeight: 40,
        title: Text(widget.otherUserId, style: const TextStyle(fontSize: 16)),
        automaticallyImplyLeading: true,
        backgroundColor: MyColors.cardBackground,
      ),
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
            if (state is ChatInitial) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
            }

            return Column(
              children: [
                if (state is ChatRoomLoading)
                  // skeleton loading
                  const Expanded(
                    child: SizedBox(),
                  ),
                if (state is ChatRoomLoaded)
                  Expanded(
                    child: StreamBuilder<List<ChatMessage>>(
                      stream: state.messages,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: SizedBox());
                        } else if (snapshot.hasError) {
                          return const Center(
                              child: Text('Error loading messages'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(child: Text('No messages'));
                        }

                        final messages = snapshot.data!;

                        // Use post frame callback to scroll to bottom after messages are loaded
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToBottom();
                        });

                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isCurrentUser =
                                message.senderId == widget.currentUserId;

                            return _buildMessageBubble(message, isCurrentUser);
                          },
                        );
                      },
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: const TextStyle(
                              fontSize: 16,
                              fontFamily: Font.family,
                              fontWeight: FontWeight.w500),
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const FaIcon(FontAwesomeIcons.paperclip,
                                      size: 20, color: Colors.grey),
                                  onPressed: _showAttachmentBottomSheet,
                                ),
                                IconButton(
                                  icon: const Icon(FontAwesomeIcons.camera,
                                      size: 20, color: Colors.grey),
                                  onPressed: _showAttachmentBottomSheet,
                                ),
                              ],
                            ),
                            suffixIconConstraints: const BoxConstraints(
                              minWidth: 100,
                              maxWidth: 100,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: MyColors.blue,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () {
                            if (_messageController.text.trim().isNotEmpty) {
                              final message = ChatMessage(
                                id: const Uuid().v4(),
                                senderId: widget.currentUserId,
                                content: _messageController.text.trim(),
                                timestamp: DateTime.now(),
                              );

                              if (state is ChatRoomLoaded) {
                                context.read<ChatBloc>().add(SendMessage(
                                    chatRoomId: state.chatRoomId,
                                    message: message));

                                _messageController.clear();
                              }
                              // Scroll to bottom after sending a message
                              _scrollToBottom();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
