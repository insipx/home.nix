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
      url = "https://mcp.datadoghq.com/api/mcp";
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
  };

  programs.claude-code = {
    enable = true;
    package = pkgs.llm-agents.claude-code;
    enableMcpIntegration = true;
  };
}
