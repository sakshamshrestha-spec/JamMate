import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';

/// A single conversation. Every message is saved in SQLite.
class ChatScreen extends StatefulWidget {
  final ChatThread thread;
  const ChatScreen({super.key, required this.thread});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await AppState.sendMessage(widget.thread, text, fromMe: true);
    if (!mounted) return;
    setState(() {});
    _scrollToBottom();

    // Demo auto-reply so the chat feels alive (also saved in SQLite).
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    await AppState.sendMessage(widget.thread, 'Sounds great! See you at the jam.',
        fromMe: false);
    if (!mounted) return;
    setState(() {});
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.thread;
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
                color: Colors.white, boxShadow: AppShadows.card),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 20, 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                    Avatar(name: t.avatar, label: t.name, size: 42, online: true),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 16)),
                        const Text('Active now',
                            style: TextStyle(
                                color: AppColors.online,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: t.messages.isEmpty
                ? const Center(
                    child: Text('Say hello and plan your first jam!',
                        style: TextStyle(color: AppColors.muted)))
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    itemCount: t.messages.length,
                    itemBuilder: (context, i) {
                      final m = t.messages[i];
                      return Align(
                        alignment: m.fromMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 11),
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.74),
                          decoration: BoxDecoration(
                            gradient: m.fromMe ? AppGradients.brand : null,
                            color: m.fromMe ? null : Colors.white,
                            boxShadow: m.fromMe ? null : AppShadows.card,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: Radius.circular(m.fromMe ? 20 : 5),
                              bottomRight: Radius.circular(m.fromMe ? 5 : 20),
                            ),
                          ),
                          child: Text(m.text,
                              style: TextStyle(
                                  fontSize: 14,
                                  height: 1.3,
                                  color:
                                      m.fromMe ? Colors.white : AppColors.text)),
                        ),
                      );
                    },
                  ),
          ),
          // Message box
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(
                16, 10, 16, 10 + MediaQuery.of(context).padding.bottom * 0),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Write a message...',
                        hintStyle: const TextStyle(
                            color: AppColors.muted, fontSize: 14),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 13),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(26),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                          gradient: AppGradients.brand, shape: BoxShape.circle),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 21),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
