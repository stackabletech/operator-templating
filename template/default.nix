{ sources ? import ./nix/sources.nix # managed by https://github.com/nmattia/niv
, nixpkgs ? sources.nixpkgs
, overlays ? [ (self: super: {
    # fakeroot (used for building the Docker image) seems to freeze or crash
    # on Darwin (macOS), but doesn't seem to actually be necessary beyond
    # production hardening.
    fakeroot =
        if self.buildPlatform.isDarwin then
            self.writeScriptBin "fakeroot" ''exec "$@"''
        else
            super.fakeroot;
}) ]
# When cross-/remote-building, some binaries still need to run on the local machine instead
# (non-Nix build tools like Tilt, as well as the container composition scripts)
, pkgsLocal ? import nixpkgs { inherit overlays; }
# Default to building for the local CPU architecture
, targetArch ? pkgsLocal.hostPlatform.linuxArch
, targetSystem ? "${targetArch}-unknown-linux-gnu"
, pkgsTarget ? import nixpkgs {
    inherit overlays;

    # Build our containers for Linux for the local CPU architecture
    # A remote Linux builder can be set up using https://github.com/stackabletech/nix-docker-builder
    system = targetSystem;

    # Currently using remote builders rather than cross-compilation,
    # because the latter requires us to recompile the world several times
    # just to get the full cross-toolchain up and running.
    # (Or I (@nightkr) am just dumb and missing something obvious.)
    # If uncommenting this, make sure to comment the `system =` clause above.
    #crossSystem = { config = targetSystem; };
}
, cargo ? import ./Cargo.nix rec {
    inherit nixpkgs;
    pkgs = pkgsTarget;
    # We're only using this for dev builds at the moment,
    # so don't pay for release optimization.
    release = false;
    defaultCrateOverrides = pkgs.defaultCrateOverrides // {
      prost-build = attrs: {
        buildInputs = [ pkgs.protobuf ];
      };
      tonic-reflection = attrs: {
        buildInputs = [ pkgs.rustfmt ];
      };
      csi-grpc = attrs: {
        nativeBuildInputs = [ pkgs.protobuf ];
      };
      stackable-secret-operator = attrs: {
        buildInputs = [ pkgs.protobuf pkgs.rustfmt ];
      };
      stackable-opa-user-info-fetcher = attrs: {
        # TODO: why is this not pulled in via libgssapi-sys?
        buildInputs = [ pkgs.krb5 ];
      };
      krb5-sys = attrs: {
        nativeBuildInputs = [ pkgs.pkg-config ];
        buildInputs = [ pkgs.krb5 ];
        LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";
        # Clang's resource directory is located at ${pkgs.clang.cc.lib}/lib/clang/<version>.
        # Starting with Clang 16, only the major version is used for the resource directory,
        # whereas the full version was used in prior Clang versions (see
        # https://github.com/llvm/llvm-project/commit/e1b88c8a09be25b86b13f98755a9bd744b4dbf14).
        # The clang wrapper ${pkgs.clang} provides a symlink to the resource directory, which
        # we use instead.
        BINDGEN_EXTRA_CLANG_ARGS = "-I${pkgs.glibc.dev}/include -I${pkgs.clang}/resource-root/include";
      };
      libgssapi-sys = attrs: {
        buildInputs = [ pkgs.krb5 ];
        LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";
        BINDGEN_EXTRA_CLANG_ARGS = "-I${pkgs.glibc.dev}/include -I${pkgs.clang}/resource-root/include";
      };
    };
  }
, meta ? pkgsLocal.lib.importJSON ./nix/meta.json
, dockerName ? "oci.stackable.tech/sandbox/${meta.operator.name}"
, dockerTag ? null
}:
rec {
  inherit cargo sources pkgsLocal pkgsTarget meta;
  inherit (pkgsLocal) lib;
  pkgs = lib.warn "pkgs is not cross-compilation-aware, explicitly use either pkgsLocal or pkgsTarget" pkgsLocal;
  build = cargo.allWorkspaceMembers;
  entrypoint = build+"/bin/stackable-${meta.operator.name}";
  # Run crds in the target environment, to avoid compiling everything twice
  crds = pkgsTarget.runCommand "${meta.operator.name}-crds.yaml" {}
  ''
    ${entrypoint} crd > $out
  '';

  # We're building the docker image *for* Linux, but we need to
  # build it in the local environment so that the generated load-image
  # can run locally.
  # That's still fine, as long as we only refer to pkgsTarget *inside* of the image.
  dockerImage = pkgsLocal.dockerTools.streamLayeredImage {
    name = dockerName;
    tag = dockerTag;
    #includeStorePaths = false;
    contents = [
      # Common debugging tools
      pkgsTarget.bashInteractive
      pkgsTarget.coreutils
      pkgsTarget.util-linuxMinimal
      # Kerberos 5 must be installed globally to load plugins correctly
      pkgsTarget.krb5
      # Make the whole cargo workspace available on $PATH
      build
    ];
    config = {
      Env =
        let
          fileRefVars = {
            PRODUCT_CONFIG = deploy/config-spec/properties.yaml;
          };
        in lib.concatLists (lib.mapAttrsToList (env: path: lib.optional (lib.pathExists path) "${env}=${path}") fileRefVars);
      Entrypoint = [ entrypoint ];
      Cmd = [ "run" ];
    };
  };
  docker = pkgsLocal.linkFarm "listener-operator-docker" [
    {
      name = "load-image";
      path = dockerImage;
    }
    {
      name = "ref";
      path = pkgsLocal.writeText "${dockerImage.name}-image-tag" "${dockerImage.imageName}:${dockerImage.imageTag}";
    }
    {
      name = "image-repo";
      path = pkgsLocal.writeText "${dockerImage.name}-repo" dockerImage.imageName;
    }
    {
      name = "image-tag";
      path = pkgsLocal.writeText "${dockerImage.name}-tag" dockerImage.imageTag;
    }
    {
      name = "crds.yaml";
      path = crds;
    }
  ];

  # need to use vendored crate2nix because of https://github.com/kolloch/crate2nix/issues/264
  crate2nix = import sources.crate2nix { pkgs = pkgsLocal; };
  tilt = pkgsLocal.tilt;

  regenerateNixLockfiles = pkgsLocal.writeScriptBin "regenerate-nix-lockfiles"
  ''
    #!/usr/bin/env bash
    set -euo pipefail
    echo Running crate2nix
    ${crate2nix}/bin/crate2nix generate

    # crate2nix adds a trailing newline (see
    # https://github.com/nix-community/crate2nix/commit/5dd04e6de2fbdbeb067ab701de8ec29bc228c389).
    # The pre-commit hook trailing-whitespace wants to remove it again
    # (see https://github.com/pre-commit/pre-commit-hooks?tab=readme-ov-file#trailing-whitespace).
    # So, remove the trailing newline already here to avoid that an
    # unnecessary change is shown in Git.
    if [[ "$(uname)" == "Darwin" ]]; then
      sed -i \"\" '$d' Cargo.nix
    else
      sed -i '$d' Cargo.nix
    fi
  '';
}
