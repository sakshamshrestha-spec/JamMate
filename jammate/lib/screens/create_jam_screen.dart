import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/app_chip.dart';
import '../widgets/app_text_field.dart';
import '../widgets/musician_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_header.dart';
import 'jam_details_screen.dart';
import 'upload_music_screen.dart';

/// Screen 7 - Create a Jam (the "Post" tab). The jam is saved in SQLite.
class CreateJamScreen extends StatefulWidget {
  const CreateJamScreen({super.key});

  @override
  State<CreateJamScreen> createState() => _CreateJamScreenState();
}

class _CreateJamScreenState extends State<CreateJamScreen> {
  static const _roles = {
    'Guitarist': 'Guitar',
    'Bass player': 'Bass',
    'Drummer': 'Drums',
    'Singer': 'Vocals',
  };

  final _song = TextEditingController();
  final _location = TextEditingController();
  final _when = TextEditingController();
  final Set<String> _selected = {};
  DateTime? _date;

  @override
  void dispose() {
    _song.dispose();
    _location.dispose();
    _when.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final day = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (day == null || !mounted) return;
    final time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    final picked =
        DateTime(day.year, day.month, day.day, time.hour, time.minute);
    setState(() {
      _date = picked;
      _when.text = formatWhen(picked);
    });
  }

  Future<void> _create() async {
    if (_song.text.trim().isEmpty ||
        _selected.isEmpty ||
        _date == null ||
        _location.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill in all fields and choose who you need')));
      return;
    }
    final title = _song.text.trim();
    final jam = Jam(
      title: title,
      genre: 'Jam',
      description: 'A great session starts with an invite.',
      roles: _roles.keys.where(_selected.contains).toList(),
      when: _when.text,
      location: _location.text.trim(),
      host: 'You',
    );
    await AppState.addJam(jam); // saved in SQLite
    if (!mounted) return;

    _song.clear();
    _location.clear();
    _when.clear();
    setState(() {
      _selected.clear();
      _date = null;
    });
    Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => JamDetailsScreen(jam: jam)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            ScreenHeader(
              title: 'Create a Jam',
              subtitle: 'A great session starts with an invite.',
              trailing: GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const UploadMusicScreen())),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                      color: AppColors.coralLight,
                      borderRadius: BorderRadius.circular(16)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.file_upload_outlined,
                          color: AppColors.coral, size: 17),
                      SizedBox(width: 5),
                      Text('Upload',
                          style: TextStyle(
                              color: AppColors.coral,
                              fontSize: 12,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'Song name',
                    hint: 'e.g. Paranoid',
                    controller: _song,
                    prefixIcon: Icons.music_note_outlined,
                  ),
                  const SizedBox(height: 18),
                  const Text('Who do you need?',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: [
                      for (final e in _roles.entries)
                        AppChip(
                          label: e.key,
                          icon: instrumentIcon(e.value),
                          selected: _selected.contains(e.key),
                          onTap: () => setState(() {
                            if (!_selected.remove(e.key)) _selected.add(e.key);
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: 'Date and time',
                    hint: 'Choose a date and time',
                    controller: _when,
                    readOnly: true,
                    prefixIcon: Icons.calendar_today_outlined,
                    onTap: _pickDateTime,
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: 'Location',
                    hint: 'Where to meet?',
                    controller: _location,
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 26),
                  PrimaryButton(
                      label: 'Create Jam',
                      icon: Icons.queue_music,
                      onPressed: _create),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
