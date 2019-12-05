# Custom error pages for Traefik

A bunch of custom error pages for Traefik built with [Jekyll](https://jekyllrb.com/).
> This is a [fork](https://github.com/Jakob-em/traefik-custom-error-pages.git).
> I do provide images for arm64, arm7 and amd64 on [DockerHub](https://hub.docker.com/repository/docker/tprasadtp/traefik-error-pages)


## How to use with Traefik and Docker

Labels are already define in the image to work with Traefik.

To use it in production just run the container :

```bash
$ docker run -d tprasadtp/traefik-custom-error-pages
```

## Build the image

```console
➜ docker buildx create --name mybuilder
➜ ./build.sh -h
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


```

> Building on ARM is not supported as jekyll/builder is not available for ARM/ARM64
> Do note that the the image from this repo is indeed supported on arm64, arm and amd64
> Just that you cannot build this on arm(yet)

- Because how buildx works, you have to either push to docker hub/registry or load the image manually
- You can skip pushing to docker hub via `-p` option.

## How it works?

As you can see in the Dockerfile, I use [Nginx](https://www.nginx.com/) as Web server to serve static files. To generate this pages, I use [Jekyll](https://jekyllrb.com/) in the first step of the build.

For traefik, You need to add right labels. that depends on traefik version.

## Traefik v2

Use errorpages
```yaml
services:
    errorservice:
        image: tprasadtp/traefik-custom-error-pages:latest
    traefik:
        image: traefik:latest
        labels:
            # Add Custom routers and middleware
            # Add erorpage middleware to your low priority router
            - "traefik.http.middlewares.errorpage.errors.status=500-599"
            - "traefik.http.middlewares.errorpage.errors.service=errorservice"
            - "traefik.http.middlewares.errorpage.errors.query=/{status}.html"
```

> It is very important that you set priorities on backend(v1) and routers(v2) correctly.
> Additionally for v2 you need be careful with order of middlewares.

## Credits

I used the [Laravel](https://laravel.com/) default HTTP error pages.

## Contributing

Do not hesitate to contribute to the project by adapting or adding features ! Bug reports or pull requests are welcome.

## License

This project is released under the [MIT](http://opensource.org/licenses/MIT) license.
