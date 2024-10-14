{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        bluespecPkg = with pkgs;
          stdenv.mkDerivation rec {
            pname = "bluespec";
            version = "2024.07";

            src = fetchzip {
              url = "https://github.com/B-Lang-org/bsc/releases/download/${version}/bsc-${version}-macos-14.tar.gz";
              sha256 = "sha256:0bxc08c4d7waggd7rbr8hjz2v800ma1jac5xl4ywjvsr059vnv8w";
            };

            installPhase = ''
              mkdir -p $out
              cp -r $src/* $out
            '';

            meta = {
              description = "Toolchain for the Bluespec Hardware Definition Language";
              homepage = "https://github.com/B-Lang-org/bsc";
              license = lib.licenses.bsd3;
              mainProgram = "bsc";
              platforms = [ "aarch64-darwin" ];
            };
          };


      in
      with pkgs;
      {

        devShells.default = mkShell {
          packages = [
            bluespecPkg
          ];
        };
      });
}
