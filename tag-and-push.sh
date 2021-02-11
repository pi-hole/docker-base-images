#!/bin/bash -e

# Usage: ./tag-and-push.sh ${docker-compose-service-name}
# examples:
#     ./tag-and-push.sh debian-base-buster
#     ./tag-and-push.sh ftl-build_aarch64
#
# DRY_RUN=true to skip pushing images
#
function main() {
  target="${1}"
  current_git_tag=$(git describe --tags --exact-match 2> /dev/null || true)
  current_branch=$(git rev-parse --abbrev-ref HEAD | sed "s/\//-/g")

  # Push debian tags
  if [[ "${target:0:11}" = "debian-base" ]]; then
    flavor=${target:12:$$}
    # Since this is a 'based images' repo, does it make sense to even provide
    # a 'default' version? Perhaps all versions should be debian specific?
    primary_debian_version="buster"
    branch_based_tag=$(build_branch_tag "${current_branch}")
    flavored_git_tag_based_tag=$(build_flavored_git_tag_tag "${flavor}" "${current_git_tag}")
    flavored_branch_name=$(build_flavored_branch_name "${current_branch}" "${flavor}")

    if [[ "${flavor}" = "${primary_debian_version}" ]]; then
      tag_and_push "pihole/debian-base" "${flavor}" "${current_git_tag}"
      tag_and_push "pihole/debian-base" "${flavor}" "${flavored_git_tag_based_tag}"
      tag_and_push "pihole/debian-base" "${flavor}" "${branch_based_tag}"
      tag_and_push "pihole/debian-base" "${flavor}" "${flavored_branch_name}"
    else
      tag_and_push "pihole/debian-base" "${flavor}" "${flavored_branch_name}"
      tag_and_push "pihole/debian-base" "${flavor}" "${flavored_git_tag_based_tag}"
    fi
  fi

  # Push web-build node version
  if [[ "${target}" = "web-build" ]]; then
    branch_based_tag=$(build_branch_tag "${current_branch}")
    tag_and_push "pihole/web-build" "latest" "${current_git_tag}"
    tag_and_push "pihole/web-build" "latest" "${branch_based_tag}"
    tag_and_push "pihole/web-build" "latest" "12"
  fi

  # Push FTL tags
  if [[ "${target:0:9}" = "ftl-build" ]]; then
    flavor=${target:10:$$}
    branch_based_tag=$(build_ftl_branch_tag "${flavor}" "${current_branch}")
    tag_and_push "pihole/ftl-build" "${flavor}" "${branch_based_tag}"

    git_tag_based_tag=$(build_flavored_git_tag_tag "${flavor}" "${current_git_tag}")
    tag_and_push "pihole/ftl-build" "${flavor}" "${git_tag_based_tag}"
  fi
}

# Tag and push a docker image if the given tag isn't empty
# Set environment var `DRY_RUN=true` to disable docker push.
function tag_and_push() {
  image="${1}"
  local_tag="${2}"
  target_tag="${3}"
  if [[ -n "${target_tag}" ]]; then
    echo "Tagging ${image}:${local_tag} as ${target_tag}"
    docker tag "${image}:${local_tag}" "${image}:${target_tag}"
    if [[ "${DRY_RUN}" != "true" ]]; then
        docker push "${image}:${target_tag}"
    fi
  fi
}

# Build a docker tag based on the git branch.
# examples:
#     dev branch: dev
#     master branch: latest
function build_branch_tag() {
  branch="${1}"

  if [[ "${branch}" = "master" ]]; then
    echo "latest"
  else
    echo "${branch}"
  fi
}

function build_flavored_branch_name() {
  branch="${1}"
  flavor="${2}"

  if [[ "${branch}" = "master" ]]; then
    echo "${flavor}"
  else
    echo "${branch}-${flavor}"
  fi
}

# Build a docker tag based on the architecture flavor and git branch.
# examples:
#     dev branch: dev-x86_64-musl
#     master branch: x86_64-musl
function build_ftl_branch_tag() {
  flavor="${1}"
  branch="${2}"

  if [[ "${branch}" = "master" ]]; then
    echo "${flavor}"
  else
    echo "${branch}-${flavor}"
  fi
}

# Build a docker tag based on the FTL-architecture/debian flavor and git tag.
# examples:
#     tag v1.1: "v1.1-x86_64-musl"
#     tag v1.1: "v1.1-buster"
#     no tag: ""
function build_flavored_git_tag_tag() {
  flavor="${1}"
  git_tag="${2}"

  if [[ -n "${git_tag}" ]]; then
    echo "${git_tag}-${flavor}"
  fi
}

main "$@"
