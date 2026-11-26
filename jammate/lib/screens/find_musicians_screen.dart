import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../models/models.dart';
import '../widgets/app_chip.dart';
import '../widgets/app_text_field.dart';
import '../widgets/jam_tile.dart';
import '../widgets/musician_card.dart';
import '../widgets/screen_header.dart';
import '../theme/app_theme.dart';
import 'jam_details_screen.dart';
import 'musician_profile_screen.dart';

/// Screen 4 - Find Musicians (search + instrument filter)
class FindMusiciansScreen extends StatefulWidget {
  const FindMusiciansScreen({super.key});

  @override
  State<FindMusiciansScreen> createState() => _FindMusiciansScreenState();
}

class _FindMusiciansScreenState extends State<FindMusiciansScreen> {
  static const _instruments = [
    'Any',
    'Guitar',
    'Bass',
    'Drums',
    'Vocals',
    'Keyboard'
  ];
  String _instrument = 'Any';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase();
    final results = AppState.musicians.where((m) {
      final okInstrument = _instrument == 'Any' || m.instrument == _instrument;
      final okQuery = m.name.toLowerCase().contains(q) ||
          m.instrument.toLowerCase().contains(q) ||
          m.genre.toLowerCase().contains(q);
      return okInstrument && okQuery;
    }).toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const ScreenHeader(
                title: 'Find Musicians',
                subtitle: 'Search by name, instrument or genre'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppTextField(
                hint: 'Name, instrument or genre',
                prefixIcon: Icons.search,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  for (final i in _instruments)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AppChip(
                        label: i,
                        filled: true,
                        icon: i == 'Any' ? null : instrumentIcon(i),
                        selected: _instrument == i,
                        onTap: () => setState(() => _instrument = i),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Musicians near you',
                      trailing: 'Within 5 km'),
                  const SizedBox(height: 14),
                  if (results.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Center(
                          child: Text('No musicians found',
                              style: TextStyle(color: AppColors.muted))),
                    ),
                  for (final m in results)
                    MusicianCard(
                      musician: m,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => MusicianProfileScreen(musician: m)),
                      ),
                    ),
                  const SizedBox(height: 14),
                  const SectionTitle('Jams near you'),
                  const SizedBox(height: 14),
                  ValueListenableBuilder<List<Jam>>(
                    valueListenable: AppState.jams,
                    builder: (context, jams, _) => Column(
                      children: [
                        for (final jam in jams)
                          JamTile(
                            jam: jam,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => JamDetailsScreen(jam: jam)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
