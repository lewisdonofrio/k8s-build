#!/usr/bin/env bash
set -euo pipefail

K8S_VERSION="v1.34.3"
BUILD_ROOT="${HOME}/k8s-build"
SRC_DIR="${BUILD_ROOT}/kubernetes"
SCRIPTS_DIR="${BUILD_ROOT}/scripts"
ARTIFACT_DIR="${BUILD_ROOT}/artifacts/kube-scheduler"

echo "[1/7] Creating directory structure..."
mkdir -p "${BUILD_ROOT}" "${SCRIPTS_DIR}" "${ARTIFACT_DIR}"
echo "  BUILD_ROOT:    ${BUILD_ROOT}"
echo "  SCRIPTS_DIR:   ${SCRIPTS_DIR}"
echo "  ARTIFACT_DIR:  ${ARTIFACT_DIR}"

echo "[2/7] Validating required tools..."
command -v go >/dev/null 2>&1 || { echo "ERROR: Go not found. sudo port install go"; exit 1; }
command -v git >/dev/null 2>&1 || { echo "ERROR: git not found. sudo port install git"; exit 1; }
command -v make >/dev/null 2>&1 || { echo "ERROR: make not found. Install Xcode CLT."; exit 1; }
echo "  Go:   $(go version)"
echo "  Git:  $(git --version)"
echo "  Make: $(make -v | head -n 1)"

echo "[3/7] Fetching Kubernetes source..."
if [ ! -d "${SRC_DIR}" ]; then
  echo "  Cloning Kubernetes..."
  git clone https://github.com/kubernetes/kubernetes.git "${SRC_DIR}"
fi
cd "${SRC_DIR}"
git fetch --all --tags
git checkout "${K8S_VERSION}"

echo "[4/7] Cleaning build tree..."
make clean >/dev/null 2>&1 || true
go clean -cache -modcache

echo "[5/7] Cross-compiling kube-scheduler for ARMv7..."
export GOOS=linux GOARCH=arm GOARM=7 CGO_ENABLED=0
echo "Force Kubernetes build system to honor cross-compile settings"
export KUBE_BUILD_PLATFORMS="linux/arm"
make WHAT=cmd/kube-scheduler

echo "[6/7] Packaging artifact..."
OUTPUT_BIN="_output/bin/kube-scheduler"
TARGET_BIN="${ARTIFACT_DIR}/kube-scheduler-${K8S_VERSION}-armv7"
TARGET_TAR="${TARGET_BIN}.tar.gz"
cp "${OUTPUT_BIN}" "${TARGET_BIN}"
cd "${ARTIFACT_DIR}"
tar -czf "${TARGET_TAR}" "$(basename "${TARGET_BIN}")"

echo "[7/7] Build complete."
echo "Binary:   ${TARGET_BIN}"
echo "Tarball:  ${TARGET_TAR}"

