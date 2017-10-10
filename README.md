## Usage

1. Setup config file and modify it to your needs:

        $ cp .env.dist .env

2. Pull and build images:

        $ make build

2. Start containers:

        $ make up

3. Check containers status:

        $ make status

    ```
              Name                      Command           State           Ports
    ------------------------------------------------------------------------------------
    nightwatch_chrome_1         /opt/bin/entry_point.sh   Up      0.0.0.0:5900->5900/tcp
    nightwatch_firefox_1        /opt/bin/entry_point.sh   Up      0.0.0.0:5901->5900/tcp
    nightwatch_selenium_hub_1   /opt/bin/entry_point.sh   Up      4444/tcp
    ```

3. Run the nightwatch tests:

        $ make test mode=debug env=local settings=chrome,firefox

## Extra configuration

You can customize your application by changing `.env` settings file:

Param | Default value | Description
--- | --- | ---
COMPOSE_PROJECT_NAME | nightwatch | Project name
NW_APP_VOLUME_PATH | ./src | Nightwatch tests directory on your host
NW_SELENIUM_GRID_TIMEOUT | 120000 | Selenium grid timeout
NW_SELENIUM_GRID_BROWSER_TIMEOUT | 120000 | Selenium browser timeout
NW_SELENIUM_NO_PROXY | localhost | Selenium no proxy host
NW_SELENIUM_TIME_ZONE | Europe/Kiev | Selenium timezone
NW_CHROME_CONTAINERS_NUMBER | 1 | Containers number for a chrome service
NW_FIREFOX_CONTAINERS_NUMBER | 1 | Containers number for a chrome service
NW_CHROME_VNC_PORT | 5900 | Chrome service VNC port
NW_FIREFOX_VNC_PORT | 5901 | Firefox service VNC port
NW_HOST_UID | | Provide your uid (`$ id -u`) to map it with `nw` user inside container (optional)
NW_HOST_GID | | Provide your gid (`$ id -u`) to map it with `nw` user inside container (optional)
NW_CONTAINER_USER | nw
NW_CONTAINER_GROUP | nw

You need to restart containers after editing `.env` file:

    $ make up mode=debug env=local
