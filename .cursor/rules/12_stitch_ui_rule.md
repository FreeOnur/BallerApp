# Stitch (Google Labs UI) — rule

When the user references **Stitch**, **Stitch exports**, or **designs from stitch.withgoogle.com**:

1. **Default: von Stitch abschauen und 1:1 in Flutter umsetzen.** Layout, Abstände, Typo, Farben, Komponenten-Hierarchie und **Scroll-Verhalten** (z. B. was fix bleibt vs. mitscrollt) sollen dem Stitch-Screen entsprechen, soweit Flutter und die App-Architektur das zulassen.

2. **Import / Export:** Wenn Stitch oder ein verknüpftes Tool einen **direkten Flutter-/Dart-Export oder Import** anbietet, diesen **bevorzugen** und ins Repo sauber einbinden (Assets, `pubspec.yaml`, Anpassung an `lib/theme/`). Fehlt so ein Weg, bleibt der Weg **1:1 manuell in Dart/Widgets** nachbauen. Kein `WebView` für ganze Screens als Standardlösung; nur wenn der Nutzer das ausdrücklich will oder es der einzig vereinbarte Importweg ist.

3. **Design einholen:** Screenshots, Stitch-Export (HTML/CSS nur als **Maßstab** für Maße und Styles beim Nachbauen), Kurzbeschreibung, oder Dateien unter z. B. `docs/design/stitch/`. Bei großen Screens ohne Referenz: kurz nachfragen.

4. **Komponenten strikt trennen** — wie bereits projektweit: kleine, wiederverwendbare Bausteine in `lib/widgets/`, Screens in `lib/pages/`, **keine** monolithischen „alles-in-einem“-Widgets. Details und Schichten: **`.cursor/rules/03_page_rules.md`** und **`.cursor/skills/flutter_architect.md`** (UI vs. Services, keine API-Logik in Pages).

5. **Thema & Assets:** Farben/Typo über `lib/theme/` bündeln; Bilder/Icons nach `assets/` mit `pubspec.yaml`. Abweichungen von Stitch nur mit kurzer Begründung (Plattform, Accessibility, Performance).

6. **Figma:** Wenn Stitch → Figma, Figma MCP nutzen wenn eingerichtet; Umsetzung bleibt Flutter, weiterhin **1:1** anstreben.
