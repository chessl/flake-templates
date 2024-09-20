{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        riscvPkgs = pkgs.pkgsCross.riscv64-embedded;

        spike = with pkgs; stdenv.mkDerivation rec {
          pname = "spike";
          version = "master";
          src = fetchFromGitHub {
            owner = "riscv-software-src";
            repo = "riscv-isa-sim";
            rev = "52aff0233f5cc844ea047b4e16806f576cd8815b";
            sha256 = "sha256-uutHnplq24wM4vsdxqfw2O9kLE2Pm3jNgb001jKsppQ=";
          };
          nativeBuildInputs = [ dtc ];
          enableParallelBuilding = true;
        };

      in
      with pkgs;
      {

        # https://discourse.nixos.org/t/risc-v-cross-compilation-on-aarch64-darwin/38721
        # https://ayats.org/blog/nix-cross
        # https://nixos.wiki/wiki/Cross_Compiling
        devShells.default = riscvPkgs.stdenv.mkDerivation {
          name = "nix-shell";
          # get rid of ld warnings
          hardeningDisable = [ "relro" "bindnow" ];
          nativeBuildInputs = [
            riscvPkgs.buildPackages.gdb
            riscvPkgs.buildPackages.dtc
            spike
            riscvPkgs.riscv-pk
            qemu
          ];
        };
      });
}
