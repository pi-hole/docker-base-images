#!/bin/bash -ex

function main() {
  current_git_tag=$(git describe --tags --exact-match || true)
  current_branch=$(git rev-parse --abbrev-ref HEAD | sed "s/\//-/g")

  # Push debian tags
  tag_and_push "pihole/debian-base" "latest" "${current_git_tag}"
  branch_based_tag=$(build_debian_branch_tag "${current_git_tag}")
  tag_and_push "pihole/debian-base" "latest" "${branch_based_tag}"

  # Push ftl-build tags
  for flavor in "aarch64" "arm" "arm-qemu" "armhf" "x86_32" "x86_64" "x86_64-musl"; do
    branch_based_tag=$(build_ftl_branch_tag "${flavor}" "${current_branch}")
    tag_and_push "pihole/ftl-build" "${flavor}" "${branch_based_tag}"

    git_tag_based_tag=$(build_ftl_git_tag_tag "${flavor}" "${current_git_tag}")
    tag_and_push "pihole/ftl-build" "${flavor}" "${git_tag_based_tag}"
  done
}

# Tag and push a docker image if the given tag isn't empty
function tag_and_push() {
  image="${1}"
  local_tag="${2}"
  target_tag="${3}"
  if [ -n "${target_tag}" ]; then
    docker tag "${image}:${local_tag}" "${image}:${target_tag}"
    docker push "${image}:${target_tag}"
  fi
}

# Build a docker tag based on the git branch.
# examples:
#     dev branch: dev
#     master branch: latest
function build_debian_branch_tag() {
  branch="${1}"

  if [ "${branch}" = "master" ]; then
    echo "latest"
  else
    echo "${branch}"
  fi
}

# Build a docker tag based on the architecture flavor and git branch.
# examples:
#     dev branch: dev-x86_64-musl
#     master branch: x86_64-musl
function build_ftl_branch_tag() {
  flavor="${1}"
  branch="${2}"

  if [ "${branch}" = "master" ]; then
    echo "${flavor}"
  else
    echo "${branch}-${flavor}"
  fi
}

# Build a docker tag based on the FTL architecture flavor and git tag.
# examples:
#     tag v1.1: "v1.1-x86_64-musl"
#     no tag: ""
function build_ftl_git_tag_tag() {
  flavor="${1}"
  git_tag="${2}"

  if [ -n "${git_tag}" ]; then
    echo "${current_git_tag}-${flavor}"
  fi
}

main
