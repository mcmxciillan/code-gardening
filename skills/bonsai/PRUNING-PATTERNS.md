# Bonsai Pruning Taxonomy & Transformation Patterns

Authoritative reference for `/bonsai` scanners and pruning workers. Apply the **5 Pruning Shears** to remove ceremony, collapse shallow indirection, and delete dead weight while preserving 100% of observable behavior and the **8 Pillars** ([`../greenfield-architecture/PILLARS.md`](../greenfield-architecture/PILLARS.md)).

---

## Shear 1: Expression & Control-Flow Compression (The 12 → 3 Line Rule)

Target verbose imperative plumbing that expresses a simple transformation across a dozen lines.

### 1. Imperative Accumulator Loops → Declarative Pipelines
```typescript
// BEFORE (12 lines)
const activeEmails: string[] = [];
for (let i = 0; i < users.length; i++) {
  const user = users[i];
  if (user && user.isActive && user.email) {
    activeEmails.push(user.email.trim().toLowerCase());
  }
}
return activeEmails;

// AFTER (3 lines)
return users
  .filter((u): u is User & { email: string } => Boolean(u?.isActive && u?.email))
  .map((u) => u.email.trim().toLowerCase());
```

### 2. Nested `if/else` Pyramids → Flat Guard Clauses
```typescript
// BEFORE (14 lines)
async function cancelOrder(orderId: string, actor: Actor) {
  const order = await repo.findById(orderId);
  if (order) {
    if (order.ownerId === actor.id || actor.role === 'admin') {
      if (order.status === 'pending') {
        return await repo.updateStatus(orderId, 'cancelled');
      } else {
        throw new ConflictError('Only pending orders can be cancelled');
      }
    } else {
      throw new ForbiddenError('Not authorized');
    }
  } else {
    throw new NotFoundError('Order not found');
  }
}

// AFTER (6 lines)
async function cancelOrder(orderId: string, actor: Actor) {
  const order = await repo.findById(orderId);
  if (!order) throw new NotFoundError('Order not found');
  if (order.ownerId !== actor.id && actor.role !== 'admin') throw new ForbiddenError('Not authorized');
  if (order.status !== 'pending') throw new ConflictError('Only pending orders can be cancelled');
  return repo.updateStatus(orderId, 'cancelled');
}
```

### 3. Verbose `switch` / `if-else` Chains → Lookup Tables & Nullish Coalescing
```typescript
// BEFORE (12 lines)
function getRetryDelayMs(tier: string): number {
  switch (tier) {
    case 'realtime':
      return 100;
    case 'priority':
      return 500;
    case 'batch':
      return 5000;
    default:
      return 1000;
  }
}

// AFTER (2 lines)
const RETRY_DELAY_MS: Record<string, number> = { realtime: 100, priority: 500, batch: 5000 };
const getRetryDelayMs = (tier: string): number => RETRY_DELAY_MS[tier] ?? 1000;
```

### 4. Redundant Ceremony Elimination
- `if (condition) { return true; } else { return false; }` → `return Boolean(condition);`
- `const result = await doWork(); return result;` → `return doWork();` (outside `try/catch`)
- Manual property-by-property assignment → object destructuring / rest spread (`const { password, ...safeUser } = user;`)
- Verbose null checks (`x !== null && x !== undefined ? x.name : 'Guest'`) → `x?.name ?? 'Guest'`

---

## Shear 2: The Deletion Test — Collapsing Shallow Indirection (YAGNI)

Apply the **Deletion Test**: *If you delete this layer/wrapper, does complexity vanish (shallow pass-through), or does complexity reappear across N callers (deep module)?*

| Bloat Smell | Pruning Action |
| :--- | :--- |
| **Pass-Through Service / Helper** (`return this.repo.getById(id)`) | Delete the middleman function and invoke the deep module directly. |
| **Single-Caller Private Helper** | Inline the helper into its sole caller unless it isolates a complex algorithm. |
| **One-Adapter Interface / Abstract Factory** | When an interface or abstract class has only 1 implementation and is not an external gateway seam (Pillar 3), collapse it into the concrete module. |
| **Speculative Parameters & Option Bags** | Remove config flags, optional callbacks, and generic type parameters that have only 1 hardcoded value across all callers. |

---

## Shear 3: Deduplication & Seam Consolidation

| Bloat Smell | Pruning Action |
| :--- | :--- |
| **Copy-Pasted Route Auth / Validation / Try-Catch** | Collapse repeated 15-line handler ceremony into a single declarative guard (`withAuth()`, `withValidatedBody()`) so every route adapter drops under 15 lines. |
| **Near-Duplicate Clones** | Unify 2–5 functions that share >80% structure into one parameterized function. |
| **Synchronized Derived State (Pillar 5)** | Delete `useState` + `useEffect` pairs that mirror props or compute derived values; compute the derived value inline in 1 line (`const total = items.reduce(...)`). |
| **Repetitive Test Boilerplate** | Collapse copy-pasted test blocks testing the same seam with varying inputs into parameterized `test.each` / table-driven tests while retaining every assertion. |

