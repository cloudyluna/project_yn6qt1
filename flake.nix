{
  description = "";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      rust-overlay,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      in
      {
        devShells.default =
          with pkgs;
          mkShell rec {
            buildInputs = [
              pkg-config
              openssl
              valgrind
              upx
              glibc

              (rust-bin.stable."1.84.1".default.override {
                extensions = [ "rust-docs" ];
                targets = [
                  "i686-unknown-linux-gnu"
                  "i686-pc-windows-gnu"
                  "x86_64-pc-windows-gnu"
                  "x86_64-unknown-freebsd"
                  "aarch64-apple-darwin"
                ];
              })

              rust-analyzer
            ];

            LD_LIBRARY_PATH = "${lib.makeLibraryPath buildInputs}:${stdenv.cc.targetPrefix}";
            RUST_SRC_PATH = rustPlatform.rustLibSrc;
          };
      }
    );
}
