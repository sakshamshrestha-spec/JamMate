/// Turns a DateTime into text like "Saturday • 4:00 PM".
String formatWhen(DateTime d) {
  const days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  final period = d.hour >= 12 ? 'PM' : 'AM';
  return '${days[d.weekday - 1]} • $hour:$minute $period';
}

/// "now", "5m", "2h", "3d" from a time in milliseconds.
String timeAgo(int millis) {
  final diff = DateTime.now().millisecondsSinceEpoch - millis;
  final minutes = diff ~/ 60000;
  if (minutes < 1) return 'now';
  if (minutes < 60) return '${minutes}m';
  final hours = minutes ~/ 60;
  if (hours < 24) return '${hours}h';
  return '${hours ~/ 24}d';
}

String firstName(String full) {
  final t = full.trim();
  return t.isEmpty ? '' : t.split(' ').first;
}

/// "Sunday session" -> "sunday_session.jpg" (name used for picture lookup).
String coverKey(String title) {
  final k = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  return '$k.jpg';
}
