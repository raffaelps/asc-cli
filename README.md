# asc-cli — App Store Connect CLI

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
- [Updating](#updating)
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
  - [Customer reviews](#customer-reviews)
  - [Diagnostics](#diagnostics)
  - [Store page metadata](#store-page-metadata)
  - [Review submission](#review-submission)
  - [Release workflow](#release-workflow)
  - [Sales reports](#sales-reports)
  - [Webhooks](#webhooks)
- [JSON output](#json-output)
- [Exit codes](#exit-codes)
- [Use in GitHub Actions / CI](#use-in-github-actions--ci)
- [Security notes](#security-notes)

---

## Install

### Homebrew (macOS & Linux)

```bash
brew tap raffaelps/asc-cli https://github.com/raffaelps/asc-cli
brew install asc-cli
```

To update later, see [Updating](#updating) — both steps are required.

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
sudo mv asc-cli /usr/local/bin/
asc-cli --version
```

> **macOS Gatekeeper:** if you downloaded the binary manually (not via Homebrew)
> and macOS blocks it, clear the quarantine flag: `xattr -d com.apple.quarantine ./asc`.

---

## Updating

Homebrew does **not** refresh third-party taps automatically, so always run both
steps — in this order:

```bash
brew update           # 1) refresh the tap (pull the new formula)
brew upgrade asc-cli  # 2) then upgrade the binary
```

> Running `brew upgrade asc-cli` on its own may report
> `already installed` even when a newer version exists — that just means the
> local tap is stale. `brew update` fixes it.

If you ever tapped an older version and `brew install` can't find the formula,
re-tap fresh:

```bash
brew untap raffaelps/asc-cli
brew tap raffaelps/asc-cli https://github.com/raffaelps/asc-cli
```

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
asc-cli apps list                       # all apps in your account
asc-cli status com.example.myapp        # live version + in-flight + latest build
asc-cli metrics 1234567890              # performance & crash metrics
```

Most commands take an **app reference** that is either the numeric **app id** or
the **bundle id** — the CLI resolves a bundle id automatically.

---

## Use as an AI agent (MCP)

`asc-cli` ships a built-in [MCP](https://modelcontextprotocol.io) server, so AI tools
that speak MCP — **Claude** (Desktop, Code), **Cursor**, **Kiro**, Windsurf, Zed
— can call App Store Connect directly as structured tools.

Start it with:

```bash
asc-cli mcp                  # read-only tools
asc-cli mcp --enable-writes  # also expose rollout pause/resume/release
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
      "command": "asc-cli",
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
  -- asc-cli mcp
```

### Cursor / Kiro / Windsurf

These use the same shape in their MCP config (`.cursor/mcp.json` for Cursor):

```jsonc
{
  "mcpServers": {
    "appstoreconnect": {
      "command": "asc-cli",
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

Run `asc-cli --help` or `asc <command> --help` for full options at any time.
Add `--json` to any command for machine-readable output.

### Apps

#### `asc-cli apps list`
List every app in the account.

```bash
asc-cli apps list
asc-cli apps list --limit 10 --json
```

#### `asc-cli apps get <app>`
Show every attribute of a single app. Optionally enrich with related resources
via `--include` (comma-separated).

```bash
asc-cli apps get com.example.myapp
asc-cli apps get com.example.myapp --include localizations,betaGroups,versions,builds --json
```

| `--include` value | Adds |
|---|---|
| `versions` | every App Store version + its state |
| `builds` | recent TestFlight builds |
| `localizations` | per-locale description, keywords, what's new (latest version) |
| `betaGroups` | TestFlight beta groups + public links |

### Status & summary

#### `asc-cli status <app>`
One-shot health summary: the live (published) version, any version currently
in-flight (in review / pending), and the latest TestFlight build.

```bash
asc-cli status com.example.myapp
asc-cli status com.example.myapp --json
```

### App Store versions

#### `asc-cli versions status <app>`
List App Store versions and their states (`READY_FOR_SALE`, `IN_REVIEW`,
`PENDING_DEVELOPER_RELEASE`, `REJECTED`, …).

```bash
asc-cli versions status com.example.myapp
```

#### `asc-cli versions rollout <app>`
Show phased-release progress of the live version: state, current day, and the
percentage of users it has reached.

```bash
asc-cli versions rollout com.example.myapp
```

Apple's fixed schedule: day 1 = 1%, 2 = 2%, 3 = 5%, 4 = 10%, 5 = 20%, 6 = 50%,
7 = 100%.

#### `asc-cli versions create <app> --version <X>`
Create a new, editable App Store version (the prerequisite for editing store
metadata, since live versions are read-only).

#### `asc-cli versions wait <app> --state <STATE>`
Block until any version reaches a state — useful in CI pipelines.

```bash
asc-cli versions create com.example.myapp --version 6.7.0
asc-cli versions wait com.example.myapp --state READY_FOR_SALE --timeout 3600
```

### Phased rollout control

These **change the live rollout**, so they ask for confirmation. Pass `--yes`
(`-y`) to skip the prompt in automation.

#### `asc-cli versions pause <app>`
Pause the phased rollout.

#### `asc-cli versions resume <app>`
Resume a paused rollout.

#### `asc-cli versions release <app>`
Complete the rollout — release to **all** users immediately (irreversible).

```bash
asc-cli versions pause com.example.myapp
asc-cli versions resume com.example.myapp
asc-cli versions release com.example.myapp --yes
```

### Performance & crash metrics

#### `asc-cli metrics <app>`
Aggregated Power & Performance metrics (from MetricKit): crashes/terminations,
hangs, launch time, memory, battery, disk, animation, storage — with median
(p50) and tail (p90) values per latest version, plus any regressions Apple has
flagged.

```bash
asc-cli metrics com.example.myapp                  # all categories
asc-cli metrics com.example.myapp -c TERMINATION   # one category (crash proxy)
asc-cli metrics com.example.myapp -c HANG --json
```

**CI gates** (exit non-zero on failure):

```bash
asc-cli metrics <app> --fail-on-regression           # fail if Apple flagged a regression
asc-cli metrics <app> -c TERMINATION --fail-above 1.0 # fail if median crash rate exceeds 1.0/day
```

### Version comparison

#### `asc-cli compare <app>`
Compare two versions' metrics and report each metric's percent change. All
metrics are lower-is-better, so a **positive change is a regression**. Defaults
to the two latest versions with data.

```bash
asc-cli compare com.example.myapp                       # two latest versions
asc-cli compare com.example.myapp --from 6.4.0 --to 6.6.0
asc-cli compare com.example.myapp --fail-above-pct 25   # fail if a metric worsened >25%
```

### TestFlight

#### `asc-cli testflight builds <app>`
List recent TestFlight builds and their processing state.

```bash
asc-cli testflight builds com.example.myapp
asc-cli testflight builds com.example.myapp --limit 50 --json
```

#### `asc-cli builds latest <app>`
The most recently uploaded build and whether it finished processing
(`ready: true` once `processingState` is `VALID`). Closes the loop after a CI
upload.

```bash
asc-cli builds latest com.example.myapp --json
```

#### `asc-cli builds wait <app>`
Block until the latest build finishes processing — exits `0` when `VALID`,
non-zero on a failure state, `124` on timeout. Ideal right after a CI upload.

```bash
asc-cli builds wait com.example.myapp --timeout 1800 --interval 30
```

#### Beta groups & testers
List groups and testers; manage testers (writes prompt for confirmation).

```bash
asc-cli testflight groups com.example.myapp
asc-cli testflight testers com.example.myapp --group <group-id>
asc-cli testflight add-tester --group <group-id> --email t@example.com --first Ada --last Lovelace
asc-cli testflight remove-tester --group <group-id> --tester <tester-id>
asc-cli testflight create-group com.example.myapp --name "Beta crew"
```

### Customer reviews

#### `asc-cli reviews list <app>`
Recent reviews, newest first. Filter by rating or territory.

```bash
asc-cli reviews list com.example.myapp --limit 20
asc-cli reviews list com.example.myapp --rating 1 --json   # only 1-star
```

#### `asc-cli reviews reply <review-id> --body "..."`
Publish a **public** developer response to a review. Prompts to confirm; pass
`--yes` in CI.

```bash
asc-cli reviews reply 00000000-... --body "Thanks for the feedback!"
```

### Diagnostics

#### `asc-cli diagnostics <app>`
Diagnostic signatures (hangs / disk writes) for a build — defaults to the latest.
Complements `metrics` with per-build detail.

```bash
asc-cli diagnostics com.example.myapp
asc-cli diagnostics com.example.myapp --type HANGS --json
```

### Store page metadata

Read and edit per-locale store text (description, keywords, what's new,
promotional text, marketing/support URLs). Editing targets the **editable**
version — create one first with `versions create` if needed.

```bash
asc-cli localizations list com.example.myapp
asc-cli localizations get com.example.myapp --locale en-US
asc-cli localizations set com.example.myapp --locale en-US \
  --whats-new "Bug fixes and improvements" --keywords "bible,prayer,verse"
```

Editable fields: `--description`, `--keywords`, `--whats-new`, `--promo`,
`--marketing-url`, `--support-url`. Set one locale per call.

### Review submission

```bash
asc-cli submissions com.example.myapp          # submission history
asc-cli submit com.example.myapp               # submit the editable version (prompts)
asc-cli submit com.example.myapp --version 6.7.0 --yes
```

### Release workflow

#### `asc-cli release status <app>`
One dashboard combining live version + rollout, in-flight version + its
submission state, and latest build readiness.

```bash
asc-cli release status com.example.myapp --json
```

#### `asc-cli release ship <app>`
Ensure an editable version exists (create it with `--version` if none) and
submit it for review. Prompts to confirm; `--no-submit` prepares only.

```bash
asc-cli release ship com.example.myapp --version 6.7.0
```

### Sales reports

> Requires a **Finance** (or Admin) API key and your account's **vendor number**
> (App Store Connect → Payments and Financial Reports).

Download and summarize a sales report (units by title and country):

```bash
asc-cli sales <vendor-number> --date 2026-06-22 --frequency DAILY --json
```

### Webhooks

> Requires an **Admin** App Store Connect API key (read/manage webhooks is not
> available to lower roles).

```bash
asc-cli webhooks list <app>
asc-cli webhooks create <app> --url https://example.com/hook --secret S3CR3T --events APP_STORE_VERSION_APP_VERSION_STATE_UPDATED
asc-cli webhooks deliveries <webhook-id>   # delivery history, for debugging
asc-cli webhooks delete <webhook-id>
```

---

## JSON output

Every command accepts `--json`, emitting structured output to stdout — ideal for
piping into `jq`, feeding AI tools, or parsing in CI.

```bash
asc-cli status com.example.myapp --json | jq '.liveVersion'
```

---

## Exit codes

| Code | Meaning |
|---|---|
| `0` | Success |
| `1` | API error (e.g. the request was rejected) |
| `2` | Configuration error (missing/invalid credentials or arguments) |
| `3` | A CI gate failed (`--fail-on-regression`, `--fail-above`, `--fail-above-pct`) |
| `124` | A `wait` command timed out |

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
          brew install asc-cli
      - name: Status
        run: asc-cli status com.example.myapp
      - name: Fail on metric regression
        run: asc-cli metrics com.example.myapp --fail-on-regression
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
