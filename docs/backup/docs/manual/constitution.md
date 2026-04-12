
# Project Constitution: GitHub Spec-Kit Standard

## I. Supremacy & Governance
1.1 **Source of Truth**: This Constitution is the supreme law of the project. All development MUST adhere to the mandates herein.
1.2 **Authority Path**: All architectural decisions, feature implementations, and code quality requirements are governed by the documents located in:
  - `.\specify\contracts\*` (Functional Enforcement)
  - `.\specify\standards\*` (Quality & Style)
1.3 **Precedence**: In the event of a conflict, the order of precedence is: Constitution > Contracts > Standards.

## II. Development Mandates
2.1 **Runtime**: All scripts MUST target PowerShell 7.5+ and include `#Requires -Version 7.5`.
2.2 **Controller Scripts**: Scripts located in `.\src\Controllers\` are designated as "Orchestrators." They are strictly forbidden from containing substantive business logic (Logic Density Limit: 10%).
2.3 **Mandatory Features**: Every Controller Specification MUST implement and adhere to the following:
  - **Authentication**: Mandated via `contracts\auth-contract.md`.
  - **Telemetry**: Mandated via `contracts\telemetry-contract.md`.
  - **Logging**: Mandated via `contracts\logging-contract.md`.
  - **Orchestration**: Mandated via `contracts\controller-contract.md`.
2.4 **The Doctor Pattern**: Controllers intended for automated system consumption MUST implement the output standards defined in `contracts\doctor-contract.md`.

## III. Architectural Constraints
3.1 **Encapsulation**: All functional logic MUST reside within local PowerShell modules in `.\src\Modules\`. Modules MUST be self-contained with internal `Public`, `Private`, and `Tests` directories.
3.2 **Dependency Rule**: Modules perform "Units of Work." Controllers perform "Business Orchestration." Controllers MUST NOT define internal functions.
3.3 **Standards Compliance**: All code, regardless of function, MUST pass the quality gates defined in `standards\global-standard.md`.

## IV. Verification & Compliance
4.1 **Testing**: Modules require Unit Tests. Controllers require Integration Tests utilizing the shared mocking strategy defined in `.\src\Controllers\Tests\Shared\`.
4.2 **AI Tooling Note**: The `.\docs\*` directory is for supplemental information only. AI agents MUST prioritize the `.\specify\` directory for all generation and validation tasks.
4.3 **Compliance Review**: No Pull Request (PR) shall be merged unless it satisfies the self-attestation checklist for all relevant Contracts and Standards.

## V. Versioning & Amendments
5.1 **Policy**: This project follows Semantic Versioning (SemVer) for all Constitutional changes. 
  - `MAJOR`: Structural changes to mandates or removal of a Contract.
  - `MINOR`: Addition of new Contracts or Modules.
  - `PATCH`: Documentation clarifications.
5.2 **Procedure**: Amendments must be proposed via PR, updated in this document, and propagated to all affected Contracts/Standards.