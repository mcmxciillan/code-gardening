# The 8 Pillars of Greenfield Architecture & Deep-Module Design

*Derived from the empirical analysis of 25 comprehensive software architecture review cycles.*

When building software agentically, systems frequently decay into 20+ cycles of iterative refactoring when code is developed reactively—mixing storage logic, UI state, authorization checks, and external API payloads inside route handlers and monolithic views.

The **8 Pillars of Greenfield Architecture** provide a technology-agnostic foundation for designing and building software correctly from Day 1.

---

## 1. Domain Entities, Relationships & Cardinality (Pillar 1)
- **Law**: Model core domain entities, cardinalities (1:1, 1:N, N:M), and hierarchical relationships explicitly before writing code.
- **Smell**: Loose entity typing (`any`), ambiguous nullability, and ad-hoc relational queries inside loops.
- **Pattern**: Authoritative domain type definitions and composite read projections (`getCompositeDirectoryAggregate()`) that eliminate N+1 query loops.

---

## 2. Invariants, Compliance & Lifecycle Transitions (Pillar 2)
- **Law**: Business rules, compliance mandates (e.g., audit logging, immutable revision history, soft-deletion), and lifecycle transitions must be guaranteed by architecture, not developer discipline.
- **Smell**: Writing mutations in route handlers that rely on the developer remembering to manually call an audit log or create a revision record.
- **Pattern**: **Deep Domain Repositories** that automatically execute relational cascades, version snapshotting, and audit logging inside an atomic transactional boundary.

---

## 3. External Boundaries & Anti-Corruption Gateways (Pillar 3)
- **Law**: Never allow external vendor payload shapes, SDK exceptions, API tokens, or hardcoded integration IDs to leak into internal application code.
- **Smell**: Scattered `fetch()` calls with hardcoded form GUIDs or vendor SDK imports across UI pages and action handlers.
- **Pattern**: **Anti-Corruption Domain Gateways** (`HubSpotGateway`, `MediaStorageGateway`) that isolate third-party integrations, PII sanitization, retry policies, and mock fallback handlers behind clean domain-native interfaces.

---

## 4. Authorization, Actors & Declarative Policy Guards (Pillar 4)
- **Law**: Security and tenancy boundaries must be declarative, non-negotiable, and fail-closed.
- **Smell**: Copy-pasting imperative `if (user.role !== 'admin') return error;` blocks across dozens of server actions.
- **Pattern**: **Higher-Order Guard Wrappers** (`SessionGuard.withAdmin(action)`, `withRole()`) that automatically verify sessions, enforce permissions, and record security audit events before entering domain services.

---

## 5. Headless State Models & Pure Presentation Surfaces (Pillar 5)
- **Law**: State machines, dirty tracking, validation logic, and mutation dispatchers must be decoupled from visual presentation markup.
- **Smell**: Giant 600-line monolithic components mixing 20+ raw `useState` variables, browser-blocking `alert()` / `confirm()` dialogs, and raw `window.location.reload()`.
- **Pattern**: **Headless State Hooks / Models** (`useUserManagement`, `useSiteDataForm`) that manage state transitions with 100% testability, leaving UI components purely presentational.

---

## 6. Code Locality & Domain Subsystem Barrels (Pillar 6)
- **Law**: Code used by only one caller must live with that caller. Shared code must live in domain subsystems with explicit public barrel facades.
- **Smell**: Dumping single-route views into a global `components/` directory, or deeply importing internal files across nested dynamic paths.
- **Pattern**: **Route Client Locality** (co-locating route-specific client views in `app/<route>/`) and **Subsystem Barrels** (`components/layout/index.ts`, `components/editor/index.ts`).

---

## 7. Query Projections, Performance & Caching (Pillar 7)
- **Law**: High-traffic read paths must use unified projection pipelines to eliminate query fragmentation and metric calculation drift.
- **Smell**: Public pages and search widgets implementing independent calculation logic for platform statistics and follower counts.
- **Pattern**: Authoritative projection engines that compute statistics once and cache them at appropriate system boundaries (Edge, Memory, ISR).

---

## 8. Deterministic Anchor Truths & Quality Gates (Pillar 8)
- **Law**: Architectural invariants must be asserted by immutable automated test suites that run from Day 1.
- **Smell**: Relying on code reviews to catch leaked storage imports or missing auth guards.
- **Pattern**: **Anchor Truth Test Suites** that programmatically assert:
  - 100% Zero-Storage in delivery routes.
  - Zero circular dependencies.
  - Strict statement and branch coverage thresholds (≥85%).
  - Deterministic Red-to-Green regression reproduction.
