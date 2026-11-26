import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import 'app_image.dart';

IconData instrumentIcon(String instrument) {
  switch (instrument) {
    case 'Vocals':
      return Icons.mic;
    case 'Keyboard':
      return Icons.piano;
    case 'Drums':
      return Icons.album;
    case 'Bass':
      return Icons.graphic_eq;
    default:
      return Icons.music_note;
  }
}

/// One row in "Musicians near you".
class MusicianCard extends StatelessWidget {
  final Musician musician;
  final VoidCallback? onTap;
  const MusicianCard({super.key, required this.musician, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Avatar(name: musician.avatar, label: musician.name, size: 54, online: true),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(musician.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 3),
                  Text('${musician.instrument} • ${musician.genre}',
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 12.5)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 13, color: AppColors.coral),
                      const SizedBox(width: 3),
                      Text(musician.distance,
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 11.5)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: AppColors.coralLight,
                  borderRadius: BorderRadius.circular(14)),
              child: Icon(instrumentIcon(musician.instrument),
                  color: AppColors.coral, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
