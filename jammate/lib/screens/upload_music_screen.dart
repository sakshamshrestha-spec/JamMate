import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/app_text_field.dart';
import '../widgets/picker_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_header.dart';

/// Screen 6 - Upload Music. The new cover is saved in SQLite.
/// (File picking is simulated: tapping the box "selects" a demo file.
///  To pick real files later, add the `file_picker` package.)
class UploadMusicScreen extends StatefulWidget {
  const UploadMusicScreen({super.key});

  @override
  State<UploadMusicScreen> createState() => _UploadMusicScreenState();
}

class _UploadMusicScreenState extends State<UploadMusicScreen> {
  final _song = TextEditingController();
  String? _file;
  String? _instrument;
  String? _genre;

  @override
  void dispose() {
    _song.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    if (_file == null || _song.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add a file and a song name')));
      return;
    }
    final title = _song.text.trim();
    await AppState.addCover(
        CoverItem(title, coverKey(title), genre: _genre ?? 'Rock'));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Music posted!')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final picked = _file != null;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            const ScreenHeader(
                title: 'Upload Music',
                subtitle: 'Your sound deserves to be heard.'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _file = 'my_cover.mp3'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      decoration: BoxDecoration(
                        color: picked ? AppColors.coralLight : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                            color: AppColors.coral, width: picked ? 1.6 : 1),
                        boxShadow: AppShadows.card,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: const BoxDecoration(
                                gradient: AppGradients.brand,
                                shape: BoxShape.circle),
                            child: Icon(
                                picked
                                    ? Icons.check_rounded
                                    : Icons.file_upload_outlined,
                                color: Colors.white,
                                size: 28),
                          ),
                          const SizedBox(height: 12),
                          Text(_file ?? 'Add video or audio',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 15)),
                          const SizedBox(height: 4),
                          const Text('MP4, MOV or MP3 · up to 100 MB',
                              style: TextStyle(
                                  color: AppColors.muted, fontSize: 11.5)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                      label: 'Song name',
                      hint: 'Give your cover a name',
                      controller: _song,
                      prefixIcon: Icons.music_note_outlined),
                  const SizedBox(height: 16),
                  PickerField(
                    label: 'Instrument',
                    hint: 'Choose an instrument',
                    value: _instrument,
                    options: const ['Guitar', 'Bass', 'Drums', 'Vocals', 'Keyboard'],
                    onChanged: (v) => setState(() => _instrument = v),
                  ),
                  const SizedBox(height: 16),
                  PickerField(
                    label: 'Genre',
                    hint: 'Choose a genre',
                    value: _genre,
                    options: const ['Rock', 'Metal', 'Pop', 'Jazz', 'Blues', 'Folk'],
                    onChanged: (v) => setState(() => _genre = v),
                  ),
                  const SizedBox(height: 26),
                  PrimaryButton(
                      label: 'Post Music',
                      icon: Icons.cloud_upload_outlined,
                      onPressed: _post),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
