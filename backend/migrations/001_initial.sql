-- BallerApp self-hosted schema (migrated from Supabase tables + app auth)
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- App-owned auth (replaces Supabase Auth on cutover)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS refresh_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash TEXT NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user ON refresh_tokens(user_id);

-- profiles.id matches users.id after cutover (or legacy Supabase user uuid on import)
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY,
    username TEXT NOT NULL DEFAULT '',
    avatar_url TEXT,
    age INT,
    location INT,
    gender INT,
    skill_level INT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS courts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source TEXT NOT NULL DEFAULT 'community',
    name TEXT NOT NULL,
    lat DOUBLE PRECISION NOT NULL,
    lng DOUBLE PRECISION NOT NULL,
    indoor BOOLEAN NOT NULL DEFAULT FALSE,
    lights BOOLEAN NOT NULL DEFAULT FALSE,
    has_markings BOOLEAN NOT NULL DEFAULT FALSE,
    surface TEXT,
    hoops INT,
    address TEXT,
    status TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_courts_status ON courts(status);
CREATE INDEX IF NOT EXISTS idx_courts_lat_lng ON courts(lat, lng);

CREATE TABLE IF NOT EXISTS court_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    court_id UUID NOT NULL REFERENCES courts(id) ON DELETE CASCADE,
    file_path TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_court_images_court ON court_images(court_id);
