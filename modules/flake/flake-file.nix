{ inputs, ... }:

{
  imports = [
    inputs.flake-file.flakeModules.dendritic
  ];

  flake-file = {
    description = "7mochi's Niri Noctalia setup";

    inputs = {
      flake-file.url = "github:denful/flake-file";

      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

      flake-parts = {
        url = "github:hercules-ci/flake-parts";
        inputs.nixpkgs-lib.follows = "nixpkgs";
      };

      import-tree.url = "github:vic/import-tree";

      treefmt-nix = {
        url = "github:numtide/treefmt-nix";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      home-manager = {
        url = "github:nix-community/home-manager/master";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      niri.url = "github:sodiboo/niri-flake";

      noctalia = {
        url = "github:noctalia-dev/noctalia/cachix";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      sops-nix = {
        url = "github:Mic92/sops-nix";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

      nix-flatpak.url = "github:gmodena/nix-flatpak?ref=v0.7.0";

      zen-browser = {
        url = "github:0xc000022070/zen-browser-flake";
        inputs.nixpkgs.follows = "nixpkgs";
        inputs.home-manager.follows = "home-manager";
      };

      firefox-addons = {
        url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      nix-vscode-extensions = {
        url = "github:nix-community/nix-vscode-extensions";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      nix-jetbrains-plugins = {
        url = "github:nix-community/nix-jetbrains-plugins";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      llm-agents = {
        url = "github:numtide/llm-agents.nix";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      qylock = {
        url = "github:Darkkal44/qylock";
        flake = false;
      };

      agent-skills = {
        url = "github:Kyure-A/agent-skills-nix";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      quarkus-skills = {
        url = "github:quarkusio/skills";
        flake = false;
      };

      nix-osu-stable = {
        url = "github:gaavin/nix-osu-stable";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      deadband = {
        url = "git+https://codeberg.org/Epaphroditus/gamesir-linux-tools-nix";
        inputs.nixpkgs.follows = "nixpkgs";
        inputs.upstream-src.follows = "deadband-src";
      };

      deadband-src = {
        url = "github:broroeror/gamesir-linux-tools/v0.5.0";
        flake = false;
      };
    };

    nixConfig = {
      extra-substituters = [
        "https://niri.cachix.org"
        "https://noctalia.cachix.org"
        "https://cache.xinux.uz"
        "https://cache.numtide.com"
      ];
      extra-trusted-public-keys = [
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
        "cache.xinux.uz:BXCrtqejFjWzWEB9YuGB7X2MV4ttBur1N8BkwQRdH+0="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };
  };
}
