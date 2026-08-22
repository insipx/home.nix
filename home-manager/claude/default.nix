{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  vendoredSkills = lib.genAttrs [
    "android-nixpkgs"
    "nixpkgs-contributions"
    "orchestrating-pr-agents"
  ] (name: ./skills + "/${name}");

  cloudflareSkills = lib.genAttrs [
    "agents-sdk"
    "cloudflare"
    "cloudflare-email-service"
    "cloudflare-one"
    "cloudflare-one-migrations"
    "durable-objects"
    "turnstile-spin"
    "web-perf"
    "workers-best-practices"
    "wrangler"
  ] (name: "${inputs.cloudflare-skills}/skills/${name}");

  researchSkills = lib.genAttrs [
    "research"
    "research-add-fields"
    "research-add-items"
    "research-deep"
    "research-report"
  ] (name: "${inputs.research-skills}/skills/research-en/${name}");
in
{
  programs.claude-code = {
    context = ./CLAUDE.md;
    hooksDir = ./hooks;
    agentsDir = ./agents;

    skills =
      vendoredSkills
      // cloudflareSkills
      // researchSkills
      // {
        hallmark = "${inputs.hallmark-skill}/skills/hallmark";
        gh-stack = "${inputs.gh-stack-skill}/skills/gh-stack";
        adversarial-review = "${inputs.noodle-skills}/.agents/skills/adversarial-review";
        jujutsu = "${inputs.jujutsu-skill}/jujutsu";
      };

    plugins = [
      (pkgs.fetchFromGitHub {
        name = "code-simplifier";
        owner = "anthropics";
        repo = "claude-plugins-official";
        rev = "6d578313aa15e37f0562afb7535f6d0d5e612040";
        hash = "sha256-cB3KY7jTCjiYOLrxiEO6QL3xNxfpFV1B04L+CDNbV8E=";
      })
      (pkgs.fetchFromGitHub {
        name = "claudish-to-english";
        owner = "gvzdv";
        repo = "claudish-to-english";
        rev = "2c78a0ff4f5bfed96244c6de58f4a2be106d6873";
        hash = "sha256-C0OnpiKGOORmZUpxdOCAN/oASlK8gCwaEyRNu7gTfVU=";
      })
      (pkgs.fetchFromGitHub {
        name = "ponytail";
        repo = "ponytail";
        owner = "DietrichGebert";
        rev = "2ed6c52c9d7e5e56942508591085fd45dea277d3";
        hash = "sha256-bGdXvzhWPwGdz3T2Yh2h6lf+3PBRFAfdBxP5pESmCHI=";
      })
    ];
  };

  home.file."${config.programs.claude-code.configDir}/statusline.sh" = {
    source = ./statusline.sh;
    executable = true;
  };

  home.packages = with pkgs; [
    llm-agents.code-review-graph
    llm-agents.codex
    mcp-server-filesystem
    notion-mcp-server
    github-mcp-server
    mcp-nixos
  ];
}
