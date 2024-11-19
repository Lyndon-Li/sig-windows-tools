#!/bin/bash
set -e

args=$(getopt -o v:r:s:b:p -l version:,repository:,source:,branch:,push -- "$@")
eval set -- "$args"

while [ $# -ge 1 ]; do
  case "$1" in
    --)
      shift
      break
      ;;
    -v|--version)
      version="$2"
      shift 
      ;;
    -r|--repository)
      repository="$2"
      shift
      ;;
    -s|--source)
      source="$2"
      shift
      ;;
    -b|--branch)
      branch="$2"
      shift
      ;;
    -p|--push)
      push="1"
      shift
      ;;
  esac
  shift
done

if [[ -z "$version" ]]; then
  echo "--version is required"
  exit 1
fi
echo "Using version ${version}"

output="type=docker,dest=./export.tar"

if [[ "$push" == "1" ]]; then
  output="type=registry"
fi

repository=${repository:-"ghcr.io/kubernetes-sigs/sig-windows"}
echo "Using repository ${repository}"

echo "Using source ${source}"

echo "Using branch ${branch}"

echo "Using output ${output}"

set -x

docker buildx create --name img-builder-csi-proxy --use --platform windows/amd64
trap 'docker buildx rm img-builder-csi-proxy' EXIT


docker buildx build --platform windows/amd64 --output=$output --build-arg=CSI_PROXY_SOURCE=${source} --build-arg=CSI_PROXY_BRANCH=${branch} -f Dockerfile.windows -t ${repository}/csi-proxy:${version} .

