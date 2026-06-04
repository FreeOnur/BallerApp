# BallerApp auf deinen Server (Coolify)

**Einzige Anleitung.** Ziel: API + Postgres auf Hetzner, Bilder in Backblaze B2, App nutzt `https://api.DEINE-DOMAIN.de`.

Repo: `BallerApp/backend` · Compose für Coolify: `docker-compose.coolify.yml`

---

## Übersicht

```
Domain-DNS (A-Record)  →  Server-IP
Coolify (auf Server)   →  Docker: Postgres + FastAPI
Backblaze B2           →  Bilder (Keys nur in Coolify Env)
Flutter App            →  API_BASE_URL=https://api...
```

**DNS machst du nicht in CMD** und nicht in Coolify zuerst — sondern beim **Domain-Anbieter** (Cloudflare, IONOS, Namecheap, Hetzner DNS, …).

---

## Teil 1 — Server + Coolify

### 1.1 Hetzner

- Server (CPX22, Ubuntu 24.04)
- **IPv4 notieren:** z. B. `123.45.67.89`

### 1.2 Coolify installieren (SSH auf Server)

```bash
ssh root@DEINE_SERVER_IP
```

Offizielles Install-Skript (von [coolify.io](https://coolify.io/docs)):

```bash
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
```

Warten bis fertig. Coolify-UI im Browser:

- `http://DEINE_SERVER_IP:8000` (Port laut Installer-Ausgabe)

Einrichtung: Admin-Account, Server ist „localhost“.

---

## Teil 2 — DNS (A-Record) — wichtig

API-URL wird z. B. **`https://api.ballup.net`** (Subdomain `api` + deine Domain).

### Bei deinem Panel (Screenshot: Domain-Registrierung)

1. Links **Einstellungen** → **DNS-Verwaltung** (nicht SSL Manager).
2. Domain **`ballup.net`** auswählen (Status grün = aktiv).
3. **Neuen Eintrag** / **Record hinzufügen**:

| Feld (deutsch/englisch) | Eintrag |
|-------------------------|---------|
| **Typ** | `A` |
| **Name / Host / Subdomain** | `api` (nur `api`, nicht `api.ballup.net` — je nach Panel) |
| **Ziel / Wert / IPv4** | **Hetzner-Server-IP** (z. B. `123.45.67.89`) |
| **TTL** | 300 oder Standard |

4. Speichern.

Ergebnis: `api.ballup.net` zeigt auf deinen Server.

**SSL für HTTPS** macht **Coolify** (Let’s Encrypt) — im DNS-Panel brauchst du nur den **A-Record**, kein SSL-Manager-Eintrag für die API.

### Andere Anbieter

| Anbieter | Wo |
|----------|-----|
| **Cloudflare** | DNS → Add record |
| **IONOS / Strato** | DNS-Verwaltung |
| **Hetzner DNS** | Console → DNS Zone |

### Prüfen

| Feld | Wert |
|------|------|
| **Type** | `A` |
| **Name** | `api` |
| **Value** | Hetzner IPv4 |

**Nicht** in Windows CMD, **nicht** auf dem Server mit `nslookup` eintragen — nur beim Domain-Provider speichern.

### Prüfen (optional, CMD/PowerShell auf PC)

```powershell
nslookup api.deine-domain.de
```

Muss deine **Server-IP** zeigen (kann 5–60 Min dauern).

---

## Teil 3 — Projekt in Coolify

### 3.1 Code verbinden

**Project** → **+ New Resource** → **Public / Private Git Repository**

- Repo: `FreeOnur/BallerApp` (oder dein Fork)
- Branch: `main` / `master`
- **Base Directory / Root:** `BallerApp/backend` (Pfad zum Ordner mit `Dockerfile`)

Falls kein Git auf Server: Resource **Docker Compose** + Repo per Deploy Key.

### 3.2 Docker Compose

- **Docker Compose Location:** `docker-compose.coolify.yml`
- Nicht `docker-compose.prod.yml` (das ist für manuelles Caddy — bei Coolify unnötig)

### 3.3 Environment Variables (Coolify UI)

Unter **Environment Variables** der Resource (Production):

```env
POSTGRES_USER=baller
POSTGRES_PASSWORD=starkes-passwort-hier
POSTGRES_DB=baller

JWT_SECRET=mindestens-32-zufaellige-zeichen
JWT_ACCESS_MINUTES=15
JWT_REFRESH_DAYS=30
ENVIRONMENT=production
CORS_ORIGINS=*

B2_KEY_ID=...
B2_APP_KEY=...
B2_BUCKET=courtfinder-images
B2_ENDPOINT=https://s3.us-west-002.backblazeb2.com
B2_REGION=us-west-002
```

`CORS_ORIGINS` später auf deine App-Domain einschränken.

**Passwort mit `#` oder `@`:** in `DATABASE_URL` URL-encoden, oder nur über die einzelnen `POSTGRES_*` Vars arbeiten (Compose setzt `DATABASE_URL` automatisch).

### 3.4 Domain in Coolify (SSL)

Resource → **Domains** (oder **Configuration → Domains**):

| Feld | Wert |
|------|------|
| **Domain** | `api.ballup.net` (oder `api.deine-domain.de`) |
| **Service** | `api` |
| **Port** | `8000` |
| **HTTPS** | an (Let’s Encrypt) |

Coolify holt Zertifikat — dafür muss der **A-Record schon** auf die Server-IP zeigen und Port **80/443** am Server erreichbar sein (Coolify/Firewall).

**Deploy** klicken.

### 3.5 Test

Browser: `https://api.deine-domain.de/health`  
→ `{"status":"ok","environment":"production"}`

Swagger: `https://api.deine-domain.de/docs`

Logs in Coolify: Resource → **Logs** → Service `api` / `db`.

---

## Teil 4 — Daten von Supabase

### 4.1 Export (PC)

Supabase Dashboard → SQL oder `pg_dump` — Tabellen:

- `courts`
- `profiles`
- `court_images`

Details: `backend/scripts/export-from-supabase.md`

Datei: `supabase-data.sql`

### 4.2 Import (Server)

**Option A — Coolify Terminal** (Service `db`):

```bash
# In Coolify: db container shell, oder SSH:
cd /data/coolify/...   # Pfad je nach Setup
cat supabase-data.sql | docker exec -i CONTAINER_NAME psql -U baller -d baller
```

**Option B — SSH + Compose-Pfad:**

```bash
# SQL nach Server kopieren (PC):
scp supabase-data.sql root@DEINE_SERVER_IP:/tmp/

# Auf Server, im Backend-Deploy-Verzeichnis von Coolify oder:
docker ps   # Name des db-Containers finden
docker exec -i <db-container> psql -U baller -d baller < /tmp/supabase-data.sql
```

Prüfen:

```bash
docker exec -i <db-container> psql -U baller -d baller -c "SELECT COUNT(*) FROM courts;"
```

---

## Teil 5 — Flutter auf deinen Server

```powershell
cd baller_app
flutter pub get
flutter run --dart-define=USE_LEGACY_SUPABASE=false --dart-define=API_BASE_URL=https://api.ballup.net
```

Release/APK: dieselben `--dart-define`.

| Gerät | API_BASE_URL |
|-------|----------------|
| Emulator Android | `https://api.deine-domain.de` (nicht localhost) |
| echtes Handy | `https://api.deine-domain.de` |

### Alte Supabase-Nutzer

Passwörter von Supabase Auth funktionieren **nicht** auf dem neuen Backend → Nutzer müssen **neu registrieren** oder du schickst Passwort-Reset (wenn SMTP in `.env`).

### Bilder

- **Kurz:** App kann noch Supabase Storage nutzen (`USE_LEGACY_SUPABASE=true` nur für Uploads) = Hybrid.
- **Ziel:** B2 über API `POST /uploads/presign` — Flutter-Code noch anpassen, Backend ist bereit.

---

## Teil 6 — Weiter coden

| Modus | Wann |
|-------|------|
| `USE_LEGACY_SUPABASE=true` | Nur Supabase-Features testen / alte Uploads |
| `USE_LEGACY_SUPABASE=false` | Alles über deinen Server (Ziel) |

Lokal am Code arbeiten wie gewohnt in Cursor. Nach Push: Coolify **Redeploy** (Webhook oder manuell).

Backend-Code: `backend/app/`  
Flutter: `baller_app/lib/`

---

## Teil 7 — Backup

Coolify oder Cron auf dem Server — täglich:

```bash
docker exec <db-container> pg_dump -U baller baller | gzip > backup.sql.gz
```

Backup nach B2 kopieren.

---

## Checkliste

- [ ] Server + Coolify läuft
- [ ] A-Record `api` → Server-IP (beim Domain-Anbieter)
- [ ] Coolify: Git `BallerApp/backend`, Compose `docker-compose.coolify.yml`
- [ ] Env: Postgres, JWT, B2
- [ ] Domain in Coolify → `api...` Port 8000, HTTPS
- [ ] `/health` ok
- [ ] Supabase-Daten importiert
- [ ] Flutter mit `API_BASE_URL` getestet

---

## Fehler

| Problem | Fix |
|---------|-----|
| SSL schlägt fehl | A-Record prüfen, 80/443 offen, Domain in Coolify exakt |
| `health` timeout | Logs `api`, DB healthy? |
| App Network Error | `https://` in URL, kein Zertifikat-Problem am Handy |
| DNS „geht nicht in CMD“ | Normal — DNS nur im **Domain-Panel** setzen |

---

*Stand: Coolify + FastAPI + PostGIS + B2. Manuell mit Caddy: `docker-compose.prod.yml` (ohne Coolify).*
