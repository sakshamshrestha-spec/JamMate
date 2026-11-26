const express = require('express');
const cors = require('cors');
require('dotenv').config();
const { db, hashPassword, coverKey } = require('./db');

const app = express();
app.use(cors());
app.use(express.json());

function getCoversForOwner(owner) {
  return db
    .prepare('SELECT title, image, genre FROM covers WHERE owner = ? ORDER BY id DESC')
    .all(owner);
}

function getAllThreads() {
  const rows = db
    .prepare(`
      SELECT t.name, t.avatar
      FROM threads t
      ORDER BY COALESCE((SELECT MAX(m.id) FROM messages m WHERE m.thread_name = t.name), 0) DESC
    `)
    .all();

  const msgStmt = db.prepare(`
    SELECT text, from_me, created_at
    FROM messages
    WHERE thread_name = ?
    ORDER BY id ASC
  `);

  return rows.map((r) => ({
    name: r.name,
    avatar: r.avatar,
    messages: msgStmt.all(r.name).map((m) => ({
      text: m.text,
      fromMe: m.from_me === 1,
      createdAt: m.created_at,
    })),
  }));
}

function buildBootstrapPayload(email) {
  const user = db
    .prepare('SELECT email, name, instrument, skill, city FROM users WHERE email = ?')
    .get(email.trim().toLowerCase());

  if (!user) return null;

  const musicians = db
    .prepare('SELECT * FROM musicians ORDER BY id ASC')
    .all()
    .map((m) => ({
      ...m,
      covers: getCoversForOwner(m.name),
    }));

  const posts = db
    .prepare('SELECT id, author, subtitle, image, genre, liked FROM posts ORDER BY id ASC')
    .all()
    .map((p) => ({
      ...p,
      liked: p.liked === 1,
    }));

  const jams = db
    .prepare('SELECT * FROM jams ORDER BY id DESC')
    .all()
    .map((j) => ({
      title: j.title,
      genre: j.genre,
      description: j.description,
      roles: j.roles ? j.roles.split(',') : [],
      when: j.when_text,
      location: j.location,
      host: j.host,
      image: j.image,
    }));

  return {
    profile: user,
    musicians,
    posts,
    threads: getAllThreads(),
    jams,
    myCovers: getCoversForOwner(user.email),
  };
}

app.get('/api/health', (req, res) => {
  res.json({ ok: true, service: 'JamMate Node.js API' });
});

app.get('/api/session', (req, res) => {
  const row = db.prepare("SELECT value FROM settings WHERE key = 'session'").get();
  if (!row || !row.value) {
    return res.json({ authenticated: false, data: null });
  }
  const payload = buildBootstrapPayload(row.value);
  if (!payload) {
    return res.json({ authenticated: false, data: null });
  }
  res.json({ authenticated: true, data: payload });
});

app.post('/api/session', (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ error: 'email is required' });
  const normalized = email.trim().toLowerCase();
  db.prepare("INSERT OR REPLACE INTO settings (key, value) VALUES ('session', ?)").run(normalized);
  const data = buildBootstrapPayload(normalized);
  if (!data) return res.status(404).json({ error: 'User not found' });
  res.json({ ok: true, data });
});

app.delete('/api/session', (req, res) => {
  db.prepare("DELETE FROM settings WHERE key = 'session'").run();
  res.json({ ok: true });
});

app.post('/api/auth/register', (req, res) => {
  const { email, password, name, instrument, skill, city } = req.body;
  if (!email || !password || !name || !instrument || !skill) {
    return res.status(400).json({ error: 'All fields are required' });
  }
  const normalizedEmail = email.trim().toLowerCase();
  const exists = db.prepare('SELECT id FROM users WHERE email = ?').get(normalizedEmail);
  if (exists) {
    return res.status(409).json({ error: 'This email is already registered' });
  }

  db.prepare(`
    INSERT INTO users (email, password_hash, name, instrument, skill, city)
    VALUES (?, ?, ?, ?, ?, ?)
  `).run(
    normalizedEmail,
    hashPassword(password),
    name.trim(),
    instrument,
    skill,
    (city || 'Kathmandu').trim()
  );

  db.prepare("INSERT OR REPLACE INTO settings (key, value) VALUES ('session', ?)").run(normalizedEmail);
  const data = buildBootstrapPayload(normalizedEmail);
  res.status(201).json({ ok: true, data });
});

app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }
  const normalizedEmail = email.trim().toLowerCase();
  const user = db
    .prepare('SELECT email FROM users WHERE email = ? AND password_hash = ?')
    .get(normalizedEmail, hashPassword(password));

  if (!user) {
    return res.status(401).json({ error: 'Wrong email or password' });
  }

  db.prepare("INSERT OR REPLACE INTO settings (key, value) VALUES ('session', ?)").run(normalizedEmail);
  const data = buildBootstrapPayload(normalizedEmail);
  res.json({ ok: true, data });
});

app.put('/api/profile', (req, res) => {
  const { email, name, instrument, skill, city } = req.body;
  if (!email) return res.status(400).json({ error: 'email is required' });
  const normalizedEmail = email.trim().toLowerCase();
  const existing = db.prepare('SELECT * FROM users WHERE email = ?').get(normalizedEmail);
  if (!existing) return res.status(404).json({ error: 'User not found' });

  db.prepare(`
    UPDATE users
    SET name = ?, instrument = ?, skill = ?, city = ?
    WHERE email = ?
  `).run(
    (name || existing.name).trim(),
    instrument || existing.instrument,
    skill || existing.skill,
    (city || existing.city).trim(),
    normalizedEmail
  );

  const updated = db
    .prepare('SELECT email, name, instrument, skill, city FROM users WHERE email = ?')
    .get(normalizedEmail);
  res.json({ profile: updated });
});

