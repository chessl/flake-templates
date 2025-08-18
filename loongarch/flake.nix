{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        laPkgs = pkgs.pkgsCross.loongarch64-linux-embedded;

      in with pkgs; {

        # https://ayats.org/blog/nix-cross
        # https://nixos.wiki/wiki/Cross_Compiling
        devShells.default = laPkgs.mkShell {
          # get rid of ld warnings
          # https://nixos.org/manual/nixpkgs/stable/#sec-hardening-in-nixpkgs
          hardeningDisable = [ "relro" "bindnow" ];
          packages = [ laPkgs.buildPackages.gdb laPkgs.buildPackages.dtc qemu ];
        };
      });
}
