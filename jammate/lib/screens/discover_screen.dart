import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/app_chip.dart';
import '../widgets/app_image.dart';
import '../widgets/app_text_field.dart';
import '../widgets/post_card.dart';
import '../widgets/screen_header.dart';
import 'jam_details_screen.dart';
import 'musician_profile_screen.dart';

/// Screen 3 - Discover (Home)
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  static const _genres = ['All', 'Rock', 'Metal', 'Pop', 'Jazz', 'Blues'];
  String _genre = 'All';
  String _query = '';

  Widget _featuredJam(Jam jam) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => JamDetailsScreen(jam: jam))),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.soft),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppImage(name: jam.image, height: 130),
              const DecoratedBox(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xCC000000), Color(0x00000000)]))),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Text('NEXT JAM NEAR YOU',
                          style: TextStyle(
                              color: AppColors.coral,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5)),
                    ),
                    const SizedBox(height: 8),
                    Text('${jam.title} • ${jam.genre}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text('${jam.when} • ${jam.location}',
                        style: const TextStyle(
                            color: Color(0xE6FFFFFF), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase();
    final posts = AppState.posts
        .where((p) =>
            (_genre == 'All' || p.genre == _genre) &&
            (p.author.toLowerCase().contains(q) ||
                p.subtitle.toLowerCase().contains(q)))
        .toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            // Greeting row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: ValueListenableBuilder<UserProfile?>(
                valueListenable: AppState.profile,
                builder: (context, p, _) => Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hello, ${firstName(p?.name ?? '')}',
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.muted)),
                          const SizedBox(height: 2),
                          const Text('Discover',
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => AppState.tab.value = 4,
                      child: Avatar(
                          name: 'me.jpg',
                          label: p?.name ?? '?',
                          size: 46,
                          ring: true),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppTextField(
                hint: 'Find music, people and jams',
                prefixIcon: Icons.search,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  for (final g in _genres)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AppChip(
                        label: g,
                        filled: true,
                        selected: _genre == g,
                        onTap: () => setState(() => _genre = g),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ValueListenableBuilder<List<Jam>>(
              valueListenable: AppState.jams,
              builder: (context, jams, _) => jams.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: _featuredJam(jams.first),
                    ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: SectionTitle('Fresh from the community'),
            ),
            if (posts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                    child: Text('No posts found',
                        style: TextStyle(color: AppColors.muted))),
              ),
            for (final p in posts)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PostCard(
                  post: p,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => MusicianProfileScreen(
                          musician: AppState.musicianByName(p.author)))),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
