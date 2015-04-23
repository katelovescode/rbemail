# docker_scripts

scripts to simplify `docker run` and `shipyard run`

If this is your first time using Docker, you may want to have a look at the
[documentation on How to Dockerify Your App].

## Motivation

We use [Shipyard] as a monitoring, deployment, and scheduling service for our 
Docker Staging environment.  To take full advantage of deploying via Shipyard,
it's necessary to utilize the Shipyard CLI to handle port addressing and
resource provisioning.

The Shipyard CLI has similar but different syntax than standard `docker run`.

Hence, a simple variable definition format for containers that can be used 
both locally and for pushing containers to staging.

## What it does

The scripts in this project serve as wrappers for both the `docker run` and
`shipyard run` commands.  To accomplish this a simple container definition
format must be used.

## How it works / How to use it

Add this git project to your project either as a [git submodule] or by copying
the code directly.  Create container definition files for each container that
your app requires to run.  Name these files with names that make the order 
alphabetically clear (for example, container1.sh, container2.sh, etc.).  Place
these files in a folder adjacent to this one called `container-definitions`.

You'll have to make sure that your app's Docker Image already exists 
([use shipwright!]), then enter this folder and execute the `docker-run.sh`
script.  It will load the container definitions from the adjacent folder and
run them in alphabetical order. The order of variables doesn't matter.

Here are 4 example container definition files:

container1.sh:
```bash
#!/bin/bash

CONTAINER_NAME=election_results_api_db
IMAGE_NAME=postgres:latest
ENV="POSTGRES_USER=hackathon"
```

container2.sh:
```bash
#!/bin/bash

CONTAINER_NAME=election_results_api_db_data
IMAGE_NAME=postgres:latest
LINKS="--link election_results_api_db:postgres"
VOLUMES=("$PWD/../test-data/:/tmp/")
RUN=(bash -c "\"exec psql --host \\\$POSTGRES_PORT_5432_TCP_ADDR --port \\\$POSTGRES_PORT_5432_TCP_PORT -U hackathon -d hackathon < /tmp/postgres.sql\"")
CLEANUP=true
```

container3.sh:
```bash
#!/bin/bash

GET_ABSOLUTE_LATEST=true
CONTAINER_NAME=election_results_api_web
IMAGE_NAME=engineeringd/election_results_api
ENV_FILE=../environment_variables.list
EXPOSE_PORTS=true
LINKS="--link election_results_api_db:db"
RUN=(/dnc/app/api/env/bin/python /dnc/app/api/run.py)
```

environment_variables.list:
```bash
APP_SECRET=sa0dfj*)$09asdfj0%9asjdf9asd
INTERLOCK_DATA={\\\"ssl_only\\\": true, \\\"hostname\\\": \\\"election_results_api.docker\\\", \\\"domain\\\": \\\"dnc.org\\\"}
```

container3.sh (alternate):
```bash
#!/bin/bash

GET_ABSOLUTE_LATEST=true
CONTAINER_NAME=election_results_api_web
IMAGE_NAME=engineeringd/election_results_api
ENV_FILE=../environment_variables.list
PORTS=(:80)
LINKS="--link election_results_api_db:db"
RUN=(/dnc/app/api/env/bin/python /dnc/app/api/run.py)
```


These 3 definitions will be used with `docker run` to do the following:

 1. create a postgres container called "election_results_api_db" with the
    user "hackathon"

 2. create another postgres container called "election_results_api_db_data" 
    with a data volume mount that loads a data dump into the previous 
    container by way of `psql`.  this container is "cleaned up" after use
    and deleted.

 3. create a container called "election_results_api_web" that's based off
    of the `engineeringd/election_results_api:XXXXXXXXXXXX` image.  The
    tag used is the first 12 characters of the git project's current 
    commit hash.  This is done to ensure that image pulled is the not
    simply the "latest", but really is the version that is currently being
    worked on.  **NOTE: such tags are automatically generated with the Python
    tool [shipwright]**

    This container is the app.  It's linked to the "election_results_api_db" 
    container and its ports are exposed.  Environment variables are loaded
    from the indicated `ENV_FILE` in order to provide app settings and some
    staging deployment configuration.

    Additionally, when this container is deployed to the staging environment, 
    Shipyard and Interlock work together to configure HA Proxy to load balance
    traffic to this container.  In conjunction with a `*.docker.dnc.org` 
    catch-all internal DNS record, internally, the URL 
    `http://election_results_api.docker.dnc.org` will point to the app in this 
    container!  **NOTE: this URL is determined from the `INTERLOCK_DATA`**

 4. ALTERNATE: same as above, but the ports are exposed differently.  In this
    case, the container's port 80 is mapped to a random host port.  This is
    common practice for use with the load balancer.

