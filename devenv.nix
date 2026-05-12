{ pkgs, lib, config, inputs, ... }:
let
  agents = inputs.agents.packages.${pkgs.stdenv.system};
  zellij = config.languages.rust.import ./. { };
in {
  # https://devenv.sh/basics/
  # https://devenv.sh/packages/
  packages = [
    # agents.oh-my-opencode
    # agents.oh-my-codex
    agents.opencode
    agents.codex
    pkgs.secretspec
  ];

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
    # https://devenv.sh/reference/options/#languagesrustchannel
    channel = "nightly";
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
    clippy.enable = true;
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

  # https://devenv.sh/scripts/
  scripts.hello.exec = ''
    echo hello from $GREET
  '';

  # https://devenv.sh/basics/
  enterShell = ''
    hello         # Run scripts directly
    git --version # Use packages
  '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # https://devenv.sh/git-hooks/
  # git-hooks.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
