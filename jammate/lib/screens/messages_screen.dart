import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';
import '../widgets/screen_header.dart';
import 'chat_screen.dart';

/// Screen 9 - Messages (list of chats, loaded from SQLite)
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenHeader(
                title: 'Messages',
                subtitle: 'Good conversations. Better collaborations.'),
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: AppState.chatVersion,
                builder: (context, _, __) {
                  final threads = AppState.threads;
                  if (threads.isEmpty) {
                    return const Center(
                        child: Text('No chats yet. Connect with a musician!',
                            style: TextStyle(color: AppColors.muted)));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: threads.length,
                    itemBuilder: (context, i) {
                      final t = threads[i];
                      return GestureDetector(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => ChatScreen(thread: t))),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: AppShadows.card,
                          ),
                          child: Row(
                            children: [
                              Avatar(
                                  name: t.avatar,
                                  label: t.name,
                                  size: 52,
                                  online: i < 2),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15)),
                                    const SizedBox(height: 3),
                                    Text(t.lastMessage,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: AppColors.muted,
                                            fontSize: 12.5)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(t.time,
                                  style: const TextStyle(
                                      color: AppColors.muted, fontSize: 11)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
