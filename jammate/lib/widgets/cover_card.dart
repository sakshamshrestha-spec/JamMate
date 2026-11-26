import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import 'app_image.dart';

/// Picture card with title and play icon (used in profile grids).
class CoverCard extends StatelessWidget {
  final CoverItem item;
  const CoverCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppImage(name: item.image, height: double.infinity),
            const DecoratedBox(
                decoration: BoxDecoration(gradient: AppGradients.shade)),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                    color: Color(0x66FFFFFF), shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13)),
                  if (item.genre.isNotEmpty)
                    Text(item.genre,
                        style: const TextStyle(
                            color: Color(0xCCFFFFFF), fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 2-column grid of covers that sits inside a scroll view.
class CoverGrid extends StatelessWidget {
  final List<CoverItem> items;
  const CoverGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [for (final c in items) CoverCard(item: c)],
    );
  }
}
