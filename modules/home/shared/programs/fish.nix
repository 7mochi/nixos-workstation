_:

{
  flake.modules.homeManager.fish = {
    programs.fish = {
      enable = true;

      interactiveShellInit = ''
        if command -q mise
          mise activate fish | source
        end

        if command -q zoxide
          zoxide init fish | source
        end

        if command -q atuin
          atuin init fish | source
        end
      '';

      shellInit = ''
        fish_add_path -g $HOME/.local/bin
      '';

      shellAliases = {
        rebuild = "nh os switch path:$HOME/Documents/nixos-workstation#$hostname";
        update = "nix flake update --flake path:$HOME/Documents/nixos-workstation && nh os switch path:$HOME/Documents/nixos-workstation#$hostname";
        update-pkgs = "just --justfile $HOME/Documents/nixos-workstation/Justfile update-pkgs";
        check = "nix flake check --no-build path:$HOME/Documents/nixos-workstation";
        drybuild = "nix build path:$HOME/Documents/nixos-workstation#nixosConfigurations.$hostname.config.system.build.toplevel --dry-run";
        diff = "nix build path:$HOME/Documents/nixos-workstation#nixosConfigurations.$hostname.config.system.build.toplevel && nvd diff /run/current-system result";
        doctor = "check && drybuild";
        ports = "lsof -Pan -iTCP -sTCP:LISTEN";
        nc = "cd $HOME/Documents/nixos-workstation";
        work = "cd $HOME/Work";
        c = "clear";
        cat = "bat";
        du = "dust";
        ll = "eza -la --icons=auto --group-directories-first";
        ls = "eza --icons=auto --group-directories-first";
        la = "eza -la --icons=auto --group-directories-first";
        lt = "eza --tree --icons=auto --group-directories-first";
        grep = "rg";
        find = "fd";
        top = "btop";
        g = "git";
        gs = "git status --short --branch";
        ga = "git add";
        gc = "git commit";
        gp = "git push";
        gl = "git lg";
        lg = "lazygit";
        ld = "lazydocker";
        k = "kubectl";
        tf = "tofu";
        serve3000 = "serve 3000";
        dcu = "docker compose up -d";
        dcd = "docker compose down";
        dcl = "docker compose logs -f";
        dcp = "docker compose ps";
        ndev = "nix develop";
        nrun = "nix run";
        nshell = "nix shell";
        nsearch = "nix search nixpkgs";
        nixgc = "nix store gc";
        ghpr = "gh pr create";
        ghco = "gh pr checkout";
        ghpv = "gh pr view --web";
      };

      functions = {
        tpl = ''
          if test (count $argv) -lt 1
            echo "usage: tpl <node|bun|python|rust|local-services> [directory]"
            return 1
          end

          set template $argv[1]

          if test (count $argv) -ge 2
            nix flake new -t "path:$HOME/Documents/nixos-workstation#$template" -- $argv[2]
          else
            nix flake init -t "path:$HOME/Documents/nixos-workstation#$template"
          end
        '';

        tnode = ''
          tpl node $argv
        '';

        tbun = ''
          tpl bun $argv
        '';

        tpython = ''
          tpl python $argv
        '';

        trustproj = ''
          tpl rust $argv
        '';

        tservices = ''
          tpl local-services $argv
        '';

        mkcd = ''
          mkdir -p -- $argv[1]
          and cd -- $argv[1]
        '';

        extract = ''
          if test (count $argv) -ne 1
            echo "usage: extract <archive>"
            return 1
          end

          switch $argv[1]
            case "*.tar.bz2" "*.tbz2"
              tar xjf $argv[1]
            case "*.tar.gz" "*.tgz"
              tar xzf $argv[1]
            case "*.tar.xz" "*.txz"
              tar xJf $argv[1]
            case "*.tar.zst" "*.tzst"
              tar --zstd -xf $argv[1]
            case "*.tar"
              tar xf $argv[1]
            case "*.zip"
              unzip $argv[1]
            case "*.gz"
              gunzip $argv[1]
            case "*.bz2"
              bunzip2 $argv[1]
            case "*.xz"
              unxz $argv[1]
            case "*"
              echo "extract: unsupported archive: $argv[1]"
              return 1
          end
        '';

        compress = ''
          if test (count $argv) -ne 1
            echo "usage: compress <file-or-directory>"
            return 1
          end

          set target (string replace -r '/$' "" -- $argv[1])
          tar czf "$target.tar.gz" -- "$target"
        '';

        serve = ''
          set port 8000
          if test (count $argv) -ge 1
            set port $argv[1]
          end

          python3 -m http.server $port
        '';

        fip = ''
          if test (count $argv) -lt 2
            echo "usage: fip <remote> <port> [port...]"
            return 1
          end

          set remote $argv[1]
          for port in $argv[2..-1]
            set socket "$XDG_RUNTIME_DIR/ssh-fwd-$remote-$port"
            ssh -M -S "$socket" -fN -L "$port:localhost:$port" "$remote"
            echo "forwarded localhost:$port -> $remote:localhost:$port"
          end
        '';

        dip = ''
          if test (count $argv) -lt 2
            echo "usage: dip <remote> <port> [port...]"
            return 1
          end

          set remote $argv[1]
          for port in $argv[2..-1]
            set socket "$XDG_RUNTIME_DIR/ssh-fwd-$remote-$port"
            ssh -S "$socket" -O exit "$remote"
          end
        '';

        lip = ''
          command ls "$XDG_RUNTIME_DIR"/ssh-fwd-* 2>/dev/null
        '';

        hlds = ''
          set -l conf /var/lib/hlds/launch.conf

          if test (count $argv) -eq 0
            systemctl status docker-hlds
            return
          end

          switch $argv[1]
            case status
              systemctl status docker-hlds
            case start
              sudo systemctl start docker-hlds
            case stop
              sudo systemctl stop docker-hlds
            case restart
              sudo systemctl restart docker-hlds
            case logs
              journalctl CONTAINER_NAME=hlds -f $argv[2..-1]
            case game
              if test (count $argv) -lt 2
                echo "usage: hlds game <name> [map]"
                return 1
              end

              set -l game $argv[2]
              if not string match -qr '^[A-Za-z0-9_-]+$' -- $game
                echo "hlds: invalid game name: $game"
                return 1
              end

              set -l map crossfire
              if test (count $argv) -ge 3
                set map $argv[3]
              else if test "$game" = ag
                set map ag_crossfire
              end

              set -l args (sed -n 's/^ARGS=//p' $conf 2>/dev/null | tail -n 1)
              test -n "$args"; or set args "+sv_lan 1 +maxplayers 12"

              mkdir -p /var/lib/hlds/config/$game
              ln -sfn /var/lib/hlds/config/$game /var/lib/hlds/config-active
              printf 'GAME=%s\nMAP=%s\nARGS=%s\n' $game $map "$args" > $conf
              sudo systemctl restart docker-hlds
              echo "hlds: $game / $map"
            case map
              if test (count $argv) -ne 2
                echo "usage: hlds map <map>"
                return 1
              end

              set -l game (sed -n 's/^GAME=//p' $conf 2>/dev/null | tail -n 1)
              test -n "$game"; or set game valve
              set -l args (sed -n 's/^ARGS=//p' $conf 2>/dev/null | tail -n 1)
              test -n "$args"; or set args "+sv_lan 1 +maxplayers 12"

              printf 'GAME=%s\nMAP=%s\nARGS=%s\n' $game $argv[2] "$args" > $conf
              sudo systemctl restart docker-hlds
              echo "hlds: $game / $argv[2]"
            case args
              if test (count $argv) -lt 2
                echo "usage: hlds args <arg> [arg...]"
                return 1
              end

              set -l game (sed -n 's/^GAME=//p' $conf 2>/dev/null | tail -n 1)
              test -n "$game"; or set game valve
              set -l map (sed -n 's/^MAP=//p' $conf 2>/dev/null | tail -n 1)
              test -n "$map"; or set map crossfire

              set -l args (string join ' ' $argv[2..-1])
              printf 'GAME=%s\nMAP=%s\nARGS=%s\n' $game $map "$args" > $conf
              sudo systemctl restart docker-hlds
              echo "hlds: $game / $map"
            case mods
              cd /var/lib/hlds/mods
            case config
              set -l game (sed -n 's/^GAME=//p' $conf 2>/dev/null | tail -n 1)
              test -n "$game"; or set game valve
              cd /var/lib/hlds/config/$game
            case info
              set -l game (sed -n 's/^GAME=//p' $conf 2>/dev/null | tail -n 1)
              test -n "$game"; or set game valve
              set -l map (sed -n 's/^MAP=//p' $conf 2>/dev/null | tail -n 1)
              test -n "$map"; or set map crossfire
              set -l args (sed -n 's/^ARGS=//p' $conf 2>/dev/null | tail -n 1)
              test -n "$args"; or set args "+sv_lan 1 +maxplayers 12"
              echo "GAME=$game"
              echo "MAP=$map"
              echo "ARGS=$args"
            case ip
              ip -brief addr show enp6s0
            case console
              docker attach hlds
            case shell
              docker exec -it hlds sh
            case help
              echo "usage: hlds <status|start|stop|restart|logs|game|map|args|mods|config|info|ip|console|shell>"
            case "*"
              echo "usage: hlds <status|start|stop|restart|logs|game|map|args|mods|config|info|ip|console|shell>"
              return 1
          end
        '';
      };
    };
  };
}
