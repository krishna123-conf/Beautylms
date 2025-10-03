import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';
import '../models/participant.dart';

class ChatPanel extends StatefulWidget {
  final List<ChatMessage> messages;
  final Participant currentParticipant;
  final Function(String) onSendMessage;

  const ChatPanel({
    super.key,
    required this.messages,
    required this.currentParticipant,
    required this.onSendMessage,
  });

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ChatPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length > oldWidget.messages.length) {
      // Scroll to bottom when new message arrives
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      widget.onSendMessage(message);
      _messageController.clear();
    }
  }

  String _formatTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.chat, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Chat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.messages.length}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: widget.messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No messages yet',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: widget.messages.length,
                  itemBuilder: (context, index) {
                    final message = widget.messages[index];
                    final isOwnMessage = message.sender == widget.currentParticipant.name;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: isOwnMessage
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (!isOwnMessage)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4, left: 4),
                              child: Text(
                                message.sender,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 250),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isOwnMessage
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.message,
                                  style: TextStyle(
                                    color: isOwnMessage
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(message.timestamp),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isOwnMessage
                                        ? Colors.white70
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
