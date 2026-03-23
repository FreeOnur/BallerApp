# Stitch UI design → BallerApp Flutter



## Role



Stitch-Designs **importieren** (visuell/technisch erfassen) und in BallerApp **1:1** als Flutter umsetzen — mit **getrennten Komponenten** und bestehender Architektur (siehe unten).



## When to use this skill



Use when the user mentions **Stitch**, **Stitch export**, **1:1**, **import/export**, **HTML/CSS from Stitch**, **Tailwind from Stitch**, or **umsetzen** / **nachcoden** nach einem Stitch-Screen.



## Expertise



- **Stitch:** UI-Varianten, Screens, typisch Export als **HTML/CSS** (z. B. Tailwind), optional **Figma**-Handoff. **Flutter-Export** von Stitch nutzen, **sobald verfügbar**; sonst Nachbau in Widgets.

- **BallerApp:** Struktur und Trennung wie in **`.cursor/skills/flutter_architect.md`** und **`.cursor/rules/03_page_rules.md`** (Pages = leicht, nur UI; Logik in Services; Models datenrein).



## Workflow



### 1. Import



1. **Flutter/Dart-Export** aus Stitch (oder verbundenen Tools) — wenn vorhanden: einbinden und an Theme/Projektstruktur anpassen.
If the user moved the design to **Figma**, use Figma MCP **only** to pull specs or assets when available; **implementation remains Flutter** following the same token and layout mapping as above.
2. Sonst: **Screenshot** oder **Video** als visuelle Wahrheit + optional **HTML/CSS-Export** zum Ablesen von Maßen, Farben, Schrift, Radii, Flex/Grid-Struktur.

3. Ablegen unter z. B. **`docs/design/stitch/<feature>/`** wenn der Nutzer feste Ablage will.



### 2. 1:1 interpretieren



- **Layout & Hierarchie:** Spalten/Zeilen, Karten, Listen, AppBar — wie in Stitch.

- **Scroll:** Welche Bereiche sind **fix**, was **scrollt** (z. B. `CustomScrollView`, `SliverAppBar`, `ListView` + `Column`) — dem Stitch-Screen entsprechen.

- **Tokens:** Farben, Typo, Abstände, Radii — in **`lib/theme/`** oder bestehende Konstanten; keine willkürlichen Einzel-`Color(...)` ohne Sinn.

- **Komponenten:** Jede klar erkennbare UI-Einheit (Button-Leiste, Karte, Listenzeile, Formfeld-Gruppe) → **eigenes Widget** in `lib/widgets/` oder klar benannte private Widget-Klasse in derselben Datei nur wenn wirklich screen-spezifisch und klein — **kein** „Gott-Widget“ für den ganzen Screen.



### 3. Umsetzen (Nachcoden)



- **Page** in `lib/pages/`: komponiert nur aus Widgets und übergibt Daten/Callbacks.

- **Wiederverwendbare Teile** in `lib/widgets/` mit sauberen Parametern.

- **Logik:** Services (`.cursor/rules/03_page_rules.md`); keine Supabase-/API-Aufrufe aus dem Stitch-Layout-Code heraus.

- **HTML/CSS:** nicht als Laufzeit-UI einchecken; daraus **Flutter-Widgets bauen** für 1:1-Ergebnis. WebView nur auf **expliziten** Nutzerwunsch.



### 4. Figma-Zwischenstufe



Specs/Assets per Figma MCP wenn aktiv; Ziel bleibt **Flutter 1:1** zu Stitch/Figma.



### 5. Fertig, wenn



- Screen wirkt **wie Stitch** (1:1), inkl. Scroll und grober Pixel-Treue.

- Komponenten **getrennt** und mit **flutter_architect** / **03_page_rules** vereinbar.

- Abweichungen kurz genannt.



## Anti-patterns



- Ganzen Screen in einem unlesbaren `build` ohne extrahierte Widgets.

- Business-Logik in der Page statt im Service.

- Standardmäßig WebView statt Flutter-Widgets für 1:1-UI.



## Weitere Regeln



Für alles, was hier nicht wiederholt wird (Page-Pattern, Services, Models): **`.cursor/rules/03_page_rules.md`**, **`.cursor/skills/flutter_architect.md`**, **`.cursor/rules/02_flutter_rules.md`** bei Bedarf.


