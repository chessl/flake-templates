{
  description =
    "Personal, ready-made templates for easily creating flake-driven environments";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      overlays = [
        (final: prev:
          let
            getSystem =
              "SYSTEM=$(nix eval --impure --raw --expr 'builtins.currentSystem')";
            forEachDir = exec: ''
              for dir in */; do
                (
                  cd "''${dir}"

                  ${exec}
                )
              done
            '';
          in {
            format = final.writeShellApplication {
              name = "format";
              runtimeInputs = with final; [
                nixpkgs-fmt
                (mdformat.withPlugins (p:
                  with p;
                  [
                    mdformat-tables
                    # mdformat-footnote
                    # mdformat-frontmatter
                    # mdformat-beautysh
                    # mdformat-shfmt
                    # mdformat-web
                    # mdformat-gofmt
                    # mdformat-rustfmt
                  ]))

              ];
              text = ''
                nixpkgs-fmt -- **/*.nix
                mdformat README.md
              '';
            };

            # only run this locally, as Actions will run out of disk space
            build = final.writeShellApplication {
              name = "build";
              text = ''
                ${getSystem}

                ${forEachDir ''
                  echo "building ''${dir}"
                  nix build ".#devShells.''${SYSTEM}.default"
                ''}
              '';
            };

            check = final.writeShellApplication {
              name = "check";
              text = forEachDir ''
                echo "checking ''${dir}"
                nix flake check --all-systems --no-build
              '';
            };

            dvt = final.writeShellApplication {
              name = "dvt";
              text = ''
                if [ -z $1 ]; then
                  echo "no template specified"
                  exit 1
                fi

                TEMPLATE=$1

                nix \
                  --experimental-features 'nix-command flakes' \
                  flake init \
                  --template \
                  "github:the-nix-way/dev-templates#''${TEMPLATE}"
              '';
            };

            update = final.writeShellApplication {
              name = "update";
              text = forEachDir ''
                echo "updating ''${dir}"
                nix flake update
              '';
            };
          })
      ];
      supportedSystems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f:
        nixpkgs.lib.genAttrs supportedSystems
        (system: f { pkgs = import nixpkgs { inherit overlays system; }; });
    in {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [ build check format update nixpkgs-fmt ];
        };
      });

      packages = forEachSupportedSystem ({ pkgs }: rec {
        default = dvt;
        inherit (pkgs) dvt;
      });
    }

    //

    {
      templates = rec {
        c-cpp = {
          path = ./c-cpp;
          description = "C/C++ development environment";
        };

        empty = {
          path = ./empty;
          description = "Empty dev template that you can customize at will";
        };

        go = {
          path = ./go;
          description = "Go (Golang) development environment";
        };

        haskell = {
          path = ./haskell;
          description = "Haskell development environment";
        };

        idris = {
          path = ./idris;
          description = "Idris2 development environment";
        };

        node = {
          path = ./node;
          description = "Node.js development environment";
        };

        ruby = {
          path = ./ruby;
          description = "Ruby development environment";
        };

        rust = {
          path = ./rust;
          description =
            "Rust development environment with Rust version defined by a rust-toolchain.toml file";
        };

        rust-toolchain = {
          path = ./rust-toolchain;
          description =
            "Rust development environment with Rust version defined by a rust-toolchain.toml file";
        };

        riscv = {
          path = ./riscv;
          description = "RISC-V assembly toolchain";
        };

        bluespec = {
          path = ./bluespec;
          description = "Bluespec dev env";
        };

        clash = {
          path = ./clash;
          description = "Clash dev env";
        };

        zig = {
          path = ./zig;
          description = "Zig development environment";
        };

        markdown = {
          path = ./markdown;
          description = "Markdown writing environment";
        };

        # Aliases
        nodejs = node;
        rt = rust-toolchain;
        c = c-cpp;
        cpp = c-cpp;
      };
    };
}
