{
  description = "A basic gomod2nix flake";

  inputs = {
    # keep-sorted start block=yes case=no
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    pre-commit-hooks = {
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
      url = "github:/cachix/git-hooks.nix";
    };
    systems.url = "github:nix-systems/default";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # keep-sorted end
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      perSystem =
        {
          self',
          pkgs,
          lib,
          system,
          ...
        }:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ inputs.gomod2nix.overlays.default ];
          };
          treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs (
            { pkgs, ... }:
            {
              projectRootFile = "flake.nix";
              # keep-sorted start block=yes case=no
              programs.dprint = {
                enable = true;
                settings = {
                  includes = [
                    "**/*.toml"
                    "**/*.json"
                    "**/*.md"
                  ];
                  excludes = [
                    "**/target"
                  ];
                  plugins =
                    let
                      dprintWasmPluginUrl = n: v: "https://plugins.dprint.dev/${n}-${v}.wasm";
                    in
                    [
                      (dprintWasmPluginUrl "json" "0.19.3")
                      (dprintWasmPluginUrl "markdown" "0.17.8")
                      (dprintWasmPluginUrl "toml" "0.6.2")
                    ];
                };
              };
              programs.gofmt.enable = true;
              programs.jsonfmt = {
                enable = true;
                package = pkgs.jsonfmt;
              };
              programs.keep-sorted.enable = true;
              programs.nixfmt = {
                enable = true;
                package = pkgs.nixfmt-rfc-style;
              };
              programs.statix.enable = true;
              # keep-sorted end
              settings.formatter = {
                # keep-sorted start block=yes
                actionlint = {
                  command = pkgs.actionlint;
                  includes = [ "./.github/workflows/*.yml" ];
                };
                jsonfmt.includes = [
                  "*.json"
                  "./.github/*.json"
                  "./.vscode/*.json"
                ];
                # keep-sorted end
              };
            }
          );
          goEnv = pkgs.mkGoEnv { pwd = ./.; };
          pname = "echoing-grype";
          version = "0.0.1";
          commit = if (self ? shortRev) then self.shortRev else "dirty";
        in
        rec {
          devShells.default = pkgs.mkShell {
            shellHook =
              ''
                export GOROOT="${pkgs.go}/share/go"
                unset GOPATH;
              ''
              + "\n"
              + self'.checks.pre-commit-check.shellHook;
            packages = [
              goEnv
              pkgs.go
              pkgs.gopls
              pkgs.gotools
              pkgs.go-tools
              packages.gomod2nix
            ];
          };
          packages.default = pkgs.buildGoApplication {
            inherit pname version;
            pwd = ./.;
            src = ./.;
            modules = ./gomod2nix.toml;

            CGO_ENABLED = 0;

            ldflags = [
              "-s"
              "-w"
              "-X github.com/a1994sc/echoing-grype/route.version=v${version}"
              "-X github.com/a1994sc/echoing-grype/route.commit=${commit}"
            ];
          };
          packages.gomod2nix = inputs.gomod2nix.packages.${system}.default.overrideAttrs (
            final: prev: {
              patches = [
                (pkgs.fetchpatch2 {
                  url = "https://github.com/nix-community/gomod2nix/commit/f5ce6cf5a48ba9cb3d6e670fae1cd104d45eea44.patch";
                  hash = "sha256-DPJh0o4xiPSscXWyEcp2TfP8DwoV6qGublr7iGT0QLs=";
                })
              ];
            }
          );
          formatter = treefmtEval.config.build.wrapper;
          checks.pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              # keep-sorted start case=no
              check-executables-have-shebangs.enable = true;
              detect-private-keys.enable = true;
              end-of-file-fixer.enable = true;
              gofmt.enable = true;
              nixfmt-rfc-style.enable = true;
              trim-trailing-whitespace.enable = true;
              # keep-sorted end
              file-format-nix = {
                enable = true;
                entry = "nix fmt";
                pass_filenames = false;
              };
            };
          };
        };
    };
}
