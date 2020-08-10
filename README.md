houio:
=============
Library to read and manipulate Houdini files & data


Build instructions:
-------------------

- Install docker if not already done:
http://wikianim.mikros.int/doku.php?id=public:projects:dev:docker_locally#how_to_install

- Go to the root directory of this package, i.e. where the file "Dockerfile" located

- Build the Docker image if you have not already done so :

    ```
    docker build -t houio:base \
        --build-arg USER_ID=$(id -u) \
        --build-arg GROUP_ID=$(id -g) \
        --build-arg USER_NAME=$(id -u -n) ./
    ```

- Run a new container to make a call to `cmake` :

    ```
    docker run -it --rm -w $(pwd) --user $(id -u -n) \
        --mount type=bind,source=/datas/$(id -u -n),target=/datas/$(id -u -n) \
        --mount type=bind,source=/s/apps/packages,target=/s/apps/packages,readonly \
        --name houio \
        houio:base \
        /bin/bash -c 'cmake .. && make && make install'
    ```

- A to_build.sh script is deployed at Mikros with the REZ packages.
