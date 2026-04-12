# Global Standard

## I. Syntax & Style
To ensure consistency and prevent technical debt, all code MUST adhere to these stylistic mandates:

* **Naming Conventions**:
    * Use **PascalCase** for all Function names, Parameter names, and Variables (e.g., `$VpgName`, not `$vpg_name`).
    * Functions MUST follow the standard `Verb-Noun` format using approved PowerShell verbs.
* **No Aliases**: Explicit cmdlet names MUST be used (e.g., `Where-Object` instead of `?`, `ForEach-Object` instead of `%`).
* **Strict Typing**: Explicitly type parameters and variables where possible to improve performance and prevent casting errors (e.g., `[string]$Name`).
* **Indentation**: Use **4 spaces** for indentation (no tabs).

## II. Error Handling Standard
The project operates on a "Fail Fast" philosophy.

* **Global Preference**: Every script MUST set `$ErrorActionPreference = 'Stop'` at the top.
* **Granular Try/Catch**: 
    * Do NOT use a single `try/catch` for the entire script. 
    * Wrap individual "Units of Work" (API calls, File I/O) in their own blocks to provide specific error messages.
* **Clean Termination**: Use `throw` for critical failures to ensure the calling system (automation engine or CI/CD) registers the failure.

## III. Module Development Rules
Modules are the engine room of the project.

* **Self-Containment**: A module MUST house its own `Public`, `Private`, `Tests`, and `Docs`.
* **Function Boundaries**: 
    * **Public**: Only export functions that act as the primary interface.
    * **Private**: Keep helper logic, proxy calls, and complex regex hidden.
* **Unit Testing**: Every Public function MUST have a corresponding Pester test file within the module’s `Tests` directory.

## IV. Documentation Standard
Code must be self-documenting for both humans and AI agents.

* **Comment-Based Help (CBH)**: Every function MUST include `.SYNOPSIS`, `.DESCRIPTION`, and `.PARAMETER` definitions. Output Shape and Examples should reflect what to expect from the function.
* **Inline Comments**: Use comments to explain **why** a specific logic branch exists, not **what** the code is doing (the code should be readable enough to explain the "what").

## V. Performance & Best Practices
* **Object Manipulation**: Prefer `[PSCustomObject]` for creating structured data. Avoid `Add-Member` inside loops due to performance overhead.
* **String Handling**: Use the `-f` format operator or variable interpolation. For massive string building, use `[System.Text.StringBuilder]`.
* **Pipeline Usage**: While the pipeline is powerful, use standard `foreach` loops in Modules for better performance and easier debugging of complex logic.

---

## VI. Quality Gate Checklist
Before any code is considered "Standard Compliant," it must pass:
1.  **PSScriptAnalyzer**: Zero Errors, Zero Warnings.
2.  **Pester**: 100% pass rate for Unit and Integration tests.
