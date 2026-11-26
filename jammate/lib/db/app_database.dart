import 'package:sqflite/sqflite.dart';

import '../data/seed_data.dart';
import '../models/models.dart';
import '../utils/security.dart';

/// All SQLite code lives here.
///
/// Tables: users, musicians, posts, covers, jams, threads, messages, settings
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  late Database _db;

  Future<void> init() async {
    final dir = await getDatabasesPath();
    _db = await openDatabase(
      '$dir/jammate.db',
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        name TEXT NOT NULL,
        instrument TEXT NOT NULL,
        skill TEXT NOT NULL,
        city TEXT NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE musicians (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        instrument TEXT NOT NULL,
        genre TEXT NOT NULL,
        city TEXT NOT NULL,
        distance TEXT NOT NULL,
        avatar TEXT NOT NULL,
        status TEXT NOT NULL,
        style TEXT NOT NULL,
        posts INTEGER NOT NULL,
        connections INTEGER NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        author TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        image TEXT NOT NULL,
        genre TEXT NOT NULL,
        liked INTEGER NOT NULL DEFAULT 0
      )''');
    await db.execute('''
      CREATE TABLE covers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        owner TEXT NOT NULL,
        title TEXT NOT NULL,
        image TEXT NOT NULL,
        genre TEXT NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE jams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        genre TEXT NOT NULL,
        description TEXT NOT NULL,
        roles TEXT NOT NULL,
        when_text TEXT NOT NULL,
        location TEXT NOT NULL,
        host TEXT NOT NULL,
        image TEXT NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE threads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        avatar TEXT NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        thread_name TEXT NOT NULL,
        text TEXT NOT NULL,
        from_me INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )''');

    await SeedData.insertAll(db);
  }

  // ---------------------------------------------------------------- users

  UserProfile _user(Map<String, Object?> r) => UserProfile(
        email: r['email'] as String,
        name: r['name'] as String,
        instrument: r['instrument'] as String,
        skill: r['skill'] as String,
        city: r['city'] as String,
      );

  Future<bool> emailExists(String email) async {
    final rows = await _db.query('users',
        columns: ['id'],
        where: 'email = ?',
        whereArgs: [email.trim().toLowerCase()]);
    return rows.isNotEmpty;
  }

  Future<void> registerUser({
    required String email,
    required String password,
    required String name,
    required String instrument,
    required String skill,
  }) async {
    await _db.insert('users', {
      'email': email.trim().toLowerCase(),
      'password_hash': hashPassword(password),
      'name': name.trim(),
      'instrument': instrument,
      'skill': skill,
      'city': 'Kathmandu',
    });
  }

  /// Returns the user if the email + password are correct, otherwise null.
  Future<UserProfile?> login(String email, String password) async {
    final rows = await _db.query('users',
        where: 'email = ? AND password_hash = ?',
        whereArgs: [email.trim().toLowerCase(), hashPassword(password)]);
    return rows.isEmpty ? null : _user(rows.first);
  }

  Future<UserProfile?> getUser(String email) async {
    final rows = await _db
        .query('users', where: 'email = ?', whereArgs: [email.toLowerCase()]);
    return rows.isEmpty ? null : _user(rows.first);
  }

  Future<void> updateUser(UserProfile p) async {
    await _db.update(
      'users',
      {'name': p.name, 'instrument': p.instrument, 'skill': p.skill},
      where: 'email = ?',
      whereArgs: [p.email],
    );
  }

  // ------------------------------------------------------------- settings

  Future<String?> getSetting(String key) async {
    final rows = await _db.query('settings', where: 'key = ?', whereArgs: [key]);
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) async {
    await _db.insert('settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> clearSetting(String key) async {
    await _db.delete('settings', where: 'key = ?', whereArgs: [key]);
  }

  // ------------------------------------------------------------- musicians

  Future<List<Musician>> getMusicians() async {
    final rows = await _db.query('musicians', orderBy: 'id');
    final list = <Musician>[];
    for (final r in rows) {
      final name = r['name'] as String;
      list.add(Musician(
        name: name,
        role: r['role'] as String,
        instrument: r['instrument'] as String,
        genre: r['genre'] as String,
        city: r['city'] as String,
        distance: r['distance'] as String,
        avatar: r['avatar'] as String,
        status: r['status'] as String,
        style: r['style'] as String,
        posts: r['posts'] as int,
        connections: r['connections'] as int,
        covers: await getCovers(name),
      ));
    }
    return list;
  }

  // ---------------------------------------------------------------- covers

  Future<List<CoverItem>> getCovers(String owner) async {
    final rows = await _db.query('covers',
        where: 'owner = ?', whereArgs: [owner], orderBy: 'id DESC');
    return rows
        .map((r) => CoverItem(r['title'] as String, r['image'] as String,
            genre: r['genre'] as String))
        .toList();
  }

  Future<void> insertCover(String owner, CoverItem c) async {
    await _db.insert('covers', {
      'owner': owner,
      'title': c.title,
      'image': c.image,
      'genre': c.genre,
    });
  }

  // ----------------------------------------------------------------- posts

  Future<List<PostItem>> getPosts() async {
    final rows = await _db.query('posts', orderBy: 'id');
    return rows
        .map((r) => PostItem(
              id: r['id'] as int,
              author: r['author'] as String,
              subtitle: r['subtitle'] as String,
              image: r['image'] as String,
              genre: r['genre'] as String,
              liked: (r['liked'] as int) == 1,
            ))
        .toList();
  }

  Future<void> setLiked(int postId, bool liked) async {
    await _db.update('posts', {'liked': liked ? 1 : 0},
        where: 'id = ?', whereArgs: [postId]);
  }

  // ------------------------------------------------------------------ jams

  Future<List<Jam>> getJams() async {
    final rows = await _db.query('jams', orderBy: 'id DESC');
    return rows
        .map((r) => Jam(
              title: r['title'] as String,
              genre: r['genre'] as String,
              description: r['description'] as String,
              roles: (r['roles'] as String).split(','),
              when: r['when_text'] as String,
              location: r['location'] as String,
              host: r['host'] as String,
              image: r['image'] as String,
            ))
        .toList();
  }

  Future<void> insertJam(Jam j) async {
    await _db.insert('jams', {
      'title': j.title,
      'genre': j.genre,
      'description': j.description,
      'roles': j.roles.join(','),
      'when_text': j.when,
      'location': j.location,
      'host': j.host,
      'image': j.image,
    });
  }

  // ----------------------------------------------------------------- chats

  Future<List<ChatThread>> getThreads() async {
    final rows = await _db.rawQuery('''
      SELECT t.name, t.avatar FROM threads t
      ORDER BY COALESCE((SELECT MAX(m.id) FROM messages m
                         WHERE m.thread_name = t.name), 0) DESC
    ''');
    final list = <ChatThread>[];
    for (final r in rows) {
      final name = r['name'] as String;
      final msgs = await _db.query('messages',
          where: 'thread_name = ?', whereArgs: [name], orderBy: 'id');
      list.add(ChatThread(
        name: name,
        avatar: r['avatar'] as String,
        messages: msgs
            .map((m) => ChatMessage(m['text'] as String,
                (m['from_me'] as int) == 1, m['created_at'] as int))
            .toList(),
      ));
    }
    return list;
  }

  Future<void> ensureThread(String name, String avatar) async {
    await _db.insert('threads', {'name': name, 'avatar': avatar},
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> insertMessage(
      String thread, String text, bool fromMe, int createdAt) async {
    await _db.insert('messages', {
      'thread_name': thread,
      'text': text,
      'from_me': fromMe ? 1 : 0,
      'created_at': createdAt,
    });
  }
}
