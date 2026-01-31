#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
#  Kubernetes kube-proxy ARMv7 Build Script (macOS 16 + MacPorts)
#  Fully self-contained: creates all directories, validates tools, builds cleanly
# -----------------------------------------------------------------------------

K8S_VERSION="v1.34.3"
BUILD_ROOT="${HOME}/k8s-build"
SRC_DIR="${BUILD_ROOT}/kubernetes"
SCRIPTS_DIR="${BUILD_ROOT}/scripts"
ARTIFACT_DIR="${BUILD_ROOT}/artifacts/kube-proxy"

echo "[1/7] Creating directory structure..."
mkdir -p "${BUILD_ROOT}"
mkdir -p "${SCRIPTS_DIR}"
mkdir -p "${ARTIFACT_DIR}"

echo "  BUILD_ROOT:    ${BUILD_ROOT}"
echo "  SCRIPTS_DIR:   ${SCRIPTS_DIR}"
echo "  ARTIFACT_DIR:  ${ARTIFACT_DIR}"

# -----------------------------------------------------------------------------
# 2. Validate required tools
# -----------------------------------------------------------------------------
echo "[2/7] Validating required tools..."

if ! command -v go >/dev/null 2>&1; then
    echo "ERROR: Go not found. Install with: sudo port install go"
    exit 1
fi

if ! command -v git >/dev/null 2>&1; then
    echo "ERROR: git not found. Install with: sudo port install git"
    exit 1
fi

if ! command -v make >/dev/null 2>&1; then
    echo "ERROR: make not found. Ensure Xcode Command Line Tools are installed."
    exit 1
fi

echo "  Go:   $(go version)"
echo "  Git:  $(git --version)"
echo "  Make: $(make -v | head -n 1)"

# -----------------------------------------------------------------------------
# 3. Fetch Kubernetes source
# -----------------------------------------------------------------------------
echo "[3/7] Fetching Kubernetes source..."

if [ ! -d "${SRC_DIR}" ]; then
    echo "  Cloning Kubernetes..."
    git clone https://github.com/kubernetes/kubernetes.git "${SRC_DIR}"
fi

cd "${SRC_DIR}"
git fetch --all --tags
git checkout "${K8S_VERSION}"

# -----------------------------------------------------------------------------
# 4. Clean build tree
# -----------------------------------------------------------------------------
echo "[4/7] Cleaning build tree..."
make clean >/dev/null 2>&1 || true
go clean -cache -modcache

# -----------------------------------------------------------------------------
# 5. Cross-compile kube-proxy for ARMv7
# -----------------------------------------------------------------------------
echo "[5/7] Cross-compiling kube-proxy for ARMv7..."

export GOOS=linux
export GOARCH=arm
export GOARM=7
export CGO_ENABLED=0

make WHAT=cmd/kube-proxy

# -----------------------------------------------------------------------------
# 6. Package artifact
# -----------------------------------------------------------------------------
echo "[6/7] Packaging artifact..."

OUTPUT_BIN="_output/bin/kube-proxy"
TARGET_BIN="${ARTIFACT_DIR}/kube-proxy-${K8S_VERSION}-armv7"
TARGET_TAR="${TARGET_BIN}.tar.gz"

cp "${OUTPUT_BIN}" "${TARGET_BIN}"

cd "${ARTIFACT_DIR}"
tar -czf "${TARGET_TAR}" "$(basename "${TARGET_BIN}")"

# -----------------------------------------------------------------------------
# 7. Completion
# -----------------------------------------------------------------------------
echo "[7/7] Build complete."
echo "Binary:   ${TARGET_BIN}"
echo "Tarball:  ${TARGET_TAR}"

