import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';
import '../widgets/cover_card.dart';
import '../widgets/generated_art.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_header.dart';

/// Screen 5 - Musician Profile
class MusicianProfileScreen extends StatelessWidget {
  final Musician musician;
  const MusicianProfileScreen({super.key, required this.musician});

  Widget _stat(String value, String label) => Expanded(
        child: Column(
          children: [
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 3),
            Text(label,
                style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
          ],
        ),
      );

  Widget _divider() =>
      Container(width: 1, height: 28, color: AppColors.line);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          // Banner + avatar
          SizedBox(
            height: 200,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 150,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(32)),
                    child: GeneratedArt(
                        seed: '${musician.name}banner', showIcon: false),
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
                        child: const Icon(Icons.arrow_back_ios_new, size: 16),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Avatar(
                        name: musician.avatar,
                        label: musician.name,
                        size: 100,
                        ring: true),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Text(musician.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text('${musician.role} • ${musician.city}',
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 13)),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                      color: AppColors.coralLight,
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                            color: AppColors.online, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 7),
                      Text(musician.status,
                          style: const TextStyle(
                              color: AppColors.coral,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Connect',
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: () async {
                    final t = await AppState.threadFor(musician);
                    AppState.openChat(t);
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppShadows.card,
                  ),
                  child: Row(
                    children: [
                      _stat('${musician.posts}', 'posts'),
                      _divider(),
                      _stat('${musician.connections}', 'connections'),
                      _divider(),
                      _stat(musician.genre, 'genre'),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const Align(
                    alignment: Alignment.centerLeft,
                    child: SectionTitle('Music posts')),
                const SizedBox(height: 14),
                CoverGrid(items: musician.covers),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
