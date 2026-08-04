# AGENTS.md

## Project overview

Base Docker images used by other Pi-hole build processes. Currently this means the `ftl-build` images: the toolchain containers used by the pi-hole/FTL repository to cross-compile FTL for all supported architectures. Images are published to Docker Hub (`pihole/ftl-build`) and GHCR (`ghcr.io/pi-hole/ftl-build`).

## Repository layout

- `ftl-build/Dockerfile` - the FTL build toolchain image
- `.github/workflows/` - the build and publish pipelines

## How publishing works

Everything is driven by GitHub Actions (see the README for full detail):

- Pull requests trigger test builds only (nothing is pushed).
- Pushes to any branch except `master` publish images tagged with the branch name; these are for testing and development.
- Pushes to `master` (and a weekly schedule) publish the `nightly` tag.
- GitHub releases publish the version tag and `latest`.

This means merging to `master` has direct downstream impact: FTL's CI consumes these images. Treat changes accordingly.

## Testing instructions

- Validate locally by building the image and confirming FTL still compiles inside it: `docker build -t ftl-build:local ftl-build/`
- For broader validation, push a branch: CI will publish a branch-named tag which the FTL repository can be temporarily pointed at for a full cross-architecture test.
- Toolchain changes must work across all target architectures, not just amd64.

## PR instructions

- **This repository uses `master` as its default branch**; pull requests target `master` (unlike most Pi-hole repositories, which use `development`).
- Every commit must be signed off (DCO): use `git commit -s`.
- Use Unix line endings (LF).
- Keep images lean: they are pulled frequently by CI.
- The correct project spelling is "Pi-hole" (capital P, lowercase h, hyphen).

## Common pitfalls

- Underestimating blast radius: a broken image here breaks FTL's CI for every architecture.
- Testing only amd64 when the toolchain must support all target architectures.
- Forgetting the DCO sign-off on commits.