app.get('/api/musicians', (req, res) => {
  const { instrument, q } = req.query;
  let rows = db.prepare('SELECT * FROM musicians ORDER BY id ASC').all();

  if (instrument && instrument !== 'Any') {
    rows = rows.filter((m) => m.instrument.toLowerCase() === String(instrument).toLowerCase());
  }
  if (q && String(q).trim() !== '') {
    const term = String(q).trim().toLowerCase();
    rows = rows.filter(
      (m) =>
        m.name.toLowerCase().includes(term) ||
        m.instrument.toLowerCase().includes(term) ||
        m.genre.toLowerCase().includes(term)
    );
  }

  const result = rows.map((m) => ({
    ...m,
    covers: getCoversForOwner(m.name),
  }));
  res.json(result);
});

app.get('/api/posts', (req, res) => {
  const { genre, q } = req.query;
  let rows = db.prepare('SELECT id, author, subtitle, image, genre, liked FROM posts ORDER BY id ASC').all();

  if (genre && genre !== 'All') {
    rows = rows.filter((p) => p.genre.toLowerCase() === String(genre).toLowerCase());
  }
  if (q && String(q).trim() !== '') {
    const term = String(q).trim().toLowerCase();
    rows = rows.filter(
      (p) => p.author.toLowerCase().includes(term) || p.subtitle.toLowerCase().includes(term)
    );
  }

  res.json(rows.map((p) => ({ ...p, liked: p.liked === 1 })));
});

app.patch('/api/posts/:id/like', (req, res) => {
  const postId = Number(req.params.id);
  const { liked } = req.body;
  db.prepare('UPDATE posts SET liked = ? WHERE id = ?').run(liked ? 1 : 0, postId);
  res.json({ ok: true, id: postId, liked: Boolean(liked) });
});

app.get('/api/covers', (req, res) => {
  const { owner } = req.query;
  if (!owner) return res.status(400).json({ error: 'owner query param is required' });
  res.json(getCoversForOwner(String(owner)));
});

app.post('/api/covers', (req, res) => {
  const { owner, title, image, genre } = req.body;
  if (!owner || !title) {
    return res.status(400).json({ error: 'owner and title are required' });
  }
  const cleanTitle = title.trim();
  const item = {
    title: cleanTitle,
    image: image || coverKey(cleanTitle),
    genre: genre || 'Rock',
  };
  db.prepare('INSERT INTO covers (owner, title, image, genre) VALUES (?, ?, ?, ?)').run(
    owner.trim(),
    item.title,
    item.image,
    item.genre
  );
  res.status(201).json(item);
});

app.get('/api/jams', (req, res) => {
  const rows = db.prepare('SELECT * FROM jams ORDER BY id DESC').all();
  res.json(
    rows.map((j) => ({
      title: j.title,
      genre: j.genre,
      description: j.description,
      roles: j.roles ? j.roles.split(',') : [],
      when: j.when_text,
      location: j.location,
      host: j.host,
      image: j.image,
    }))
  );
});

app.post('/api/jams', (req, res) => {
  const { title, genre, description, roles, when, location, host, image } = req.body;
  if (!title || !when || !location) {
    return res.status(400).json({ error: 'title, when, and location are required' });
  }
  const cleanTitle = title.trim();
  const roleList = Array.isArray(roles)
    ? roles
    : String(roles || '')
        .split(',')
        .map((r) => r.trim())
        .filter(Boolean);

  const jam = {
    title: cleanTitle,
    genre: genre || 'Jam',
    description: description || 'A great session starts with an invite.',
    roles: roleList,
    when: when.trim(),
    location: location.trim(),
    host: host || 'You',
    image: image || coverKey(cleanTitle),
  };

  db.prepare(`
    INSERT INTO jams (title, genre, description, roles, when_text, location, host, image)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `).run(
    jam.title,
    jam.genre,
    jam.description,
    jam.roles.join(','),
    jam.when,
    jam.location,
    jam.host,
    jam.image
  );

  res.status(201).json(jam);
});

app.get('/api/threads', (req, res) => {
  res.json(getAllThreads());
});

app.post('/api/threads', (req, res) => {
  const { name, avatar } = req.body;
  if (!name) return res.status(400).json({ error: 'name is required' });
  db.prepare('INSERT OR IGNORE INTO threads (name, avatar) VALUES (?, ?)').run(
    name.trim(),
    avatar || `${name.trim().toLowerCase()}.jpg`
  );
  const threads = getAllThreads();
  const thread = threads.find((t) => t.name === name.trim());
  res.status(201).json(thread);
});

app.post('/api/messages', (req, res) => {
  const { threadName, avatar, text, fromMe, createdAt } = req.body;
  if (!threadName || !text) {
    return res.status(400).json({ error: 'threadName and text are required' });
  }
  const cleanThread = threadName.trim();
  db.prepare('INSERT OR IGNORE INTO threads (name, avatar) VALUES (?, ?)').run(
    cleanThread,
    avatar || `${cleanThread.toLowerCase()}.jpg`
  );
  const ts = createdAt || Date.now();
  const flag = fromMe ? 1 : 0;

  db.prepare(`
    INSERT INTO messages (thread_name, text, from_me, created_at)
    VALUES (?, ?, ?, ?)
  `).run(cleanThread, text.trim(), flag, ts);

  res.status(201).json({
    message: {
      text: text.trim(),
      fromMe: Boolean(fromMe),
      createdAt: ts,
    },
    threads: getAllThreads(),
  });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`JamMate Node.js backend running at http://localhost:${PORT}`);
});
