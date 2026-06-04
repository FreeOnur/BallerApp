# BallerApp — Komplettes Tutorial (eigener Server)

**Eine Datei. Alles in Reihenfolge.**  
Ziel: Weg von Supabase → **dein Server (Hetzner + Coolify)** + **api.ballup.net** + Bilder in **Backblaze B2**.

**Repo auf PC:** `C:\Users\runolion\Documents\code\BallerApp\BallerApp`

---

## Checkliste (zum Abhaken)

```
[ ] 1. Hetzner Server + IPv4 notiert
[ ] 2. Coolify installiert (Browser UI erreichbar)
[ ] 3. DNS: api.ballup.net → A-Record → Server-IP (DNS-Verwaltung)
[ ] 4. Coolify: Git + docker-compose.coolify.yml + alle Env-Variablen
[ ] 5. Coolify: Domain api.ballup.net → Service api → Port 8000 → HTTPS
[ ] 6. https://api.ballup.net/health → ok
[ ] 7. Supabase-Daten exportiert + in Postgres importiert
[ ] 8. Flutter: USE_LEGACY_SUPABASE=false + API_BASE_URL=https://api.ballup.net
[ ] 9. App getestet (Login, Courts)
[ ] 10. Weiter coden / später Supabase abschalten
```

---

## Vorher / Nachher

| | **Vorher (Supabase)** | **Nachher (dein Setup)** |
|---|----------------------|---------------------------|
| Auth | Supabase Auth | FastAPI + JWT (dein Server) |
| DB | Supabase Postgres | Postgres in Docker (Coolify) |
| API | Supabase Client | `https://api.ballup.net` |
| Bilder | Supabase Storage | Backblaze B2 (Keys in Coolify) |
| App-Flag | `USE_LEGACY_SUPABASE=true` | `USE_LEGACY_SUPABASE=false` |

---

## Was läuft wo (Übersicht)

```
Handy (Flutter)
    ↓ HTTPS
api.ballup.net          ← DNS A-Record (dein Domain-Panel)
    ↓
Coolify (Proxy + SSL)
    ↓
FastAPI Container :8000
    ↓
Postgres Container (nur intern)
Bild-Dateien → Backblaze B2
```

**DNS:** nur im **Domain-Panel** (Einstellungen → DNS-Verwaltung). **Nicht** in CMD. **Nicht** zuerst in Coolify.

**Secrets:** nur in **Coolify → Environment Variables**. **Nicht** in Git committen.

---

# Schritt 1 — Hetzner Server

