# How to Dockerify Your App

## Some Docker basics

### Login to the DNC Registry

```bash
docker login https://docker-reg.dnc.org

Username: dnc
Password: dnc
Email: dnc
```

### No need to login to the public registry

If you run `docker login` you will be prompted to login to the public registry.
This is not necessary if you are only planning on pulling public images.

### Docker Images

To view the images that you have on your machine:
```bash
docker images
```

To delete images:
```bash
docker rmi <IMAGE NAME>:<TAG>
# or
docker rmi <FIRST FEW CHARACTERS OF IMAGE ID>
```

### Docker Containers

To view the containers (that may be running or stopped) on your machine:
```bash
docker ps -a
```

To stop, start, restart, delete containers:
```bash
docker stop <NAME OR ID OF CONTAINER>
docker start <NAME OR ID OF CONTAINER>
docker restart <NAME OR ID OF CONTAINER>
# if it has already been stopped:
docker rm <NAME OR ID OF CONTAINER>
# to force it to stop, then delete it:
docker rm -f <NAME OR ID OF CONTAINER>
```

To view a container's logs:
```bash
docker logs <NAME OR ID OF CONTAINER>
# or follow!
docker logs -f <NAME OR ID OF CONTAINER>
```

To enter a running container:
```bash
docker exec -it <NAME OR ID OF CONTAINER> /bin/bash
```

To inspect a container:
```bash
docker inspect <NAME OR ID OF CONTAINER>
```

## Prepare your app

### Add a `BUILD` path

The `BUILD` path will hold the `scripts` folder and the `container-definitions`
that define the containers that your app uses.

```bash
cd /path/to/myapp
mkdir -p BUILD/container-definitions
```

### Include docker_scripts

This can be done by downloading it directly, or by using it as a git submodule.

```bash
cd /path/to/myapp/BUILD
git submodule add git@github.com:democrats/docker_scripts.git scripts
git commit -a -m 'added docker_scripts as a git submodule'
```

## Plan your containers

Your app will likely use more than one container.  Usually 2-3.  Because of
this, writing a `Dockerfile` alone is not usually sufficient.  You'll need to
pull and experiment with connecting some containers together to satisfy the
requirements of your app.

To do this, you can write up container definitions and run the script 
`./docker-run.sh` to read the definitions and start up your containers.  As
you may find out, giving a name to these containers is helpful, so that 
re-running the `./docker-run.sh` script kills the old containers and replaces
them correctly.

### Remember the separation of concerns

Your app probably needs a database.  It probably also needs a cache.  And 
maybe it also needs a message queue.  You could put all of these services into 
one container, but that would unnecessarily link their fates and make it much
harder to scale them independently, effectively.  A better solution would be
to put each of these services into a separate container -- much as you would
be putting them into a separate Virtual Machine if you weren't using 
containers.

### Finding the Docker images that you need

So, you should look on https://registry.hub.docker.com for either an official 
or highly-rated base image that satisfies your requirements.  For example, you
can easily use Redis, PostgreSQL, MySQL, and MongoDB from offical base images
in this public registry.  You can then pull them and play with them by using 
the `docker pull` command.

If you can't find an image, you could always make a custom one for your extra
service too.

## Create an image for your app

The `Dockerfile` is a file that describes what goes into your Docker image.

### Decide on a base image for your app

Usually, you want this image to be based on an official Docker image that is
has something in common with your app's environment.

For example, if you want your app to run Nginx, you might consider using 
something like the [Phusion Passenger Baseimage].  The Phusion people have 
[customized versions] of this that support different frameworks and lots of 
[documentation] on how to most effectively use it.

### Make sure that your app dependencies are installed

One of the great benefits of building your own Docker image for your app is that
you can install of the app's dependencies here and now.  This greatly speeds up
deployment, so remember to write that into your `Dockerfile`.

#### PROTIP: Changing the Base Image

At this point, you might be able to take advantage of a neat trick to greatly
speed up your Docker image building.  Change the `Dockerfile` to start with a
base image by the same name of the image you are creating.  For example,

```bash
FROM docker-reg.dnc.org/toolbox-v2:latest
```

will cause new builds of the `toolbox-v2` to use the latest version of the
this image that are available.  This means that when the `bundle install`
portion of the image building happens, it goes **much much** faster!

## Write container definitions

Now that you know what containers your app needs to run (plus the one for your
app itself), you can write container definitions to run the images you have
found and created. You will need one container definition for every container 
that your app requires. 

See the [README.md] for details on how they should be formatted.

## Use environment variables

Defining app secrets with Environment Variables is *by far* the simplest way
to get that data into a container with Docker.  Out of the box, Docker supports
an `--env-file` flag that can read in a simple list of variable assignments.

## Use Shipwright (probably)

You have a `Dockerfile`, possibly with a `.dockerignore`, want to add another
random, root-level config file?  If you don't mind adding a `.shipwright.json`
file, you can use that with [Shipwright] to greatly simplify the building and
tagging of your custom Docker images.

Here's an example of what that should look like:

```bash
{
    "version": 1.0,
    "namespace": "docker-reg.dnc.org",
    "names": {
        "/": "docker-reg.dnc.org/tooldocs"
    }
}
```

As you can see here, there are references to the DNC Registry.  That part helps
to ensure that when you do a `docker push` the image goes to the private 
registry, instead of the public.


[Phusion Passenger Baseimage]: https://github.com/phusion/baseimage-docker
[customized versions]: https://registry.hub.docker.com/repos/phusion/
[documentation]: https://github.com/phusion/baseimage-docker/blob/master/README.md
[README.md]: README.md
[Shipwright]: https://github.com/6si/shipwright
