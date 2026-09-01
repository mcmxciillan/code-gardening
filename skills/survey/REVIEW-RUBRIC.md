# 0-Trust Code Review Rubric (8 Pillars of Greenfield Architecture)

As a Ruthless Adversarial Reviewer, evaluate every Pull Request against these non-negotiable architectural gates. Do NOT rubber-stamp code. Actively attempt to find edge-case failures, unhandled exceptions, and architectural erosion.

---

## Gate 1: Acceptance Criteria Fulfillment (Spec-to-Code Parity)
- **Check**: Did the implementation satisfy 100% of the bulleted acceptance criteria in the referenced spec or ticket?
- **Disproof Test**: Look for unhandled edge conditions explicitly mentioned in the spec (e.g., negative numbers, empty arrays, timeout errors, permission rejections).
- **Veto Trigger**: Any unfulfilled acceptance criterion or partial implementation marked as complete.

---

## Gate 2: The 8-Pillars Architectural Audit

### 1. Entities & Types (Pillar 1)
- Are types strict and expressive?
- **Flag**: Use of `any`, `unknown` without type guards, non-null assertions (`!`), or loose string primitives where domain enums/types are required.

### 2. Invariants & Compliance (Pillar 2)
- Are regulatory, audit, or revision invariants guaranteed?
- **Flag**: Any write operation that modifies records without triggering an audit log, revision snapshot, or necessary status transition within an atomic transaction.

### 3. External Boundaries & Anti-Corruption (Pillar 3)
- Are third-party vendor schemas, raw HTTP clients, or API tokens isolated?
- **Flag**: Raw `fetch()` or third-party SDK calls made directly in routes, UI components, or general services rather than behind an authoritative Gateway.

### 4. Authorization & Policy Gating (Pillar 4)
- Is security declarative and fail-closed?
- **Flag**: Imperative `if (user.role === 'admin')` checks copy-pasted across action handlers instead of using higher-order guard wrappers (e.g., `withAdmin()`).

### 5. Headless State & UI Decoupling (Pillar 5)
- Is client/presentation state cleanly separated from rendering markup?
- **Flag**: Monolithic components (>300 lines), components with >3 `useState` hooks, raw browser `alert()`/`confirm()` popups, or raw `window.location.reload()`.

### 6. Code Locality & Barrels (Pillar 6)
- Is code organized strictly by consumer scope?
- **Flag**: Route-specific client components stranded in global component folders, or shared subsystems lacking an authoritative `index.ts` barrel.

### 7. Projections & Performance (Pillar 7)
- Are data read paths optimized?
- **Flag**: N+1 database/storage queries inside loops, unindexed filters, or computing aggregate stats inside UI render loops.

### 8. Anchor Quality Gates & Test Rigor (Pillar 8)
- Are tests comprehensive, deterministic, and protective against regressions?
- **Flag**: Superficial tests that only test trivial mocks without asserting invariants, lack of negative test cases (error handling/auth failures), or test coverage <85%.
