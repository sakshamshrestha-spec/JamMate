import '../utils/format.dart';

class CoverItem {
  final String title;
  final String image;
  final String genre;
  const CoverItem(this.title, this.image, {this.genre = ''});
}

class PostItem {
  final int id;
  final String author;
  final String subtitle;
  final String image;
  final String genre;
  bool liked;
  PostItem({
    required this.id,
    required this.author,
    required this.subtitle,
    required this.image,
    required this.genre,
    this.liked = false,
  });
}

class Musician {
  final String name;
  final String role;
  final String instrument;
  final String genre;
  final String city;
  final String distance;
  final String avatar;
  final String status;
  final String style;
  final int posts;
  final int connections;
  final List<CoverItem> covers;

  Musician({
    required this.name,
    required this.role,
    required this.instrument,
    required this.genre,
    required this.city,
    required this.distance,
    required this.avatar,
    required this.status,
    required this.style,
    required this.posts,
    required this.connections,
    required this.covers,
  });
}

class Jam {
  final String title;
  final String genre;
  final String description;
  final List<String> roles;
  final String when;
  final String location;
  final String host;
  final String image;

  Jam({
    required this.title,
    required this.genre,
    required this.description,
    required this.roles,
    required this.when,
    required this.location,
    required this.host,
    String? image,
  }) : image = image ?? coverKey(title);
}

class ChatMessage {
  final String text;
  final bool fromMe;
  final int createdAt;
  const ChatMessage(this.text, this.fromMe, this.createdAt);
}

class ChatThread {
  final String name;
  final String avatar;
  final List<ChatMessage> messages;

  ChatThread({
    required this.name,
    required this.avatar,
    required this.messages,
  });

  String get lastMessage => messages.isEmpty ? 'Say hello!' : messages.last.text;
  String get time => messages.isEmpty ? '' : timeAgo(messages.last.createdAt);
}

class UserProfile {
  final String email;
  final String name;
  final String instrument;
  final String skill;
  final String city;
  const UserProfile({
    required this.email,
    required this.name,
    required this.instrument,
    required this.skill,
    this.city = 'Kathmandu',
  });
}
