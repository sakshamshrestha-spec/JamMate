import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Bottom navigation: Home, Search, Post (+), Chats, Profile.
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.search_rounded, 'Search'),
    (Icons.add_rounded, 'Post'),
    (Icons.chat_bubble_rounded, 'Chats'),
    (Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
              color: Color(0x1A000000), blurRadius: 24, offset: Offset(0, -6)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              for (int i = 0; i < _items.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: i == 2 ? _centerButton() : _item(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _centerButton() {
    return Center(
      child: Container(
        width: 52,
        height: 44,
        decoration: BoxDecoration(
          gradient: AppGradients.brand,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x4DE84C5C), blurRadius: 14, offset: Offset(0, 6)),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _item(int i) {
    final active = i == currentIndex;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: active ? AppColors.coralLight : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(_items[i].$1,
              size: 23, color: active ? AppColors.coral : AppColors.muted),
        ),
        const SizedBox(height: 2),
        Text(_items[i].$2,
            style: TextStyle(
                fontSize: 10.5,
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                color: active ? AppColors.coral : AppColors.muted)),
      ],
    );
  }
}
