import 'package:sqflite/sqflite.dart';

import '../utils/format.dart';
import '../utils/security.dart';

/// Starter data that is written into the SQLite database the first time
/// the app is opened.
class SeedData {
  static const demoEmail = 'demo@jammate.com';
  static const demoPassword = 'demo123';

  static const List<Map<String, String>> _musicians = [
    {'name': 'Milan', 'role': 'Guitarist', 'instrument': 'Guitar', 'genre': 'Rock', 'distance': '1.2 km away', 'avatar': 'milan.jpg', 'style': 'Rock & blues'},
    {'name': 'Rohan', 'role': 'Drummer', 'instrument': 'Drums', 'genre': 'Metal', 'distance': '2.4 km away', 'avatar': 'rohan.jpg', 'style': 'Heavy metal'},
    {'name': 'Aarav', 'role': 'Bass player', 'instrument': 'Bass', 'genre': 'Rock', 'distance': '3.1 km away', 'avatar': 'aarav.jpg', 'style': 'Rock & blues'},
    {'name': 'Mira', 'role': 'Guitarist', 'instrument': 'Guitar', 'genre': 'Pop', 'distance': '3.6 km away', 'avatar': 'mira.jpg', 'style': 'Acoustic pop'},
    {'name': 'Sam', 'role': 'Keyboardist', 'instrument': 'Keyboard', 'genre': 'Jazz', 'distance': '4.2 km away', 'avatar': 'sam.jpg', 'style': 'Jazz & soul'},
    {'name': 'Anisha', 'role': 'Vocalist', 'instrument': 'Vocals', 'genre': 'Pop', 'distance': '4.8 km away', 'avatar': 'anisha.jpg', 'style': 'Pop & RnB'},
    {'name': 'Nima', 'role': 'Guitarist', 'instrument': 'Guitar', 'genre': 'Blues', 'distance': '4.9 km away', 'avatar': 'nima.jpg', 'style': 'Blues'},
  ];

  static const Map<String, List<String>> _coverTitles = {
    'Guitar': ['Hotel California', 'Blackbird', 'Sunday Morning', 'Come Together'],
    'Bass': ['Another One', 'Sunday groove', 'Late-night jam', 'Come Together'],
    'Drums': ['Paranoid', 'Back in Black', 'Sunday session', 'Double kick drill'],
    'Vocals': ['Yellow', 'Creep', 'Golden hour', 'Skyfall'],
    'Keyboard': ['Clair de Lune', 'Take Five', 'Fix You', 'Rainy keys'],
  };

  static Future<void> insertAll(Database db) async {
    final b = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;

    // Demo account (login: demo@jammate.com / demo123)
    b.insert('users', {
      'email': demoEmail,
      'password_hash': hashPassword(demoPassword),
      'name': 'Demo User',
      'instrument': 'Guitar',
      'skill': 'Intermediate',
      'city': 'Kathmandu',
    });
    for (final t in ['Sunday session', 'Yellow', 'Creep', 'Paranoid']) {
      b.insert('covers', {
        'owner': demoEmail,
        'title': t,
        'image': coverKey(t),
        'genre': 'Rock',
      });
    }

    // Musicians + their covers
    for (int i = 0; i < _musicians.length; i++) {
      final m = _musicians[i];
      b.insert('musicians', <String, Object?>{
        ...m,
        'city': 'Kathmandu',
        'status': i % 2 == 0 ? 'Open to a good jam' : 'Looking for a band',
        'posts': 8 + i * 4,
        'connections': 90 + i * 17,
      });
      for (final t in _coverTitles[m['instrument']]!) {
        b.insert('covers', {
          'owner': m['name'],
          'title': t,
          'image': coverKey(t),
          'genre': m['genre'],
        });
      }
    }

    // Discover feed posts
    const posts = [
      ['Aarav', 'Bass cover • Rock', 'aarav.jpg', 'Rock'],
      ['Mira', 'Acoustic cover • Pop', 'mira.jpg', 'Pop'],
      ['Rohan', 'Drum solo • Metal', 'rohan.jpg', 'Metal'],
      ['Sam', 'Piano jam • Jazz', 'sam.jpg', 'Jazz'],
      ['Milan', 'Guitar solo • Rock', 'milan.jpg', 'Rock'],
      ['Anisha', 'Vocal cover • Pop', 'anisha.jpg', 'Pop'],
      ['Nima', 'Blues riff • Blues', 'nima.jpg', 'Blues'],
    ];
    for (final p in posts) {
      b.insert('posts', {
        'author': p[0],
        'subtitle': p[1],
        'image': p[2],
        'genre': p[3],
        'liked': 0,
      });
    }

    // Jams (inserted oldest first because the app shows newest first)
    b.insert('jams', {
      'title': 'Take Five', 'genre': 'Jazz',
      'description': 'Relaxed jazz night. All levels welcome.',
      'roles': 'Drummer,Bass player', 'when_text': 'Friday • 7:30 PM',
      'location': 'Thamel', 'host': 'Sam', 'image': coverKey('Take Five'),
    });
    b.insert('jams', {
      'title': 'Come Together', 'genre': 'Rock',
      'description': 'Classic rock covers and good vibes.',
      'roles': 'Bass player,Drummer', 'when_text': 'Sunday • 6:00 PM',
      'location': 'Patan', 'host': 'Milan', 'image': coverKey('Come Together'),
    });
    b.insert('jams', {
      'title': 'Paranoid', 'genre': 'Rock',
      'description': 'A little Sabbath. A lot of good energy.',
      'roles': 'Guitarist,Drummer', 'when_text': 'Saturday • 4:00 PM',
      'location': 'Kathmandu', 'host': 'Aarav', 'image': coverKey('Paranoid'),
    });

    // Chats
    void chat(String name, String avatar, String text, int minutesAgo) {
      b.insert('threads', {'name': name, 'avatar': avatar},
          conflictAlgorithm: ConflictAlgorithm.ignore);
      b.insert('messages', {
        'thread_name': name,
        'text': text,
        'from_me': 0,
        'created_at': now - minutesAgo * 60000,
      });
    }

    chat('Sam', 'sam.jpg', "Let's work on something new.", 26 * 60);
    chat('Mira', 'mira.jpg', 'Loved your acoustic cover!', 120);
    chat('Rohan', 'rohan.jpg', 'I can bring my drum kit!', 60);
    chat('Milan', 'milan.jpg', 'Hey! Up for a jam this Saturday?', 5);
    chat('Milan', 'milan.jpg', "I've been learning Paranoid.", 3);

    await b.commit(noResult: true);
  }
}
