{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs:
    let
      overlay = final: prev:
        {
          wait-for-it = prev.callPackage ./nix/wait-for-it { };

          my-ruby = prev.ruby_3_2;

          app-env = prev.buildEnv {
            name = "app-env";
            paths = with final; [
              wait-for-it

              nodejs-18_x
              yarn
              purescript
              spago

              my-ruby

              postgresql
            ];
          };
        };

      perSystem = system:
        let
          pkgs = import inputs.nixpkgs { inherit system; overlays = [ overlay ]; };
        in
        {
          devShell = pkgs.mkShell {
            buildInputs = with pkgs; [
              app-env

              docker-compose
              entr
              gnumake
              lazydocker
            ];
          };

          packages = {
            dev-image = import ./docker/dev.nix { inherit pkgs; };
          };
        };
    in
    { inherit overlay; } // inputs.flake-utils.lib.eachDefaultSystem perSystem;
}