---

## Shear 4: Dead Code, Zombie Branches & Orphan Purge

1. **Unreferenced Exports, Types & Files**: Verify zero callers across the codebase (including dynamic imports, framework route conventions, and scripts) and delete unused functions, types, barrel re-exports, and orphan files.
2. **Zombie Control Flow**: Remove unreachable statements after `return`/`throw`, branches guarded by constants, and retired feature flags.
3. **Commented-Out Code & Stale Boilerplate**: Delete commented-out implementations, auto-generated framework placeholder comments, and empty life-cycle hooks.

---

## Shear 5: Dependency Weight & Library Footprint Pruning (1MB Library → 10KB Capability)

Third-party dependencies are invisible code bloat: a 1-line `import` can silently drag **1MB+ of bundle/install weight** and dozens of transitive dependencies into the project when a **1–10KB reusable internal module** (or 1-line native API) does the job cleanly.

### 1. Audit Dependency Size vs. Actual Call-Site Usage
For every non-core dependency in `package.json` / `Cargo.toml` / `pyproject.toml` / `go.mod`:
1. **Measure Footprint**: Check unpacked size (`du -sh node_modules/<pkg>` or package `size`/`sideEffects` metadata), transitive dependency fan-out (`npm ls <pkg>`), and bundle weight.
2. **Count Imported Symbols**: Run `git grep "<pkg>"` to see how many functions/components the codebase actually uses.
3. **Apply the Footprint-to-Utility Threshold**:
   - **0 Callers**: Dead dependency—uninstall immediately.
   - **1–3 Narrow Call Sites on a Heavy Package (>100KB–1MB+)**: Replace with either a **native runtime primitive** or a **compact, zero-dependency internal deep module (<10KB / 20–100 lines)** and uninstall the library.

### 2. Heavy Library → Lean Custom Capability or Native API

| Bloated Dependency Pattern | Weight | Lean Replacement (0 KB Native or <10 KB Custom Module) |
| :--- | :--- | :--- |
| **`moment` / heavy date libraries** used only for formatting or relative time | ~300KB–4MB | Native `Intl.DateTimeFormat` + `Intl.RelativeTimeFormat` in a 20-line date helper (0 KB). |
| **`lodash` / `ramda` / `underscore`** imported for `debounce`, `groupBy`, `uniq`, `pick`, `cloneDeep` | ~500KB–1.4MB | Native `structuredClone`, `Object.groupBy`, `[...new Set()]`, or a 10-line typed `debounce` utility. |
| **`axios` + retry plugins** used for JSON REST calls | ~100KB+ | A 35-line (~2KB) internal `HttpClient` / Pillar 3 Gateway built on native `fetch` + `AbortSignal.timeout`. |
| **Massive Vendor SDKs** (e.g., 2MB+ CRM/Email/Webhook SDK used for 1–2 REST calls) | 1MB–15MB | A 40-line (~3KB) Pillar 3 **Anti-Corruption Gateway** calling the vendor's REST endpoint via native `fetch` with strict domain types. |
| **Heavy CSV / Query / State / Classname libraries** used for simple tabular export or string joining | 100KB–800KB | A reusable 25-line (<2KB) internal module with unit tests covering the exact project requirements. |
| **`uuid` / `nanoid` / `deep-equal` / `qs`** | 20KB–150KB | Native `crypto.randomUUID()`, `URLSearchParams`, or a 15-line structural equality check. |
| **Full Barrel Imports from UI/Icon Packs** (`import { Icon } from 'huge-icons'`) | 500KB+ bundle | Direct subpath imports or inline SVG symbols for the handful of icons actually rendered. |

---

## The 4 Bonsai Safety Guardrails

1. **Idiomatic Clarity Over Code Golf**: Write flat, typed, step-debuggable expressions (early-return guard clauses, lookup maps, `.filter().map()` pipelines) that are faster to read than the ceremony they replace. Avoid nested ternaries, cryptic bitwise tricks, or mutating `.reduce()` one-liners.
2. **Preserve Deep Architectural Seams**: Prune *inside* deep modules and *at* thin adapters while keeping every 5-Tier seam—Domain Repository (Pillar 2), Anti-Corruption Gateway (Pillar 3), Declarative Policy Guard (Pillar 4), and Headless State Model (Pillar 5)—intact behind its public interface.
3. **Characterization Anchor Before Pruning**: If a target function or replaced library seam lacks automated test coverage, write a concise characterization test first, observe `GREEN`, prune or swap the dependency for the lean capability, and verify `GREEN`.
4. **Hard Net-Negative Footprint Rule**: Every pruning unit must achieve either:
   - **Net-Negative Source LOC** (`lines deleted > lines added` in `git diff --numstat`), **OR**
   - **Massive Net Dependency Weight Reduction** (e.g., adding a 30-line / 2KB reusable internal capability that eliminates a 500KB–5MB external library and thousands of lockfile/transitive lines), with 100% passing tests and typechecks.
