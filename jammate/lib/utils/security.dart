import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Passwords are never stored in plain text - only their SHA-256 hash.
String hashPassword(String password) =>
    sha256.convert(utf8.encode(password)).toString();
