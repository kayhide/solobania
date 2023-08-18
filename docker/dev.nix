{ pkgs ? import ../. { }
}:

let
  inherit (pkgs) lib;

  lib-path = with pkgs; lib.makeLibraryPath [
    glib
    libGL
    libffi
    opencv
    stdenv.cc.cc
  ];

  nixos-image = pkgs.dockerTools.pullImage {
    imageName = "nixos/nix";
    imageDigest = "sha256:d66c307749b460c054d8edf6191f58ec38c569c8639161d41eb6e4879baf7ff2";
    sha256 = "1p7as8cxddqa6aimddchsj02yd1nammpf8a6f7yicblp7295wydc";
    finalImageName = "nixos/nix";
    finalImageTag = "2.5.1";
  };

  base-image = pkgs.dockerTools.buildImage {
    name = "solobania-base";
    tag = "latest";
    created = "now";
    fromImage = nixos-image;
    contents = with pkgs; [
      bash # sh
      binutils.bintools # readelf
      cacert
      diffutils # diff cmp
      file
      gawk
      git
      gnumake
      gnused
      stdenv.cc
      tzdata
    ];
  };

  bash-env = pkgs.writeText "bash-env" ''

    export PATH="$BUNDLE_BIN:$PATH:/bin:/sbin:/usr/bin:/usr/sbin"
  '';

  dev-image = pkgs.dockerTools.buildImage {
    name = "solobania-dev";
    tag = "latest";
    created = "now";
    fromImage = base-image;
    contents = with pkgs; [
      app-env

      bashInteractive_5
      entr
      neovim
      tree
      vim
    ];
    config = {
      WorkingDir = "/app";
      # User = "1000:1000";
      Env = [
        "SHELL=/bin/bash"
        "LD_LIBRARY_PATH=${lib-path}"
      ];
      Cmd = [ "/bin/bash" ];
    };
    extraCommands = ''
      mkdir -p usr/bin
      ln -s ${pkgs.file}/bin/file usr/bin/

      mkdir -p usr/include
      ln -s ${pkgs.libffi.dev}/include usr/include/ffi

      mkdir -p root
      cat ${./bashrc} ${bash-env} > root/.bashrc
      cp ${bash-env} root/.bash_env
    '';
  };

in

dev-image
