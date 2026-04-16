#!/usr/bin/env bash
# bwrap sandbox for running claude & npm/dotnet builds
# Run in the folder containing what you want to work on and it will be mounted at ~/work
# Inpsired by https://patrickmccanna.net/a-detailed-writeup-of-claude-code-constrained-by-bubblewrap/
# Depends on bubblewrap https://github.com/containers/bubblewrap

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SANDBOX_HOME="/home/user"
MISE_DATA="$HOME/.local/share/mise"

args=(
  --ro-bind /usr /usr                   # core binaries (bash, coreutils, etc.)
  --ro-bind /lib /lib                   # shared libraries (glibc etc.)
  --ro-bind /lib64 /lib64               # dynamic linker
  --ro-bind /bin /bin                   # essential binaries
  --proc /proc                          # process info, needed by node/dotnet
  --dev /dev                            # /dev/null, /dev/urandom, etc.
  --tmpfs /tmp                          # isolated ephemeral tmp (not host's)

  # DNS resolution (claude API, npm registry, nuget)
  --ro-bind /etc/resolv.conf /etc/resolv.conf
  --ro-bind /etc/nsswitch.conf /etc/nsswitch.conf
  --ro-bind /etc/hosts /etc/hosts
  --ro-bind /etc/ssl /etc/ssl           # TLS certificates (HTTPS for nuget, npm, claude API)

  # mise-managed toolchains (node, dotnet, claude)
  --ro-bind "$MISE_DATA" "$SANDBOX_HOME/.local/share/mise"
  --ro-bind "$HOME/.config/mise" "$SANDBOX_HOME/.config/mise"
  --ro-bind "$HOME/dm" "$HOME/dm"               # symlink target for dotfiles managed via ~/dm, without this linked config files can't be read

  # claude config + state (future work to deny write)
  --bind "$HOME/.claude" "$SANDBOX_HOME/.claude"
  --bind "$HOME/.claude.json" "$SANDBOX_HOME/.claude.json"

  # nuget: packages, plugins (credential provider), and config
  --bind "$HOME/.nuget" "$SANDBOX_HOME/.nuget"

  # shell profile that activates mise
  --ro-bind "$SCRIPT_DIR/sandbox.bashrc" "$SANDBOX_HOME/.bashrc"

  # working directory (read-write)
  --bind "$PWD" "$SANDBOX_HOME/work"

  --unshare-pid                         # own PID namespace so /proc doesn't leak host processes
  # --new-session not needed: TIOCSTI injection blocked by kernel ≥6.2 (LEGACY_TIOCSTI=n)

  --setenv HOME "$SANDBOX_HOME"         # remap HOME so tools write to sandbox
  --setenv SANDBOX_OUTER_PWD "$PWD"     # real path shown in shell prompt
  --chdir "$SANDBOX_HOME/work"          # start in the working directory

)

bwrap "${args[@]}" -- /usr/bin/bash
