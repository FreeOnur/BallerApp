# BallerApp — Design Knowledge (Source of Truth)

> **Was ist das?** Die zentrale, verbindliche Design-Wissensdatei für BallerApp. Alle Tokens, Systeme,
> Patterns und Regeln leben hier. Cursor-Rules (`.cursor/rules/*.mdc`), Claude und jede UI-/Bild-Generierung
> referenzieren diese Datei — niemand erfindet eigene Werte.
>
> **Speicherort:** `baller_app/baller-design-knowledge.md`
> **Referenz in Cursor/Claude:** `@baller-design-knowledge.md`
>
> **Projekt:** Flutter (Android + iOS primär, später Info-Website). Custom Design System, **kein** Material-Default-Look, **kein AI-Slop**.
> **Marke:** editorial-meets-streetball — Slam-Magazine-Cover × Nike-SNKRS-Card × Vercel-Layout-Disziplin. Nicht SaaS-clean, nicht Neon-Gamer, nicht Wellness-Pastell.

---

## 0. Die eine Regel über allen Regeln

AI-Slop ist kein Geschmack, sondern ein **statistischer Mittelwert**: LLMs sagen den wahrscheinlichsten nächsten Token voraus, und die wahrscheinlichsten Frontend-Tokens stammen aus Tailwind/shadcn/Vercel-Code 2020–2024. Das Modell *designt* nicht, es *mittelt*. Der sichtbare Fingerabdruck: Inter-Font überall, Indigo/Lila-Verläufe (Ursprung: Tailwinds `bg-indigo-500`), Drei-Icon-Karten-Raster, zentrierte Hero-Sektionen, einheitliche runde Ecken, identische weiche Schatten, sinnlose Fade-Ins, Emoji als Feature-Icons, erfundene Metriken.

**Der Gegen-Mechanismus (immer in dieser Reihenfolge):**
1. **Erst eine kompromisslose Richtung wählen** (Tonalität als Extrem, nicht "clean & modern").
2. **In Tokens festschreiben** (Farbe, Typo, Spacing, Radius, Schatten, Motion) — danach nie mehr mitten im Code improvisieren.
3. **Vor dem Ausliefern gegen Gates prüfen** (siehe §12).
4. **Ehrliche Copy** — keine erfundenen Zahlen, keine Floskeln.

---

## 1. Slop-Blacklist (harte Verbote)

Niemals ausliefern, außer der Nutzer fordert es **namentlich** an:

**Farbe**
- Indigo/Violett/Lila-zu-Pink/Blau-Verlaufs-Hero. Das "Purple Problem". Verboten.
- Zaghafte, gleichmäßig verteilte Paletten ohne dominante Farbe. → Eine dominante Farbe + ein scharfer Akzent.
- Mehr als ein Akzent-Hue, der auf demselben Screen um Aufmerksamkeit konkurriert.

**Typografie**
- `Inter`, `Roboto`, `Arial`, `Helvetica`, rohes `system-ui` **als Marken-/Display-Face**. (Als reine Daten-/UI-Ziffern okay — siehe §3.)
- `Space Grotesk` als "Anti-Inter"-Reflex (das ist der zweithäufigste AI-Tell).
- Eine einzige Font-Familie für alles. → Display- und Body-Face trennen.
- Mehr als **3 Font-Familien** pro Screen.

**Layout & Struktur**
- "Centered-Everything"-Hero (zentrierte Eyebrow + H1 + Absatz + ein Button).
- Genau drei Feature-Karten in einer Reihe mit Icon + fettem Titel + zwei Zeilen grauem Text.
- Perfekt symmetrische Raster ohne Fokuspunkt, ohne Asymmetrie, ohne grid-brechendes Element.
- AI-Nav-Fingerabdruck: Logo links + 4 zentrierte Links + eine gefüllte Pille rechts.
- AI-Footer-Fingerabdruck: 4 identische Link-Spalten + Copyright.

