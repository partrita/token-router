---
name: token-router
description: Route oversized logs, source files, and long agent-reference documents through a local Ollama model to select exact line ranges before analysis. Use for large logs, stack traces, source files, or long AGENTS.md, GEMINI.md, CLAUDE.md, or other task-specific instruction references where reducing cloud context is useful.
compatibility: antigravity, opencode
license: MIT
---

# Token Router

Use this skill to reduce model context without lossy summarization. A local Ollama model selects relevant line ranges, then the bundled router returns the **raw, unmodified lines from the original file**.

## When to use

Use it for:

- Large deployment or CI logs and stack traces.
- Source files that are too large to inspect efficiently in one pass.
- Long, task-specific agent reference documents.
- Investigations where a focused query can identify likely evidence.

Do **not** use it when complete context is required, such as a broad architecture review or a security audit where every line may matter.

## Workflow

1. Identify the target file and the user's task/query.
2. Choose one routing mode:
   - `error_log` for logs, CI output, stack traces, and operational failures.
   - `heavy_code` for large source files and localized implementation investigations.
   - `agent_context` for long task-specific instruction/reference files.
3. Run the bundled `scripts/router.py` from this skill directory. The skill runtime exposes the skill's base directory; resolve the script relative to that directory rather than assuming the current working directory contains the repository.

Examples:

```bash
python3 <TOKEN_ROUTER_SKILL_DIR>/scripts/router.py error_log path/to/deploy.log --query "database migration timeout"
python3 <TOKEN_ROUTER_SKILL_DIR>/scripts/router.py heavy_code path/to/service.py --query "token expiration"
python3 <TOKEN_ROUTER_SKILL_DIR>/scripts/router.py agent_context path/to/frontend.md --query "frontend testing workflow"
```

4. Analyze the returned slices. They are copied directly from the original file and retain original line locations.
5. If the selected context is too narrow, rerun with a better query or inspect a wider nearby range directly. Never infer unseen code or instructions from a narrow slice.

## Important context rules

The router is a selector, not a summarizer. Its local model may miss relevant ranges. The lossless guarantee applies only to the text that is selected and extracted.

For agent instructions, keep short mandatory rules in the root `AGENTS.md` or `GEMINI.md` that the client automatically loads. Put long task-specific guidance in separate reference files and route those on demand. A router cannot recover tokens already spent on an instruction file that the client has automatically injected.

Never move safety, ownership, permission, credential, or other non-negotiable rules out of always-on context solely to save tokens.

## Configuration

The bundled router defaults to a local Ollama endpoint and model. Override these environment variables when appropriate:

- `OLLAMA_MODEL` — local routing model.
- `OLLAMA_URL` — Ollama generate endpoint.
- `ROUTER_TIMEOUT` — Ollama request timeout in seconds.
- `ROUTER_MAX_CHARS` — maximum line-numbered content sent to Ollama.
- `ROUTER_MAX_OUTPUT_LINES` — maximum raw lines returned after selected ranges are merged.
- `ROUTER_STREAM_THRESHOLD_BYTES` — threshold for streaming large-log prefiltering.
- `ROUTER_LOG_CONTEXT_LINES` — surrounding lines for log matches.
- `ROUTER_LOG_TAIL_LINES` — tail lines retained for large logs.
- `ROUTER_CODE_CONTEXT_LINES` — surrounding lines for code matches.
- `ROUTER_AGENT_CONTEXT_LINES` — surrounding lines for agent-context matches.
- `OLLAMA_NUM_CTX` — local model context window.
- `OLLAMA_KEEP_ALIVE` — Ollama model residency after routing.

If Ollama is unavailable or returns invalid JSON, treat the deterministic fallback as a starting point and retrieve additional raw context before making a diagnosis.

## Client compatibility

This skill intentionally lives under `.agents/skills/token-router/` so the same skill package can be discovered by both Antigravity CLI and OpenCode. OpenCode discovers `.agents/skills/*/SKILL.md`, while Antigravity CLI uses `.agents/skills/` for workspace skills. The skill contains its own `scripts/` directory so it remains usable when installed independently of this repository.
