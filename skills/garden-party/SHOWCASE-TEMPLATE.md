# Garden Party Progressive-Depth HTML Showcase Guide

Authoritative reference for `/garden-party` when compiling `garden-party-showcase.html`. Build on the base HTML & Mermaid conventions in [`../greenfield-architecture/DASHBOARD-STYLE.md`](../greenfield-architecture/DASHBOARD-STYLE.md) while structuring the page as a **4-Tier Progressive Altitude Scroll**—where the top third speaks to business executives with zero technical jargon, and each scroll tier progressively reveals deeper architectural diagrams and function-level `Input → Processing → Output` data flows.

---

## 1. The 4-Tier Progressive Altitude Scroll

Design the single-page HTML document so every reader finds their natural stopping depth:

| Scroll Depth | Tier Name & Metaphor | Target Audience | Required Content & Visuals | Jargon & Code Density |
| :--- | :--- | :--- | :--- | :--- |
| **Top 1/3 (`0%–30%`)** | **Tier 1: The Lawn**<br>*(Executive & Business Overview)* | Executives, Clients, Sales, Non-Technical Stakeholders | - Plain-English mission statement (what the product does & why it matters).<br>- 4 Business Value & Trust KPI cards (Capabilities, Security, Integrations, Reliability).<br>- High-level Ecosystem Mermaid diagram (*Actors → Product → External Partners*). | **0% Code**. Pure business outcomes and plain English. |
| **Upper-Mid (`30%–55%`)** | **Tier 2: The Garden Pathways**<br>*(Business Capabilities & Journeys)* | Product Managers, Operations, Domain Experts | - Core Capability Cards structured as **Trigger → Automated Rules & Safeguards → Business Outcome**.<br>- Step-by-step plain-English user journey Mermaid flowcharts. | **Low Technicality**. Domain terms from `GLOSSARY.md` (if present); zero file paths or syntax. |
| **Lower-Mid (`55%–80%`)** | **Tier 3: The Greenhouse**<br>*(System Architecture & 5-Tier Seams)* | Technical Product Leads, Architects, Engineering Managers | - 5-Tier Deep Seam Architecture Mermaid diagram (Delivery Adapters, Policy Guards, Domain Modules, Anti-Corruption Gateways, Headless State Models).<br>- Subsystem Ownership Matrix mapping each module to its business rules, data store, and external APIs. | **Medium Technicality**. Subsystem names, directory barrels, and 8-Pillar seam roles. |
| **Bottom 1/3 (`80%–100%`)** | **Tier 4: The Root System**<br>*(Function-Level Data Flow: Input → Processing → Output)* | Software Engineers, Staff Architects, Technical Auditors | - End-to-end **Input → Processing → Output** pipeline traces for every critical workflow.<br>- Function-level Mermaid `sequenceDiagram`s and `flowchart LR` data-transformation graphs.<br>- Exact `file:line` function signatures, payload shapes, transaction cascades, and collapsible `<details>` code inspection blocks. | **100% Engineering Depth**. Exact function names, `file:line` links, types, and invariants. |

---

## 2. Tier 4 Function-Level Data Flow Standard (`Input → Processing → Output`)

Every critical workflow in **Tier 4 (The Root System)** must trace how real data moves through specific functions in the codebase using three structured columns plus a function-level Mermaid sequence/flow diagram:

1. **📥 Input (Entry Seam & Validation)**:
   - **Entry Function & File**: Exact route, controller, CLI command, event listener, or UI state trigger (`e.g., POST /api/orders -> createOrderHandler in src/app/api/orders/route.ts:14`).
   - **Incoming Payload Shape**: Domain type/schema name and key fields (`CreateOrderInput: { workspaceId, items[], idempotencyKey }`).
   - **Policy Guard & Preconditions**: Auth/tenancy wrapper (`SessionGuard.withWorkspaceRole('member')`) and input validation rules that run before domain logic.
2. **⚙️ Processing (Deep Module Execution & Invariants)**:
   - **Core Domain Functions**: Exact repository or domain module methods called in sequence (`OrderRepository.placeOrder(input, actor)` in `src/domains/orders/order-repository.ts:48`).
   - **Data Transformations & Business Rules**: How the input is normalized, priced, or validated, and which state machine transitions occur (`draft -> confirmed`).
   - **Atomic Transactions & External Gateways**: Database writes, audit/revision cascades (Pillar 2), and outbound Anti-Corruption Gateway calls (`StripeBillingGateway.authorizeCharge()` in `src/gateways/stripe/index.ts:31`).
