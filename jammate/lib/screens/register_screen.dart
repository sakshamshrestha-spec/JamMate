import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../db/app_database.dart';
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/picker_field.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart';
import 'main_shell.dart';

/// Create account - saves the new user in SQLite.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _instrument;
  String? _skill;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _register() async {
    final email = _email.text.trim();
    if (_name.text.trim().isEmpty ||
        email.isEmpty ||
        _instrument == null ||
        _skill == null) {
      _toast('Please fill in all fields');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _toast('Please enter a valid email');
      return;
    }
    if (_password.text.length < 6) {
      _toast('Password must be at least 6 characters');
      return;
    }
    setState(() => _busy = true);
    if (await AppDatabase.instance.emailExists(email)) {
      if (!mounted) return;
      setState(() => _busy = false);
      _toast('This email is already registered');
      return;
    }
    await AppDatabase.instance.registerUser(
      email: email,
      password: _password.text,
      name: _name.text,
      instrument: _instrument!,
      skill: _skill!,
    );
    await AppState.startSession(email.toLowerCase());
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()), (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create account',
      subtitle: 'Join JamMate and find people to jam with.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
              label: 'Full name',
              hint: 'Your name',
              controller: _name,
              fill: AppColors.background,
              prefixIcon: Icons.person_outline),
          const SizedBox(height: 14),
          AppTextField(
              label: 'Email',
              hint: 'you@example.com',
              controller: _email,
              fill: AppColors.background,
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 14),
          AppTextField(
              label: 'Password',
              hint: 'At least 6 characters',
              controller: _password,
              fill: AppColors.background,
              prefixIcon: Icons.lock_outline,
              obscure: true),
          const SizedBox(height: 14),
          PickerField(
            label: 'Main instrument',
            hint: 'Choose an instrument',
            value: _instrument,
            fill: AppColors.background,
            options: const ['Guitar', 'Bass', 'Drums', 'Vocals', 'Keyboard'],
            onChanged: (v) => setState(() => _instrument = v),
          ),
          const SizedBox(height: 14),
          PickerField(
            label: 'Skill level',
            hint: 'Choose your level',
            value: _skill,
            fill: AppColors.background,
            options: const ['Beginner', 'Intermediate', 'Advanced', 'Professional'],
            onChanged: (v) => setState(() => _skill = v),
          ),
          const SizedBox(height: 22),
          PrimaryButton(
              label: _busy ? 'Please wait...' : 'Create Account',
              onPressed: _busy ? null : _register),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen())),
              child: const Text.rich(
                TextSpan(
                  text: 'Already have an account? ',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                  children: [
                    TextSpan(
                        text: 'Log in',
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
