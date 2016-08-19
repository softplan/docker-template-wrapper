# Docker-template wrapper

This project is a group of shell scripts meant to help managing `Dockerfiles` using templates.

Many times, for maintainability, some images are better created / maintained using templates. Usually, these images have multiple versions / tags that differ in details:
- version of the packaged software: eg. `tomcat:6.0.7`, `tomcat:7.0.10`, `tomcat:8.0.0`
- base image: eg. `java:8` (Debian-based) and `java:8-alpine` (Alpine-based); `tomcat:8-jdk8` (oracle jdk8) and `tomcat:8-opendk7` (openjdk 7)

These are some examples where few variables would need to be replaced in order to create each variant of the same image. Many [docker library][docker-library] images, like [postgres][postgres-docker], [mysql][mysql-docker], [python][python-docker], are maintained using a template to generate the actual (version) image.

All the given examples use **shell script** to update the `Dockerfile`. Most of them are pretty simple in their template. Therefore, `sed`-based substitution of variables work for them. However, it is not always like that. For most use cases the template must be way more complex. In these more complex scenarios, simple variables substitutions, like in those shell scripts, are not a viable option.

[Docker-template] is a ruby-based tool that allow complex template-based docker images. It allows writing *dockerfiles* using [ERB] (ruby's embedded template engine). It is also designed for a full-automated scenario. Therefore, it is thought to execute  **build** and **push** process itself. Thus, differently from the **docker library** images, it does not have in mind keeping the generated `Dockerfile` and `README` files in control version.

This project aims to bridge these two cases: have complex template-based docker images (with `docker-template`) and keep the `Dockerfiles` (like **docker library** images). To do so, we use a shell script (`update-dockerfile`) that uses `docker-template` outputs to update images. It do it through `docker-template cache` and `docker-template list`. Moreover, it also to generate and update project files.

## Setup

Docker-template requires Ruby 2.1+. So, firstly you need Ruby 2.1+ up and running in your system.

With Ruby 2.1+ up and running, the easiest way to setup your project to use with `docker-template-wrapper` is cloning this repo and executing the `setup` script.

Once you have clonned this repository in your system, just run:
```shell
# from your dockerfiles project folder
~/projects/my-dockerfiles $ <path_to_docker_template_wrapper>/setup

# or from anywhere using '--project-path' option
~/<path_to_docker_template_wrapper> $ ./setup --projet-path=~/projects/my-dockerfiles
```

> **Important:** Docker template 0.9.0+ is required. As 2016-07-27, it has not been released in **rubygems**. Installation through `bundler`, pointing to project `master` branch, is required to this project work.
> Once version 0.9.0 is released, system-wide installation through `gem install` will work as well.

For reference how to use create template-based images with docker-template visit its [wiki][docker-template-wiki] and this 2 example projects: [jekyll-docker] and [envygeeks-docker].

## Update-dockerfile

Following the `docker-template` schema, templates are located into `/repos/[image]` directory in this repository. The `/opts.yml` holds configurations applied to all images, like maintainer. Each image, **repository** in docker-template lingo, has the following files under `/repos/[image]`:
* `Dockerfile`: ERB-templated dockerfile.
* `opts.yml`: Image specific configurations.
* `README.md`: Image's README without the "Supported versions and tags" section. (extension of this project)

Example:
```shell
~/projects/my-dockerfiles $ ls -lhR repos/tomcat
repos/tomcat:
total 36K
-rw-rw-r-- 1 user user 2,8K Jul 22 15:50 Dockerfile
-rw-rw-r-- 1 user user  619 Jul 22 15:50 opts.yml
-rw-rw-r-- 1 user user 3,9K Jul 22 15:50 README.md
```

Execute:
```shell
# from your dockerfiles project folder
~/projects/my-dockerfiles $ <path_to_docker_template_wrapper>/update-dockerfile --project-url=https://github.com/me/my-dockerfiles

# or from anywhere using '--project-path' option
~/<path_to_docker_template_wrapper> $ ./update-dockerfile  --projet-path=~/projects/my-dockerfiles --project-url=https://github.com/me/my-dockerfiles
```

Executing `update-dockerfile`, it will create a `/[image]` directory within the repository root folder for each image inside `/repos/[image]`. This image folder will contain:
* a `README.md` generated from `/repos/[image]/README.md`, inserting a section of all tags (versions) provided (with links) on its top.
* a folder per `tag` in `opts.yml` with:
    * a symlink to the image's `README.md`
    * a plain `Dockerfile`

> Note the `--project-url` param, it is used to create the links to image's dockerfiles in README.

Example:
```shell
~/projects/my-dockerfiles $ ls -lhR tomcat
tomcat:
total 40K
drwxrwxr-x 2 user user 4,0K Jul 22 15:50 6-jdk6
drwxrwxr-x 2 user user 4,0K Jul 22 15:50 6-jdk7
drwxrwxr-x 2 user user 4,0K Jul 22 15:50 7-jdk7
drwxrwxr-x 2 user user 4,0K Jul 22 15:50 7-jdk8
drwxrwxr-x 2 user user 4,0K Jul 22 15:50 8-jdk7
drwxrwxr-x 2 user user 4,0K Jul 22 15:50 8-jdk8
-rw-rw-r-- 1 user user 4,7K Jul 22 15:50 README.md

tomcat/6-jdk6:
total 16K
-rw-rw-r-- 1 user user 2,7K Jul 22 15:50 Dockerfile
lrwxrwxrwx 1 user user   12 Jul 22 15:50 README.md -> ../README.md

tomcat/6-jdk7:
total 16K
-rw-rw-r-- 1 user user 2,7K Jul 22 15:50 Dockerfile
lrwxrwxrwx 1 user user   12 Jul 22 15:50 README.md -> ../README.md

tomcat/7-jdk7:
total 16K
-rw-rw-r-- 1 user user 2,7K Jul 22 15:50 Dockerfile
lrwxrwxrwx 1 user user   12 Jul 22 15:50 README.md -> ../README.md

tomcat/7-jdk8:
total 16K
-rw-rw-r-- 1 user user 2,7K Jul 22 15:50 Dockerfile
lrwxrwxrwx 1 user user   12 Jul 22 15:50 README.md -> ../README.md

tomcat/8-jdk7:
total 16K
-rw-rw-r-- 1 user user 2,7K Jul 22 15:50 Dockerfile
lrwxrwxrwx 1 user user   12 Jul 22 15:50 README.md -> ../README.md

tomcat/8-jdk8:
total 16K
-rw-rw-r-- 1 user user 2,7K Jul 22 15:50 Dockerfile
lrwxrwxrwx 1 user user   12 Jul 22 15:50 README.md -> ../README.md
```


The script supports update all images or a list of given ones.

```shell
# update all images (repositories in docker-template lingo)
~/projects/my-dockerfiles $ <path_to_docker_template_wrapper>/update-dockerfile

# update only tomcat images
~/projects/my-dockerfiles $ <path_to_docker_template_wrapper>/update-dockerfile tomcat

# update tomcat and oracle-java images
~/projects/my-dockerfiles $ <path_to_docker_template_wrapper>/update-dockerfile tomcat oracle-java
```

Always use `update-dockerfile --help` for full usage.


## Running with Docker

For easy of use, a docker image is provided to run the application out-of-the-box.

Simply run:

```shell
docker run -it -v $PWD:/project rflbianco/docker-template-wrapper
```

Any option accepted by `update-dockerfile` can be passed as argument to your `docker run`:

```shell
docker run -it -v $PWD:/project rflbianco/docker-template-wrapper --project-url="https://github.com/namespace/repository" --verbose tomcat oracle-java
```

### Environment variables

- `PROJECT_URL`: sets the project repository URL (eg. GitHub) to create the "Supported versions" in the `README` file. Default: `https://github.com/<your_namespace>/<your_repository>`


[docker-template]: https://github.com/envygeeks/docker-template
[docker-template-wiki]: https://github.com/envygeeks/docker-template/wiki
[envygeeks-docker]: https://github.com/envygeeks/docker/
[jekyll-docker]: https://github.com/jekyll/docker/
[ruby]: https://ruby-lang.org/
[erb]: https://en.wikipedia.org/wiki/ERuby
[rubygems]: https://rubygems.org/

[docker-library]: https://github.com/docker-library
[postgres-docker]: https://github.com/docker-library/postgres
[mysql-docker]: https://github.com/docker-library/mysql
[python-docker]: https://github.com/docker-library/python
