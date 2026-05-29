{ pkgs, lib, config, inputs, ... }:
let
  llm-agents = inputs.agents.packages.${pkgs.stdenv.system};
  cargoNix = inputs.crate2nix.tools.${pkgs.stdenv.system}.appliedCargoNix {
    name = "zellij";
    src = ./.;
  };
  zellij = cargoNix.workspaceMembers.zellij.build;
  rustBuildEnv = lib.concatStringsSep " " [
    "OPENSSL_NO_VENDOR=1"
    "PKG_CONFIG_PATH='${pkgs.openssl.dev}/lib/pkgconfig'"
    "PATH='${lib.makeBinPath [ config.git-hooks.tools.cargo pkgs.pkg-config pkgs.perl pkgs.stdenv.cc pkgs.binutils pkgs.mold ]}:$PATH'"
  ];
in {
  # https://devenv.sh/basics/
  # https://devenv.sh/packages/
  packages = [
    # agents.oh-my-opencode
    llm-agents.oh-my-codex
    llm-agents.opencode
    llm-agents.codex
    llm-agents.beads
    llm-agents.ck
    llm-agents.rtk
    llm-agents.zat
    pkgs.stdenv.cc
    pkgs.openssl
    pkgs.pkg-config
    pkgs.perl
    pkgs.secretspec
  ];

  env.OPENSSL_NO_VENDOR = "1";
  env.PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";

  # https://devenv.sh/languages/
  languages.python = {
    enable = true;
    uv.enable = true;
    lsp.package = pkgs.ty;
  };
  languages.javascript = {
    enable = true;
    bun.enable = true;
  };
  languages.typescript.enable = true;

  languages.rust = {
    enable = true;
    mold.enable = true;
    # Keep devenv aligned with rust-toolchain.toml / Cargo.toml.
    channel = "stable";
    version = "1.92.0";
    components = [
      "rustc"
      "cargo"
      "clippy"
      "rustfmt"
      "rust-analyzer"
      "rust-std"
    ];
    # targets = [ "wasm32-unknown-unknown" ];
  };

  git-hooks.hooks = {
    rustfmt.enable = true;
    clippy = {
      enable = true;
      entry = "env ${rustBuildEnv} ${config.git-hooks.tools.cargo}/bin/cargo-clippy clippy --no-default-features --features vendored_curl,web_server_capability --";
    };
  };
  # git-hooks.settings.rust.cargoManifestPath = "./Cargo.toml";

  # Expose the package as an output for testing
  outputs = {
    inherit zellij;
  };

  # https://devenv.sh/processes/
  # processes.dev.exec = "${lib.getExe pkgs.watchexec} -n -- ls -la";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/basics/
  enterShell = ''
  '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  enterTest = ''
    cargo fmt --check
    cargo test -p zellij-server --lib osc_11
    cargo test -p zellij-client --lib stdin_ansi_parser
    cargo check -p zellij-server -p zellij-client
  '';

  # https://devenv.sh/git-hooks/
  # git-hooks.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
