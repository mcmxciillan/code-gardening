# Seed Catalog Documentation & Vocabulary Standards

Authoritative reference for `/seed-catalog` when extracting a project's shared vocabulary (`GLOSSARY.md`) and creating or updating core documentation (`README.md`, `AGENTS.md` / `CLAUDE.md`, `docs/`).

---

## 1. Shared Vocabulary Standard (`GLOSSARY.md`)

A project's vocabulary fails when humans and agents use 4 different words for the same concept (e.g., *Account*, *Tenant*, *Workspace*, *Organization*) or call every file a generic *"component"* or *"service"*.

`GLOSSARY.md` establishes a **single canonical language** across three sections:

### Section A: Domain Ubiquitous Language
Define every core domain concept specific to the project. Keep definitions to 1–2 tight sentences stating *what the concept is* and list retired synonyms under `_Avoid_`:

```markdown
# Project Glossary & Shared Vocabulary

Canonical language for humans and AI agents working in this repository. Use the bolded canonical terms in code, specs, prompts, and docs; retire the listed `_Avoid_` synonyms.

## 1. Domain Concepts

**Workspace**:
A billable organization boundary that owns Projects, Members, and Subscriptions. All tenant-scoped queries filter by `workspaceId`.
- _Canonical Type / Schema_: `src/domains/workspace/types.ts` (`Workspace`)
- _Avoid_: Tenant, Account, Organization, Company, Client

**Member**:
An authenticated user's role-bound membership inside a specific Workspace (`owner | admin | editor | viewer`).
- _Canonical Type / Schema_: `src/domains/workspace/types.ts` (`WorkspaceMember`)
- _Avoid_: Collaborator, Seat, AccountUser
```

### Section B: Deep Module, Subsystem & Seam Catalog (5-Tier Seam Taxonomy)
Anchor architectural language in the deep-module vocabulary (**Module**, **Interface**, **Implementation**, **Seam**, **Adapter**, **Depth**, **Leverage**, **Locality**) and the **5-Tier Seam Roles** ([`../greenfield-architecture/PILLARS.md`](../greenfield-architecture/PILLARS.md)). Replace vague references to *"the auth service"* or *"the user component"* with each module's canonical name, 5-Tier Seam Role, and public interface:

| Canonical Module Name | 5-Tier Seam Role | Public Interface / Barrel | Responsibility & Invariants | _Avoid_ Calling It |
| :--- | :--- | :--- | :--- | :--- |
| **`WorkspaceRepository`** | Deep Domain Module (Pillar 2) | `src/domains/workspace/index.ts` | Atomic workspace creation, member role mutations, and audit trail snapshots. | "Workspace service", "Org DB helper", "Tenant manager" |
| **`StripeBillingGateway`** | Anti-Corruption Gateway (Pillar 3) | `src/gateways/billing/index.ts` | Translates Stripe webhook/SDK payloads into domain `SubscriptionState`; provides `InMemoryBillingGateway` for tests. | "Stripe helper", "Payment util", "Billing API" |
| **`SessionGuard`** | Declarative Policy Guard (Pillar 4) | `src/guards/session-guard.ts` | Fail-closed authentication and `withWorkspaceRole()` wrapper for routes and actions. | "Auth middleware", "Permission check" |
| **`useMemberInviteFlow`** | Headless State Model (Pillar 5) | `src/domains/workspace/use-member-invite.ts` | State machine, validation, and optimistic updates for inviting members without DOM coupling. | "Invite modal state", "Invite hook" |

### Section C: Semantic Rename Recommendations (Functions, Classes & Files)
A shared vocabulary is only as strong as the identifiers in the codebase. Flag vague, generic, or drifted file, class, and function names and propose high-clarity canonical replacements aligned with `GLOSSARY.md` and the **5-Tier Seam Taxonomy**:

