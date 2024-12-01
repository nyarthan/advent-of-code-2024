{
  description = "Formeta flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    globignore.url = "github:nyarthan/globignore";
    globignore.inputs.nixpkgs.follows = "nixpkgs";
    globignore.inputs.flake-parts.follows = "flake-parts";
    globignore.inputs.flake-root.follows = "flake-root";
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      treefmt-nix,
      flake-root,
      globignore,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      imports = [
        treefmt-nix.flakeModule
        flake-root.flakeModule
      ];

      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        {
          treefmt.config = {
            inherit (config.flake-root) projectRootFile;
            package = pkgs.treefmt;
            settings = {
              global.excludes = builtins.fromJSON (
                builtins.readFile (
                  pkgs.runCommand "globignore-list" { } ''
                    ${globignore.packages.${system}.default}/bin/globignore --cwd ${./.} > $out
                  ''
                )
              );
              formatter = {
                "justfile" = {
                  command = "${pkgs.just}/bin/just";
                  options = [
                    "--unstable"
                    "--fmt"
                    "--check"
                    "--justfile"
                  ];
                  includes = [ "justfile" ];
                };
              };
            };
            programs = {
              nixfmt.enable = true;
              mdformat.enable = true;
              yamlfmt.enable = true;
              biome.enable = true;
            };
          };

          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.just
              pkgs.treefmt
              pkgs.rustc
              pkgs.cargo
            ];

            shellHook = ''
              cp -f ${config.treefmt.build.configFile} treefmt.toml
            '';
          };

          formatter = config.treefmt.build.wrapper;
        };
    };
}
