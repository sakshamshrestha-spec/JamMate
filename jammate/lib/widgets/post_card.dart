import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'app_image.dart';

/// Discover feed card: big picture, genre tag, play button, heart and author.
class PostCard extends StatefulWidget {
  final PostItem post;
  final VoidCallback? onTap;
  const PostCard({super.key, required this.post, this.onTap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  void _toggleLike() {
    setState(() => widget.post.liked = !widget.post.liked);
    AppState.saveLike(widget.post); // saved in SQLite
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 240,
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: AppShadows.soft,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppImage(name: p.image, height: 240),
              const DecoratedBox(
                  decoration: BoxDecoration(gradient: AppGradients.shade)),
              // Genre tag
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(p.genre,
                      style: const TextStyle(
                          color: AppColors.coral,
                          fontSize: 11,
                          fontWeight: FontWeight.w800)),
                ),
              ),
              // Heart
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: _toggleLike,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Icon(
                      p.liked ? Icons.favorite : Icons.favorite_border,
                      color: AppColors.coral,
                      size: 20,
                    ),
                  ),
                ),
              ),
              // Play button
              Center(
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                      color: Color(0x59FFFFFF), shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 34),
                ),
              ),
              // Author
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Row(
                  children: [
                    Avatar(name: '${p.author.toLowerCase()}.jpg', label: p.author, size: 38, ring: true),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.author,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15)),
                          Text(p.subtitle,
                              style: const TextStyle(
                                  color: Color(0xE6FFFFFF), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
