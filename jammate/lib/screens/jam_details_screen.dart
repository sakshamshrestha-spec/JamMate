import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';
import '../widgets/musician_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_header.dart';

/// Screen 8 - Jam Details
class JamDetailsScreen extends StatelessWidget {
  final Jam jam;
  const JamDetailsScreen({super.key, required this.jam});

  bool get _isMine => jam.host == 'You';

  Future<void> _askToJoin() async {
    final host = AppState.musicianByName(jam.host);
    final thread = await AppState.threadFor(host);
    await AppState.sendMessage(
      thread,
      "Hi ${host.name}! I'd like to join your jam: ${jam.title}.",
      fromMe: true,
    );
    AppState.openChat(thread);
  }

  Widget _iconBox(IconData icon) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            color: AppColors.coralLight,
            borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppColors.coral, size: 20),
      );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _iconBox(icon),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.muted)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final hostName = _isMine
        ? (AppState.profile.value?.name ?? 'You')
        : jam.host;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Hero picture with title
                SizedBox(
                  height: 270,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(32)),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            AppImage(name: jam.image, height: 270),
                            const DecoratedBox(
                                decoration:
                                    BoxDecoration(gradient: AppGradients.shade)),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 20,
                        child: SafeArea(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(top: 8),
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              child:
                                  const Icon(Icons.arrow_back_ios_new, size: 16),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 22,
                        right: 22,
                        bottom: 22,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16)),
                              child: Text(jam.genre,
                                  style: const TextStyle(
                                      color: AppColors.coral,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800)),
                            ),
                            const SizedBox(height: 8),
                            Text(jam.title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 2),
                            Text(jam.description,
                                style: const TextStyle(
                                    color: Color(0xE6FFFFFF), fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle('Who we need'),
                      const SizedBox(height: 12),
                      for (final r in jam.roles)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppShadows.card,
                          ),
                          child: Row(
                            children: [
                              _iconBox(instrumentIcon(_instrumentOf(r))),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(r,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                    color: AppColors.coralLight,
                                    borderRadius: BorderRadius.circular(12)),
                                child: const Text('Needed',
                                    style: TextStyle(
                                        color: AppColors.coral,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppShadows.card,
                        ),
                        child: Column(
                          children: [
                            _infoRow(Icons.calendar_today_rounded, 'When', jam.when),
                            const Divider(height: 1, color: AppColors.line),
                            _infoRow(Icons.location_on_rounded, 'Where', jam.location),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppShadows.card,
                        ),
                        child: Row(
                          children: [
                            Avatar(
                                name: _isMine ? 'me.jpg' : AppState.musicianByName(jam.host).avatar,
                                label: hostName,
                                size: 44),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Hosted by',
                                    style: TextStyle(
                                        fontSize: 11, color: AppColors.muted)),
                                Text(hostName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            color: AppColors.background,
            child: _isMine
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                        color: AppColors.coralLight,
                        borderRadius: BorderRadius.circular(16)),
                    child: const Center(
                      child: Text('You are hosting this jam',
                          style: TextStyle(
                              color: AppColors.coral,
                              fontWeight: FontWeight.w800)),
                    ),
                  )
                : PrimaryButton(
                    label: 'Ask to Join',
                    icon: Icons.waving_hand_rounded,
                    onPressed: _askToJoin),
          ),
        ],
      ),
    );
  }

  /// "Bass player" -> "Bass", "Guitarist" -> "Guitar" (for the icon)
  String _instrumentOf(String role) {
    final r = role.toLowerCase();
    if (r.contains('guitar')) return 'Guitar';
    if (r.contains('bass')) return 'Bass';
    if (r.contains('drum')) return 'Drums';
    if (r.contains('sing') || r.contains('vocal')) return 'Vocals';
    if (r.contains('key') || r.contains('piano')) return 'Keyboard';
    return 'Guitar';
  }
}
