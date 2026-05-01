## Principles

- Write code that expresses **how** it works. Write tests that express **what** the behavior is. Write commit messages that explain **why** the change was made. Write code comments only to explain **why not** — i.e., non-obvious decisions or rejected alternatives.
- When you change code, **MUST** update all related documentation in the same commit.
- Keep every change as small and simple as possible. Minimize the number of lines and files affected.
- Fix root causes, not symptoms. Do not apply temporary workarounds.
- Touch only what is necessary. Do not introduce unrelated changes or new bugs.

---

## Sub-Agent Usage

- **ALWAYS** delegate research, investigation, and parallel analysis to sub-agents to keep the main context window clean.
- Assign exactly one well-defined task per sub-agent. Provide explicit step-by-step instructions and a clear goal so the sub-agent does not lose direction.
- Use sub-agents to apply more compute to complex, multi-step problems.
- **NEVER** delegate open-ended or ambiguous tasks to sub-agents. Handle those in the main context so you can track progress and adjust direction.

---

## Verification Before Completion

- **NEVER** mark a task as complete without evidence that it works.
- Run tests, check logs, and confirm correct behavior before presenting results.
- When relevant, diff your changes against the base branch to verify scope.
- Before finalizing, ask: "Would a staff engineer approve this?"

---

## Implementation Quality

- Before making a significant change, pause and ask: "Is this the best approach given everything I know?"
- If a fix feels like a hack, stop and implement the best solution using all available context.
- Skip this deliberation for trivially obvious fixes — do not over-engineer.
- Self-review your work before presenting it.

---

## Session Handover

- At session start, check the `.claude/handovers/` directory in the project root. If files exist, read the most recent one.
- At session end or at a natural stopping point, prompt the user to run `/handover`.

---

## Security

### NEVER

- **NEVER** hardcode credentials, API keys, passwords, or secrets.
- **NEVER** commit code that fails formatting, linting, or tests.
- **NEVER** push directly to `master` or `main` branches.

### MUST

- **MUST** write tests for every feature addition and bug fix.
- **MUST** use feature branches for all changes.
- **MUST** add documentation for every public interface, function, type, or module.
