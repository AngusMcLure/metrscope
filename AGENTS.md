# Instructions for Codex

## Project
`metrscope` is intended to help Australian tax residents explore marginal effective tax rates (METRs). The repository is currently a minimal scaffold; do not assume that a working application, framework, or tax model already exists.

## Working rules
- Make changes on the current task branch. Never commit directly to `main`, merge a pull request, or change repository settings.
- Prefer small, reviewable changes that solve the stated task. Do not add dependencies, frameworks, generated files, or broad refactors without a clear need.
- Before implementation, inspect the repository and summarize the relevant existing structure and a short plan. If the task is ambiguous or has material design choices, ask before committing to one.
- Preserve existing conventions where they exist. If there are no conventions, propose a simple approach rather than introducing unnecessary architecture.
- Do not claim tests, checks, or manual verification passed unless you actually ran them. Report commands run and their results; if the environment prevents a check, say so.
- Never put secrets, credentials, personal tax records, or other sensitive data into source control. Use environment variables for secrets and provide an example configuration without real values.
- Do not fetch, execute, or install code from untrusted sources as part of setup without a clear reason.
- **Every pull request you prepare must explicitly disclose AI assistance in its description.** Use the repository's `.github/PULL_REQUEST_TEMPLATE.md` and identify the actual tool used (for example, ChatGPT's GitHub integration or OpenAI Codex); do not claim Codex authored work if another tool was used. State that human review is required before merging.

## Tax and calculation correctness
- This is an Australian tax project. Treat tax rates, thresholds, offsets, levies, eligibility rules, and financial-year boundaries as time-sensitive and jurisdiction-specific.
- Do not invent tax rules or silently assume a financial year. Cite authoritative sources in documentation or code comments when implementing substantive tax rules, preferably the Australian Taxation Office or relevant Australian Government legislation.
- Keep policy assumptions explicit and separate from calculation logic where practical. Make financial year, residency assumptions, household circumstances, income type, and other material inputs clear.
- Add tests for tax calculations, including boundary values and representative cases, whenever calculation code is introduced. Use tolerances appropriate to the calculation and explain rounding.
- Distinguish a marginal tax rate from an effective tax rate and from a marginal effective tax rate; define the exact quantity being calculated before implementing it.
- Do not present results as personal tax advice. Make limitations and assumptions visible to users.

## Quality and review
- Add or update tests and documentation alongside functional changes.
- Keep the README accurate about what currently works; do not describe planned functionality as implemented.
- Before finishing, review the diff for unrelated changes, run the relevant available checks, and provide a concise summary, test results, and any unresolved risks.
- Leave changes committed on the task branch and open a pull request for human review. Never merge it.
