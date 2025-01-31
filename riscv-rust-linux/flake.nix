{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [
          rust-overlay.overlays.default
          (final: prev: {
            rustToolchain = let rust = prev.rust-bin;
            in if builtins.pathExists ./rust-toolchain.toml then
              rust.fromRustupToolchainFile ./rust-toolchain.toml
            else if builtins.pathExists ./rust-toolchain then
              rust.fromRustupToolchainFile ./rust-toolchain
            else
              rust.nightly.latest.default.override {
                extensions = [ "rust-src" "rustfmt" ];
                targets = [ "riscv64gc-unknown-linux-gnu" ];
              };
          })
        ];

        # pkgs = nixpkgs.legacyPackages.${system};
        pkgs = import nixpkgs { inherit overlays system; };
        riscvPkgs = pkgs.pkgsCross.riscv64;

        spike = with pkgs;
          stdenv.mkDerivation rec {
            pname = "spike";
            version = "master";
            src = fetchFromGitHub {
              owner = "riscv-software-src";
              repo = "riscv-isa-sim";
              rev = "18f4d0ff13ce8d6933ddaf080dfbc5aa2217d2ab";
              sha256 = "sha256-XIwXiNc0v9++0JQjXJw2iRmAVo90JDpuTH3bQnZqvqE=";
            };
            nativeBuildInputs = [ dtc ];
            enableParallelBuilding = true;
          };

      in with pkgs; {

        # https://discourse.nixos.org/t/risc-v-cross-compilation-on-aarch64-darwin/38721
        # https://ayats.org/blog/nix-cross
        # https://nixos.wiki/wiki/Cross_Compiling
        devShells.default = riscvPkgs.mkShell {
          # get rid of ld warnings
          # https://nixos.org/manual/nixpkgs/stable/#sec-hardening-in-nixpkgs
          hardeningDisable = [ "relro" "bindnow" ];
          packages = [
            rustToolchain
            openssl
            pkg-config
            cargo-deny
            cargo-edit
            cargo-watch
            rust-analyzer
            riscvPkgs.buildPackages.gdb
            # riscvPkgs.buildPackages.gcc
            riscvPkgs.buildPackages.dtc
            # riscvPkgs.buildPackages.binutils
            spike
            riscvPkgs.riscv-pk
            qemu
            lima
          ];
        };
      });
}
