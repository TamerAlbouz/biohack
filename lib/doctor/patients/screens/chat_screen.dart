import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/backend/injectable.dart';
import 'package:medtalk/backend/patient/models/patient.dart';
import 'package:medtalk/common/widgets/custom_input_field.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/font.dart';
import 'package:medtalk/styles/sizes.dart';

import '../bloc/chat_bloc.dart';
import '../models/patients_models.dart';

class ChatScreen extends StatefulWidget {
  final Patient patient;

  const ChatScreen({
    super.key,
    required this.patient,
  });

  static Route<void> route(Patient patient) {
    return MaterialPageRoute<void>(
      builder: (_) => ChatScreen(patient: patient),
    );
  }

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<FileAttachment> _attachments = [];
  bool _isAttaching = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ChatBloc>(
          // Initialize with repositories as needed
          )
        ..add(LoadChatHistory(patientId: widget.patient.uid)),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: kToolbarHeight,
          iconTheme: const IconThemeData(color: Colors.white),
          // Explicitly set back button color
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Text(
                  _getInitials(widget.patient.name ?? 'Unknown'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: MyColors.primary,
                  ),
                ),
              ),
              kGap10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.patient.name ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: Font.small,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.patient.email,
                      style: const TextStyle(
                        fontSize: Font.extraSmall,
                        color: Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: MyColors.primary,
          foregroundColor: Colors.white,
        ),
        body: BlocConsumer<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state is ChatMessageSent || state is ChatHistoryLoaded) {
              // Scroll to bottom when new messages arrive or history loads
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
            }

            if (state is ChatError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }

            if (state is ChatFileSent) {
              // Update documents tab via BLoC or other state management

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('File shared successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ChatLoading && state is! ChatHistoryLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            // Get messages either from loaded state or empty list
            final List<Message> messages =
                state is ChatHistoryLoaded ? state.messages : [];

            return Column(
              children: [
                // Chat messages area
                Expanded(
                  child: messages.isEmpty
                      ? _buildEmptyChatView()
                      : _buildChatMessages(messages),
                ),

                // Attachments preview
                if (_attachments.isNotEmpty) _buildAttachmentsPreview(),

                // Input area
                _buildInputArea(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyChatView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FaIcon(
            FontAwesomeIcons.solidComments,
            size: 60,
            color: Colors.grey,
          ),
          kGap20,
          Text(
            'No messages with ${widget.patient.name}',
            style: const TextStyle(
              fontSize: Font.medium,
              color: Colors.grey,
            ),
          ),
          kGap8,
          const Text(
            'Start the conversation by sending a message',
            style: TextStyle(
              fontSize: Font.small,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages(List<Message> messages) {
    // Group messages by date
    final groupedMessages = <String, List<Message>>{};

    for (final message in messages) {
      final date = DateFormat('yyyy-MM-dd').format(message.timestamp);

      if (groupedMessages.containsKey(date)) {
        groupedMessages[date]!.add(message);
      } else {
        groupedMessages[date] = [message];
      }
    }

    // Sort dates
    final sortedDates = groupedMessages.keys.toList()..sort();

    return ListView.builder(
      controller: _scrollController,
      padding: kPadd16,
      itemCount: sortedDates.length,
      itemBuilder: (context, dateIndex) {
        final date = sortedDates[dateIndex];
        final messagesForDate = groupedMessages[date]!;

        return Column(
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatMessageDate(DateTime.parse(date)),
                    style: const TextStyle(
                      fontSize: Font.extraSmall,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Messages for this date
            ...messagesForDate.map((message) {
              return _buildMessageBubble(message);
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isFromDoctor = message.senderId != message.receiverId;
    final hasAttachment = message.hasAttachment;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment:
            isFromDoctor ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar for patient messages
          if (!isFromDoctor) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Text(
                _getInitials(widget.patient.name ?? 'P'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            kGap8,
          ],

          // Message content
          Flexible(
            child: Column(
              crossAxisAlignment: isFromDoctor
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isFromDoctor ? MyColors.primary : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight:
                          isFromDoctor ? const Radius.circular(0) : null,
                      bottomLeft:
                          !isFromDoctor ? const Radius.circular(0) : null,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message text
                      Text(
                        message.content,
                        style: TextStyle(
                          fontSize: Font.small,
                          color: isFromDoctor ? Colors.white : Colors.black,
                        ),
                      ),

                      // Attachment if any
                      if (hasAttachment) ...[
                        kGap8,
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isFromDoctor
                                ? MyColors.primary.withValues(alpha: 0.8)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isFromDoctor
                                  ? Colors.white.withValues(alpha: 0.3)
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.fileLines,
                                size: 16,
                                color: isFromDoctor
                                    ? Colors.white
                                    : MyColors.primary,
                              ),
                              kGap8,
                              Flexible(
                                child: Text(
                                  message.attachmentName ?? 'File',
                                  style: TextStyle(
                                    fontSize: Font.extraSmall,
                                    color: isFromDoctor
                                        ? Colors.white
                                        : MyColors.primary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Timestamp
                Padding(
                  padding:
                      const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
                  child: Text(
                    DateFormat('h:mm a').format(message.timestamp),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Avatar for doctor messages
          if (isFromDoctor) ...[
            kGap8,
            CircleAvatar(
              radius: 16,
              backgroundColor: MyColors.primary.withValues(alpha: 0.2),
              child: const Text(
                'Dr',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: MyColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachmentsPreview() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 4.0),
            child: Text(
              'Attachments',
              style: TextStyle(
                fontSize: Font.extraSmall,
                fontWeight: FontWeight.bold,
                color: MyColors.subtitleDark,
              ),
            ),
          ),
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _attachments.length,
              separatorBuilder: (context, index) => kGap8,
              itemBuilder: (context, index) {
                final attachment = _attachments[index];
                return _buildAttachmentPreview(attachment, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentPreview(FileAttachment attachment, int index) {
    return Stack(
      children: [
        Container(
          width: 60,
          height: 60,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                _getFileIcon(attachment.fileName),
                size: 20,
                color: MyColors.primary,
              ),
              kGap4,
              Text(
                attachment.fileName.length > 8
                    ? '${attachment.fileName.substring(0, 6)}...'
                    : attachment.fileName,
                style: const TextStyle(
                  fontSize: 10,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: InkWell(
            onTap: () {
              setState(() {
                _attachments.removeAt(index);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            // Attachment button
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.paperclip,
                size: 20,
                color: MyColors.subtitleDark,
              ),
              onPressed:
                  _isAttaching ? null : () => _showAttachmentOptions(context),
            ),

            // Text input field
            Expanded(
              child: CustomInputField(
                controller: _messageController,
                hintText: 'Type a message...',
                onChanged: (value) {},
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),

            // Send button
            IconButton(
              icon: const Icon(
                Icons.send,
                color: MyColors.primary,
                size: 24,
              ),
              onPressed: () => _sendMessage(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.image),
              title: const Text('Photo Library'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.file),
              title: const Text('Document'),
              onTap: () {
                Navigator.pop(context);
                _pickDocument();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isAttaching = true;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (image != null) {
        setState(() {
          _attachments.add(
            FileAttachment(
              filePath: image.path,
              fileName: image.name,
              fileType: 'image',
            ),
          );
        });
      }
    } catch (e) {
      // Handle error
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to attach image'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isAttaching = false;
      });
    }
  }

  Future<void> _pickDocument() async {
    setState(() {
      _isAttaching = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'csv'],
      );

      if (result != null) {
        for (var file in result.files) {
          if (file.path != null) {
            setState(() {
              _attachments.add(
                FileAttachment(
                  filePath: file.path!,
                  fileName: file.name,
                  fileType: 'document',
                ),
              );
            });
          }
        }
      }
    } catch (e) {
      // Handle error
      debugPrint('Error picking document: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to attach document'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isAttaching = false;
      });
    }
  }

  void _sendMessage(BuildContext context) {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty && _attachments.isEmpty) return;

    // Send message using BLoC
    if (messageText.isNotEmpty || _attachments.isNotEmpty) {
      context.read<ChatBloc>().add(
            SendMessage(
              content: messageText,
              patientId: widget.patient.uid,
              attachments: _attachments,
            ),
          );

      // Clear input and attachments
      _messageController.clear();
      setState(() {
        _attachments.clear();
      });
    }
  }

  void _showPatientInfoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: kPadd20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            kGap20,
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: MyColors.primary.withValues(alpha: 0.2),
                  child: Text(
                    _getInitials(widget.patient.name ?? 'Unknown'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: MyColors.primary,
                    ),
                  ),
                ),
                kGap16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.patient.name ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: Font.medium,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      kGap4,
                      Text(
                        widget.patient.email,
                        style: const TextStyle(
                          fontSize: Font.small,
                          color: MyColors.subtitleDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            kGap20,
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PatientInfoButton(
                  icon: FontAwesomeIcons.notesMedical,
                  label: 'Patient\nRecord',
                ),
                _PatientInfoButton(
                  icon: FontAwesomeIcons.calendarCheck,
                  label: 'View\nAppointments',
                ),
                _PatientInfoButton(
                  icon: FontAwesomeIcons.solidFile,
                  label: 'View\nDocuments',
                ),
              ],
            ),
            kGap20,
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return FontAwesomeIcons.filePdf;
      case 'doc':
      case 'docx':
        return FontAwesomeIcons.fileWord;
      case 'xls':
      case 'xlsx':
        return FontAwesomeIcons.fileExcel;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return FontAwesomeIcons.fileImage;
      default:
        return FontAwesomeIcons.file;
    }
  }

  String _formatMessageDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final weekAgo = DateTime(now.year, now.month, now.day - 7);

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    } else if (date.isAfter(weekAgo)) {
      return DateFormat('EEEE').format(date); // Day name
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    } else {
      return name[0];
    }
  }
}

class _PatientInfoButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PatientInfoButton({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: MyColors.primary.withValues(alpha: 0.1),
            child: FaIcon(
              icon,
              size: 20,
              color: MyColors.primary,
            ),
          ),
          kGap8,
          Text(
            label,
            style: const TextStyle(
              fontSize: Font.extraSmall,
              color: MyColors.subtitleDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
