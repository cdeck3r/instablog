# instablog

Server software for automatically creating daily blog posts from Instagram posts

## Documentation Blog

The project has its own website under http://cdeck3r.com/instablog.

## Development Quickstart

You need to have docker installed as a prerequisite.

1. Clone this repo

``` bash
git clone https://github.com/cdeck3r/instablog.git
cd instablog
```

2. Create the Docker image

The repo's subdirectory `Docker` contains a `Dockerfile`, which defines an image for the development.
Change to `Docker` directory, rund the `build.sh` script and check for image name.

``` bash
cd Docker
./build.sh
```

By default the build script will derive the name from the directory name. The output contains

``` bash
...
Default image name: Docker
Default target name: latest
```

Change the image name by defining the var `IMG_NAME`. Ensure that previous image is removed and
create a new image tagged as `instablog:latest`.

``` bash
export IMG_NAME=instablog

./build.sh --remove
./build.sh --base
```

Convince yourself that the images has been successfully created using the command `docker images`.

3. Run Docker container

We assume you are in the repo's root directory, i.e. `.../instablog`.
If you are still in the docker subdirectory just go one level up.

The container spins up, mounts the repo's root from the host into the container and start the bash shell.
``` bash
export IMG_NAME=instablog
export HOST_DIR=$(pwd -P)

docker run -it --rm -v "$HOST_DIR":/home/jovyan "$IMG_NAME":latest /bin/bash
```

This starts a bash shell. You may run a jupyter environment issuing the following command with the variables defined as above.

``` bash
docker run -it --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -e NB_UID=1000 \
    --user root -v "$HOST_DIR":/home/jovyan "$IMG_NAME":latest
```

4. Setup tools

When on the bash shell **within** the docker container, run the following

``` bash
make init
make requirements
```

The `init` target installes tools by calling the `install_supplementals.sh` script. The `requirements` target installs necessary python packages. A virtualenv can be initialized by `make venv`. However, it may be not required, because the docker container's file system is removed when the container exits. After the container's restart simply re-run the `make requirements`.



## License

See [LICENSE](LICENSE) file.
