# k8s-build — ARMv7 Kubernetes Builder Environment

A reproducible, doctrine-aligned builder environment for compiling the full Kubernetes stack for ARMv7 on modern macOS (Apple Silicon) using MacPorts, Go toolchains, and a clean, deterministic workflow.

This repository contains:

- A suite of ARMv7 build scripts for all Kubernetes components
- A consistent directory layout for artifacts and source trees
- A reproducible workflow for maintainers working across macOS and Linux
- A clean separation between builder logic and upstream Kubernetes source

The goal is to provide a future-proof, explicit, and maintainable build pipeline for legacy ARMv7 hardware.

## Repository Layout

k8s-build/
├── scripts/                 # All ARMv7 build scripts (tracked)
│   ├── build-kubelet-armv7.sh
│   ├── build-kube-proxy-armv7.sh
│   ├── build-kubectl-armv7.sh
│   ├── build-kube-apiserver-armv7.sh
│   ├── build-kube-scheduler-armv7.sh
│   ├── build-kube-controller-manager-armv7.sh
│   └── build-kubeadm-armv7.sh
│
├── kubernetes/              # Upstream Kubernetes source tree (ignored)
│                            # Re-cloned on each build
│
├── artifacts/               # Output binaries (ignored)
│   └── <component>/         # e.g., kubelet, kubectl, kube-proxy
│
└── .gitignore               # Ensures clean repo boundaries

## Build Scripts Overview

Each script:

- Clones the correct Kubernetes release tag
- Applies ARMv7-specific environment variables
- Builds the component using Go
- Places the resulting binary in artifacts/<component>/
- Performs explicit validation steps
- Leaves no side effects outside the repo root

Components supported:

- kubelet
- kube-proxy
- kubectl
- kube-apiserver
- kube-scheduler
- kube-controller-manager
- kubeadm

## Prerequisites

### macOS (Apple Silicon)

- MacPorts installed
- Go toolchain installed via MacPorts
- Xcode Command Line Tools
- Sufficient disk space for Kubernetes source (~3–5 GB)

### ARMv7 Target

- Linux ARMv7 rootfs or device for testing
- SSH access recommended
- Matching glibc/musl environment depending on target

## Quickstart

From the repo root:

cd scripts
./build-kubelet-armv7.sh
./build-kube-proxy-armv7.sh
./build-kubectl-armv7.sh
./build-kube-apiserver-armv7.sh
./build-kube-scheduler-armv7.sh
./build-kube-controller-manager-armv7.sh
./build-kubeadm-armv7.sh

Artifacts will appear under:

artifacts/<component>/

## Operational Doctrine

This builder follows a strict set of rules:

- No silent failures
- No hidden state
- No reliance on host-global paths
- Every build is self-contained
- Every step is explicit and logged
- Upstream source is always re-cloned
- Artifacts are never committed
- Scripts are idempotent and nano-safe

This ensures future maintainers can reproduce every binary exactly.

## Cleaning the Workspace

To reset the environment:

rm -rf kubernetes/
rm -rf artifacts/*

This preserves your scripts while removing all build outputs and source trees.

## Future Work

- Add Makefile wrapper for full pipeline
- Add bootstrap script for new builder machines
- Add automated validation tests
- Add release workflow for GitHub Actions
- Add ARMv7 CI smoke tests

## License

MIT or Apache-2.0 (choose one and update this section)