**Form & Tiefe**
- Reflexhaft runde Ecken überall mit demselben Radius. **Radius ist ein bewusster Token, kein Default.** Für BallerApp: scharf 0–8 px + Pillen (9999) nur wo es passt.
- Floatige, identische Schatten auf allem (dann liest nichts als erhaben).
- Glassmorphism / Backdrop-Blur als Deko ohne Funktion.
- Verschwommene "Blobs" im Hintergrund.

**Motion**
- Generisches `fade-in-up` auf allem beim Scrollen, ohne Bedeutung.
- Spinner als einzige Ladezustand-Lösung. → Skeletons / optimistisches UI.
- Konfetti/Jubel-Toasts für Routine-Erfolge.

**Copy & Inhalt**
- Erfundene Metriken ("10.000+ zufriedene Nutzer", "99,9 % Uptime"), die nicht real sind.
- Floskeln: "Built for the modern team", "Supercharge your workflow", "Take it to the next level", Lorem-Ipsum in Prod.
- Emoji als Feature-Icon.
- Nachgezeichnete UI-Chrome (Fake-Browser-Bars, Fake-OS-Fenster) als Deko.

---

## 2. Prozess: erst denken, dann coden (Pflicht)

Vor jeglichem Markup/Widget-Code in 3–6 Zeilen festlegen:
1. **Zweck & Zielgruppe** — Casual Pickup-Spieler, Reisende, später Competitive.
2. **Tonalität als Extrem** — für BallerApp: *editorial / brutalist / bold-athletic*. NIE "clean & modern".
3. **Das eine merkbare Element** — was bleibt hängen? (überdimensioniertes Display-Lettering, Scoreboard-Treatment, scharfe Akzentfarbe, eine Signatur-Interaktion).
4. **Hell oder dunkel + dominante Farbe** — BallerApp default **dark** (Sport-App, früh/spät genutzt). Nicht reflexhaft Weiß.
5. **Tokens zuerst** — damit das Modell ausführt statt mitten im File neu zu entscheiden.

Aufwand an die Vision koppeln: maximalistisch braucht aufwändigen Code; raffiniertes Minimal braucht Zurückhaltung und obsessive Sorgfalt bei Spacing & Typo.

---

## 3. Typografie

**Pairing:** distinktives Display-Face + raffiniertes Body-Face. "Eine-Font-Seite = Template-Seite."

**Display-Kandidaten (athletisch/streetball):**
- Premium: **Druk / Druk Wide** (Heavy condensed, editorial/sport), **Trade Gothic Bold Condensed** (Nikes Editorial-Face), **Futura Bold Condensed**, **National 2 Condensed**, **Monument Grotesk Heavy**, **Boathouse** (Stravas Brand-Face seit Nov 2024).
- Free (Google Fonts): **Anton**, **Oswald**, **Bebas Neue**, **Barlow Condensed**, **League Gothic**.

**Body-Kandidaten:** IBM Plex Sans, Manrope, General Sans, Public Sans, Söhne, Geist. (Strava nutzt Inter **nur** für Ziffern/Pace/Distanz — als reines Datenfeld legitim, nie als Marken-Face.)

**Empfehlung BallerApp:** Heavy/Condensed-Display (Druk Wide Heavy, oder free: Anton + Barlow Condensed) für Titel/Scoreboards/„GAME ON"-Momente + neutrales Body (IBM Plex Sans oder Manrope). Tabellenziffern für tickende Zahlen.

**Numerische Regeln**
- Type-Scale (modular, ~1,25): **12 · 14 · 16 · 18 · 20 · 24 · 30 · 36 · 48 · 60 · 72 · 96**.
- Line-Height: Display **1,05–1,2**; Body **1,4–1,6**; Lauftext **1,6+**. Je größer die Schrift, desto enger.
- Letter-Spacing: Uppercase-Labels **≥ +0,05em**; große Display-Headlines **−1 % bis −3 %**.
- Measure (Zeilenlänge): **50–75 Zeichen**, ideal ~65.
- Hierarchie über **Größe + Weight + Farbe**, nicht nur Größe. Weights paaren: 400 + 700 (nicht 500 + 600).
- Textfarben dreistufig: `ink` (fast schwarz/weiß) · `inkMuted` · `inkSubtle`.
- **Tabellenziffern Pflicht** für Scoreboards/Stats: `FontFeature.tabularFigures()`.
- Display:Body-Verhältnis ≥ **2,5×** (nicht 1,25×).
- Max **3 Font-Familien** pro Screen, das Outlier-Face in **≤ 2 Slots**.

