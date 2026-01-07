#!/usr/bin/env bash
set -euo pipefail

IMAGE="ceposta/failover-429:latest"
DOCKER_CONFIG_DIR=""

usage() {
  cat <<'EOF'
Usage: build-and-push.sh [--image <repo/name:tag>] [--docker-config <dir>]

Builds the failover 429 image from this directory and pushes to docker.io.

Options:
  --image         Image tag to build/push (default: ceposta/failover-429:latest)
  --docker-config Use an alternate Docker config dir (avoids macOS Keychain/credsStore issues)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --image)
      IMAGE="${2:-}"
      shift 2
      ;;
    --docker-config)
      DOCKER_CONFIG_DIR="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown arg: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "${IMAGE}" ]]; then
  echo "ERROR: --image cannot be empty" >&2
  exit 2
fi

SCRIPT_DIR="$(
  cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
  pwd
)"

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker is not installed or not on PATH" >&2
  exit 1
fi

DOCKER=(docker)
if [[ -n "${DOCKER_CONFIG_DIR}" ]]; then
  DOCKER+=(--config "${DOCKER_CONFIG_DIR}")
fi

echo "Building ${IMAGE} from ${SCRIPT_DIR} ..."
"${DOCKER[@]}" build --pull -t "${IMAGE}" "${SCRIPT_DIR}"

echo "Pushing ${IMAGE} to Docker Hub (docker.io) ..."
"${DOCKER[@]}" push "${IMAGE}"

echo "Done: ${IMAGE}"
