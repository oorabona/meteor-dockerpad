# Meteor Docker Pad

This piece of software mostly derives from the work of [meteor-launchpad](https://github.com/jshimko/meteor-launchpad/).
At first I was thinking about submitting PR, but I reconsidered when I found I did too many modifications in [jshimko](https://github.com/jshimko) code !

# Features

Using this docker image as a base for your dockerized Meteor projects enables you to:
- choose your flavor of `NodeJS`
- choose your version of `Meteor` you want to build against (helps with testing with new versions)
- let you add extra packages if needed
- use directly your `settings.json` file without any need to take care of it
- install `Meteor` direct dependencies:
  - `MongoDB` if you want to have a all-in-one Meteor package to deploy (__not__ recommanded for production environment)
  - `NginX` if you want to serve static files directly from it (__highly__ recommanded for production environment)

# How it works

This image is based on the official `NodeJS` packaged Docker images.
Mostly it provides a ground layer to build your Meteor apps upon. You can use it in two ways:
- use the prebuilt Docker image
- build your own customized launchpad image

## Using the prebuilt Docker image

You can do that simply by starting your ```Dockerfile``` with :

```
FROM oorabona/meteor-dockerpad:dev
```

If you want to use the __development__ version of _DockerPad_.
Roughly difference between the two are about NodeJS version used.
By default, __development__ always use the latest NodeJS version (_latest_ or _stretch_).
__production__ environment use at the moment NodeJS version codenamed _BORON_.

```
FROM oorabona/meteor-dockerpad:boron
```

I do not know yet if I will maintain these versions alongside with official
NodeJS versions. As a matter of fact this is why there is a ```build.sh``` script.

## Build your own customized launchpad image

If for whatever reason you want to customize the build, it will be just a matter of minutes to do so.

```
$ git clone this repo
$ NODE_VERSION=<your_version> ./build.sh [your_base_image_name]
$ ./build.sh mynamespace/mylaunchpad
```

This will build only the __development__ version of the image.
Now, if you want to go further in the __production__ stages, you can iterate with version tags:
```
$ NODE_VERSION=<your_version> ./build.sh [your_base_image_name] [tag]
$ ./build.sh mynamepsace/mylaunchpad boron
```

And it will also produce the __development__ version all at once !

> Be very careful, ```NODE_VERSION``` is the only way to specify the NodeJS
version you want to build against. I.e. issuing the following command
> ```NODE_VERSION=stretch ./build.sh mynamespace/mylaunchpad boron```
will produce an image named ```mynamespace/mylaunchpad:boron``` but with ```stretch``` NodeJS !!!

I designed this to work this way to allow maximum flexibility wether you feel like you want to version your images or just put ```dev``` and ```prod``` tags.

Flexibility comes at a certain price for sure.

# Project build options

As you can see from the `Dockerfile`, scripts are `ONBUILD` meaning they will re-run everytime you build your derived images.

That allows most of the customisation described below:

| Environment variable | Description | Present in `launchpad.conf` | Default value
-|-|-|-|
| APT_GET_INSTALL | Put here all packages you would need to install with `apt` | No | No
| TOOL_NODE_FLAGS | Additional `node` flags to pass when building your project | No | No
| METEOR_VERSION | Meteor version to download and build against | Yes | Value taken from `.meteor/release`
| METEOR_SETTINGS_FILE | The Meteor `settings.json` file you want to use | Yes | `settings.json`
| INSTALL_MONGO | Name says it all, if you want to install set it to `true` | Yes | No
| INSTALL_NGINX | Name says it all, if you want to install set it to `true` | Yes | No

> Note: `launchpad.conf` file has precedence over `ENV` variables (even `ONBUILD` ones) defined in the `Dockerfile`.

# Deep dive

This docker image relies on [su-exec](https://github.com/ncopa/su-exec.git) instead of [gosu](https://github.com/tianon/gosu) and installs it to ```/usr/local/bin/```.

> Reason for that is that this very important tool does not need all the `Go` language and its overwhelming dependencies at all to be efficient. So, to minimize image size and maximize efficiency, the bare `C` version is more than enough :smile:

What it does:
1. Installs user prerequisites with apt-get
2. Copy source code to container path ```/opt/meteor/src```
3. Download and install Meteor based on the version found in ```.meteor/release```
4. Installs npm prerequisites if ```package.json``` is found
5. Put some safe place under ```/etc``` your __settings.json__  file for use later. It uses environment variable ```METEOR_SETTINGS_FILE``` for that purpose if you want to customize its name
6. It checks whether you want to install MongoDB or not (`INSTALL_MONGO` environment variable see above) and do the work
7. It checks whether you want to install NginX or not (`INSTALL_NGINX` environment variable see above) and do the work
8. Builds the Meteor project using ```--production``` flag
9. It finishes ```npm install```-ation on the server side
10. It cleans up working directories (source, Meteor installation...)
11. And cleans the container of everything that is no longer necessary

# Kudos

Of course @jshimko, @docker and the @meteor team for all their outstanding work !

# License

This is of course MIT based license !

# Contribute

Feel free to submit issues and PR are most welcomed too ! :smile:
