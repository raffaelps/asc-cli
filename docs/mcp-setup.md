# Install the ASC MCP server

`asc-cli mcp` is a local STDIO server. The AI client starts and manages the
process. Install the CLI on the same machine where the client runs its tools.
No Node.js, npm package, extra Python MCP installation, or listening port is
needed when using the precompiled binary.

## Prerequisites

```bash
brew install raffaelps/asc-cli/asc-cli
# If already installed: brew update && brew upgrade asc-cli
asc-cli --version
command -v asc-cli
```

Source-checkout alternative: `pipx install .` (Python 3.10+). The published
standalone binaries support macOS Apple Silicon and Linux x86_64. For Windows,
use a Python source installation and its absolute executable path, or run both
the AI client tooling and ASC inside WSL.

Create an App Store Connect API key and obtain its Issuer ID, Key ID and `.p8`
private-key file. Use a key with permissions for your tasks; financial reports
need Finance/Admin access. Prefer a path to the key over copying the PEM into
client configuration. On macOS/Linux:

```bash
chmod 600 /absolute/path/AuthKey_ABCD1234EF.p8
```

Replace all placeholder IDs and paths below. The executable path used in the
examples, `/opt/homebrew/bin/asc-cli`, is typical on Apple Silicon; use the path
printed by `command -v asc-cli` on your machine. For pipx it may be under
`~/.local/bin`; expand `~` to the absolute home directory. On Windows, use escaped
backslashes in JSON or forward slashes and the actual `asc-cli.exe` path.

Merge entries into existing configuration instead of replacing other servers.
Keep configurations containing account details out of source control.

## Shared JSON configuration

The following `mcpServers` format is used by Claude Desktop and Gemini CLI;
Cursor and Copilot use small adaptations described below:

```json
{
  "mcpServers": {
    "appstoreconnect": {
      "command": "/opt/homebrew/bin/asc-cli",
      "args": ["mcp"],
      "env": {
        "ASC_ISSUER_ID": "00000000-0000-0000-0000-000000000000",
        "ASC_KEY_ID": "ABCD1234EF",
        "ASC_PRIVATE_KEY_PATH": "/absolute/path/AuthKey_ABCD1234EF.p8"
      }
    }
  }
}
```

Desktop applications may not inherit your terminal environment. Providing
`env` explicitly and using absolute paths avoids that dependency.

## Codex

Add to your user configuration at `~/.codex/config.toml`:

```toml
[mcp_servers.appstoreconnect]
command = "/opt/homebrew/bin/asc-cli"
args = ["mcp"]
startup_timeout_sec = 30
tool_timeout_sec = 180

[mcp_servers.appstoreconnect.env]
ASC_ISSUER_ID = "00000000-0000-0000-0000-000000000000"
ASC_KEY_ID = "ABCD1234EF"
ASC_PRIVATE_KEY_PATH = "/absolute/path/AuthKey_ABCD1234EF.p8"
```

Or use the installed Codex CLI:

```bash
codex mcp add appstoreconnect \
  --env ASC_ISSUER_ID="YOUR_ISSUER_ID" \
  --env ASC_KEY_ID="YOUR_KEY_ID" \
  --env ASC_PRIVATE_KEY_PATH="/absolute/path/AuthKey_YOUR_KEY_ID.p8" \
  -- /opt/homebrew/bin/asc-cli mcp
codex mcp list
```

Restart the local client/server after changing configuration. This applies to
the Codex local host, including desktop and IDE clients that share that config.
If `codex` is not on PATH, use the TOML method; the CLI command is optional.
Hosted ChatGPT web sessions do not read this local file.

[Official Codex MCP documentation](https://learn.chatgpt.com/docs/extend/mcp).

## Claude Desktop

In Claude Desktop's developer settings, open the MCP configuration and merge
the shared JSON above. Common file locations:

- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`
- Linux: `~/.config/Claude/claude_desktop_config.json`

Quit and reopen the application. Confirm `appstoreconnect` appears in the tools
list and ask it to list your apps. Use local MCP configuration; the web account's
remote connector URL field cannot launch this STDIO command.

[Official local-server guide](https://modelcontextprotocol.io/docs/develop/connect-local-servers).

## Claude Code

Register for your user account:

```bash
claude mcp add \
  --env ASC_ISSUER_ID="YOUR_ISSUER_ID" \
  --env ASC_KEY_ID="YOUR_KEY_ID" \
  --env ASC_PRIVATE_KEY_PATH="/absolute/path/AuthKey_YOUR_KEY_ID.p8" \
  --transport stdio --scope user appstoreconnect \
  -- /opt/homebrew/bin/asc-cli mcp
claude mcp list
claude mcp get appstoreconnect
```

Keep `--transport` / `--scope` between the environment options and server name,
and keep `--` before the executable. Use `/mcp` inside Claude Code to inspect
the connection.

[Official Claude Code MCP documentation](https://code.claude.com/docs/en/mcp).

## Cursor

Merge the shared JSON into your personal `~/.cursor/mcp.json` and add
`"type": "stdio"` inside the `appstoreconnect` server entry, alongside `command`.
Cursor also supports project configuration at `.cursor/mcp.json`; avoid putting
private credentials in a shared project file. Enable the server in Cursor's MCP
settings and inspect its status before asking the agent to list apps.

[Official Cursor MCP documentation](https://cursor.com/docs/mcp).

## VS Code / GitHub Copilot

For the current Copilot harness, open **Chat: Open Customizations**, choose
**MCP Servers**, then **Add Server**, and select a STDIO command. Use the
executable, `mcp` argument and three environment variables from the shared JSON.
Choose **Global > Copilot Global** for a personal installation.

Alternatively, merge the shared JSON into `~/.copilot/mcp-config.json` and add
`"type": "stdio"` and `"tools": ["*"]` inside the server entry. If
`COPILOT_HOME` is set, use its `mcp-config.json` instead.

Older/editor-managed Local configurations use `.vscode/mcp.json` with a
top-level `servers` object instead of `mcpServers`. For that format only:

```json
{
  "servers": {
    "appstoreconnect": {
      "type": "stdio",
      "command": "/opt/homebrew/bin/asc-cli",
      "args": ["mcp"],
      "env": {
        "ASC_ISSUER_ID": "00000000-0000-0000-0000-000000000000",
        "ASC_KEY_ID": "ABCD1234EF",
        "ASC_PRIVATE_KEY_PATH": "/absolute/path/AuthKey_ABCD1234EF.p8"
      }
    }
  }
}
```

Use the configuration appropriate to the selected harness. Restart the server
and verify a tool call in agent chat; in Remote SSH/Containers/WSL the executable
and key must exist in the tooling execution environment.

[Official VS Code MCP configuration reference](https://code.visualstudio.com/docs/agents/reference/mcp-configuration).

## Gemini CLI

Merge the shared JSON into `~/.gemini/settings.json` for user scope, or
`.gemini/settings.json` for a single project. Keep existing settings alongside
`mcpServers`. Restart Gemini CLI and inspect the server with `/mcp`; use
`gemini mcp list` from the terminal to inspect configured servers.

[Official Gemini CLI MCP documentation](https://geminicli.com/docs/tools/mcp-server/).

## Windsurf / Cascade

For versions offering custom local MCP servers, open the MCP configuration
from the client's settings and merge the shared `mcpServers` JSON above. Use a
local command/STDIO entry, the absolute ASC executable, `args: ["mcp"]`, and the
three `env` variables. Reload the server and verify it in Cascade's tool list.

The vendor's [Windsurf MCP documentation](https://docs.windsurf.com/windsurf/cascade/mcp)
currently redirects to [Devin Desktop customizations](https://docs.devin.ai/desktop/devin-local/customizations).
The configuration path/UI varies by installed product version, so open it from
the application instead of assuming a legacy config-file location. This client
recipe has not been exercised here; use the vendor's current UI as the authority.

## Enable write tools explicitly

The default `args: ["mcp"]` exposes read tools only. To expose actions such as
rollout control, review replies, metadata editing, submission, tester changes,
and analytics subscription setup, change arguments to:

```json
["mcp", "--enable-writes"]
```

For CLI registration, append `--enable-writes` after the server's `mcp` argument.
Restart the MCP server after changing it. Client approvals and your Apple key's
permissions still apply; leave writes disabled for reporting-only workflows.

## Verify and troubleshoot

1. Run `asc-cli --version` and `asc-cli mcp --help` in the environment where the
   AI client runs. After updating the binary, restart its MCP process.
2. Confirm the server is connected, then ask: “Use appstoreconnect to list my
   apps.” A successful tool call verifies Apple credentials as well as MCP.
3. For financial summaries, provide your Vendor Number and API fiscal code.
   Ask the agent to report `periodStart`, `periodEnd`, and `periodWarning`.
4. `command not found` / `ENOENT`: replace `command` with the absolute path
   printed by `command -v asc-cli` (or `where asc-cli` on Windows).
5. Credential errors: check the three ASC variables, key permissions and the
   `.p8` path as seen by the client. A project `.env` is not automatically loaded
   by ASC. `403` may indicate insufficient Apple role permissions.
6. A running `asc-cli mcp` looks idle in a terminal: it waits for protocol input.
   Let the AI client start it; don't point it at the ASC REST API URL as an MCP URL.

Examples were checked against official client documentation in November 2026.
JSON/TOML syntax and ASC STDIO startup are validated locally; this is not a claim
of end-to-end testing in every listed AI application.
