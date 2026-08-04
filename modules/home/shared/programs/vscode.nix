{ inputs, ... }:

{
  flake.modules.homeManager.shared =
    { pkgs, ... }:

    let
      marketplace =
        pub: name: inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace.${pub}.${name};
    in
    {
      programs.vscode = {
        enable = true;
        package = pkgs.vscode;
        mutableExtensionsDir = false;

        extensions = [
          # nixpkgs (pkgs.vscode-extensions)
          pkgs.vscode-extensions.biomejs.biome
          pkgs.vscode-extensions.eamodio.gitlens
          pkgs.vscode-extensions.gruntfuggly.todo-tree
          pkgs.vscode-extensions.ms-azuretools.vscode-containers
          pkgs.vscode-extensions.ms-azuretools.vscode-docker
          pkgs.vscode-extensions.rust-lang.rust-analyzer
          pkgs.vscode-extensions.timonwong.shellcheck

          # marketplace (not in nixpkgs)
          (marketplace "1nvitr0" "censitive")
          (marketplace "abhinash" "amxxpawn-language")
          (marketplace "clemenspeters" "format-json")
          (marketplace "shakram02" "bash-beautify")
        ];
      };
    };
}