1. [Hetzner Cloud](https://console.hetzner.cloud/) → Server anlegen  
   - Typ: **CPX22** (reicht für Start)  
   - Image: **Ubuntu 24.04**  
   - SSH-Key hinzufügen  
2. **IPv4 kopieren** (z. B. `95.xxx.xxx.xxx`) — brauchst du für DNS und SSH.

Vom PC verbinden:

```powershell
ssh root@DEINE_HETZNER_IP
```

---

# Schritt 2 — Coolify installieren

Auf dem Server (SSH):

```bash
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
```

Warten (einige Minuten). Dann im **Browser auf dem PC**:

```
http://DEINE_HETZNER_IP:8000
```

(Port steht in der Installer-Ausgabe, falls anders.)

- Admin-Account anlegen  
- Server „localhost“ ist ok  

Coolify ist deine Oberfläche für Deploy, SSL und Env-Variablen.

---

# Schritt 3 — DNS für die API (ballup.net)

### Wo (dein Panel)

1. **Einstellungen** → **DNS-Verwaltung** (nicht „SSL Manager“)  
2. Domain **ballup.net** wählen  
3. **Neuer Eintrag:**

| Feld | Wert |
|------|------|
| Typ | **A** |
| Name / Host | **api** |
| Ziel / IPv4 | **DEINE_HETZNER_IP** |
| TTL | Standard |

4. Speichern  

→ **`api.ballup.net`** zeigt auf deinen Server.

**HTTPS/SSL:** kommt von **Coolify** (Schritt 5). Im DNS-Panel nur der A-Record.

### Prüfen (PC)

```powershell
nslookup api.ballup.net
```

Antwort muss deine **Hetzner-IP** sein (5–60 Min warten ist normal).

---

# Schritt 4 — Backend in Coolify deployen

## 4.1 Neue Resource

Coolify UI:

1. **+ New Project** (falls noch keins)  
2. **+ New Resource** → **Public Repository** (oder Private mit Deploy Key)  
3. Repository: `https://github.com/FreeOnur/BallerApp`  
4. Branch: `main` oder `master`  
5. **Base Directory / Pfad im Repo:**  
   ```
   BallerApp/backend
   ```
   (Ordner mit `Dockerfile` und `docker-compose.coolify.yml`)

## 4.2 Docker Compose

| Einstellung | Wert |
|-------------|------|
| Build Pack | Docker Compose |
| Compose-Datei | **`docker-compose.coolify.yml`** |

**Nicht** `docker-compose.prod.yml` (nur für Setup ohne Coolify).

### Was die Compose-Datei macht

- Service **`db`**: Postgres + PostGIS  
- Service **`api`**: FastAPI (baut aus `Dockerfile`)  
- `${JWT_SECRET}` usw. = **Platzhalter** — Werte kommen aus Coolify (nächster Schritt)

## 4.3 Environment Variables (WICHTIG)

Coolify → deine Resource → **Environment Variables** → **Production** (oder „Preview“ je nach UI).

**Alle** eintragen (Beispiel — eigene Secrets verwenden):

```env
POSTGRES_USER=baller
POSTGRES_PASSWORD=HierStarkesPasswortOhneSonderzeichen
POSTGRES_DB=baller

JWT_SECRET=hierMindestens32ZufaelligeZeichenABC123xyz
JWT_ACCESS_MINUTES=15
JWT_REFRESH_DAYS=30

ENVIRONMENT=production
CORS_ORIGINS=*

B2_KEY_ID=dein_backblaze_key_id
B2_APP_KEY=dein_backblaze_application_key
B2_BUCKET=courtfinder-images
B2_ENDPOINT=https://s3.us-west-002.backblazeb2.com
B2_REGION=us-west-002
```

| Variable | Wofür |
|----------|--------|
| `POSTGRES_*` | Datenbank (Courts, User, …) |
| `JWT_SECRET` | Login-Tokens (App-Auth) |
| `CORS_ORIGINS` | Welche Apps die API aufrufen dürfen (`*` = alle, später einschränken) |
| `B2_*` | Bild-Uploads (Presign-URLs) |

**`POSTGRES_PASSWORD`:** keine Zeichen `#`, `@`, `:` — sonst bricht `DATABASE_URL`. Nur Buchstaben/Zahlen.

**B2 Keys:** Backblaze → App Keys → Application Key mit Zugriff auf Bucket `courtfinder-images`.

Ohne B2: API läuft trotzdem; Uploads über Presign gehen dann nicht.

## 4.4 Domain + SSL in Coolify

Resource → **Domains** (oder Configuration → Domains):

| Feld | Wert |
|------|------|
| Domain | **`api.ballup.net`** |
| Container / Service | **`api`** |
| Port | **`8000`** |
| HTTPS | **An** (Let’s Encrypt) |

Voraussetzung: A-Record (Schritt 3) zeigt schon auf den Server.

## 4.5 Deploy

**Deploy** klicken. Warten bis grün / Running.

### Test

Im Browser:

- https://api.ballup.net/health  
  → `{"status":"ok","environment":"production"}`  
- https://api.ballup.net/docs  
  → Swagger-UI  

### Bei Fehler

Coolify → **Logs** → Service `api` und `db`.

| Problem | Lösung |
|---------|--------|
| SSL failed | DNS noch nicht propagiert; A-Record prüfen |
| api crashed | Logs lesen; fehlt `JWT_SECRET` in Env? |
| db unhealthy | `POSTGRES_PASSWORD` gesetzt? Redeploy |

---

# Schritt 5 — Daten von Supabase importieren

## 5.1 Export (auf dem PC)

Supabase Dashboard → Project → **SQL** oder Database.

Tabellen exportieren:

- `courts`  
- `profiles`  
- `court_images`  

Ausführlich: `backend/scripts/export-from-supabase.md`

Ergebnis: Datei **`supabase-data.sql`**

## 5.2 SQL auf den Server kopieren

```powershell
scp C:\Pfad\zu\supabase-data.sql root@DEINE_HETZNER_IP:/tmp/supabase-data.sql
```

## 5.3 Import in Postgres

SSH auf Server:

```bash
docker ps
```

Container mit **postgis** / **db** im Namen suchen (Coolify-Prefix).

```bash
docker exec -i CONTAINER_NAME psql -U baller -d baller < /tmp/supabase-data.sql
```

Prüfen:

```bash
docker exec -i CONTAINER_NAME psql -U baller -d baller -c "SELECT COUNT(*) FROM courts;"
```

---

# Schritt 6 — Flutter App umstellen

## 6.1 Gegen deinen Server starten

```powershell
cd C:\Users\runolion\Documents\code\BallerApp\BallerApp\baller_app
flutter pub get
flutter run --dart-define=USE_LEGACY_SUPABASE=false --dart-define=API_BASE_URL=https://api.ballup.net
```

| Gerät | `API_BASE_URL` |
|-------|----------------|
| Android-Emulator | `https://api.ballup.net` |
| Echtes Handy | `https://api.ballup.net` |

**Nicht** `localhost` — die API läuft auf dem Server.

## 6.2 Testen

- [ ] Neuen Account **registrieren**  
- [ ] **Login**  
- [ ] **Courts / Karte** laden  

## 6.3 Alte Supabase-Nutzer

Passwörter von Supabase Auth werden **nicht** übernommen.

→ Nutzer müssen sich **neu registrieren** (oder du baust später E-Mail-Passwort-Reset).

## 6.4 Bilder (Übergang)

| Phase | Verhalten |
|-------|-----------|
| **Jetzt** | Uploads können noch **Supabase Storage** nutzen, wenn du `USE_LEGACY_SUPABASE=true` nur für Upload-Tests lässt = Hybrid |
| **Ziel** | App holt Presign-URL von `POST /uploads/presign`, lädt nach **B2** — Flutter-Teil noch anpassen |

DB + Auth können schon auf deinem Server sein, Bilder kurz noch bei Supabase.

---

# Schritt 7 — Weiter coden

1. Code ändern in Cursor (`baller_app/`, `backend/`)  
2. `git push` zu GitHub  
3. Coolify → **Redeploy** (oder Auto-Deploy per Webhook)  

| Modus | Bedeutung |
|-------|-----------|
| `USE_LEGACY_SUPABASE=false` | **Ziel** — alles über api.ballup.net |
| `USE_LEGACY_SUPABASE=true` | Nur noch für alte Supabase-Tests / Hybrid-Uploads |

**Release / Play Store:** dieselben `--dart-define` beim Build setzen.

---

# Schritt 8 — Backup (empfohlen)

SSH, täglich DB sichern:

```bash
docker exec CONTAINER_NAME pg_dump -U baller baller | gzip > /tmp/baller-backup.sql.gz
```

Datei nach **Backblaze B2** oder Hetzner Storage kopieren.

---

# Schritt 9 — Supabase abschalten (ganz am Ende)

Erst wenn:

- [ ] `https://api.ballup.net/health` ok  
- [ ] App stabil mit `USE_LEGACY_SUPABASE=false`  
- [ ] Daten importiert  
- [ ] Nutzer informiert (neue Passwörter)  

Dann Supabase-Projekt **pausieren** oder löschen (vorher letztes Backup).

---

# Kurz: Reihenfolge

```
1 Hetzner IP
2 Coolify installieren
3 DNS api.ballup.net → A → IP (DNS-Verwaltung)
4 Coolify: Git backend + compose.coolify.yml + Env-Variablen
5 Coolify: Domain api.ballup.net:8000 + HTTPS + Deploy
6 /health ok
7 Supabase SQL import
8 Flutter API_BASE_URL=https://api.ballup.net
9 Coden / Redeploy
10 Supabase aus (später)
```

---

# Env-Variablen — nochmal klar

| Wo stehen die Werte? | Antwort |
|---------------------|---------|
| In `docker-compose.coolify.yml`? | Nur **Namen** wie `${JWT_SECRET}` |
| Wo eintragen? | **Coolify → Environment Variables** |
| In Git committen? | **Nein** |

---

# Hilfe

| Thema | Datei |
|-------|--------|
| Supabase Export | `backend/scripts/export-from-supabase.md` |
| Compose Coolify | `backend/docker-compose.coolify.yml` |
| Backend lokal (optional) | `docker-compose.dev.yml` + `backend/README.md` |

---

*Domain-Beispiel: **ballup.net** → API: **https://api.ballup.net***