#### Naming Smells to Flag
1. **Grab-Bag Files & Classes**: `utils.ts`, `helpers.ts`, `common.ts`, `manager.ts`, `handler.ts`, `data.ts`, `misc.ts`.
2. **Vague Verb Functions**: `processData()`, `handleSubmit()`, `doUpdate()`, `checkUser()`, `getInfo()`, `execute()`—functions whose name conceals what domain entity changes or what invariant is enforced.
3. **Synonym-Drifted Identifiers**: Identifiers still named after a banned `_Avoid_` synonym (e.g., `fetchClientAccount()` when the canonical domain term is `Workspace`).
4. **Mislabeled Seam Roles**:
   - Pillar 2 Repository called `UserManager` or `DbService` $\rightarrow$ rename to `<Entity>Repository` (e.g., `WorkspaceRepository`).
   - Pillar 3 External Integration called `stripeHelper` or `crmApi` $\rightarrow$ rename to `<Vendor><Domain>Gateway` (e.g., `StripeBillingGateway`).
   - Pillar 4 Policy Guard called `checkAdmin` $\rightarrow$ rename to `SessionGuard.withRole('admin')` or `requireWorkspaceAdmin`.
   - Pillar 5 Headless State Model called `useFormStuff` $\rightarrow$ rename to `use<Domain><Workflow>Model` (e.g., `useMemberInviteModel`).

#### Semantic Rename Table Format
Include a scannable rename proposal table in `GLOSSARY.md` (under `## 3. Semantic Rename Catalog`) and in `seed-catalog-dashboard.html`:

| Kind | Current Name (`file:line`) | Suggested Canonical Name | Aligned Term / Seam | Plain-English Rationale | Call Sites |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **File** | `src/utils/org-helper.ts` | `src/domains/workspace/workspace-repository.ts` | `Workspace` (Pillar 2) | Replaces generic "org-helper" grab-bag with the canonical `Workspace` domain repository. | 8 imports |
| **Class** | `ClientPaymentService` (`src/billing/service.ts:12`) | `StripeBillingGateway` | `Subscription` (Pillar 3) | Clarifies that this class is an external Stripe Anti-Corruption Gateway, not a domain repository. | 4 callers |
| **Function** | `processItem(d)` (`src/orders/index.ts:44`) | `publishValidatedOrder(order, actor)` | `Order` (Pillar 2) | States the exact lifecycle transition (`publish`) and invariant (`ValidatedOrder`) instead of vague `processItem`. | 3 callers |

---

## 2. Core Documentation Hierarchy & Anti-Sediment Rules

Every documentation file must earn its token and maintenance cost by serving a distinct audience without duplicating volatile environment details:

| File | Primary Audience | Required Contents | What to Prune (Anti-Sediment) |
| :--- | :--- | :--- | :--- |
| **`GLOSSARY.md`** | Humans & Agents | Domain Ubiquitous Language + Subsystem & Seam Catalog + `_Avoid_` synonym bans. | Implementation algorithms, temporary TODOs, generic programming terms. |
| **`README.md`** | Humans & Onboarding Devs | 1. Plain-English project purpose.<br>2. Mermaid 5-Tier architecture & data-flow diagram.<br>3. Subsystem directory map linked to `GLOSSARY.md` names.<br>4. Verified setup, test, and build commands. | Outdated badges, stale directory trees pointing to deleted folders, walls of unformatted prose. |
| **`AGENTS.md` / `CLAUDE.md`** | AI Coding Agents (Always Loaded) | 1. Context pointer to `GLOSSARY.md` and `docs/`.<br>2. Non-negotiable 8-Pillar seam rules & unwritten gotchas.<br>3. Exact verification command (`npm test`, etc.). | Anything the agent already does by default (**no-ops**) or can discover from a 1-file lookup. Keep under 80 lines. |
| **`docs/ARCHITECTURE.md`** *(Optional, for large repos)* | Deep Reference (Disclosed) | Entity relationship diagrams (Pillar 1), transaction/audit flows (Pillar 2), gateway contracts (Pillar 3), and caching/projection topology (Pillar 7). | Copy-pasting raw source files that will immediately drift from code. |

---

## 3. Documentation Verification Gates

Before `/seed-catalog` completes, verify three deterministic truths:
1. **Zero Broken Links or Phantom Paths**: Every file path, directory, barrel export, and script command referenced in `GLOSSARY.md`, `README.md`, `AGENTS.md`, or `docs/` must exist on disk (`test -e <path>`) and match `package.json` / build manifests.
2. **Zero Vocabulary Drift**: Core documentation must use the canonical terms from `GLOSSARY.md` consistently and purge occurrences of banned `_Avoid_` synonyms.
3. **Plain-English Clarity**: Human-facing sections and `seed-catalog-dashboard.html` must explain what each subsystem does in direct, plain English ([`../greenfield-architecture/DASHBOARD-STYLE.md`](../greenfield-architecture/DASHBOARD-STYLE.md)).
