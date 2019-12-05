#!/bin/bash
#!/usr/bin/env bash
set -eo pipefail

count=0

function _info()
{
    echo "$((++count)). $@"
}

function display_usage()
{
  # Display help
cat << EOF
Usage : build.sh [options]

Build traefik-erro-pages docker images

Requires:
    1. docker-ce 19.05 and above
    2. docker cli experimental features enabled
    3. You have created a builder named mybuilder
    4. If using docker.io package, install buildx
    5. Install qemu-user package to enable cross builds.

Options:
-h --help         Display this message
-c --skip-cross   Skip cross build, just build jelkyll assets
-p --skip-push    Skip Pushing do Docker Hub
-l --latest       Add Tag latest
EOF
}


function build_assets()
{

    _info " Build Static Pages"
    docker build -t traefik-error-pages-builder  jekyll/

    # dummy container
    _info "Copying files from image..."
    _info "Stop if any old container is running"
    docker stop copier &> /dev/null || true
    _info "Delete old container if exists"
    docker rm copier &> /dev/null|| true
    _info "Running a dummy Image"
    docker run --name copier -it traefik-error-pages-builder true
    sleep 2
    _info "Cleaning old files"
    rm -rf docker/_site/
    mkdir docker/_site
    _info "Copying static files"
    docker cp copier:/tmp/_site/ docker/
}


main()
{
    while [ "${1}" != "" ]; do
        case ${1} in
        -c | --skip-cross)               skip_cross="true";;
        -p | --skip-push)                skip_push="true";;
        -h | --help)                     display_usage;exit 0;;
        -l | --latest)                   latest_tag="true";;
        *)                               printf "Invalid argument!\n";exit 1;;
        esac
        shift
    done

    build_assets
    if [[ $skip_cross != "true" ]]; then
        _info "Cross build via buildx"
        docker buildx use mybuilder
        docker buildx inspect --bootstrap
        _info "Building....."
        if [[ $latest_tag == "true" ]]; then
            _info "Image tag will be latest"
            image_tag="latest"
        else
            _info "Image tag will be dev"
            image_tag="dev"
        fi
        if [[ $skip_push == "true" ]]; then
            _info "Image will not be pushed"
            docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t "tprasadtp/traefik-error-pages:${image_tag}"  docker
        else
            docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t "tprasadtp/traefik-error-pages:${image_tag}" --push docker
        fi
    else
        _info "Cross build is disabled"
    fi
}

main "$@"
