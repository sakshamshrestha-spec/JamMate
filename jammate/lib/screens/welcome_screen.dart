import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_image.dart';
import '../widgets/generated_art.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart';
import 'register_screen.dart';

/// Screen 1 - Welcome
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Widget _photo(String name, double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [
          BoxShadow(
              color: Color(0x40000000), blurRadius: 22, offset: Offset(0, 10)),
        ],
      ),
      child: AppImage(name: name, width: w, height: h, radius: 22),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ---- gradient top with tilted pictures
          Expanded(
            flex: 11,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const GeneratedArt(
                    seed: 'brand',
                    colors: AppGradients.brandColors,
                    showIcon: false),
                SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(11)),
                              child: const Icon(Icons.music_note,
                                  color: AppColors.coral, size: 21),
                            ),
                            const SizedBox(width: 10),
                            const Text('JAMMATE',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.translate(
                                offset: const Offset(-92, 14),
                                child: Transform.rotate(
                                    angle: -0.16,
                                    child: _photo('mira.jpg', 118, 158)),
                              ),
                              Transform.translate(
                                offset: const Offset(92, 22),
                                child: Transform.rotate(
                                    angle: 0.16,
                                    child: _photo('rohan.jpg', 118, 158)),
                              ),
                              _photo('aarav.jpg', 132, 178),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ---- white bottom panel
          Expanded(
            flex: 10,
            child: Container(
              width: double.infinity,
              transform: Matrix4.translationValues(0, -26, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Good music starts\nwith good company.',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.15)),
                    const SizedBox(height: 10),
                    const Text(
                        'Find musicians near you, share your covers\nand start a jam session today.',
                        style: TextStyle(
                            color: AppColors.muted, fontSize: 13.5, height: 1.4)),
                    const SizedBox(height: 22),
                    PrimaryButton(
                      label: 'Get Started',
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen())),
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Log In',
                      outlined: true,
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen())),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
