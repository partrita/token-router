# Antigravity CLI and OpenCode

`token-router` can be used as a shared Agent Skill by both Antigravity CLI and OpenCode.

## Workspace installation

Copy the complete skill directory into the target project:

```bash
mkdir -p .agents/skills
a=$(pwd)/.agents/skills/token-router
mkdir -p "$a/scripts"
cp -R path/to/token-router/.agents/skills/token-router/* "$a/"
```

The important layout is:

```text
.agents/skills/token-router/
├── SKILL.md
└── scripts/
    └── router.py
```

Antigravity CLI discovers workspace skills from `.agents/skills/`. OpenCode also discovers `.agents/skills/*/SKILL.md`, so the same directory works for both clients.

## Global installation

For Antigravity CLI, copy the skill directory into its global skills directory:

```bash
mkdir -p ~/.gemini/antigravity-cli/skills
a=$(pwd)/.agents/skills/token-router
cp -R "$a" ~/.gemini/antigravity-cli/skills/token-router
```

For OpenCode, copy it into the global Agent Skills compatibility directory:

```bash
mkdir -p ~/.agents/skills
cp -R .agents/skills/token-router ~/.agents/skills/token-router
```

Keeping `scripts/router.py` inside the skill package is intentional: both clients can run the skill independently of a checkout of the `token-router` repository.

## Usage

After the skill is discovered, invoke it naturally or use its slash-command entry when offered by the client. Typical tasks are:

```text
Use token-router to inspect this large CI log for the database timeout.
Use token-router to find the relevant code for the token expiration bug.
Use token-router to route the long deployment instructions relevant to approval workflow.
```

The skill selects `error_log`, `heavy_code`, or `agent_context` and runs the bundled router with the user's query. The router returns raw source lines rather than a local-model summary.

## Ollama

The skill requires a locally running Ollama server unless a compatible `OLLAMA_URL` is configured. The default model is `gemma4:e2b-it-q4_K_M`.

```bash
ollama pull gemma4:e2b-it-q4_K_M
```

See `SKILL.md` for the supported environment variables and routing guidance.