3. **📤 Output (Return Envelope, Side Effects & Error Modes)**:
   - **Returned Data Shape**: Exact output DTO or state update returned to the caller (`OrderReceipt { orderId, status: 'confirmed', totalCents }`).
   - **Persisted & Emitted Side Effects**: Rows committed, audit log entries recorded, cache invalidations (Pillar 7), or domain events dispatched.
   - **Typed Failure Envelopes**: Exact error types returned when guards, invariants, or gateways reject (`ForbiddenError`, `InsufficientInventoryError`, `PaymentGatewayTimeoutError`).

---

## 3. Self-Contained HTML Shell & Sticky Altitude Bar

Use this self-contained HTML structure (Tailwind CSS + Mermaid v11 ESM) so `open garden-party-showcase.html` works immediately in any browser with zero build step:

```html
<!DOCTYPE html>
<html lang="en" class="scroll-smooth">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>[Project Name] — Garden Party Codebase Showcase</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <script type="module">
    import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';
    mermaid.initialize({ startOnLoad: true, theme: 'neutral', securityLevel: 'loose' });
  </script>
</head>
<body class="bg-slate-50 text-slate-900 antialiased">
  <!-- Sticky Progressive-Depth Navigation Bar -->
  <nav class="sticky top-0 z-50 bg-white/95 backdrop-blur border-b border-slate-200 px-6 py-3">
    <div class="max-w-7xl mx-auto flex flex-wrap items-center justify-between gap-4">
      <div class="font-bold text-slate-900">🌿 [Project Name] — Garden Party Tour</div>
      <div class="flex items-center gap-2 text-xs font-medium">
        <a href="#tier-1-lawn" class="px-3 py-1.5 rounded-full bg-emerald-100 text-emerald-900 hover:bg-emerald-200">1. The Lawn (Business Overview)</a>
        <span>→</span>
        <a href="#tier-2-pathways" class="px-3 py-1.5 rounded-full bg-teal-100 text-teal-900 hover:bg-teal-200">2. The Pathways (User Journeys)</a>
        <span>→</span>
        <a href="#tier-3-greenhouse" class="px-3 py-1.5 rounded-full bg-sky-100 text-sky-900 hover:bg-sky-200">3. The Greenhouse (Architecture)</a>
        <span>→</span>
        <a href="#tier-4-roots" class="px-3 py-1.5 rounded-full bg-indigo-100 text-indigo-900 hover:bg-indigo-200">4. The Roots (Function & Data Flow)</a>
      </div>
    </div>
  </nav>

  <main class="max-w-7xl mx-auto p-8 space-y-16">
    <!-- SECTION 1 (#tier-1-lawn): Executive Summary, Business KPIs & High-Level Ecosystem Diagram -->
    <!-- SECTION 2 (#tier-2-pathways): Core Capabilities (Trigger -> Safeguards -> Outcome) & Journey Flows -->
    <!-- SECTION 3 (#tier-3-greenhouse): 5-Tier Deep Seam Architecture & Subsystem Matrix -->
    <!-- SECTION 4 (#tier-4-roots): Function-Level Input -> Processing -> Output Traces & Sequence Diagrams -->
  </main>
</body>
</html>
```

---

## 4. Showcase Quality Guardrails

1. **Respect the Altitude Gradient**: Keep Tier 1 (`#tier-1-lawn`) 100% free of file paths, variable names, and framework acronyms so a non-technical executive or client feels immediately welcomed. Save exact `file:line` citations, function names, and type signatures for Tier 3 and Tier 4.
2. **Ground Every Diagram & Function Trace in Real Code**: Every capability, subsystem, and `Input → Processing → Output` function trace in Tier 4 must cite real files and functions verified in the repository—never placeholder or hypothetical functions.
3. **Quote Mermaid Node Labels**: Always wrap Mermaid labels containing parentheses, arrows, colons, or slashes in double quotes (`A["OrderRepository.placeOrder()"] --> B["StripeBillingGateway.charge()"]`).
