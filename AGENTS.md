# Agent Instructions

These instructions apply to all future agent work in this repository.

## Milestone Workflow

Every milestone must start with a scope review before implementation begins.

- Read the current README, NEWS, TODO, next-milestone scope notes, handoff prompt, and any relevant plan/spec files.
- Restate the milestone goal, in-scope work, non-goals, and acceptance criteria.
- Identify open human-in-the-loop decisions before coding.
- Develop or update an implementation plan before editing code or data.
- Keep epidemiologic counts manually curated unless a future human-approved milestone explicitly changes that governance model.

## Version Tags And NEWS

Every version tag must include a corresponding `NEWS.md` update before the tag is created.

- Patch tags should document the concrete fix or documentation change they release.
- Milestone releases should advance the milestone-level version tag according to the project's current versioning convention, not only create a patch tag for the milestone work.
- Do not create or move a tag until `NEWS.md` describes the release content and local verification has passed.

## Milestone Release Checklist

Every milestone release must include:

- A review of the milestone scope against the completed work.
- A review of progress toward the overall project goals.
- An updated `NEWS.md` section for the release tag.
- Updated human-in-the-loop tasks for the next milestone.
- An updated next-agent handoff prompt.
- Verification with the project test and validation commands documented for that milestone.

For the current project phase, the standard verification commands are:

```powershell
Rscript tests/testthat.R
Rscript R/validate_counts.R
Rscript -e "parsed <- yaml::read_yaml('.github/workflows/validate.yml'); stopifnot('on' %in% names(parsed)); message('Workflow YAML parsed')"
```
