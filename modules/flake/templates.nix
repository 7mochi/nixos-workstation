_:

{
  flake.templates = {
    node = {
      path = ../../templates/node;
      description = "TypeScript Node.js service with pnpm, tsx, Vitest, and a Nix dev shell";
    };

    bun = {
      path = ../../templates/bun;
      description = "TypeScript Bun service with Bun test and a Nix dev shell";
    };

    python = {
      path = ../../templates/python;
      description = "Python project with uv, pytest, ruff, pyright, and a Nix dev shell";
    };

    rust = {
      path = ../../templates/rust;
      description = "Rust binary project with cargo, rustfmt, clippy, rust-analyzer, and a Nix dev shell";
    };

    local-services = {
      path = ../../templates/local-services;
      description = "Docker Compose recipes for PostgreSQL, Redis, MySQL, Valkey, and Mailpit";
    };
  };
}
