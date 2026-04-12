<!--
==============================================================================
SYNC IMPACT REPORT
==============================================================================
Version Change  : (template) → 1.0.0
Bump Rationale  : Initial population of blank constitution template.
                  All placeholder tokens replaced with concrete values.
                  This is the founding ratification of the document.

Modified Principles : N/A (initial population)

Added Sections:
  - I.  Supremacy & Governance
  - II. Development Mandates
  - III. Architectural Constraints
  - IV. Verification & Compliance
  - V.  Versioning & Amendments
  - Governance (footer)

Removed Sections : N/A

Template Propagation:
  ✅ .specify/templates/plan-template.md
     - Constitution Check section references ".specify/memory/constitution.md"
       as authority source. No structural misalignment found. No changes needed.
  ✅ .specify/templates/spec-template.md
     - No constitution-specific mandatory sections conflict. Template is generic
       and compatible. No changes needed.
  ✅ .specify/templates/tasks-template.md
     - Auth, Telemetry, Logging, and Doctor pattern tasks should appear in
       Phase 2 (Foundational) for any Controller feature. Existing template
       comment guidance is sufficient. No structural change required.
  ⚠  .specify/templates/constitution-template.md
     - Source template unchanged intentionally (it remains a blank template
       for future use). Operational constitution is at .specify/memory/.

Deferred TODOs   : None. All fields resolved.
==============================================================================
-->

# Zerto ZVM Automation — Project Constitution

## I. Supremacy & Governance

This Constitution is the supreme governing document of the Zerto ZVM Automation
project. All development, tooling decisions, and AI-agent generation tasks
MUST adhere to the mandates herein. No deliverable may contradict or bypass
these rules without an approved constitutional amendment.

**Authority Path**: Governance is enforced through two document categories
located within the `.specify/` directory:

- `.specify/Contracts/` — Functional Enforcement (shared behavioral contracts)
- `.specify/standards/` — Quality & Style (code quality gates and style rules)

**Precedence Order** (highest to lowest):
Constitution → Contracts → Standards

> Any conflict between documents MUST be resolved by deferring to the
> higher-authority document in this chain.

**AI Tooling Note**: The `./docs/` directory is for supplemental information
only. AI agents MUST prioritize the `.specify/` directory for all generation
and validation tasks.

## II. Development Mandates

These are the non-negotiable technical requirements that apply to every script
and module produced by this project.

- **Runtime**: All scripts MUST target PowerShell 7.5+ and MUST include
  `#Requires -Version 7.5` as the first directive.

- **Controller Scripts**: Scripts located in `./src/Controllers/` are designated
  as "Orchestrators." They are strictly forbidden from containing substantive
  business logic. Logic Density Limit: ≤ 10% of lines may contain inline logic;
  all other logic MUST be delegated to modules.

- **Mandatory Contract Compliance**: Every Controller Specification MUST
  implement and adhere to the following contracts:
  - **Authentication** — `Contracts/auth-contract.md`
  - **Telemetry** — `Contracts/telemetry-contract.md`
  - **Logging** — `Contracts/logging-contract.md`
  - **Orchestration** — `Contracts/controller-contract.md`

- **The Doctor Pattern**: Controllers intended for automated system consumption
  MUST implement the output standards defined in `Contracts/doctor-contract.md`.
  Human-facing scripts MAY implement this pattern at the author's discretion.

## III. Architectural Constraints

The following structural rules define how this codebase is organized and how
components relate to one another.

- **Encapsulation**: All functional logic MUST reside within local PowerShell
  modules under `./src/Modules/`. Every module MUST be self-contained and
  include its own `Public/`, `Private/`, and `Tests/` subdirectories.

- **`ZertoZVM.APIWrapper`**: Pure REST API calls (Method / URI / Body) for the Zerto API only.
  No business logic permitted.
- **`ZertoZVM.Core`**: Zerto-specific business logic, utility functions, and output formatters.
- **`InfraCode.Telemetry`**: Dynatrace session management and KPI submission.
- **`InfraCode.Snow`**: Pure REST API calls (Method / URI / Body) for ServiceNow (SNOW) only.
- **`InfraCode.Email`**: Functions for email composition and HTML formatting.
- **`InfraCode.HeadQuarters`**: Pure REST API calls (Method / URI / Body) for the
  Headquarters API only.

- **Dependency Rule**:
  - Modules perform "Units of Work" (discrete, testable operations).
  - Controllers perform "Business Orchestration" (sequencing and decision-making).
  - Controllers MUST NOT define internal functions (zero `function` keywords
    inside a Controller script body).

- **Standards Compliance**: All code, regardless of type or location, MUST pass
  the quality gates defined in `standards/standards.md` before being considered
  mergeable.

## IV. Verification & Compliance

All work products MUST meet these verification requirements before being
integrated into the main branch.

- **Testing Requirements**:
  - Modules MUST include Unit Tests (Pester) for every Public function,
    co-located within the module's `Tests/` directory.
  - Controllers MUST include Integration Tests that utilize the shared mocking
    strategy under `./src/Controllers/Tests/Shared/`.

- **Compliance Review**: No Pull Request (PR) shall be merged unless the author
  provides a self-attestation confirming compliance with all relevant Contracts
  and Standards. This attestation MUST reference the specific contract(s)
  satisfied.

- **Quality Gates** (from `standards/standards.md`):
  - PSScriptAnalyzer: Zero Errors, Zero Warnings.
  - Pester: 100% pass rate for all Unit and Integration tests.

## V. Versioning & Amendments

- **SemVer Policy**: This project follows Semantic Versioning (SemVer) for all
  Constitutional changes:
  - `MAJOR`: Structural changes to mandates, removal of a Contract, or
    redefinition of a governing Principle.
  - `MINOR`: Addition of new Contracts, Modules, or materially expanded guidance.
  - `PATCH`: Documentation clarifications, wording refinements, or typo fixes.

- **Amendment Procedure**: Amendments MUST be:
  1. Proposed via Pull Request with a clear rationale.
  2. Reflected in this document with an updated version line
     and `Last Amended` date.
  3. Propagated to all affected Contracts and Standards files before the PR
     is considered complete.

## Governance

This Constitution supersedes all other project practices, conventions, and
prior agreements. Any code, document, or process that conflicts with these
mandates MUST be updated to comply at the earliest opportunity.

All PRs and reviews MUST verify compliance with the applicable Contracts and
Standards. Complexity that appears to violate a mandate MUST be formally
justified via the Complexity Tracking section of the relevant `plan.md`.

For runtime development guidance and workflow instructions, refer to
`.specify/templates/` and the agent skill files under `.agent/skills/`.

**Version**: 1.0.0 | **Ratified**: 2026-04-12 | **Last Amended**: 2026-04-12
