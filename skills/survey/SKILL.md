---
name: survey
description: Spec-traceable PR compilation and zero-trust adversarial code review. Use when preparing a pull request, auditing completed work before merge, or running /survey.
---

# Survey (`/survey`)

Compile completed engineering work into a traceable Pull Request and subject the changes to an **independent, zero-trust Adversarial Reviewer subagent** before publishing or merging.

```mermaid
graph TD
    Work["Completed Commits / Working Tree"] --> PRGen["Phase 1: Compile PR from PR-TEMPLATE.md"]
    PRGen --> Spawn["Phase 2: Dispatch Independent 0-Trust Reviewer Subagent"]
    Spawn --> Audit["Inspect Diff + Callers, Audit 8 Pillars & Verify Tests"]
    Audit --> Verdict{"Verdict"}
    Verdict -->|"REQUEST_CHANGES / VETO (<= 3 rounds)"| Fix["Author Fixes Findings & Re-Runs Tests"]
    Fix --> Spawn
    Verdict -->|APPROVED| Publish["Phase 3: Publish Verified PR"]
```

---

## Phase 1: Pull Request Compilation & Traceability

1. **Inspect Changes & Originating Specs**:
   - Determine the base ref (`BASE_REF`, e.g., `main` or merge-base) and inspect `git status` and `git diff ${BASE_REF}...HEAD --stat`.
   - Locate all originating specifications (`docs/specs/SPEC-*.md`), user stories (`US-*`), or issue tickets.
2. **Draft the Pull Request**:
   - Populate [`PR-TEMPLATE.md`](PR-TEMPLATE.md) and save the draft to `~/private/tmp/{project-name}/PR-DRAFT.md`:
     - **Conventional Title**: e.g., `feat(content): encapsulate audit cascades in CommentaryRepository`.
     - **Before / After Mermaid Diagram**: Contrasting prior coupling with the new deep seam.
     - **Acceptance Criteria Matrix**: Map every bulleted requirement from the spec/ticket to the exact `file:line` test assertion that proves it.
     - **Test Runner Output**: Run the test suite and record the real output and coverage metrics.

---

## Phase 2: Independent Zero-Trust Adversarial Review

Delegate the code audit to an isolated subagent (`invoke_subagent`) so the author context never grades its own work. Pass file paths and git refs rather than pasting large diffs inline:

```text
You are an independent, zero-trust Principal Architect performing an adversarial review for /survey.

YOUR MANDATE:
Actively attempt to DISPROVE that the candidate changes satisfy the specification and the 8 Pillars of Greenfield Architecture. Identify unverified claims, missing edge cases, leaky seams, and shallow tests.

INPUTS:
1. Review Rubric: Read `~/.gemini/config/skills/survey/REVIEW-RUBRIC.md`.
2. Originating Spec / Ticket: `[Path to spec, issue file, or acceptance criteria]`
3. Draft PR & AC Matrix: `~/private/tmp/{project-name}/PR-DRAFT.md`
4. Git Range to Inspect: Run `git diff <BASE_REF>...HEAD` (or inspect uncommitted changes via `git diff HEAD`).

AUDIT STEPS:
1. Read the originating spec and verify every Acceptance Criterion in `PR-DRAFT.md` against the actual implementation and test files at the cited lines.
2. Inspect the modified files AND their surrounding callers to check all 8 Pillars in `REVIEW-RUBRIC.md`.
3. Execute the relevant test suite to confirm tests genuinely pass and fail when invariants are violated.

REQUIRED OUTPUT FORMAT:
- **Verdict**: `APPROVED` | `REQUEST_CHANGES` | `BLOCKING_VETO`
- **Acceptance Criteria Audit**: Table showing each AC, `PASS`/`FAIL`, and `file:line` evidence.
- **8-Pillars Scorecard**: Pass/Fail per applicable pillar with exact `file:line` citations.
- **Findings**: Grouped under `[BLOCKER]`, `[MAJOR SMELL]`, or `[MINOR]` with concrete remediation instructions.
```

---

## Phase 3: Remediation Loop & Publication

Evaluate the reviewer subagent's verdict (maximum **3 review rounds**):

1. **On `REQUEST_CHANGES` or `BLOCKING_VETO`**:
   - Resolve every `[BLOCKER]` and `[MAJOR SMELL]` at the deep module seam and add regression tests for any uncovered edge cases.
   - Update `PR-DRAFT.md` with the new test evidence and re-dispatch the reviewer subagent.
   - If a finding remains disputed after 3 rounds due to an external constraint or spec conflict, surface the trade-off to the human for adjudication.
2. **On `APPROVED`**:
   - Append the verified **0-Trust Review Scorecard** summary to `PR-DRAFT.md`.
   - Create or update the remote GitHub Pull Request (`gh pr create` / `gh pr edit` or GitHub MCP) when a remote repository is configured, and present the final PR summary to the user.
