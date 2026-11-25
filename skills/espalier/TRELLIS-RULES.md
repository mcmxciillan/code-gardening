# Espalier Trellis Rules & Minimal Feature Plan Template

Authoritative reference for `/espalier` when planning and implementing small, controlled feature additions on top of an existing codebase. Combines the **8 Pillars** ([`../greenfield-architecture/PILLARS.md`](../greenfield-architecture/PILLARS.md)) with the **5 Pruning Shears** ([`../bonsai/PRUNING-PATTERNS.md`](../bonsai/PRUNING-PATTERNS.md)).

---

## The 5 Espalier Laws (Trained Growth on Existing Rails)

Just as horticultural espalier trains a branch to grow flat along an existing trellis—maximizing fruit with minimal wood—every feature built with `/espalier` obeys five strict constraints:

### 1. Reuse Before Build (Extend Existing Seams First)
- Inspect existing domain repositories, policy guards, external gateways, and headless state models before creating any new file.
- Add a focused method or parameter to an existing deep module rather than creating a parallel helper or shallow pass-through wrapper (`Deletion Test`).
- Only create a new file when the feature introduces a genuinely distinct domain concept or single-route local view (Pillar 6).

### 2. Minimal Cross-Feature Access (Barrel-Only, Strictly Necessary)
- Access another feature's subsystem **only** when reusing its capability directly prevents duplicating business rules, data queries, or external integrations.
- Import exclusively from the other subsystem's **public facade/barrel** (`src/domains/<feature>/index.ts` or package entrypoint)—keeping internal files private and preventing circular imports.
- Keep cross-feature dependencies explicit and justified in the **Trellis Reuse Table** before writing code.

### 3. Minimal Code Budget (`12 → 3 Line` Discipline From Line 1)
- Write flat, idiomatic expressions on the first pass: early-return guard clauses, lookup maps, declarative pipelines (`.filter().map()`), optional chaining (`?.`), and nullish coalescing (`??`).
- Keep delivery adapters under **30 lines** and omit speculative generalization, unused options bags, or single-adapter interfaces (`YAGNI`).
- Target the smallest readable diff that satisfies 100% of the feature's acceptance criteria.

### 4. Zero-Bloat Dependency Gate (`0 KB` Native or `<10 KB` Custom)
- Solve new utility needs with existing project dependencies, native runtime primitives (`fetch`, `Intl`, `crypto.randomUUID`, `structuredClone`, `URLSearchParams`), or a compact `<10 KB` internal helper.
- Treat adding a new third-party package as a last resort requiring explicit justification in the Trellis Plan (never pull in a `1MB` library for a small feature).

### 5. Prune-as-You-Grow Diff Audit
- After tests turn `GREEN`, audit your own `git diff` against the **5 Pruning Shears** ([`../bonsai/PRUNING-PATTERNS.md`](../bonsai/PRUNING-PATTERNS.md)) before finishing—trimming any unnecessary local variables, verbose conditionals, or accidental duplication introduced during implementation.

---

## Trellis Plan Template (`~/private/tmp/{project-name}/espalier-plan.md`)

Keep the plan compact (1 page) and concrete:

```markdown
# Espalier Trellis Plan: [Small Feature Title]

## 1. Feature Goal & Acceptance Criteria
- **Goal**: [1–2 plain-English sentences describing the feature and user value]
- **AC-1**: Given [Precondition], When [Action], Then [Observable Result].
- **AC-2**: Given [Edge Case / Unauthorized Actor], When [Action], Then [Expected Error / Guardrail].

## 2. Existing Trellis Reuse & Cross-Feature Access Map
| Existing Seam / Public Barrel | Action (`Reuse` / `Extend`) | Why Accessed (Duplication Prevented) |
| :--- | :--- | :--- |
| `src/guards/session-guard.ts` | Reuse | Enforces existing role/tenant check without copy-pasting auth logic. |
| `src/domains/orders/index.ts` | Extend | Adds `applyPromoCode()` inside the existing transactional repository instead of creating a new service. |

## 3. Minimal Touch-List & Code Budget
| File Path | Action (`Edit` / `Create`) | Est. Net LOC | 5-Tier Seam Role |
| :--- | :--- | :--- | :--- |
| `src/domains/orders/order-repository.ts` | Edit | +25 lines | Deep Domain Module (Pillar 2) |
| `src/app/api/orders/promo/route.ts` | Create | +18 lines | Thin Delivery Adapter (<30 lines) |
| `src/domains/orders/order-repository.test.ts` | Edit | +35 lines | Deterministic Anchor Test (Pillar 8) |

- **New Dependencies Added**: `None` *(using native runtime APIs / existing seams)*
- **Cross-Feature Coupling**: `1` public barrel import (`SessionGuard`), `0` internal imports, `0` circular deps.
```
