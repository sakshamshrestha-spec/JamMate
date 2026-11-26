const Database = require('better-sqlite3');
const crypto = require('crypto');
require('dotenv').config();

const db = new Database(process.env.DB_PATH || './jammate_backend.db');
db.pragma('journal_mode = WAL');

function hashPassword(password) {
  return crypto.createHash('sha256').update(password).digest('hex');
}

function coverKey(title) {
  const k = title.toLowerCase().replace(/[^a-z0-9]+/g, '_');
  return `${k}.jpg`;
}

function initDatabase() {
  db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL,
      name TEXT NOT NULL,
      instrument TEXT NOT NULL,
      skill TEXT NOT NULL,
      city TEXT NOT NULL DEFAULT 'Kathmandu'
    );

    CREATE TABLE IF NOT EXISTS musicians (
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
    );

    CREATE TABLE IF NOT EXISTS posts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      author TEXT NOT NULL,
      subtitle TEXT NOT NULL,
      image TEXT NOT NULL,
      genre TEXT NOT NULL,
      liked INTEGER NOT NULL DEFAULT 0
    );

    CREATE TABLE IF NOT EXISTS covers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      owner TEXT NOT NULL,
      title TEXT NOT NULL,
      image TEXT NOT NULL,
      genre TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS jams (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      genre TEXT NOT NULL,
      description TEXT NOT NULL,
      roles TEXT NOT NULL,
      when_text TEXT NOT NULL,
      location TEXT NOT NULL,
      host TEXT NOT NULL,
      image TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS threads (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT UNIQUE NOT NULL,
      avatar TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS messages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      thread_name TEXT NOT NULL,
      text TEXT NOT NULL,
      from_me INTEGER NOT NULL,
      created_at INTEGER NOT NULL
    );

    CREATE TABLE IF NOT EXISTS settings (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    );
  `);

  const userCount = db.prepare('SELECT COUNT(*) AS count FROM users').get().count;
  if (userCount === 0) {
    seedData();
  }
}

function seedData() {
  const now = Date.now();
  const demoEmail = 'demo@jammate.com';
  const demoPassword = 'demo123';

  const musiciansList = [
    { name: 'Milan', role: 'Guitarist', instrument: 'Guitar', genre: 'Rock', distance: '1.2 km away', avatar: 'milan.jpg', style: 'Rock & blues' },
    { name: 'Rohan', role: 'Drummer', instrument: 'Drums', genre: 'Metal', distance: '2.4 km away', avatar: 'rohan.jpg', style: 'Heavy metal' },
    { name: 'Aarav', role: 'Bass player', instrument: 'Bass', genre: 'Rock', distance: '3.1 km away', avatar: 'aarav.jpg', style: 'Rock & blues' },
    { name: 'Mira', role: 'Guitarist', instrument: 'Guitar', genre: 'Pop', distance: '3.6 km away', avatar: 'mira.jpg', style: 'Acoustic pop' },
    { name: 'Sam', role: 'Keyboardist', instrument: 'Keyboard', genre: 'Jazz', distance: '4.2 km away', avatar: 'sam.jpg', style: 'Jazz & soul' },
    { name: 'Anisha', role: 'Vocalist', instrument: 'Vocals', genre: 'Pop', distance: '4.8 km away', avatar: 'anisha.jpg', style: 'Pop & RnB' },
    { name: 'Nima', role: 'Guitarist', instrument: 'Guitar', genre: 'Blues', distance: '4.9 km away', avatar: 'nima.jpg', style: 'Blues' },
  ];

  const coverTitles = {
    Guitar: ['Hotel California', 'Blackbird', 'Sunday Morning', 'Come Together'],
    Bass: ['Another One', 'Sunday groove', 'Late-night jam', 'Come Together'],
    Drums: ['Paranoid', 'Back in Black', 'Sunday session', 'Double kick drill'],
    Vocals: ['Yellow', 'Creep', 'Golden hour', 'Skyfall'],
    Keyboard: ['Clair de Lune', 'Take Five', 'Fix You', 'Rainy keys'],
  };

  const insertUser = db.prepare(`
    INSERT INTO users (email, password_hash, name, instrument, skill, city)
    VALUES (?, ?, ?, ?, ?, ?)
  `);
  const insertCover = db.prepare(`
    INSERT INTO covers (owner, title, image, genre)
    VALUES (?, ?, ?, ?)
  `);
  const insertMusician = db.prepare(`
    INSERT INTO musicians (name, role, instrument, genre, city, distance, avatar, status, style, posts, connections)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `);
  const insertPost = db.prepare(`
    INSERT INTO posts (author, subtitle, image, genre, liked)
    VALUES (?, ?, ?, ?, ?)
  `);
  const insertJam = db.prepare(`
    INSERT INTO jams (title, genre, description, roles, when_text, location, host, image)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `);
  const insertThread = db.prepare(`
    INSERT OR IGNORE INTO threads (name, avatar) VALUES (?, ?)
  `);
  const insertMessage = db.prepare(`
    INSERT INTO messages (thread_name, text, from_me, created_at) VALUES (?, ?, ?, ?)
  `);

  const tx = db.transaction(() => {
    insertUser.run(demoEmail, hashPassword(demoPassword), 'Demo User', 'Guitar', 'Intermediate', 'Kathmandu');
    for (const title of ['Sunday session', 'Yellow', 'Creep', 'Paranoid']) {
      insertCover.run(demoEmail, title, coverKey(title), 'Rock');
    }

    musiciansList.forEach((m, i) => {
      insertMusician.run(
        m.name,
        m.role,
        m.instrument,
        m.genre,
        'Kathmandu',
        m.distance,
        m.avatar,
        i % 2 === 0 ? 'Open to a good jam' : 'Looking for a band',
        m.style,
        8 + i * 4,
        90 + i * 17
      );
      for (const t of coverTitles[m.instrument] || []) {
        insertCover.run(m.name, t, coverKey(t), m.genre);
      }
    });

    const initialPosts = [
      ['Aarav', 'Bass cover • Rock', 'aarav.jpg', 'Rock', 0],
      ['Mira', 'Acoustic cover • Pop', 'mira.jpg', 'Pop', 0],
      ['Rohan', 'Drum solo • Metal', 'rohan.jpg', 'Metal', 0],
      ['Sam', 'Piano jam • Jazz', 'sam.jpg', 'Jazz', 0],
      ['Milan', 'Guitar solo • Rock', 'milan.jpg', 'Rock', 0],
      ['Anisha', 'Vocal cover • Pop', 'anisha.jpg', 'Pop', 0],
      ['Nima', 'Blues riff • Blues', 'nima.jpg', 'Blues', 0],
    ];
    for (const p of initialPosts) {
      insertPost.run(...p);
    }

    insertJam.run(
      'Take Five', 'Jazz', 'Relaxed jazz night. All levels welcome.',
      'Drummer,Bass player', 'Friday • 7:30 PM', 'Thamel', 'Sam', coverKey('Take Five')
    );
    insertJam.run(
      'Come Together', 'Rock', 'Classic rock covers and good vibes.',
      'Bass player,Drummer', 'Sunday • 6:00 PM', 'Patan', 'Milan', coverKey('Come Together')
    );
    insertJam.run(
      'Paranoid', 'Rock', 'A little Sabbath. A lot of good energy.',
      'Guitarist,Drummer', 'Saturday • 4:00 PM', 'Kathmandu', 'Aarav', coverKey('Paranoid')
    );

    function addSeedChat(name, avatar, text, minutesAgo) {
      insertThread.run(name, avatar);
      insertMessage.run(name, text, 0, now - minutesAgo * 60000);
    }

    addSeedChat('Sam', 'sam.jpg', "Let's work on something new.", 26 * 60);
    addSeedChat('Mira', 'mira.jpg', 'Loved your acoustic cover!', 120);
    addSeedChat('Rohan', 'rohan.jpg', 'I can bring my drum kit!', 60);
    addSeedChat('Milan', 'milan.jpg', 'Hey! Up for a jam this Saturday?', 5);
    addSeedChat('Milan', 'milan.jpg', "I've been learning Paranoid.", 3);
  });

  tx();
}

initDatabase();

module.exports = { db, hashPassword, coverKey };
