#!/bin/bash
# Shared safety guard for CKAD exercise scripts.
#
# Cluster-mutating scripts (each setup.sh, cleanup.sh, setup-all.sh) call
# ckad_confirm_cluster before creating or deleting anything. If the current
# kubectl context is not the expected local kind cluster ("kind-kind"), the
# user must confirm interactively first. This prevents accidentally running an
# exercise against a shared or production cluster.
#
# Bypass the prompt (CI, or intentional use on another cluster):
#   export CKAD_CLUSTER_CONFIRMED=1
#
# Change the expected context name:
#   export CKAD_EXPECTED_CONTEXT=my-context

ckad_confirm_cluster() {
  local expected="${CKAD_EXPECTED_CONTEXT:-kind-kind}"

  # Already confirmed earlier in this process tree (e.g. by setup-all.sh).
  if [ "${CKAD_CLUSTER_CONFIRMED:-}" = "1" ]; then
    return 0
  fi

  local ctx
  ctx="$(kubectl config current-context 2>/dev/null || true)"

  if [ "$ctx" = "$expected" ]; then
    export CKAD_CLUSTER_CONFIRMED=1
    return 0
  fi

  echo "WARNING: current kubectl context is '${ctx:-<none>}', not '$expected'." >&2
  echo "This script creates or deletes resources on that cluster." >&2

  # No terminal to prompt on (e.g. CI): fail closed rather than guess.
  if [ ! -e /dev/tty ]; then
    echo "No interactive terminal available; refusing to continue." >&2
    echo "Set CKAD_CLUSTER_CONFIRMED=1 to run against this cluster anyway." >&2
    exit 1
  fi

  local reply=""
  printf "Really continue against context '%s'? [y/N] " "${ctx:-<none>}" >&2
  # Group the redirection so a failed /dev/tty open is silenced too.
  { read -r reply </dev/tty; } 2>/dev/null || reply=""
  case "$reply" in
    y | Y | yes | YES)
      export CKAD_CLUSTER_CONFIRMED=1
      return 0
      ;;
    *)
      echo "Aborted. No changes made." >&2
      exit 1
      ;;
  esac
}
