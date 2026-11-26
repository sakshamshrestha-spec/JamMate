import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_state.dart';
import '../widgets/bottom_nav_bar.dart';
import 'create_jam_screen.dart';
import 'discover_screen.dart';
import 'find_musicians_screen.dart';
import 'messages_screen.dart';
import 'my_profile_screen.dart';

/// Holds the bottom navigation bar and one Navigator per tab, so the bar
/// stays visible when you open inner screens (profile, jam details, chat...).
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  Widget _tab(int index, Widget root) {
    return Navigator(
      key: AppState.navKeys[index],
      onGenerateRoute: (settings) =>
          MaterialPageRoute(builder: (_) => root, settings: settings),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hide the bar while the keyboard is open (e.g. when typing a message).
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return ValueListenableBuilder<int>(
      valueListenable: AppState.tab,
      builder: (context, index, _) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            final nav = AppState.navKeys[index].currentState;
            if (nav != null && nav.canPop()) {
              nav.pop();
            } else if (index != 0) {
              AppState.tab.value = 0;
            } else {
              SystemNavigator.pop();
            }
          },
          child: Scaffold(
            body: IndexedStack(
              index: index,
              children: [
                _tab(0, const DiscoverScreen()),
                _tab(1, const FindMusiciansScreen()),
                _tab(2, const CreateJamScreen()),
                _tab(3, const MessagesScreen()),
                _tab(4, const MyProfileScreen()),
              ],
            ),
            bottomNavigationBar: keyboardOpen
                ? null
                : BottomNavBar(
                    currentIndex: index,
                    onTap: (i) {
                      if (i == index) {
                        // Tapping the active tab goes back to its first screen.
                        AppState.navKeys[i].currentState
                            ?.popUntil((r) => r.isFirst);
                      } else {
                        AppState.tab.value = i;
                      }
                    },
                  ),
          ),
        );
      },
    );
  }
}
