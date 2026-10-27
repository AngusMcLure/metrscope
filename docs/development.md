# Development guidelines

These guidelines establish the default architecture and workflow for `metrscope`. They are intentionally modest: add infrastructure when the project needs it, rather than creating a framework before there is working functionality.

## Language, style, and dependencies

- Write application and calculation code in R.
- Follow the [tidyverse style guide](https://style.tidyverse.org/).
- Prefer base R for straightforward operations. The standard packages `base`, `datasets`, `graphics`, `grDevices`, `methods`, `stats`, and `utils` are available without adding project dependencies.
- The initial approved package set is `tidyverse` and `shiny`. Prefer individual tidyverse packages where appropriate; using the `tidyverse` meta-package is not required just to use one component. Ask before adding other direct dependencies, and explain why the dependency is needed and what simpler alternatives were considered.
- When project metadata and dependency management are established, record direct dependencies there and use `renv` to lock reproducible package versions. Do not hand-edit a lockfile as a substitute for running the relevant `renv` commands.
- Use GitHub Actions for repeatable automated checks. The initial workflow runs the existing `testthat` suite directly with `Rscript`, without requiring package metadata; add package-level `R CMD check` once the package scaffold and metadata are established.

## Architecture and folder layout

Use a conventional R-package layout for the reusable calculation engine, with a separate directory for the Shiny interface:

```text
metrscope/
├── R/                       # Reusable tax, benefit, and METR calculation functions
├── app/                     # Shiny entry point and UI-specific code
│   ├── app.R
│   └── R/                   # Shiny modules and app-only helpers
├── tests/
│   └── testthat/            # Unit and integration tests for backend calculations
├── library/                 # Curated Australian tax and benefits source library
├── resources/                # Supporting assets and reproducible input data
├── docs/                     # Design, methods, validation, and development docs
├── .github/
│   └── workflows/            # Automated checks
├── DESCRIPTION               # R package metadata and direct dependencies
├── NAMESPACE                 # Package namespace
├── renv.lock                 # Resolved R package versions, once initialized
├── AGENTS.md                 # Instructions for AI coding agents
└── README.md                 # Project overview and getting started
```

This is the intended direction, not a requirement to create every file or directory immediately. Git does not track empty directories, and the package metadata, lockfile, and CI workflow should be added when their choices and commands can be made coherently. In particular, settle the project's licence before finalizing package metadata.

### Separation of responsibilities

- Put reusable and testable calculation functions in the root `R/` directory. Organize files by domain or responsibility as the codebase grows (for example, tax, benefits, household assumptions, and METR calculations).
- Keep `app/` limited to Shiny concerns: collecting and validating user input, coordinating reactive updates, and presenting results. Put Shiny modules and helpers in `app/R/`.
- The Shiny layer may call the calculation engine, but the calculation engine must not depend on Shiny, reactive values, or UI code. This keeps calculations testable outside the app and allows future interfaces to reuse them.
- Keep policy facts and source references in `library/`; keep implementation choices and formulas documented alongside the relevant calculation code and methods documentation.
- Do not create an additional package or introduce a more elaborate layered architecture unless a concrete need emerges. If the Shiny app is later deployed separately, document how it loads or installs the calculation package.

## Calculation and policy rules

- Define the exact quantity being calculated before implementing it. Distinguish marginal tax rates, average/effective tax rates, and marginal effective tax rates.
- Make financial year, residency, income type, household composition, and other material assumptions explicit inputs where relevant. Avoid silently applying a default when it changes the interpretation of a result.
- Keep policy rules separate from general calculation mechanics where practical. Record authoritative sources and the relevant financial year or effective dates for substantive rules.
- Make invalid or unsupported inputs fail clearly; do not silently coerce them into plausible-looking results.
- Prefer deterministic calculation functions with explicit inputs and outputs. Isolate randomness, I/O, and other side effects when they are genuinely required.
- Explain rounding and numerical tolerances. Show users the scope, assumptions, and limitations of results; the tool is not personal tax advice.

## Testing and validation

- Use `testthat` for unit tests. Add tests alongside new calculation functions rather than postponing them.
- Cover representative cases, boundary values around thresholds and eligibility changes, invalid inputs, and interactions between relevant tax and benefit rules.
- Where feasible, compare results with authoritative worked examples or independent calculations, and document any differences in assumptions or rounding.
- Test the calculation engine independently of Shiny. Add app-level tests only where they protect meaningful input, integration, or output behaviour.
- Run the relevant tests and available package checks before opening a PR. The local test command for the current source-based suite is `Rscript -e 'testthat::test_dir("tests/testthat", reporter = "summary")'` after installing `testthat`. The GitHub Actions workflow runs this command on pull requests and pushes to `main`. Report what ran, what passed or failed, and anything not run; never imply a check ran if it did not.

## Incremental development workflow

1. Clarify the calculation, target financial year, assumptions, and authoritative sources before implementing substantive policy.
2. Implement a small calculation function or coherent group of functions with explicit inputs and outputs.
3. Add tests and document assumptions and sources with the implementation.
4. Run available checks and review the diff for unrelated changes.
5. Build the Shiny interface around tested calculation functions; keep UI work separate from policy and calculation logic.
6. Make a focused branch and PR for human review. Do not commit directly to `main` or merge PRs.

Keep the top-level README focused on project purpose, current status, and user-facing setup. Keep these development conventions here; keep AI-agent-specific instructions and non-negotiable review rules in `AGENTS.md`.
