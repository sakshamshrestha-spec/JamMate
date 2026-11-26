import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';
import '../widgets/cover_card.dart';
import '../widgets/generated_art.dart';
import '../widgets/screen_header.dart';
import 'upload_music_screen.dart';
import 'welcome_screen.dart';

/// Screen 10 - My Profile (data comes from the users + covers tables)
class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  Future<void> _edit(BuildContext context, UserProfile p) async {
    final name = TextEditingController(text: p.name);
    final instrument = TextEditingController(text: p.instrument);
    final skill = TextEditingController(text: p.skill);

    final save = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Name')),
            TextField(
                controller: instrument,
                decoration: const InputDecoration(labelText: 'Instrument')),
            TextField(
                controller: skill,
                decoration: const InputDecoration(labelText: 'Skill level')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save')),
        ],
      ),
    );

    if (save == true) {
      await AppState.saveProfile(UserProfile(
        email: p.email,
        name: name.text.trim().isEmpty ? p.name : name.text.trim(),
        instrument:
            instrument.text.trim().isEmpty ? p.instrument : instrument.text.trim(),
        skill: skill.text.trim().isEmpty ? p.skill : skill.text.trim(),
        city: p.city,
      ));
    }
  }

  Future<void> _logout(BuildContext context) async {
    await AppState.logout();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false);
  }

  Widget _stat(String value, String label) => Expanded(
        child: Column(
          children: [
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            const SizedBox(height: 3),
            Text(label,
                style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<UserProfile?>(
        valueListenable: AppState.profile,
        builder: (context, p, _) {
          if (p == null) return const SizedBox.shrink();
          return ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              SizedBox(
                height: 205,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 155,
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(32)),
                        child: GeneratedArt(
                            seed: 'brand',
                            colors: AppGradients.brandColors,
                            showIcon: false),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 22,
                      right: 14,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('My Profile',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800)),
                              IconButton(
                                tooltip: 'Log out',
                                onPressed: () => _logout(context),
                                icon: const Icon(Icons.logout_rounded,
                                    color: Colors.white),
                              ),
                            ],
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
                            name: 'me.jpg', label: p.name, size: 100, ring: true),
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
                    Text(p.name,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text('${p.instrument} • ${p.skill}',
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 13)),
                    Text('${p.city}, Nepal',
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12)),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _edit(context, p),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: AppShadows.card,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit_outlined, size: 17),
                                  SizedBox(width: 7),
                                  Text('Edit Profile',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const UploadMusicScreen())),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                gradient: AppGradients.brand,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.file_upload_outlined,
                                      size: 17, color: Colors.white),
                                  SizedBox(width: 7),
                                  Text('Upload',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<List<CoverItem>>(
                      valueListenable: AppState.myCovers,
                      builder: (context, covers, _) {
                        final myJams = AppState.jams.value
                            .where((j) => j.host == 'You')
                            .length;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: AppShadows.card,
                              ),
                              child: Row(
                                children: [
                                  _stat('${covers.length}', 'covers'),
                                  _stat('$myJams', 'jams hosted'),
                                  _stat('${AppState.threads.length}', 'chats'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),
                            SectionTitle('Your covers',
                                trailing: '${covers.length} posts'),
                            const SizedBox(height: 14),
                            if (covers.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(26),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: AppShadows.card,
                                ),
                                child: const Column(
                                  children: [
                                    Icon(Icons.library_music_outlined,
                                        size: 38, color: AppColors.coral),
                                    SizedBox(height: 10),
                                    Text('No covers yet',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15)),
                                    SizedBox(height: 4),
                                    Text('Tap Upload to share your first cover.',
                                        style: TextStyle(
                                            color: AppColors.muted,
                                            fontSize: 12.5)),
                                  ],
                                ),
                              )
                            else
                              CoverGrid(items: covers),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('Every cover tells a little of your story.',
                        style: TextStyle(color: AppColors.muted, fontSize: 11.5)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
