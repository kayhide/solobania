{ pkgs
}:

let
  inherit (pkgs) lib stdenv;

  lib-path = with pkgs; lib.makeLibraryPath [
    glib
    libGL
    opencv
    stdenv.cc.cc
  ];

in

pkgs.mkShell {
  buildInputs = with pkgs; [
    # development tools
    docker-compose
    lazydocker
    gnumake
    git-lfs

    # application env
    app-env

    # gem dependencies
    xz        # nokogiri
    zlib      # nokogiri
    graphviz  # rails-erd
    stdenv.cc # racc
  ];

  shellHook = ''
    export "LD_LIBRARY_PATH=${lib-path}"
  '';
}
