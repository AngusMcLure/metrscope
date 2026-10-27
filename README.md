# metrscope

Scope out marginal effective tax rates (METRs) for Australian tax residents.

## Status

The calculation engine currently models 2026–27 resident individual income tax, LITO, the standard individual Medicare levy, and an initial Medicare levy surcharge (MLS) calculation. MLS uses household income, the number of dependent children, and a full-year household hospital-cover assumption. Its scope and limitations are documented in [the validation notes](docs/validation.md) and [the tax-core validation specification](docs/validation/tax-core-2026-27.md).

Family payments, childcare and housing support, other levy circumstances, a general METR comparison engine, and the Shiny interface have not yet been implemented. The intended architecture is an R calculation engine with a separate Shiny interface; see [the development guidelines](docs/development.md).

## Project aim

Provide a transparent way to explore how changes in income and circumstances affect tax and other relevant payments, with assumptions and financial-year rules made explicit.

Any implemented results should clearly state their scope, inputs, assumptions, and limitations. This project is an exploratory tool, not a substitute for professional tax advice.

## Development

See [`AGENTS.md`](AGENTS.md) for instructions for AI coding agents, including Codex, and [`docs/development.md`](docs/development.md) for the R/Shiny architecture, dependency policy, style, testing, and development workflow.

Changes should be made on task branches and proposed through pull requests; do not commit directly to `main` or merge PRs.
