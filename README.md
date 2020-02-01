# PaperMC Minecraft Server Docker Image
--- 

## About this image

This Docker image allows you to create a [PaperMC](https://papermc.io) server quickly and easily. It was inspired by the `dlord/spigot` Docker image but uses a minimal base image, specifically `azul/zulu-openjdk-alpine:11`.

The first run of this instance will download the Paper JAR file and builds the server artifacts. This is done this way because pre-packaging the server artifacts would violate Minecraft's EULA. 

## What is PaperMC?

Paper is an optimized fork of [Spigot](https://spigotmc.org), which is in turn an optimized fork of [CraftBukkit](https://bukkit.org). This server was chosen both for performance and easy of installation. Most Bukkit and Spigot plugins should work without modification (with the exception that some older plugins may not be compatible with Java 11). Some of the links on this page will take you to the Spigot wiki, which for certain topics has more comprehensive documentation.

## Starting an instance

```
docker run \
    --name papermc-server \
    -p 0.0.0.0:25565:25565 \
    -d -it \
    -e MINECRAFT_EULA=true \
    cpmcdaniel/papermc
```

By default, this starts up a Paper 1.15 server instance. To start a different server version, you can use the `MINECRAFT_VERSION` variable. 

There is one variable that must be set on startup - `MINECRAFT_EULA`. This variable must be set to `true` to indicate that you are agreeing to Minecraft's EULA. Without this variable, the server will not start.

This image exposes the standard Minecraft port (25565). 

It is strongly recommended to start the container with `-it`. This will enable the execution of Minecraft console commands via `docker exec` and also allows safe shutdown via `docker stop`. 

## Commands

This image uses an entrypoint script called `paper`, which has several preset commands. If it does not recognize the command, it will be treated as a regular shell command. These preset commands are:

* `run` - Runs the Paper server and is the default command for the container. Additional parameters are passed through to the Paper server. See the [documentation](https://www.spigotmc.org/wiki/start-up-parameters/) for those additional parameters. 
* `permissions` - Resets ownership of the Paper files and directories. May be necessary after manually editing certain files or creating new ones. Probably not necessary during normal operation.
* `console` - This executes a console command in the Minecraft server (as administrator). This command enables most adminstrative tasks without the need to use `docker attach`. See the [server documentation](https://www.spigotmc.org/wiki/spigot-commands/) for more details.

### Examples

#### run - with extra args to specify a different config inside /opt/minecraft

```
docker run \
    --name papermc-server \
    -p 0.0.0.0:25565:25565 \
    -d -it \
    -e MINECRAFT_EULA=true \
    cpmcdaniel/papermc
    run --paper paper-test.yml
```

#### permissions - update file and directory permissions while container is running

```
docker exec papermc-server paper permissions
```

#### console - say hi to everyone on the server

```
docker exec papermc-server paper console say Hello, World!
```

## Data Volumes

There are two data volumes declared for this image. The `paper` script will ensure proper ownership of these files on startup, so you may freely modify files in these data volumes outside of the container without having to fool with permissions. If you need to make changes (more likely, new files) while the container is running, you can use the `permissions` command through `docker exec` on the running instance (see the example above). 

The data volumes are:
* `/opt/minecraft` - Server-related artifacts (jar files, configs, etc). 
* `/var/lib/minecraft` - World data. This has been separated from the server artifacts purely for backup convenience. 

Example using local data volumes on the docker host:

```shell
$ docker volume create minecraft
$ docker volume create minecraft-worlds
$ docker run \
    --name papermc-server \
    -p 0.0.0.0:25565:25565 \
    -d -it \
    -e MINECRAFT_EULA=true \
    --mount source=minecraft,target=/opt/minecraft \
    --mount source=minecraft-worlds,target=/var/lib/minecraft \
    cpmcdaniel/paper
```

## Environment Variables

There are additional environment variables that can be used to customize the server beyond the required `MINECRAFT_EULA` mentioned previously (and the optional `MINECRAFT_VERSION`, also mentioned).

### MINECRAFT_OPTS

JVM arguments. This actually overrides the default JVM args. The default for this can be found in the source for the [paper](paper) script.

### server.properties variables

The initial values for entries in the Paper [server.properties](https://www.spigotmc.org/wiki/spigot-configuration-server-properties/) file can be changed from their defaults. For a comprehensive list, see the source for the [paper](paper) script. Here are some that you are most likely to want to customize:

* MOTD
* LEVEL_NAME
* SERVER_PORT
* LEVEL_TYPE
* LEVEL_SEED
* DIFFICULTY
* GAMEMODE
* HARDCORE
* PLAYER_IDLE_TIMEOUT
* MAX_PLAYERS
* VIEW_DISTANCE

## Whitelist and Ops

The default configuration enables the server whitelist. This means that when the server first starts up, no one will be able to join. The very first thing you will want to do after the server first starts up is add an operator via the console:

```
docker exec papermc-server paper console whitelist add BigDaddyMac
docker exec papermc-server paper console op BigDaddyMac
```

See the relevant project documentation for additional info around operator roles and permissions.


## Warnings

The console feature of this image should provide for most of the administrative needs for the server. However, should you decide to `docker attach` to the instance, care should be taken to detach properly. When attaching to the instance, you are actually attaching to a `tmux` session running in the foreground with the footer disabled. You would normally detach from a `tmux` session via `CTRL-b d`. However, this will stop the container. Instead, be sure to use `CTRL-p CTRL-q`, which is the standard way to detach from `docker attach`.
