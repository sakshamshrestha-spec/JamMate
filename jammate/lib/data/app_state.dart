import 'package:flutter/material.dart';

import '../db/app_database.dart';
import '../models/models.dart';
import '../screens/chat_screen.dart';
import '../services/api_service.dart';

/// Keeps the data from SQLite in memory so screens can read it quickly.
/// Every change is written to SQLite first (see the methods below).
class AppState {
  static final AppDatabase _db = AppDatabase.instance;

  /// Selected bottom tab (0 Home, 1 Search, 2 Post, 3 Chats, 4 Profile).
  static final ValueNotifier<int> tab = ValueNotifier<int>(0);

  /// One Navigator per tab so the bottom bar stays visible on inner screens.
  static final List<GlobalKey<NavigatorState>> navKeys =
      List.generate(5, (_) => GlobalKey<NavigatorState>());

  /// Increases whenever chats change so lists can rebuild.
  static final ValueNotifier<int> chatVersion = ValueNotifier<int>(0);

  static List<Musician> musicians = [];
  static List<PostItem> posts = [];
  static List<ChatThread> threads = [];
  static final ValueNotifier<List<Jam>> jams = ValueNotifier<List<Jam>>([]);
  static final ValueNotifier<List<CoverItem>> myCovers =
      ValueNotifier<List<CoverItem>>([]);
  static final ValueNotifier<UserProfile?> profile =
      ValueNotifier<UserProfile?>(null);

  // ------------------------------------------------------- load / session

  /// Loads everything for the logged-in user from SQLite.
  static Future<bool> loadAll(String email) async {
    final user = await _db.getUser(email);
    if (user == null) return false;
    profile.value = user;
    musicians = await _db.getMusicians();
    posts = await _db.getPosts();
    threads = await _db.getThreads();
    jams.value = await _db.getJams();
    myCovers.value = await _db.getCovers(user.email);
    tab.value = 0;
    chatVersion.value++;
    return true;
  }

  static Future<void> startSession(String email) async {
    await _db.setSetting('session', email);
    await loadAll(email);
  }

  static Future<void> logout() async {
    final refreshToken = await _db.getSetting('refresh_token');
    await ApiService.instance.logout(refreshToken);
    await _db.clearSetting('session');
    await _db.clearSetting('access_token');
    await _db.clearSetting('refresh_token');
    profile.value = null;
    myCovers.value = [];
    tab.value = 0;
  }

  // ----------------------------------------------------------- musicians

  static Musician musicianByName(String name) => musicians.firstWhere(
        (m) => m.name == name,
        orElse: () => musicians.first,
      );

  // --------------------------------------------------------------- posts

  static Future<void> saveLike(PostItem p) => _db.setLiked(p.id, p.liked);

  // ---------------------------------------------------------------- jams

  static Future<void> addJam(Jam jam) async {
    await _db.insertJam(jam);
    jams.value = [jam, ...jams.value];
  }

  // -------------------------------------------------------------- covers

  static Future<void> addCover(CoverItem cover) async {
    final user = profile.value;
    if (user == null) return;
    await _db.insertCover(user.email, cover);
    myCovers.value = [cover, ...myCovers.value];
  }

  // ------------------------------------------------------------- profile

  static Future<void> saveProfile(UserProfile p) async {
    await _db.updateUser(p);
    profile.value = p;
  }

  // --------------------------------------------------------------- chats

  static Future<ChatThread> threadFor(Musician m) async {
    for (final t in threads) {
      if (t.name == m.name) return t;
    }
    await _db.ensureThread(m.name, m.avatar);
    final t = ChatThread(name: m.name, avatar: m.avatar, messages: []);
    threads.insert(0, t);
    chatVersion.value++;
    return t;
  }

  static Future<void> sendMessage(ChatThread t, String text,
      {required bool fromMe}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    t.messages.add(ChatMessage(text, fromMe, now));
    threads.remove(t);
    threads.insert(0, t);
    chatVersion.value++;
    await _db.insertMessage(t.name, text, fromMe, now);
  }

  /// Switches to the Chats tab and opens a conversation.
  static void openChat(ChatThread thread) {
    tab.value = 3;
    final nav = navKeys[3].currentState;
    nav?.popUntil((route) => route.isFirst);
    nav?.push(MaterialPageRoute(builder: (_) => ChatScreen(thread: thread)));
  }
}
