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
                targets = [ "loongarch64-unknown-linux-gnu" ];
              };
          })
        ];

        pkgs = import nixpkgs { inherit overlays system; };
        laPkgs = pkgs.pkgsCross.loongarch64-linux;

      in with pkgs; {

        # https://ayats.org/blog/nix-cross
        # https://nixos.wiki/wiki/Cross_Compiling
        devShells.default = laPkgs.mkShell {
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
            laPkgs.buildPackages.gdb
            laPkgs.buildPackages.dtc
            qemu
          ];
        };
      });
}
