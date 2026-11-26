# JamMate (Flutter + SQLite)

Mobile app prototype for musicians: find nearby musicians, share covers, create jam sessions and chat.

## Database (SQLite via `sqflite`)
File: `lib/db/app_database.dart`   Seed data: `lib/data/seed_data.dart`

Tables: users, musicians, posts, covers, jams, threads, messages, settings.
- Passwords are stored as SHA-256 hashes (never plain text).
- The first start creates the database and fills it with starter data.
- Demo account: demo@jammate.com / demo123 (or create your own account).
- Likes, jams, covers, chat messages, profile edits and the login session are all saved,
  so they are still there after closing the app.

## Run in Android Studio
1. `flutter create jammate`
2. Replace the new project's `lib/` folder and `pubspec.yaml` with the ones from this folder.
3. Copy the `assets/` folder into the project root, and delete `test/widget_test.dart`.
4. `flutter pub get`, plug in your phone (USB debugging on) and press Run.

Pictures: the app draws default pictures in code. To use real photos, put JPGs in
`assets/images/` (see the README there).
