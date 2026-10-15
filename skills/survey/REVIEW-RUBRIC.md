# Zero-Trust Code Review Rubric

Authoritative audit gates for the `/survey` adversarial reviewer subagent. Reference [`../greenfield-architecture/PILLARS.md`](../greenfield-architecture/PILLARS.md) for full architectural definitions.

Evaluate every change with zero self-preferential bias: verify every claim against the actual source files, callers, and test execution.

---

## Gate 1: Acceptance Criteria Parity (Spec-to-Code Disproof)
- **Check**: Does the code and test suite satisfy 100% of the acceptance criteria in the originating spec or issue?
- **Disproof Test**: Search for boundary conditions named or implied by the spec (empty inputs, null/optional fields, concurrent writes, upstream timeouts, unauthorized actors) that lack explicit handling and test assertions.
- **Veto Trigger (`BLOCKING_VETO`)**: Any acceptance criterion left unimplemented, stubbed/mocked in production code, or lacking a real test assertion at the cited `file:line`.

---

## Gate 2: The 8-Pillars Architectural Audit

Mark a pillar `N/A` only when the change genuinely does not touch that layer (e.g., Pillar 5 on a pure backend CLI job).

### 1. Entities & Types (Pillar 1)
- **Pass**: Strict domain types/schemas at boundaries; composite read queries for related entities.
- **Flag**: Unconstrained `any` / untyped dicts, unsafe casts (`as unknown as X`, non-null `!`), or stringly-typed status codes where domain enums/unions belong.

### 2. Invariants & Lifecycle (Pillar 2)
- **Pass**: State transitions, relational cascades, revision snapshots, and compliance audit logs execute atomically inside the domain repository/module.
- **Flag**: Routes or callers mutating storage directly and relying on manual follow-up calls to record audits or cascades.

### 3. External Boundaries & Gateways (Pillar 3)
- **Pass**: External APIs, SDKs, queues, and storage buckets sit behind a domain-native Anti-Corruption Gateway with timeouts/retries, PII scrubbing, and an in-memory test fake.
- **Flag**: Raw `fetch` / HTTP / third-party SDK calls or vendor payload types leaking into routes, views, or domain modules.

### 4. Authorization & Policy Guards (Pillar 4)
- **Pass**: Authentication, role permissions, and tenant scoping are enforced declaratively via fail-closed entry guards/middleware (`withRole()`, `requireTenant()`).
- **Flag**: Copy-pasted imperative role checks (`if (user.role !== 'admin')`) across handlers or unscoped multi-tenant queries.

### 5. Headless State & Presentation (Pillar 5)
- **Pass**: Complex UI/interaction state, validation, and optimistic updates live in headless hooks/models testable without a DOM; views stay declarative.
- **Flag**: Monolithic views (>300 lines), >3 raw state hooks in a view component, blocking browser `alert()`/`confirm()` calls, or forced page reloads.

### 6. Code Locality & Subsystem Barrels (Pillar 6)
- **Pass**: Single-consumer files live with their caller; shared subsystems expose a clean public facade/barrel (`index.ts` / package entrypoint) with zero circular dependencies.
- **Flag**: Single-route helpers dumped in global `components/` or `utils/`, or callers importing deep internal files across subsystems.

### 7. Projections & Performance (Pillar 7)
- **Pass**: High-traffic reads and aggregate metrics use unified projection queries and appropriate caching boundaries.
- **Flag**: N+1 queries inside loops, duplicate metric calculations across views, or unbounded list queries.

### 8. Anchor Quality Gates & Test Rigor (Pillar 8)
- **Pass**: Deterministic tests exercise the module's public interface across happy paths, edge cases, and failure/auth rejections with $\ge 85\%$ coverage on touched modules; zero direct storage imports in delivery routes.
- **Flag**: Tautological tests that only assert mock calls without testing behaviour, skipped/flaky tests, or failing typecheck/build steps.
