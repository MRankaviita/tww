{
  description = "Development environment for tww";

  outputs = { self, nixpkgs, ... }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    objdiff = pkgs.rustPlatform.buildRustPackage rec {
        pname = "objdiff";
        version = "3.8.3";
        src = pkgs.fetchFromGitHub {
          owner = "encounter";
          repo = "objdiff";
          rev = "v${version}";
          hash = "sha256-KF37Y9D/vmGq1Y7017IjeoFZk/G7aK98vYYYQe5QxaU=";
        };

        buildInputs = with pkgs; [
          fontconfig
        ];
        nativeBuildInputs = with pkgs; [
          pkg-config
        ];

        cargoLock = {
          lockFile = src + /Cargo.lock;
        };
      };
  in {
    devShells."${system}".default = let
      in pkgs.mkShell {
        packages = [
          pkgs.ghidra
          pkgs.steam-run  # For running objdiff
          objdiff
        ];

        shellHook = ''
          export _JAVA_AWT_WM_NONREPARENTING=1
        '';
      };
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };
}
