{
  inputs = {
    # Both `nixpkgs` and `flake-parts` are pinned to the same version as Creusot's
    nixpkgs.follows = "creusot/nixpkgs";
    flake-parts.follows = "creusot/flake-parts";
    creusot.url = "github:creusot-rs/creusot";
  };
  outputs =
    inputs@{
      creusot,
      flake-parts,
      nixpkgs,
      self,
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      perSystem =
        {
          pkgs,
          system,
          ...
        }:
        {

          _module.args.pkgs = import nixpkgs {
            inherit system;
            overlays = [ creusot.overlays.default ];
          };

          formatter = pkgs.nixfmt-tree;

          devShells.default = pkgs.mkShell {
            packages = [
              (pkgs.creusot.mkCreusotWrapped { isFree = true; })
              pkgs.cargo
              pkgs.clippy
              pkgs.rust-analyzer
              pkgs.rustfmt
              # ...
            ];
          };
        };
    };
}
