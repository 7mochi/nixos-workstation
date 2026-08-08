_:

{
  flake.modules.nixos.shared =
    { pkgs, ... }:

    {
      environment.systemPackages = with pkgs; [
        # Toolchain manager: rustup shims provide rustc/cargo/rustfmt/clippy and
        # let projects pin a channel with a rust-toolchain.toml file.
        rustup

        # Editor support and common cargo subcommands.
        rust-analyzer
        cargo-audit
        cargo-edit
        cargo-nextest
        cargo-watch
        bacon

        # Native dependencies commonly needed when compiling Rust crates.
        gcc
        openssl
        pkg-config
      ];
    };
}
