# The 8 Pillars of Greenfield Architecture

Authoritative reference for designing, refactoring, and auditing deep modules across the Code Gardening suite.

## The 5-Tier Deep Seam Architecture

```
[1. Thin Delivery Adapter (<30 lines: Route / Controller / CLI / Action)]
       │
       ▼
[2. Declarative Policy Guard (Fail-closed auth, role & tenancy wrapper)]
       │
       ▼
[3. Deep Domain Module / Repository (Invariants, validation, atomic transactions)]
       ├──► [4. Anti-Corruption Gateway (Vendor SDK isolation, retries, PII masking, test fake)]
       └──► [5. Headless State Model (Pure UI/interaction state machine, zero DOM/alert side effects)]
```

---

## Pillar 1: Domain Entities, Relationships & Cardinality
- **Rule**: Define explicit domain entities, value objects, cardinalities (`1:1`, `1:N`, `N:M`), and nullability states at the domain boundary.
- **Deep Pattern**: Authoritative domain types/schemas and composite read aggregates (`getCompositeDirectoryAggregate()`) that load related entities in a single query.
- **Violation Smells**: Unconstrained `any` / `dict` / `interface{}` payloads, unchecked nullability assertions (`!`), stringly-typed status fields, or N+1 query loops over child relations.

## Pillar 2: Invariants, Compliance & Lifecycle Transitions
- **Rule**: Business rules, state machine transitions (`draft -> pending_review -> published -> archived`), audit logs, revision snapshots, and soft-delete rules live inside deep domain repositories—enforced automatically inside atomic transactions.
- **Deep Pattern**: A single domain method (`repository.publish(id, actor)`) that validates state transitions, mutates the record, writes the revision snapshot, and records the compliance audit event inside one transaction.
- **Violation Smells**: Route handlers or controllers performing raw storage writes and relying on caller discipline to also call `auditLog.write()` or `revisions.create()`.

## Pillar 3: External Boundaries & Anti-Corruption Gateways
- **Rule**: Isolate every third-party API, external SDK, message bus, or object store behind a domain-native Gateway interface with deterministic test fakes.
- **Deep Pattern**: Dedicated gateway modules (`BillingGateway`, `CrmGateway`, `MediaStorageGateway`) that translate vendor payloads into domain types, enforce timeouts/retries, scrub PII/secrets from logs, and provide an in-memory fake for tests.
- **Violation Smells**: Raw `fetch()` / `axios` / vendor SDK calls inside routes, UI components, or domain services; leaked vendor error shapes or hardcoded external IDs/GUIDs.

## Pillar 4: Authorization, Actors & Declarative Policy Guards
- **Rule**: Enforce authentication, role permissions, and multi-tenant isolation declaratively at the entry boundary; fail closed before domain execution begins.
- **Deep Pattern**: Higher-order guard wrappers or middleware (`withRole('admin', handler)`, `SessionGuard.requireTenant(ctx)`) that resolve the verified `ActorContext`, reject unauthorized callers with typed error envelopes, and log security events.
- **Violation Smells**: Copy-pasted imperative checks (`if (user.role !== 'admin') return 403`) scattered across endpoints or missing tenant scoping on queries.

## Pillar 5: Headless State Models & Pure Presentation
- **Rule**: Separate state machines, form validation, dirty tracking, and optimistic mutation logic from presentation views/templates.
- **Deep Pattern**: Headless state hooks, controllers, or view-models (`useSiteDataForm`, `OrderWizardModel`) testable without rendering a browser DOM or terminal UI, paired with declarative presentation components.
- **Violation Smells**: Monolithic views (>300 lines) tangling layout markup with >3 raw state variables, inline data fetching, blocking `alert()`/`confirm()` dialogs, or forced page reloads (`window.location.reload()`).

## Pillar 6: Code Locality & Subsystem Barrels
- **Rule**: Place code used by a single caller alongside that caller; group shared capabilities into cohesive domain subsystems exposing a single public facade/barrel.
- **Deep Pattern**: Route-local views/helpers co-located inside their route folder, and shared subsystems (`src/domains/billing/index.ts`, `pkg/billing`) exporting only their public interface while hiding internal helpers.
- **Violation Smells**: Single-consumer components dumped into a global `components/` or `utils/` grab-bag, circular imports between subsystems, or callers reaching deep into another subsystem's internal files.

## Pillar 7: Query Projections, Performance & Caching
- **Rule**: Route high-traffic reads and summary metrics through unified projection pipelines with explicit caching boundaries.
- **Deep Pattern**: Single-source projection queries that compute rollups/statistics once at the storage or cache boundary (Edge, Redis, in-memory, or materialized view).
- **Violation Smells**: Multiple pages or widgets independently recalculating the same aggregate metrics in application memory, or unbounded queries missing pagination/indexes.

## Pillar 8: Deterministic Anchor Truths & Quality Gates
- **Rule**: Lock architectural invariants with fast, deterministic automated tests that fail (`RED`) when an invariant or regression occurs and pass (`GREEN`) when resolved.
- **Deep Pattern**: Anchor test suites asserting:
  1. **Zero-Storage Delivery**: Delivery routes/views import domain modules/facades, never raw database clients or ORM models.
  2. **Acyclic Dependencies**: Zero circular imports across domain subsystems.
  3. **Invariant & Edge Coverage**: Statement and branch coverage $\ge 85\%$ exercising happy paths, boundary conditions, and authorization rejections through the module's public interface.