**Flutter:** Fonts in `pubspec.yaml > fonts:` bündeln mit **expliziten** `weight`/`style` pro Datei (Flutter leitet nicht aus Dateinamen ab — sonst werden Glyphen verzerrt synthetisiert). Bei `google_fonts` in Prod: `GoogleFonts.config.allowRuntimeFetching = false` + TTFs als Assets bündeln (spart 8–40 ms First-Render-Jank). Ein `AppTypography` baut sowohl `TextTheme` als auch `ThemeExtension<BallerType>` (Brand-Styles: `displayHero`, `scoreboardLarge`, `statLabel`, `courtCaps`). Text-Scaling: `MediaQuery.textScalerOf(context)` (nicht das veraltete `textScaleFactor`), clampen auf `1.0–1.4`.

---

## 4. Farbe

**OKLCH ist der Autoren-Farbraum** (perzeptuell uniform: gleiches L = gleiche Helligkeit über alle Hues). In OKLCH entwerfen, als Hex ausliefern (Flutter hat keinen nativen OKLCH-Typ). Tools: oklch.fyi, oklch.net, Evil Martians Picker.

**BallerApp-Palette**
- **Dominante neutrale Rampe** — Asphalt/Beton-Grau, 11 Stufen, leicht kühl (Court-Beton):
  `oklch(0.20 0.01 240)` → `oklch(0.97 0.005 240)`. Optional minimal akzent-getönt (C ≤ 0,02, „tinted neutrals" à la Vercel).
- **Ein scharfer Akzent — genau EINER wählen:**
  - **Signal-Orange** (Strava / Basketball-Leder): `#FC4C02` ≈ `oklch(0.66 0.22 38)`. *(Default-Empfehlung für BallerApp.)*
  - **Volt / Safety-Yellow** (Nike Run Club Neon): `#CEFF00`.
  - **Street-Green / Cyber-Lime** — high-energy.
  - **Cardinal-Red** (Peloton): `#C41F2F` — Rot nur für Primäraktion.
  - **AND1 Schwarz + Orange** — direkteste Streetball-Heritage.
- **Semantische Farben** — Success / Warning / Error / Info als eigene Hues mit **gleichem L** (konsistenter Kontrast).
- **Atmosphärische Hintergründe** (nie flaches Weiß/Schwarz): SVG-Noise 3–5 %; Court-Linien-/Blueprint-Grid (1 px, 10–20 % Opacity, 16–24 px Raster); Beton-/Court-Textur-Foto bei 5–8 %; im Dark Mode dezente radiale Blooms (nur „atmospheric").

**Kontrast (WCAG 2.2 AA — der Boden):** Body **4,5:1**; Large (≥ 24 px regular / 18,66 px bold) & UI **3:1**. Zusätzlich APCA gegenprüfen. Niemals graue Schrift auf farbigem Grund — gleichen Hue nehmen, S/L anpassen.

**Dark Mode (BallerApp default):** nicht einfach invertieren. Body L **0,85–0,92**, Flächen L **0,18–0,22**. Akzent-C leicht anheben, damit er nicht stumpf wirkt (aber kein Neon-C auf Dunkel). Vorbilder: WHOOP (fast komplett schwarz, Daten poppen), Peloton (Woodsmoke `#101113` + Pumice `#CED0CF` + Cardinal-Rot nur für Primäraktion).

---

## 5. Spacing, Layout & Komposition

**8-pt-Grid:** alles auf 4/8-px-Vielfache snappen. Spacing-Skala:
**4 · 8 · 12 · 16 · 24 · 32 · 48 · 64 · 96 · 128 · 192 · 256**.
Padding ist Teil des Systems, kein Sonderfall. Selbstbewusste Marketing-Sektionen: **96–128 px** vertikales Padding.

**Grid bewusst brechen** (nicht das generische 12-Spalten-3-Karten-Raster):
- **Bento-Grid** — ungleiche Kacheln, gruppieren Zusammengehöriges.
- **Editorial/Magazine** — asymmetrisch, gemischte Breiten, übergroße Initiale, `max-width: 65ch`.
- **Stat-Led** — eine riesige Zahl + Kontext (perfekt für Scores).
- **Marquee-Hero** — horizontal laufender Text.
- **Manifesto/Quote-Led** — rein typografisch.
- **Asymmetric Overlap** — überlappende Karten, bleed-off Fotos.

**Container-Breiten:** Mobile full-bleed bis Safe-Area, Gutter 16–24 px. Marketing-Site max 1080–1280 px, Prosa 65 ch. "Enger Inhalt wirkt billig. Großzügiges Spacing wirkt selbstbewusst."

**Borders funktional unsichtbar:** Dark `rgba(255,255,255,0.08)`; Light `gray-200/300`. Regionen definieren, nicht zum Design-Element werden.

---

## 6. Tiefe, Schatten, Borders

- **Elevation-Skala (5 Stufen, jeweils zweiteiliger Schatten):** ein enger, dunklerer Nahschatten + ein größerer, weicher Umgebungsschatten. Schattenfarbe = transparentes Dunkel, nicht opakes Grau. **Floatet alles, hat nichts Tiefe** — große Schatten nur für echt Erhöhtes (Modals, Popovers).
- **Tiefe ohne Schatten ist oft besser:** hellere Oberkante + dunklere Unterkante, leichte Flächen-Helligkeitsverschiebung, überlappende Elemente mit Versatz.
- **Borders sparsam & funktional:** 1px Haarlinie bei niedrigem Kontrast trennt Flächen ohne Lärm.
- **Radius = Token mit Absicht** (§1): für BallerApp 0–8 px Schärfe + 9999 nur für Pillen. Konsistent als Entscheidung, nicht reflexhaft auf jede Box.

---

## 7. Motion & Micro-Interactions

Animation muss **funktional** sein: Feedback, Kontinuität, Aufmerksamkeit lenken, Marke ausdrücken. Kein Grund → keine Animation.

- **Dauern:** Micro (Hover/Toggle/Press) **120–200 ms**; Standard (Dropdown/Accordion) **200–300 ms**; groß (Modal/Route) **300–500 ms**. Unter ~100 ms = abrupt; über ~500 ms = träge.
- **Easing:** Enter → `ease-out` (`cubic-bezier(0.0,0,0.2,1)`); Exit → `ease-in` (`cubic-bezier(0.4,0,1,1)`); Move → `ease-in-out` (`cubic-bezier(0.4,0,0.2,1)`); Premium-„Settle"/Hero-Reveal → **`cubic-bezier(0.16,1,0.3,1)`** (easeOutExpo). Kein `linear` für UI (nur Spinner/Progress).
- **Ein orchestrierter Moment beim Screen-Load** (Stagger 30–80 ms zwischen Geschwistern) schlägt verstreute Scroll-Animationen.
- **Motion folgt Hierarchie:** Primäres bewegt sich zuerst/stärker; Sekundäres kürzer, weicher, niedriger-Opacity.
- **Nur `transform` & `opacity` animieren** (60 fps), nie `width`/`height`/Position für Bewegung.
- **High-Frequency** (Tabs) schneller; **High-Risk** (Löschen) langsamer/weicher.
- **Reduced Motion immer respektieren:** Flutter `MediaQuery.disableAnimationsOf(context)` → große Translationen/Scales durch Fade oder harten Cut ersetzen.

**Flutter:** implizit (`AnimatedContainer`, `AnimatedOpacity`, `AnimatedSwitcher`, `TweenAnimationBuilder`) für state-getriebene Transitions; explizit (`AnimationController` + `Tween` + `CurvedAnimation`) für choreografierte Sequenzen. `flutter_animate` für deklarative Chains; das offizielle `animations`-Paket für Route-Transitions (Container-Transform, Shared-Axis, Fade-Through).

---

## 8. Flutter-Theming-Architektur (Custom Design System)

**Nie Material-Defaults malen:** kein `Colors.deepPurple`/`ColorScheme.fromSeed`-Look, kein Default-Roboto, keine Default-`Card`-Elevation, kein Default-`ElevatedButton`-Shape. `useMaterial3: true` MIT custom `ColorScheme`, `TextTheme` und Komponenten-Themes.

**Tokens via `ThemeExtension`** (nicht in Materials Slot-Namen pressen):

```dart
@immutable
class BallerColors extends ThemeExtension<BallerColors> {
  const BallerColors({
    required this.surface, required this.surfaceMuted,
    required this.ink, required this.inkMuted, required this.inkSubtle,
    required this.court, required this.success,
    required this.warning, required this.danger, required this.outline,
  });
  final Color surface, surfaceMuted, ink, inkMuted, inkSubtle, court, success, warning, danger, outline;

  @override BallerColors copyWith({/* ... */}) => /* ... */;
  @override BallerColors lerp(ThemeExtension<BallerColors>? other, double t) {
    if (other is! BallerColors) return this;
    return BallerColors(
      surface: Color.lerp(surface, other.surface, t)!, /* ... alle Felder lerpen ... */
    );
  }
}
```

Registrieren: `ThemeData(extensions: [BallerColors.light, BallerSpacing.standard, BallerType.brand, BallerMotion.standard])`.
Zugriff über `BuildContext`-Extension → `context.colors.court`, `context.spacing.lg`, `context.motion.standard`. Korrektes `lerp` ermöglicht animierte Theme-Wechsel.

**Ordnerstruktur:**
```
baller_app/lib/
  theme/
    app_theme.dart            # AppTheme.light() / AppTheme.dark()
    tokens/                   # colors, typography, spacing, radius, elevations, motion (.dart)
    extensions/               # BallerColors, BallerType, BallerSpacing, BallerMotion
  widgets/                    # BallerButton, BallerCard, BallerScoreboard, BallerTabBar, BallerAppBar
```

**M3 vs Cupertino vs Custom:** M3-Widgets als strukturelle Primitive (Scaffold, Material, InkWell) für Ripples/Gesten/RTL/a11y nutzen, aber **aggressiv weg vom Default** themen. Cupertino-Interaktionen auf iOS (Scroll-Physik, Swipe-Back, Text-Selektion); `Icons.adaptive`, `CupertinoActivityIndicator`. Bottom-Nav: `CupertinoTabBar` (iOS) vs M3 `NavigationBar` (Android) — gleiche visuelle Markensprache, nur plattform-konventionelle Affordances unterscheiden sich.

**Responsive:** `LayoutBuilder` + `MediaQuery.sizeOf`. Breakpoints: compact < 600, medium 600–840, expanded > 840 dp. **`flutter_screenutil` meiden** bei design-system-getriebenen Apps (blindes Scaling bricht Buttons/Accessibility) — stattdessen `textTheme.apply(fontSizeFactor: 0.9–1.15)` pro Breakpoint.

**Häufige Flutter-Fehler (verboten):** `Colors.blue`/`deepPurple`-Akzente; `BoxShadow(blurRadius: 4, color: Colors.black26)` überall; alles in `FontWeight.normal`; `BorderRadius.circular(8)` ohne System; `CircularProgressIndicator()` für jeden Ladezustand; ad-hoc `Colors.grey[300/400/500]` statt Tokens; inline `EdgeInsets.all(16)` statt `context.spacing.md`; vergessenes `MaterialTapTargetSize.padded`.

---

## 9. Accessibility (nicht verhandelbar)

- **Kontrast:** Body 4,5:1, Large/UI 3:1 (APCA gegenprüfen). Bedeutung nie nur über Farbe (Icon/Text/Muster ergänzen).
- **Touch-Targets:** iOS ≥ **44 pt**, Android ≥ **48 dp** (WCAG 2.5.8 Minimum 24×24 px — Mobile ist strenger). `MaterialTapTargetSize.padded` (Default) sichert 48 dp; Custom-Widgets in `SizedBox(48,48)` wrappen.
- **Screen Reader:** interaktive Widgets in `Semantics(label:, hint:, button: true, onTap:)` wrappen, wenn sie sich nicht selbst ankündigen. Label knapp, **ohne** „Button" (Rolle wird angehängt). Icon-only-Buttons brauchen `tooltip` (dient zugleich als Label). Deko-Bilder `semanticLabel: ""` / `ExcludeSemantics`. Gruppieren mit `MergeSemantics`.
- **System-Präferenzen:** `MediaQuery.boldTextOf/highContrastOf/invertColorsOf/accessibleNavigationOf/disableAnimationsOf`.
- **Text-Scaling:** 100–200 % testen; `textScaler` clampen auf 1.0–1.4.
- Testen mit TalkBack, VoiceOver, DevTools-Accessibility-Tab.

---

## 10. Komponenten & States

**Jeder interaktive Widget braucht ALLE States:** Default · Hover · **Focus** (sichtbarer Ring via `outline`, nicht Border-Width — sonst Layout-Shift) · Pressed · **Disabled** (DREI unabhängige Signale: Opacity + Cursor/Feedback + `Semantics(enabled: false)`, nie Farbe allein) · **Loading** (Inline-Spinner, Höhe nie kollabieren) · **Error** (Farbe + Icon + Helper-Text) · **Success** (still > Jubel-Toast).

**Flutter `WidgetStateProperty`** deckt `hovered/focused/pressed/disabled/selected/dragged/scrolledUnder/error`. M3-Overlay-Defaults: Pressed 10 %, Hovered 8 %, Focused 10 % der Vordergrundfarbe.
```dart
WidgetStateProperty<Color?>.fromMap({
  WidgetState.pressed: fg.withOpacity(0.10),
  WidgetState.hovered: fg.withOpacity(0.08),
  WidgetState.focused: fg.withOpacity(0.10),
})
```
"Loading" = Konvention: `onPressed: null` (→ `WidgetState.disabled`) + Spinner im Button.

**Eingabefelder:** Höhe = Button-Höhe; Helper-/Error-Slot reserviert Höhe (kein Sprung); Focus-Ring per Overlay/`outline`.

**Loading: Skeletons > Spinner.** Spinner nur für kurze Modal-Waits (≤ 1,5 s); Skeletons für Content-Flächen (senken die *gefühlte* Wartezeit). Pakete: `skeletonizer` (auto aus echten Widgets — empfohlen) oder `shimmer`.

**Optimistisches UI:** lokalen State sofort updaten, dezenter Inline-Indikator, bei Server-Antwort reconciliieren/rollbacken. **Undo** statt Bestätigungsdialog.

**Nav/Footer:** kein AI-Fingerabdruck (§1). Mobile-Bottom-Nav: 4–5 Tabs, Custom-Icons (nicht generisch Material), markenfarbener Active-State, Haptik.

**Ehrliche Copy:** echte Metriken oder keine. Empty-States = handlungsleitende Einladung, nicht „Keine Daten". Fehler = konkrete Ursache + nächster Schritt.

---

## 11. Bild-/Mockup-Generierung (für App-Design-Bilder & Marketing)

Wenn Design-Bilder, Mockups oder Marketing-Visuals generiert werden:
- **Nie anfordern:** „purple gradient", „Inter font", „three feature cards", „glassmorphism", „floating blobs", generische Studio-Stock-Fotos.
- **Stattdessen spezifizieren:** die Makrostruktur (Bento / Stat-Led / Editorial), den Marken-Akzent als Hex (`#FC4C02` o. ä.), Dark-UI-Default, Fototreatment: **echte Basketball-Courts, echte Spieler, hartes Naturlicht, Beton/Asphalt-Textur**.
- Tonalität benennen (editorial-streetball), das eine merkbare Element festlegen, Tabellenziffern für Scores.
- Konsistenz mit den Tokens dieser Datei — gleiche Farben, gleiche Type-Logik, gleiches Spacing-Gefühl.

---

## 12. Pre-Ship-Selbstaudit (vor JEDER UI-Auslieferung)

Jede Frage beantworten. **Ein einziges „Ja" auf eine Slop-Frage → den Teil neu bauen.**

1. Display-Font = Inter/Roboto/Arial/system/Space-Grotesk, oder eine Font für alles? → fix.
2. Indigo/Lila/Blau-Verlauf, oder zaghafte Palette ohne dominante Farbe? → fix.
3. „Centered-Everything"-Hero? Genau drei Icon-Karten? → restrukturieren.
4. Jede Box gleicher Radius + identischer Schatten? → differenzieren.
5. ≥ 4 Font-Familien, oder > 1 konkurrierender Akzent-Hue? → kürzen.
6. Nav/Footer = generischer AI-Fingerabdruck? → an Inhalt anpassen.
7. Inputs springen bei Focus/Error? Disabled nur über Farbe? → States fixen.
8. Klickbarer Text bricht auf zwei Zeilen? Emoji als Feature-Icon? → fix.
9. Erfundene Metriken oder Floskeln? → ehrlich umschreiben.
10. Animation ohne Funktion? `disableAnimationsOf` nicht behandelt? → entfernen/absichern.
11. Body-Kontrast 4,5:1? Focus überall sichtbar? Touch-Target ≥ 44/48? → fix.
12. **Spiegeltest:** Neben 10 anderen AI-generierten Screens — als bewusst gestaltet erkennbar? Wenn nein → Slop. Tonalität härter ziehen.

**Optional Score 1–5** (Hallmark-Stil) auf: **Philosophy · Hierarchy · Execution · Specificity · Restraint · Variety**. Alles < 3 → überarbeiten.

---

## 13. Referenz-Design-Systeme (zum Lernen, nicht kopieren)

- **Strava** — eine Brandfarbe `#FC4C02`, Boathouse-Display + Inter nur für Ziffern, Icon-Größen 16/24/32/48, „You vs you"-Copy.
- **Nike Run Club** — Futura Bold Condensed („RUN."), schwarzer Grund, Neon-Grün für CTAs, Athleten-Fotografie in Cards.
- **WHOOP** — fast komplett schwarz, Daten poppen, Grün/Gelb/Rot-Recovery-System.
- **Peloton** — Woodsmoke + Pumice + Cardinal-Rot nur für Primäraktion.
- **AND1 / Streetball** — Schwarz + Orange, wide all-caps geometrische Letterforms, „gritty, unpolished".
- **Vercel** — 2-Farben-System + ein Grau-Ramp, Geist Sans/Mono, 96–128 px Padding, 8 %-Borders, Blueprint-Grid-Background.
- **Linear** — ultraminimal, sechs Button-Mikrostates, dichte Typo.
- **Stripe** — Söhne, Gradient-*Disziplin* (Inspiration, nicht kopieren).

---

## Caveats / Stand
- Hallmark-Zahlen (65 Gates / 22 Themes / 21 Makrostrukturen) sind versionsabhängig — Richtwert.
- OKLCH: in OKLCH entwerfen, als Hex ausliefern (Flutter hat keinen nativen OKLCH-Typ).
- `flutter_screenutil` ist umstritten; „meiden" reflektiert die Design-System-Ausrichtung dieses Projekts.
- Brandfarben/Typo-Angaben fremder Apps sind aus öffentlichen Quellen abgeleitet (direktional).

---

*Diese Datei ist die Source of Truth. Cursor-Rules und jede Generierung referenzieren `@baller-design-knowledge.md` — keine Werte erfinden.*
