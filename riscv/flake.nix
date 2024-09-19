{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        riscv-toolchain =
          import nixpkgs {
            localSystem = "${system}";
            crossSystem = {
              config = "riscv64-none-elf";
              abi = "lp64";
            };
          };

      in
      with pkgs;
      {
        packages.spike = stdenv.mkDerivation rec {
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

        devShells = {

          default = mkShell {
            buildInputs = [
              riscv-toolchain.buildPackages.gcc
              riscv-toolchain.buildPackages.gdb
              riscv-toolchain.buildPackages.binutils
              riscv-toolchain.riscv-pk
              qemu
              dtc
              self.packages.${system}.spike
            ];
          };
        };
      });
}
