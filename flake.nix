{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs:
    let
      overlay = final: prev: { };
      perSystem = system:
        let
          pkgs = import inputs.nixpkgs { inherit system; overlays = [ overlay ]; };

          wait-for-it = pkgs.callPackage ./nix/wait-for-it { };

          my-ruby = pkgs.ruby_3_2;

          app-env = with pkgs; [
            wait-for-it

            nodejs-18_x
            yarn
            purescript
            spago

            my-ruby

            postgresql
          ];

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
        };
    in
    { inherit overlay; } // inputs.flake-utils.lib.eachDefaultSystem perSystem;
}
