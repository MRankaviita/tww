{
  description = "Development environment for tww";

  outputs = { self, nixpkgs, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    ghidra-rc = pkgs.ghidra-bin.overrideAttrs (
      old: {
        version = "11.3";
        src = pkgs.fetchzip {
          url = "https://github.com/RootCubed/ghidra-ci/releases/download/2024-10-05/ghidra_11.3_DEV_20241005.zip";
          hash = "sha256-DbPLoh1YgEYSPkV4LNsJehYi/NU1umJLpjqVR66vDGg=";
        };
      }
    );
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
          libx11
          libxcursor
          libxi
        ];
        nativeBuildInputs = with pkgs; [
          pkg-config
        ];

        cargoLock = {
          lockFile = src + /Cargo.lock;
        };

        postInstall = let
            rpath = with pkgs; lib.makeLibraryPath [ libxkbcommon vulkan-loader ];
          in "patchelf --add-rpath \"${rpath}\" $out/bin/objdiff";

        dontPatchELF = true;
      };
  in
  {
    devShells."${system}".default = pkgs.mkShell {
        packages = [
          ghidra-rc
          objdiff
        ];

        shellHook = ''
          export _JAVA_AWT_WM_NONREPARENTING=1
        '';
      };
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };
}
