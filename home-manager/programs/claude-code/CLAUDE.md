## Commit Messages

- **ALWAYS** write git commit messages in English, even though the response language is set to Japanese.

## Pull Requests

- **ALWAYS** create pull requests as drafts (`gh pr create --draft`) unless the user explicitly instructs otherwise.

## Japanese Writing

- **ALWAYS** proofread with the `yomiyasu` skill whenever you write or revise Japanese text.

---

## Sub-Agent Usage

- **ALWAYS** delegate research, investigation, and parallel analysis to sub-agents to keep the main context window clean.
- Assign exactly one well-defined task per sub-agent. Provide explicit step-by-step instructions and a clear goal so the sub-agent does not lose direction.
- Use sub-agents to apply more compute to complex, multi-step problems.
- **NEVER** delegate open-ended or ambiguous tasks to sub-agents. Handle those in the main context so you can track progress and adjust direction.

---

## Development Workflow

- For feature development end-to-end, use the `develop` skill (scope → branch → design → TDD → review loop → ship).
