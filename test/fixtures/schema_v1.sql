PRAGMA foreign_keys = ON;

CREATE TABLE parent_plants (
  id TEXT NOT NULL PRIMARY KEY,
  nickname TEXT NOT NULL,
  species_text TEXT,
  notes TEXT NOT NULL DEFAULT '',
  created_at_utc INTEGER NOT NULL,
  updated_at_utc INTEGER NOT NULL,
  archived_at_utc INTEGER
);

CREATE TABLE cuttings (
  id TEXT NOT NULL PRIMARY KEY,
  parent_id TEXT NOT NULL REFERENCES parent_plants(id) ON DELETE RESTRICT,
  name TEXT NOT NULL,
  method TEXT NOT NULL,
  medium TEXT NOT NULL DEFAULT '',
  location TEXT NOT NULL DEFAULT '',
  started_at_utc INTEGER NOT NULL,
  created_at_utc INTEGER NOT NULL,
  updated_at_utc INTEGER NOT NULL,
  archived_at_utc INTEGER
);

CREATE TABLE cutting_tags (
  cutting_id TEXT NOT NULL REFERENCES cuttings(id) ON DELETE CASCADE,
  tag TEXT NOT NULL,
  PRIMARY KEY (cutting_id, tag)
);

CREATE TABLE cutting_events (
  id TEXT NOT NULL PRIMARY KEY,
  cutting_id TEXT NOT NULL REFERENCES cuttings(id) ON DELETE CASCADE,
  occurred_at_utc INTEGER NOT NULL,
  created_at_utc INTEGER NOT NULL,
  kind TEXT NOT NULL,
  note TEXT NOT NULL DEFAULT '',
  stage TEXT,
  outcome TEXT,
  corrects_event_id TEXT REFERENCES cutting_events(id) ON DELETE RESTRICT
);

CREATE TABLE media_assets (
  id TEXT NOT NULL PRIMARY KEY,
  event_id TEXT NOT NULL REFERENCES cutting_events(id) ON DELETE CASCADE,
  relative_path TEXT NOT NULL,
  sha256 TEXT NOT NULL,
  media_type TEXT NOT NULL,
  caption TEXT NOT NULL DEFAULT '',
  captured_at_utc INTEGER,
  imported_at_utc INTEGER NOT NULL
);

CREATE TABLE reminders (
  id TEXT NOT NULL PRIMARY KEY,
  cutting_id TEXT NOT NULL REFERENCES cuttings(id) ON DELETE CASCADE,
  scheduled_for_utc INTEGER NOT NULL,
  status TEXT NOT NULL,
  platform_notification_id TEXT,
  created_at_utc INTEGER NOT NULL,
  updated_at_utc INTEGER NOT NULL,
  completed_at_utc INTEGER,
  snoozed_from_utc INTEGER
);

INSERT INTO parent_plants (
  id, nickname, created_at_utc, updated_at_utc
) VALUES ('fixture-parent', 'Fixture parent', 1767268800, 1767268800);
INSERT INTO cuttings (
  id, parent_id, name, method, started_at_utc, created_at_utc, updated_at_utc
) VALUES (
  'fixture-cutting', 'fixture-parent', 'Fixture cutting', 'stem',
  1767268800, 1767268800, 1767268800
);
INSERT INTO reminders (
  id, cutting_id, scheduled_for_utc, status, created_at_utc, updated_at_utc
) VALUES (
  'fixture-reminder', 'fixture-cutting', 1767355200, 'pending',
  1767268800, 1767268800
);

PRAGMA user_version = 1;
