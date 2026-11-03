# Human-Facing Visual HTML Dashboard Guide

Shared specification for generating self-contained visual HTML dashboards (`architecture-dashboard.html`, `deforestation-dashboard.html`, `bushog-dashboard.html`, `bonsai-dashboard.html`, `seed-catalog-dashboard.html`).

## 1. Plain-English Rule

Write every human-facing dashboard in clear, direct, plain English. Reserve technical identifiers solely for exact file paths, function names, and ticket IDs.

| Avoid Academic Jargon | Write Plain English Instead |
| :--- | :--- |
| "Leaky abstraction with direct persistence coupling" | "The web page talks directly to the database instead of using a dedicated data manager." |
| "Shotgun surgery across shallow adapters" | "Changes to one feature force edits across 5 different files instead of 1." |
| "Monolithic presentation component with entangled state dispatch" | "One 600-line screen handles layout, button clicks, data fetching, and error popups all at once." |
| "Enforce immutable provenance snapshots within transactional boundary" | "Automatically saves a revision history record whenever a post is updated so nothing is lost." |
| "Higher-order declarative policy interception" | "A single security check that blocks non-admin users before running actions." |
| "Anti-corruption gateway isolating vendor telemetry payload serialization" | "A dedicated integration helper that formats data for HubSpot/Stripe so external changes don't break our app." |

### Card Copy Structure
Structure every subsystem, refactoring seam, or defect card around three scannable prompts:
- **What is the problem?** (1–2 plain sentences explaining what breaks, hurts, or slows work down).
- **How are we fixing it?** (1–2 plain sentences explaining the clean replacement seam).
- **Why this helps:** (3–5 word bullets: e.g., *"Fix bugs in one place"*, *"Blocks unauthorized edits"*, *"Removes 400 lines of duplication"*).

---

## 2. Self-Contained HTML & Live Mermaid Rendering

Dashboards must open directly from disk (`open <path>.html`) with zero build step and render all Mermaid diagrams visually. Always include the Mermaid ESM script in the HTML `<head>` and wrap diagrams in `<pre class="mermaid">`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>[Project Name] — [Dashboard Title]</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <script type="module">
    import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';
    mermaid.initialize({ startOnLoad: true, theme: 'neutral', securityLevel: 'loose' });
  </script>
</head>
<body class="bg-slate-50 text-slate-900 p-8 max-w-7xl mx-auto space-y-8">
  <!-- Executive Summary Scorecard -->
  <!-- Plain-English Cards with <pre class="mermaid"> Before/After Diagrams -->
</body>
</html>
```

### Mermaid Syntax Safety in HTML
- Quote all node labels containing parentheses, slashes, or special characters: `A["Adapter (<30 lines)"] --> B["Deep Module"]`.
- Escape `<` and `>` inside `<pre class="mermaid">` only when needed, or use quoted labels without raw HTML tags.
- Open the file automatically once written:
  ```bash
  open "<dashboard-path>.html"
  ```
