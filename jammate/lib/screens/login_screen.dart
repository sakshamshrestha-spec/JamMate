import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/seed_data.dart';
import '../db/app_database.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/primary_button.dart';
import 'main_shell.dart';
import 'register_screen.dart';

/// Screen 2 - Login (Node.js API with SQLite fallback)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      _toast('Please enter your email and password');
      return;
    }
    setState(() => _busy = true);

    // 1. Try Node.js backend authentication first
    final apiResp = await ApiService.instance.login(email: email, password: password);
    if (!mounted) return;

    if (apiResp.success && apiResp.user != null) {
      final userName = apiResp.user!['name'] as String? ?? email.split('@').first;
      final userEmail = apiResp.user!['email'] as String? ?? email;

      if (apiResp.accessToken != null) {
        await AppDatabase.instance.setSetting('access_token', apiResp.accessToken!);
      }
      if (apiResp.refreshToken != null) {
        await AppDatabase.instance.setSetting('refresh_token', apiResp.refreshToken!);
      }

      await AppDatabase.instance.upsertBackendUser(email: userEmail, name: userName);
      await AppState.startSession(userEmail);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell()), (r) => false);
      return;
    }

    // 2. If backend responded with an auth error (e.g., bad credentials or account locked)
    if (!apiResp.message.contains('Could not connect')) {
      setState(() => _busy = false);
      _toast(apiResp.message);
      return;
    }

    // 3. Server offline -> Fall back to local SQLite login
    final localUser = await AppDatabase.instance.login(email, password);
    if (!mounted) return;
    if (localUser == null) {
      setState(() => _busy = false);
      _toast('Wrong email or password (and Node.js server is offline)');
      return;
    }

    await AppState.startSession(localUser.email);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()), (r) => false);
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Your next bandmate is one hello away.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'Email',
            hint: 'you@example.com',
            controller: _email,
            fill: AppColors.background,
            prefixIcon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Password',
            hint: 'Enter your password',
            controller: _password,
            fill: AppColors.background,
            prefixIcon: Icons.lock_outline,
            obscure: _hidePassword,
            suffix: IconButton(
              icon: Icon(
                  _hidePassword ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: AppColors.muted),
              onPressed: () => setState(() => _hidePassword = !_hidePassword),
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
              label: _busy ? 'Please wait...' : 'Log In',
              onPressed: _busy ? null : _login),
          const SizedBox(height: 14),
          // Demo account helper
          GestureDetector(
            onTap: () => setState(() {
              _email.text = SeedData.demoEmail;
              _password.text = SeedData.demoPassword;
            }),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppColors.coralLight,
                  borderRadius: BorderRadius.circular(14)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.coral, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                        'Demo account: demo@jammate.com / demo123 (tap to fill)',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.coral,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: const Text.rich(
                TextSpan(
                  text: 'New here? ',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                  children: [
                    TextSpan(
                        text: 'Create an account',
                        style: TextStyle(
                            color: AppColors.coral,
                            fontWeight: FontWeight.w800)),
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
