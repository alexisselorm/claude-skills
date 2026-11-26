# claude-skills

Claude Code skills for day-to-day engineering work in any repo.

| Skill | What it does |
|---|---|
| `commit-unit` | Works on a `<type>/<slug>` branch and commits each coherent unit as it lands, then runs the full test suite and checks once at the end and fixes what fails. Stages by path, writes conventional messages, never adds trailers or attribution. |
| `code-review` | Runs parallel reviewer personas (correctness, security, tests, code quality, plus performance when relevant) over a diff and merges their findings into one severity-grouped report. Never edits. |
| `plan-feature` | Explores the repo for real extension points and researches how the market solves the problem, in parallel, then writes one plan doc that explains how the feature works and which alternatives it rejected, where every claim is a verified `path:line` or a cited source. |
| `ci-speed` | Detects the repo's own stack, measures real GitHub Actions runs (per job and per step, medians and worst cases, critical path, queue and cache use), finds where the time goes, researches fixes for that stack with cited sources, and writes a ranked plan. On request it implements one workstream at a time, runs unproven ideas as spikes with an adoption bar, and re-measures. |

## Install

```bash
./install.sh
```

Symlinks each skill into `~/.claude/skills` (override with `CLAUDE_SKILLS_DIR`), so a
`git pull` updates them in place. An existing copy of a skill is moved to
`<name>.bak-<timestamp>`, never deleted.

Invoke with `/commit-unit`, `/code-review`, `/plan-feature` or `/ci-speed`, or let Claude pick them up
from their descriptions.

## Layout

Each skill keeps `SKILL.md` short and loads its other files only when a step needs them:

```
skills/
  commit-unit/    SKILL.md, push.md, isolated-test.md, scripts/check.sh
  code-review/    SKILL.md, reviewer.md, personas/*.md, repo-invariants.md, scripts/collect.sh
  plan-feature/   SKILL.md, anatomy.md, research-notes.md, scripts/check-anchors.sh
  ci-speed/       SKILL.md, techniques.md, scripts/ci-timings.sh
```

`code-review/repo-invariants.md` is a template: fill it with what your repo must never break.