Once this is done, you'd probably run `docker ps` to see what port your app is
running on. Or, on the Shipyard staging environment, visit 
`http://docker-mon.dnc.org` to see the exposed port.  Or, visit the 

## Mapping the Container Definitions to other related commands

The container definition variables were designed to map to the `shipyard run`
and `docker run` command line arguments.  You can see that mapping below:

| Container Definitions | Shipyard CLI `shipyard run` | Docker CLI `docker run` | Docker API `POST /containers/create` |
|-----------------------|-----------------------------|-------------------------|--------------------------------------|
| `IMAGE_NAME`          | `--name` \*                 | (first argument)        | Image                                |
| `CONTAINER_NAME`      | `--container-name`          | `--name`                | ?name                                |
| --                    | `--cpus`                    | `--cpu-shares`          | CpuShares                            |
| --                    | `--memory`                  | `--memory`              | Memory                               |
| --                    | `--type`                    | --                      | --                                   |
| `HOSTNAME`            | `--hostname`                | `--hostname`            | Hostname                             |
| set to "dnc.org"      | `--domain`                  | --                      | Domainname                           |
| `ENV`, `ENV_FILE`     | `--env`                     | `--env`, `--env-file`   | Env                                  |
| `LINKS`               | `--link`                    | `--link`                | Links                                |
| `RUN`                 | `--arg`                     | (2nd+ arguments)        | Entrypoint, Cmd                      |
| `VOLUMES`             | `--vol`                     | `--volume`              | Volumes                              |
| set to "staging"      | `--label` \*                | --                      | --                                   |
| `PORTS`               | `--port`                    | `--publish`             | ExposedPorts                         |
| `EXPOSE_PORTS`        | `--publish`                 | `--publish-all=true`    | PublishAllPorts                      |
| set to "on"           | `--pull`                    | --                      | --                                   |
| --                    | `--count`                   | --                      | --                                   |
| --                    | `--restart`                 | `--restart`             | RestartPolicy                        |

\* these are required for Shipyard CLI's `shipyard run` command

Although the table above should suffice in demonstrating the use of many of
the options in container definitions, there are a few variables that can be
defined for purposes that do not align with the Shipyard CLI, Docker CLI, or
Docker API.  Here, below, is a simpler table that describes each accepted 
variable that is used in a container definition and its effective meaning.


| Container Defintions  | Meaning                                                                                                              |
|-----------------------|----------------------------------------------------------------------------------------------------------------------|
| `IMAGE_NAME`          | The name of the image to be used to create the container, format is: `<IMAGE>:<TAG>`                                 |
| `CONTAINER_NAME`      | The name that you would prefer the running container to have                                                         |
| `CLEANUP`             | If specified, the `docker-run.sh` script will make this container temporary (`--rm`)                                 |
| `ENV`                 | Use this to specify an individual environment variable (only one is supported)                                       |
| `ENV_FILE`            | The relative path to a file that contains a list of environment variables                                            |
| `LINKS`               | A string defining container links: `--link <OTHERCONTAINERNAME>:<SERVICENAME> --link ...`                            |
| `RUN`                 | The run command in the form of an array: `(/app/api/env/bin/python /app/api/run.py)`                                 |
| `VOLUMES`             | An array-formatted list of volume mounts: `("/hostpath/folder:/containerpath" "/a:/b")`                              |
| `PORTS`               | An array-formatted mapping of ports: `(1311:80 1234:8080)`                                                           |
| `EXPOSE_PORTS`        | Indicates that ALL ports should be randomly mapped on the host                                                       |
| `GET_ABSOLUTE_LATEST` | Indicates that the current git project's commit hash will be used as the image tag (replacing any already provided)  |


## Contributors 

 * Manager: Nick Gaw
 * Owner: Sunil K Chopra
 * Consulted: Nick Gaw, Jason Bragg
 * Helper: 
 * Approver: Sunil K Chopra

[documentation on How to Dockerify Your App]: HowToDockerify.md
[Shipyard]: http://shipyard-project.com/
[use shipwright!]: https://github.com/6si/shipwright
[shipwright]: https://github.com/6si/shipwright
