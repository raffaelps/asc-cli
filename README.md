# asc — App Store Connect CLI

[![Release](https://img.shields.io/github/v/release/raffaelps/asc-cli?label=release)](https://github.com/raffaelps/asc-cli/releases)

A small, fast command-line tool for the Apple [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi).
Built to be driven by **AI tooling and CI**: every command supports `--json`,
writes errors to stderr, exits non-zero on failure, and never prompts
interactively (except for explicit write confirmations).

Distributed as a **self-contained binary** — no Python, no dependencies, nothing
to clone.

---

## Table of contents

- [Install](#install)
- [Configure credentials](#configure-credentials)
- [Quick start](#quick-start)
- [Use as an AI agent (MCP)](#use-as-an-ai-agent-mcp)
- [Command reference](#command-reference)
  - [Apps](#apps)
  - [Status & summary](#status--summary)
  - [App Store versions](#app-store-versions)
  - [Phased rollout control](#phased-rollout-control)
  - [Performance & crash metrics](#performance--crash-metrics)
  - [Version comparison](#version-comparison)
  - [TestFlight](#testflight)
- [JSON output](#json-output)
- [Exit codes](#exit-codes)
- [Use in GitHub Actions / CI](#use-in-github-actions--ci)
- [Security notes](#security-notes)

---

## Install

### Homebrew (macOS & Linux)

```bash
brew tap raffaelps/asc-cli https://github.com/raffaelps/asc-cli
brew install asc
```

Update later with:

```bash
brew update && brew upgrade asc
```

### Direct binary download

Grab the binary for your platform from the
[latest release](https://github.com/raffaelps/asc-cli/releases/latest):

| Platform | Asset |
|---|---|
| macOS (Apple Silicon) | `asc-macos-arm64.tar.gz` |
| Linux (x86_64) | `asc-linux-x86_64.tar.gz` |

> Intel Macs are not supported — only Apple Silicon binaries are published.

```bash
tar -xzf asc-macos-arm64.tar.gz
sudo mv asc /usr/local/bin/
asc --version
```

> **macOS Gatekeeper:** if you downloaded the binary manually (not via Homebrew)
> and macOS blocks it, clear the quarantine flag: `xattr -d com.apple.quarantine ./asc`.

---

## Configure credentials

The API authenticates with a short-lived signed token generated from an
**App Store Connect API key** — not your Apple ID.

### 1. Create an API key

In App Store Connect: **Users and Access → Integrations → App Store Connect API → +**.
You receive:

- an **Issuer ID** (a UUID),
- a **Key ID**, and
- a one-time download of a `.p8` private key file (keep it safe — it cannot be
  re-downloaded).

### 2. Provide them via environment variables

```bash
export ASC_ISSUER_ID="00000000-0000-0000-0000-000000000000"
export ASC_KEY_ID="ABCD1234EF"
export ASC_PRIVATE_KEY_PATH="/path/to/AuthKey_ABCD1234EF.p8"
```

| Variable | Required | Description |
|---|---|---|
| `ASC_ISSUER_ID` | yes | Issuer ID (UUID) |
| `ASC_KEY_ID` | yes | Key ID of the API key |
| `ASC_PRIVATE_KEY_PATH` | one of these | Path to the `.p8` file |
| `ASC_PRIVATE_KEY` | one of these | The `.p8` **contents** inline (use this in CI; `\n`-escaped newlines are accepted) |

No token is stored or refreshed — the CLI mints a fresh one per call.

---

## Quick start

```bash
asc apps list                       # all apps in your account
asc status com.example.myapp        # live version + in-flight + latest build
asc metrics 1234567890              # performance & crash metrics
```

Most commands take an **app reference** that is either the numeric **app id** or
the **bundle id** — the CLI resolves a bundle id automatically.

---

## Use as an AI agent (MCP)

`asc` ships a built-in [MCP](https://modelcontextprotocol.io) server, so AI tools
that speak MCP — **Claude** (Desktop, Code), **Cursor**, **Kiro**, Windsurf, Zed
— can call App Store Connect directly as structured tools.

Start it with:

```bash
asc mcp                  # read-only tools
asc mcp --enable-writes  # also expose rollout pause/resume/release
```

By default only **read** tools are exposed (`app_status`, `performance_metrics`,
`compare_versions`, `list_apps`, …). The destructive rollout-control tools are
opt-in via `--enable-writes` and are tagged with MCP's `destructiveHint`, so the
client asks you to confirm before running them.

### Claude Desktop

Add to `claude_desktop_config.json`:

```jsonc
{
  "mcpServers": {
    "appstoreconnect": {
      "command": "asc",
      "args": ["mcp"],
      "env": {
        "ASC_ISSUER_ID": "00000000-0000-0000-0000-000000000000",
        "ASC_KEY_ID": "ABCD1234EF",
        "ASC_PRIVATE_KEY_PATH": "/path/to/AuthKey_ABCD1234EF.p8"
      }
    }
  }
}
```

### Claude Code

```bash
claude mcp add appstoreconnect \
  --env ASC_ISSUER_ID=... --env ASC_KEY_ID=... --env ASC_PRIVATE_KEY_PATH=/path/AuthKey.p8 \
  -- asc mcp
```

### Cursor / Kiro / Windsurf

These use the same shape in their MCP config (`.cursor/mcp.json` for Cursor):

```jsonc
{
  "mcpServers": {
    "appstoreconnect": {
      "command": "asc",
      "args": ["mcp"],
      "env": {
        "ASC_ISSUER_ID": "...",
        "ASC_KEY_ID": "...",
        "ASC_PRIVATE_KEY_PATH": "/path/to/AuthKey.p8"
      }
    }
  }
}
```

To allow rollout control, change `"args": ["mcp"]` to `"args": ["mcp", "--enable-writes"]`.

Then ask your assistant things like *"What's the status of app 1234567890?"* or
*"Did the latest version regress on any metric?"* — it calls the tools itself.

---

## Command reference

Run `asc --help` or `asc <command> --help` for full options at any time.
Add `--json` to any command for machine-readable output.

### Apps

#### `asc apps list`
List every app in the account.

```bash
asc apps list
asc apps list --limit 10 --json
```

#### `asc apps get <app>`
Show every attribute of a single app. Optionally enrich with related resources
via `--include` (comma-separated).

```bash
asc apps get com.example.myapp
asc apps get com.example.myapp --include localizations,betaGroups,versions,builds --json
```

| `--include` value | Adds |
|---|---|
| `versions` | every App Store version + its state |
| `builds` | recent TestFlight builds |
| `localizations` | per-locale description, keywords, what's new (latest version) |
| `betaGroups` | TestFlight beta groups + public links |

### Status & summary

#### `asc status <app>`
One-shot health summary: the live (published) version, any version currently
in-flight (in review / pending), and the latest TestFlight build.

```bash
asc status com.example.myapp
asc status com.example.myapp --json
```

### App Store versions

#### `asc versions status <app>`
List App Store versions and their states (`READY_FOR_SALE`, `IN_REVIEW`,
`PENDING_DEVELOPER_RELEASE`, `REJECTED`, …).

```bash
asc versions status com.example.myapp
```

#### `asc versions rollout <app>`
Show phased-release progress of the live version: state, current day, and the
percentage of users it has reached.

```bash
asc versions rollout com.example.myapp
```

Apple's fixed schedule: day 1 = 1%, 2 = 2%, 3 = 5%, 4 = 10%, 5 = 20%, 6 = 50%,
7 = 100%.

### Phased rollout control

These **change the live rollout**, so they ask for confirmation. Pass `--yes`
(`-y`) to skip the prompt in automation.

#### `asc versions pause <app>`
Pause the phased rollout.

#### `asc versions resume <app>`
Resume a paused rollout.

#### `asc versions release <app>`
Complete the rollout — release to **all** users immediately (irreversible).

```bash
asc versions pause com.example.myapp
asc versions resume com.example.myapp
asc versions release com.example.myapp --yes
```

### Performance & crash metrics

#### `asc metrics <app>`
Aggregated Power & Performance metrics (from MetricKit): crashes/terminations,
hangs, launch time, memory, battery, disk, animation, storage — with median
(p50) and tail (p90) values per latest version, plus any regressions Apple has
flagged.

```bash
asc metrics com.example.myapp                  # all categories
asc metrics com.example.myapp -c TERMINATION   # one category (crash proxy)
asc metrics com.example.myapp -c HANG --json
```

**CI gates** (exit non-zero on failure):

```bash
asc metrics <app> --fail-on-regression           # fail if Apple flagged a regression
asc metrics <app> -c TERMINATION --fail-above 1.0 # fail if median crash rate exceeds 1.0/day
```

### Version comparison

#### `asc compare <app>`
Compare two versions' metrics and report each metric's percent change. All
metrics are lower-is-better, so a **positive change is a regression**. Defaults
to the two latest versions with data.

```bash
asc compare com.example.myapp                       # two latest versions
asc compare com.example.myapp --from 6.4.0 --to 6.6.0
asc compare com.example.myapp --fail-above-pct 25   # fail if a metric worsened >25%
```

### TestFlight

#### `asc testflight builds <app>`
List recent TestFlight builds and their processing state.

```bash
asc testflight builds com.example.myapp
asc testflight builds com.example.myapp --limit 50 --json
```

---

## JSON output

Every command accepts `--json`, emitting structured output to stdout — ideal for
piping into `jq`, feeding AI tools, or parsing in CI.

```bash
asc status com.example.myapp --json | jq '.liveVersion'
```

---

## Exit codes

| Code | Meaning |
|---|---|
| `0` | Success |
| `1` | API error (e.g. the request was rejected) |
| `2` | Configuration error (missing/invalid credentials or arguments) |
| `3` | A CI gate failed (`--fail-on-regression`, `--fail-above`, `--fail-above-pct`) |

---

## Use in GitHub Actions / CI

Store credentials as repository secrets and install the binary via Homebrew (or
a direct download). Example daily health check that fails on regression:

```yaml
name: App health check
on:
  workflow_dispatch:
  schedule:
    - cron: "0 9 * * *"
jobs:
  health:
    runs-on: ubuntu-latest
    env:
      ASC_ISSUER_ID: ${{ secrets.ASC_ISSUER_ID }}
      ASC_KEY_ID: ${{ secrets.ASC_KEY_ID }}
      ASC_PRIVATE_KEY: ${{ secrets.ASC_PRIVATE_KEY }}
    steps:
      - name: Install asc
        run: |
          brew tap raffaelps/asc-cli https://github.com/raffaelps/asc-cli
          brew install asc
      - name: Status
        run: asc status com.example.myapp
      - name: Fail on metric regression
        run: asc metrics com.example.myapp --fail-on-regression
```

For CI, set `ASC_PRIVATE_KEY` to the **contents** of the `.p8` (escaped newlines
are accepted) rather than a file path.

---

## Security notes

- Your `.p8` is a **private key** — treat it like a password. Never commit it;
  store it only in secret managers / CI secrets.
- The CLI talks **directly** to Apple's API. Credentials never leave your machine
  or runner.
- Phased-rollout write commands (`pause`/`resume`/`release`) require confirmation
  unless `--yes` is passed.
