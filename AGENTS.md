# AGENTS.md — Project Conventions

## File Size

- Keep files **small and focused**. Each file should handle a single responsibility.
- Aim for **under 80 lines** per file. If a file exceeds this, consider splitting it.

## Specificity

- Each file must have a **clear, singular purpose**.
- Avoid generic names. Use descriptive filenames that convey intent (e.g., `BatteryIndicator.qml` not `Widget1.qml`).

## Comments

- Add a **header comment** at the top of every file describing its purpose in 1-2 lines.
- Add **inline comments** on key lines: property declarations, functions, bindings, and non-obvious logic.
- Comments must be written in **English**.
- Use the format: `// Description of what this line/block does`

## Language

- **All code, comments, variable names, property names, and documentation must be in English.**
- No Spanish or other languages in any file.

## QML Conventions

- Use `pragma Singleton` for singleton components.
- Place each component in its correct module directory (`Commons/`, `services/`, `modules/`, `utils/`).
- Register new components in the corresponding `qmldir` file.
- Prefer `readonly property` for constants.
- Use descriptive `id` values that reflect the component's role.
- Use `RowLayout` with `Layout.alignment: Qt.AlignVCenter` instead of `Row` when children have different heights and need vertical centering.
- Use `implicitWidth`/`implicitHeight` instead of `width`/`height` for components.
- **All colors must come from `Color` singleton in Commons.** No hardcoded hex values in QML files.
- **Color palette: black, white, gray only.** No accent colors (blue, green, red). Use `#000000` for background, `#ffffff` for text, `#333333` for dividers, `#666666` for inactive, `#999999` for muted text.
- **No borders.** Popups and UI elements must not use `border.color` or `border.width`.
- **Nerd Font glyphs must use Unicode escapes** (e.g., `\uf028`) not raw characters.
- **Do not modify or move icons in Icons.qml.** The user has manually set specific glyphs. Never change them without explicit permission.
- **Always test before committing.** Run `quickshell -c ~/projects/shell` to verify no errors.

## Architecture

- **Commons/** — Shared singletons (Color, Style, Util, BarConfig, Config). Module: `qs.Commons`.
- **services/** — System integration singletons (battery, network, audio, time).
- **modules/** — UI feature modules organized by component (e.g., `bar/`).
- **utils/** — Shared helpers (paths, icons).
- **components/** — Reusable QML primitives (empty, for future use).
- **assets/** — Static resources (empty, for future use).
