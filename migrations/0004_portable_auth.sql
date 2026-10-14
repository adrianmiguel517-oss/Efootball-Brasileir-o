CREATE TABLE auth_users(id TEXT PRIMARY KEY REFERENCES members(id),email TEXT NOT NULL UNIQUE,password_hash TEXT NOT NULL);
CREATE TABLE auth_sessions(token_hash TEXT PRIMARY KEY,user_id TEXT NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,expires_at INTEGER NOT NULL);
CREATE INDEX session_user ON auth_sessions(user_id);
CREATE TABLE auth_limits(key TEXT PRIMARY KEY,failures INTEGER NOT NULL DEFAULT 0,reset_at INTEGER NOT NULL);
INSERT INTO members(id,email,role) VALUES('admin:adrian','adrianmiguel517@gmail.com','admin');
INSERT INTO members(id,email,role) VALUES('admin:paiiva','paiivavitor07@gmail.com','admin');
