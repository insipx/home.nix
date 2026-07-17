{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ inputs.mcp-servers.homeManagerModules.default ];

  # Declarative MCP servers, surfaced through home-manager's programs.mcp
  # and consumed by claude-code via enableMcpIntegration (delivered as a
  # wrapped --plugin-dir, so ~/.claude.json is never touched).
  programs.mcp.enable = true;

  mcp-servers.programs = {
    filesystem = {
      enable = true;
      args = [ config.home.homeDirectory ];
    };

    nixos.enable = true;

    github = {
      enable = true;
      # Token resolved at server start, never written to the nix store
      passwordCommand.GITHUB_PERSONAL_ACCESS_TOKEN = [
        "${pkgs.gh}/bin/gh"
        "auth"
        "token"
      ];
    };

    notion = {
      enable = true;
      # Create this file with: NOTION_TOKEN=ntn_xxx
      envFile = "${config.home.homeDirectory}/.config/mcp/notion.env";
    };
  };

  # Servers without an mcp-servers-nix module
  mcp-servers.settings.servers = {
    # Official Datadog remote MCP server; claude-code does OAuth at runtime
    datadog = {
      url = "https://mcp.datadoghq.com/v1/mcp";
    };
    # Needs a graph: run `code-review-graph build` once per repo
    code-review-graph = {
      command = lib.getExe pkgs.llm-agents.code-review-graph;
      args = [ "serve" ];
    };
    linear = {
      url = "https://mcp.linear.app/mcp";
    };
    okx = {
      url = "https://www.okx.com/api/v1/mcp/trading-oauth";
    };
    # Bare `semble` (no subcommand) is the stdio MCP server. Use the nix
    # package directly - `uvx` is not on PATH here, and would re-download a
    # second copy of semble at server start anyway.
    semble = {
      command = lib.getExe pkgs.llm-agents.semble;
    };
  };

  programs.claude-code = {
    enable = true;
    package = pkgs.llm-agents.claude-code;
    enableMcpIntegration = true;
  };

  # Codex consumes the same programs.mcp.servers set, so code-review-graph and
  # the rest arrive without a second declaration. The binary comes from
  # environment.systemPackages in common.nix, so package is null here to avoid
  # a duplicate copy in the home profile.
  #
  # NOTE: this makes ~/.codex/config.toml a read-only store symlink. Anything
  # Codex used to write there itself now has to be declared in `settings`.
  programs.codex = {
    enable = true;
    package = null;
    enableMcpIntegration = true;

    # ~/.codex/AGENTS.md: global context merged into every session, including
    # `codex review`, so the graph is the default entry point into a codebase
    # rather than something Codex has to be reminded of per-session.
    context = ''
      ## Version control

      These are colocated `jj` repos. Use `jj` for all version control work:
      `jj status`, `jj diff`, `jj log`, `jj new`, `jj describe`, `jj squash`.

      Never run mutating `git` commands - `commit`, `add`, `checkout`,
      `branch`, `rebase`, `merge`, `push`, `reset`, `stash`. They desync the
      jj working copy.

      Read-only `git` inspection is fine where `jj` has no equivalent, and
      `codex review` builds its diff through git internally. That is expected;
      do not work around it.

      ## Code review and codebase structure

      For PR review, code review, or any task needing structural understanding
      of a codebase (impact analysis, "what calls this", architecture overview,
      blast radius of a change), use the `code-review-graph` MCP tools instead
      of cold grep/read exploration.

      1. `build_or_update_graph_tool` first, if the graph is missing or stale.
      2. Then, as the task needs:
         - `get_review_context_tool` - focused context for a diff
         - `get_impact_radius_tool` - blast radius of a change
         - `get_affected_flows_tool` - end-to-end flows a change touches
         - `query_graph_tool` - targeted structural queries
         - `get_architecture_overview_tool` - orientation in an unfamiliar repo
         - `cross_repo_search_tool` - search across indexed repos

      Fall back to `rg` and raw file reads only after the graph has been
      consulted, or when the graph has no answer for the question.
    '';

    settings = {
      # Trusted project roots. Codex normally records these itself when you
      # approve a folder; with config.toml owned by home-manager, new ones go
      # here instead.
      projects."/home/insipx".trust_level = "trusted";
      projects."/home/insipx/code/xmtplabs/convos-backend".trust_level = "trusted";

      # Dismissed model-availability notices. Cosmetic; safe to drop.
      tui.model_availability_nux = {
        "gpt-5.5" = 1;
        "gpt-5.6-sol" = 1;
      };
    };

    # ~/.codex/hooks.json. Keeps the graph fresh without the agent having to
    # remember to rebuild it. `code-review-graph` is pinned to the same store
    # path the MCP server uses so the hook and the tools can never drift to
    # different versions.
    #
    # The `git rev-parse --git-dir` guard is repo detection, not agent VCS
    # usage - it succeeds in colocated jj repos, which all of these are. The
    # leading `cat >/dev/null` drains the hook's JSON payload on stdin so the
    # command does not see a broken pipe.
    hooks = {
      PostToolUse = [
        {
          matcher = "Write|Edit|Bash";
          hooks = [
            {
              type = "command";
              command = "cat >/dev/null || true; git rev-parse --git-dir >/dev/null 2>&1 && ${lib.getExe pkgs.llm-agents.code-review-graph} update --skip-flows || true";
              timeout = 30;
              statusMessage = "Updating code-review-graph";
            }
          ];
        }
      ];
      SessionStart = [
        {
          matcher = "startup|resume";
          hooks = [
            {
              type = "command";
              command = "cat >/dev/null || true; git rev-parse --git-dir >/dev/null 2>&1 && ${lib.getExe pkgs.llm-agents.code-review-graph} status || echo 'Not a git repo, skipping'";
              timeout = 10;
              statusMessage = "Checking code-review-graph status";
            }
          ];
        }
      ];
    };
  };
  home.packages = with pkgs.llm-agents; [
    claude-plugins
    semble
    herdr
  ];
  # `/code-review` slash command in the Codex TUI. The home-manager codex
  # module has no `prompts` option, so write the file directly.
  home.file.".codex/prompts/code-review.md".text = ''
    Review the changes in this repository.

    1. Run `build_or_update_graph_tool` so the code-review-graph index is
       current for this repo.
    2. Call `get_review_context_tool` for the diff under review, and
       `get_impact_radius_tool` for each changed symbol that is not obviously
       local.
    3. Use `get_affected_flows_tool` to check whether any end-to-end flow
       changes behavior.

    Report findings most severe first. For each one give file:line, what
    breaks, and the concrete input or state that triggers it. Say so plainly
    if nothing of consequence turns up.
  '';
}
