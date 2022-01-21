Reproducible source for XXXXXXXXXXXXXXXXX
-------------------------------------------------------------------------

Copyright (C) 2018-2022 Mohammad Akhlaghi <mohammad@akhlaghi.org>\
See the end of the file for license conditions.

This is the reproducible project source for the paper titled "**XXX XXXXX
XXXXXX**", by XXXXX XXXXXX, YYYYYY YYYYY and ZZZZZZ ZZZZZ that is published
in XXXXX XXXXX.

To reproduce the results and final paper, the only dependency is a minimal
Unix-based building environment including a C and C++ compiler (already
available on your system if you have ever built and installed a software
from source) and a downloader (Wget or cURL). Note that **Git is not
mandatory**: if you don't have Git to run the first command below, go to
the URL given in the command on your browser, and download the project's
source (there is a button to download a compressed tarball of the
project). If you have received this source from arXiv or Zenodo (without
any `.git` directory inside), please see the "Building project tarball"
section below.

```shell
$ git clone XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
$ cd XXXXXXXXXXXXXXXXXX
$ ./project configure
$ ./project make
```

This paper is made reproducible using Maneage (MANaging data linEAGE). To
learn more about its purpose, principles and technicalities, please see
`README-hacking.md`, or the Maneage webpage at https://maneage.org.





### Building the project

This project was designed to have as few dependencies as possible without
requiring root/administrator permissions.

1. Necessary dependencies:

   1.1: Minimal software building tools like C compiler, Make, and other
        tools found on any Unix-like operating system (GNU/Linux, BSD, Mac
        OS, and others). All necessary dependencies will be built from
        source (for use only within this project) by the `./project
        configure` script (next step).

   1.2: (OPTIONAL) Tarball of dependencies. If they are already present (in
        a directory given at configuration time), they will be
        used. Otherwise, a downloader (`wget` or `curl`) will be necessary
        to download any necessary tarball. The necessary tarballs are also
        collected in the archived project on
        [https://doi.org/10.5281/zenodo.XXXXXXX](XXXXXXX). Just unpack that
        tarball and you should see all the tarballs of this project's
        software. When `./project configure` asks for the "software tarball
        directory", give the address of the unpacked directory that has all
        the tarballs. [[TO AUTHORS: UPLOAD THE SOFTWARE TARBALLS WITH YOUR
        DATA AND PROJECT SOURCE TO ZENODO OR OTHER SIMILAR SERVICES. THEN
        ADD THE DOI/LINK HERE. DON'T FORGET THAT THE SOFTWARE ARE A
        CRITICAL PART OF YOUR WORK'S REPRODUCIBILITY.]]

2. Configure the environment (top-level directories in particular) and
   build all the necessary software for use in the next step. It is
   recommended to set directories outside the current directory. Please
   read the description of each necessary input clearly and set the best
   value. Note that the configure script also downloads, builds and locally
   installs (only for this project, no root privileges necessary) many
   programs (project dependencies). So it may take a while to complete.

     ```shell
     $ ./project configure
     ```

3. Run the following command to reproduce all the analysis and build the
   final `paper.pdf` on `8` threads. If your CPU has a different number of
   threads, change the number (you can see the number of threads available
   to your operating system by running `./.local/bin/nproc`)

     ```shell
     $ ./project make -j8
     ```










### Building project tarball (possibly from arXiv)

If the paper is also published on arXiv, it is highly likely that the
authors also uploaded/published the full project there along with the LaTeX
sources. If you have downloaded (or plan to download) this source from
arXiv, some minor extra steps are necessary as listed below. This is
because this tarball is mainly tailored to automatic creation of the final
PDF without using Maneage (only calling LaTeX, not using the './project'
command)!

You can directly run 'latex' on this directory and the paper will be built
with no analysis (all necessary built products are already included in the
tarball). One important feature of the tarball is that it has an extra
`Makefile` to allow easy building of the PDF paper without worring about
the exact LaTeX and bibliography software commands.



#### Only building PDF using tarball (no analysis)

1. If you got the tarball from arXiv and the arXiv code for the paper is
   1234.56789, then the downloaded source will be called `1234.56789` (no
   suffix). However, it is actually a `.tar.gz` file. So take these steps
   to unpack it to see its contents.

     ```shell
     $ arxiv=1234.56789
     $ mv $arxiv $arxiv.tar.gz
     $ mkdir $arxiv
     $ cd $arxiv
     $ tar xf ../$arxiv.tar.gz
     ```

2. No matter how you got the tarball, if you just want to build the PDF
   paper, simply run the command below. Note that this won't actually
   install any software or do any analysis, it will just use your host
   operating system (assuming you already have a LaTeX installation and all
   the necessary LaTeX packages) to build the PDF using the already-present
   plots data.

   ```shell
   $ make              # Build PDF in tarball without doing analysis
   ```

3. If you want to re-build the figures from scratch, you need to make the
   following corrections to the paper's main LaTeX source (`paper.tex`):
   uncomment (remove the starting `%`) the line containing
   `\newcommand{\makepdf}{}`, see the comments above it for more.



#### Building full project from tarball (custom software and analysis)

As described above, the tarball is mainly geared to only building the final
PDF. A few small tweaks are necessary to build the full project from
scratch (download necessary software and data, build them and run the
analysis and finally create the final paper).

1. If you got the tarball from arXiv, before following the standard
   procedure of projects described at the top of the file above (using the
   `./project` script), its necessary to set its executable flag because
   arXiv removes the executable flag from the files (for its own security).

     ```shell
     $ chmod +x project
     ```

2. Make the following changes in two of the LaTeX files so LaTeX attempts
   to build the figures from scratch (to make the tarball; it was
   configured to avoid building the figures, just using the ones that came
   with the tarball).

   - `paper.tex`: uncomment (remove the starting `%`) of the line
     containing `\newcommand{\makepdf}{}`, see the comments above it for
     more.

   - `tex/src/preamble-pgfplots.tex`: set the `tikzsetexternalprefix`
     variable value to `tikz/`, so it looks like this:
     `\tikzsetexternalprefix{tikz/}`.

3. Remove extra files. In order to make sure arXiv can build the paper
   (resolve conflicts due to different versions of LaTeX packages), it is
   sometimes necessary to copy raw LaTeX package files in the tarball
   uploaded to arXiv. Later, we will implement a feature to automatically
   delete these extra files, but for now, the project's top directory
   should only have the following contents (where `reproduce` and `tex` are
   directories). You can safely remove any other file/directory.

     ```shell
     $ ls
     COPYING  paper.tex  project  README-hacking.md  README.md  reproduce/  tex/
     ```





### Building on ARM

As of 2021-10-13, very little testing of Maneage has been done on arm64
(tested in [aarch64](https://en.wikipedia.org/wiki/AArch64)). However,
_some_ testing has been done on [the
PinePhone](https://en.wikipedia.org/wiki/PinePhone), running
[Debian/Mobian](https://wiki.mobian-project.org/doku.php?id=pinephone). In
principle default Maneage branch (not all high-level software have been
tested) should run fully (configure + make) from the raw source to the
final verified pdf. Some issues that you might need to be aware of are
listed below.

#### Older packages

In old packages that may be still needed and that have an old
`config.guess` file (e.g. from 2002, such as fftw2-2.1.5-4.2, that are not
in the base Maneage branch) may crash during the build. A workaround is to
provide an updated (e.g. 2018) 'config.guess' file (automake --add-missing
--force-missing --copy) in 'reproduce/software/patches/' and copy it over
the old file during the build of the package.

#### An un-killable running job

Vampires may be a problem on the pinephone/aarch64. A "vampire" is defined
here as a job that is in the "R" (running) state, using nearly 95-100% of a
cpu, for an extremely long time (hours), without producing any output to
its log file, and is immune to being killed by the user or root with 'kill
-9'. A reboot and relaunch of the './project configure --existing-conf'
command is the only solution currently known (as of 2021-10-13) for
vampires. These are known to have occurred with linux-image-5.13-sunxi64.


#### RAM/swap space

Adding atleast 3 Gb of swap space (man swapon, man mkswap, man dd) on the
eMMC may help to reduce the chance of having errors due to the lack of RAM.


#### Time scale

On the PinePhone v1.2b, apart from the time wasted by vampires, expect
roughly 24 hours' wall time in total for the full 'configure' phase. The
default 'maneage' example calculations, diagrams and pdf production are
light and should be very fast.





### Building in Docker containers

Docker containers are a common way to build projects in an independent
filesystem, and an almost independent operating system. Containers thus
allow using GNU/Linux operating systems within proprietary operating
systems like macOS or Windows. But without the overhead and huge file size
of virtual machines. Furthermore containers allow easy movement of built
projects from one system to another without rebuilding. Just note that
Docker images are large binary files (+1 Gigabytes) and may not be usable
in the future (for example with new Docker versions not reading old
images). Containers are thus good for temporary/testing phases of a
project, but shouldn't be what you archive for the long term!

Hence if you want to save and move your maneaged project within a Docker
image, be sure to commit all your project's source files and push them to
your external Git repository (you can do these within the Docker image as
explained below). This way, you can always recreate the container with
future technologies too. Generally, if you are developing within a
container, its good practice to recreate it from scratch every once in a
while, to make sure you haven't forgot to include parts of your work in
your project's version-controlled source. In the sections below we also
describe how you can use the container **only for the software
environment** and keep your data and project source on your host.

#### Dockerfile for a Maneaged project, and building a Docker image

Below is a series of recommendations on the various components of a
`Dockerfile` optimized to store the *built state of a maneaged project* as
a Docker image. Each component is also accompanied with
explanations. Simply copy the code blocks under each item into a plain-text
file called `Dockerfile`, in the same order of the items. Don't forget to
implement the suggested corrections (in particular step 4).

**NOTE: Internet for TeXLive installation:** If you have the project
software tarballs and input data (optional features described below) you
can disable internet. In this situation, the configuration and analysis
will be exactly reproduced, the final LaTeX macros will be created, and all
results will be verified successfully. However, no final `paper.pdf` will
be created to visualize/combine everything in one easy-to-read file. Until
[task 15267](https://savannah.nongnu.org/task/?15267) is complete, we need
internet to install TeXLive packages (using TeXLive's own package manager
`tlmgr`) in the `./project configure` phase. This won't stop the
configuration, and it will finish successfully (since all the analysis can
still be reproduced). We are working on completing this task as soon as
possible, but until then, if you want to disable internet *and* you want to
build the final PDF, please disable internet after the configuration
phase. Note that only the necessary TeXLive packages are installed (~350
MB), not the full TeXLive collection!

 0. **Summary:** If you are already familiar with Docker, then the full
    Dockerfile to get the project environment setup is shown here (without
    any comments or explanations, because explanations are done in the next
    items). Note that the last two `COPY` lines (to copy the directory
    containing software tarballs used by the project and the possible input
    databases) are optional because they will be downloaded if not
    available. You can also avoid copying over all, and simply mount your
    host directories within the image, we have a separate section on doing
    this below ("Only software environment in the Docker image"). Once you
    build the Docker image, your project's environment is setup and you can
    go into it to run `./project make` manually.

    ```shell
    FROM debian:stable-slim
    RUN apt update && apt install -y gcc g++ wget
    RUN useradd -ms /bin/sh maneager
    RUN printf '123\n123' | passwd root
    USER maneager
    WORKDIR /home/maneager
    RUN mkdir build
    RUN mkdir software
    COPY --chown=maneager:maneager ./project-source /home/maneager/source
    COPY --chown=maneager:maneager ./software-dir   /home/maneager/software
    COPY --chown=maneager:maneager ./data-dir       /home/maneager/data
    RUN cd /home/maneager/source \
        && ./project configure --build-dir=/home/maneager/build \
                               --software-dir=/home/maneager/software \
                               --input-dir=/home/maneager/data
    ```

 1. **Choose the base operating system:** The first step is to select the
    operating system that will be used in the docker image. Note that your
    choice of operating system also determines the commands of the next
    step to install core software.

    ```shell
    FROM debian:stable-slim
    ```

 2. **Maneage dependencies:** By default the "slim" versions of the
    operating systems don't contain a compiler (needed by Maneage to
    compile precise versions of all the tools). You thus need to use the
    selected operating system's package manager to import them (below is
    the command for Debian). Optionally, if you don't have the project's
    software tarballs, and want the project to download them automatically,
    you also need a downloader.

    ```shell
    # C and C++ compiler.
    RUN apt update && apt install -y gcc g++

    # Uncomment this if you don't have 'software-XXXX.tar.gz' (below).
    #RUN apt install -y wget
    ```

 3. **Define a user:** Some core software packages will complain if you try
    to install them as the default (root) user. Generally, it is also good
    practice to avoid being the root user. Hence with the commands below we
    define a `maneager` user and activate it for the next steps. But just
    in case root access is necessary temporarily, with the `passwd`
    command, we are setting the root password to `123`.

    ```shell
    RUN useradd -ms /bin/sh maneager
    RUN printf '123\n123' | passwd root
    USER maneager
    WORKDIR /home/maneager
    ```

 4. **Copy project files into the container:** these commands make the
    assumptions listed below. IMPORTANT: you can also avoid copying over
    all, and simply mount your host directories within the image, we have a
    separate section on doing this below ("Only software environment in the
    Docker image").

    * The project's source is in the `maneaged/` sub-directory and this
      directory is in the same directory as the `Dockerfile`. The source
      can either be from cloned from Git (highly recommended!) or from a
      tarball. Both are described above (note that arXiv's tarball needs to
      be corrected as mentioned above).

    * (OPTIONAL) By default the project's necessary software source
      tarballs will be downloaded when necessary during the `./project
      configure` phase. But if you already have the sources, its better to
      use them and not waste network traffic (and resulting carbon
      footprint!). Maneaged projects usually come with a
      `software-XXXX.tar.gz` file that is published on Zenodo (link above).
      If you have this file, put it in the same directory as your
      `Dockerfile` and include the relevant lines below.

    * (OPTIONAL) The project's input data. The `INPUT-FILES` depends on the
      project, please look into the project's
      `reproduce/analysis/config/INPUTS.conf` for the URLs and the file
      names of input data. Similar to the software source files mentioned
      above, if you don't have them, the project will attempt to download
      its necessary data automatically in the `./project make` phase.

    ```shell
    # Make the project's build directory and copy the project source
    RUN mkdir build
    COPY --chown=maneager:maneager ./maneaged /home/maneager/source

    # Optional (for software)
    COPY --chown=maneager:maneager ./software-XXXX.tar.gz /home/maneager/
    RUN tar xf software-XXXX.tar.gz && mv software-XXXX software && rm software-XXXX.tar.gz

    # Optional (for data)
    RUN mkdir data
    COPY --chown=maneager:maneager ./INPUT-FILES /home/maneager/data
    ```

 5. **Configure the project:** With this line, the Docker image will
    configure the project (build all its necessary software). This will
    usually take about an hour on an 8-core system. You can also optionally
    avoid putting this step (and the next) in the `Dockerfile` and simply
    execute them in the Docker image in interactive mode (as explained in
    the sub-section below, in this case don't forget to preserve the build
    container after you are done).

    ```shell
    # Configure project (build full software environment).
    RUN cd /home/maneager/source \
           && ./project configure --build-dir=/home/maneager/build \
                                  --software-dir=/home/maneager/software \
                                  --input-dir=/home/maneager/data
    ```

 6. **Project's analysis:** With this line, the Docker image will do the
    project's analysis and produce the final `paper.pdf`. The time it takes
    for this step to finish, and the storage/memory requirements highly
    depend on the particular project.

    ```shell
    # Run the project's analysis
    RUN cd /home/maneager/source && ./project make
    ```

 7. **Build the Docker image:** The `Dockerfile` is now ready! In the
    terminal, go to its directory and run the command below to build the
    Docker image. We recommend to keep the `Dockerfile` in **an empty
    directory** and run it from inside that directory too. This is because
    Docker considers that directories contents to be part of the
    environment. Finally, just set a `NAME` for your project and note that
    Docker only runs as root.

    ```shell
    sudo su
    docker build -t NAME ./
    ```



#### Interactive tests on built container

If you later want to start a container with the built image and enter it in
interactive mode (for example for temporary tests), please run the
following command. Just replace `NAME` with the same name you specified
when building the project. You can always exit the container with the
`exit` command (note that all your changes will be discarded once you exit,
see below if you want to preserve your changes after you exit).

```shell
docker run -it NAME
```



#### Running your own project's shell for same analysis environment

The default operating system only has minimal features: not having many of
the tools you are accustomed to in your daily command-line operations. But
your maneaged project has a very complete (for the project!) environment
which is fully built and ready to use interactively with the commands
below. For example the project also builds Git within itself, as well as
many other high-level tools that are used in your project and aren't
present in the container's operating system.

```shell
# Once you are in the docker container
cd source
./project shell
```



#### Preserving the state of a built container

All interactive changes in a container will be deleted as soon as you exit
it. THIS IS A VERY GOOD FEATURE IN GENERAL! If you want to make persistent
changes, you should do it in the project's plain-text source and commit
them into your project's online Git repository. As described in the Docker
introduction above, we strongly recommend to **not rely on a built container
for archival purposes**.

But for temporary tests it is sometimes good to preserve the state of an
interactive container. To do this, you need to `commit` the container (and
thus save it as a Docker "image"). To do this, while the container is still
running, open another terminal and run these commands:

```shell
# These two commands should be done in another terminal
docker container list

# Get 'XXXXXXX' of your desired container from the first column above.
# Give the new image a name by replacing 'NEW-IMAGE-NAME'.
docker commit XXXXXXX NEW-IMAGE-NAME
```



#### Copying files from the Docker image to host operating system

The Docker environment's file system is completely indepenent of your host
operating system. One easy way to copy files to and from an open container
is to use the `docker cp` command (very similar to the shell's `cp`
command).

```shell
docker cp CONTAINER:/file/path/within/container /host/path/target
```





#### Only software environment in the Docker image

You can set the docker image to only contain the software environment and
keep the project source and built analysis files (data and PDF) on your
host operating system. This enables you to keep the size of the Docker
image to a minimum (only containing the built software environment) to
easily move it from one computer to another. Below we'll summarize the
steps.

 1.  Get your user ID with this command: `id -u`.

 2.  Make a new (empty) directory called `docker` temporarily (will be
     deleted later).

     ```shell
     mkdir docker-tmp
     cd docker-tmp
     ```

 3.  Make a `Dockerfile` (within the new/empty directory) with the
     following contents. Just replace `UID` with your user ID (found in
     step 1 above). Note that we are manually setting the `maneager` (user)
     password to `123` and the root password to '456' (both should be
     repeated because they must be confirmed by `passwd`).

     ```
     FROM debian:stable-slim
     RUN useradd -ms /bin/sh --uid UID maneager; \
         printf '123\n123' | passwd maneager; \
         printf '456\n456' | passwd root
     USER maneager
     WORKDIR /home/maneager
     RUN mkdir build; mkdir build/analysis
     ```

 4.  Create a Docker image based on the `Dockerfile` above. Just replace
     `MANEAGEBASE` with your desired name (this won't be your final image,
     so you can safely use a name like `maneage-base`). Note that you need
     to have root/administrator previlages when running it, so

     ```shell
     sudo docker build -t MANEAGEBASE ./
     ```

 5.  You don't need the temporary directory any more (the docker image is
     saved in Docker's own location, and accessible from anywhere).

     ```shell
     cd ..
     rm -rf docker-tmp
     ```

 6.  Put the following contents into a newly created plain-text file called
     `docker-run`, while setting the mandatory variables based on your
     system. The name `docker-run` is already inside Maneage's `.gitignore`
     file, so you don't have to worry about mistakenly commiting this file
     (which contains private information: directories in this computer).

     ```
     #!/bin/sh
     #
     # Create a Docker container from an existing image of the built
     # software environment, but with the source, data and build (analysis)
     # directories directly within the host file system. This script should
     # be run in the top project source directory (that has 'README.md' and
     # 'paper.tex'). If not, replace the '$(pwd)' part with the project
     # source directory.

     # MANDATORY: Name of Docker container
     docker_name=MANEAGEBASE

     # MANDATORY: Location of "build" directory on this system (to host the
     # 'analysis' sub-directory for output data products and possibly others).
     build_dir=/PATH/TO/THIS/PROJECT/S/BUILD/DIR

     # OPTIONAL: Location of project's input data in this system. If not
     # present, a 'data' directory under the build directory will be created.
     data_dir=/PATH/TO/THIS/PROJECT/S/DATA/DIR

     # OPTIONAL: Location of software tarballs to use in building Maneage's
     # internal software environment.
     software_dir=/PATH/TO/SOFTWARE/TARBALL/DIR





     # Internal proceessing
     # --------------------
     #
     # Sanity check: Make sure that the build directory actually exists.
     if ! [ -d $build_dir ]; then
         echo "ERROR: '$build_dir' doesn't exist"; exit 1;
     fi

     # If the host operating system has '/dev/shm', then give Docker access
     # to it also for improved speed in some scenarios (like configuration).
     if [ -d /dev/shm ]; then shmopt="-v /dev/shm:/dev/shm";
     else                     shmopt=""; fi

     # If the 'analysis' and 'data' directories (that are mounted), don't exist,
     # then create them (otherwise Docker will create them as 'root' before
     # creating the container, and we won't have permission to write in them.
     analysis_dir="$build_dir"/analysis
     if ! [ -d $analysis_dir ]; then mkdir $analysis_dir; fi

     # If the data or software directories don't exist, put them in the build
     # directory (they will remain empty, but this helps in simplifiying the
     # mounting command!).
     if ! [ -d $data_dir ]; then
         data_dir="$build_dir"/data
         if ! [ -d $data_dir ]; then mkdir $data_dir; fi
     fi
     if ! [ -d $software_dir ]; then
         software_dir="$build_dir"/tarballs-software
         if ! [ -d $software_dir ]; then mkdir $software_dir; fi
     fi

     # Run the Docker image while setting up the directories.
     sudo docker run -v "$software_dir":/home/maneager/tarballs-software \
                     -v "$analysis_dir":/home/maneager/build/analysis \
                     -v "$data_dir":/home/maneager/data \
                     -v "$(pwd)":/home/maneager/source \
                     $shmopt -it $docker_name
     ```

 7.  Make the `docker-run` script executable.

     ```shell
     chmod +x docker-run
     ```

 8.  You can now start the Docker image by executing your newly added
     script like below (it will ask for your root password). You will
     notice that you are in the Docker container with the changed prompt.

     ```shell
     ./docker-run
     ```

 9.  You are now within the container. First, we'll add the GNU C and C++
     compilers (which are necessary to build our own programs in Maneage)
     and the GNU WGet downloader (which may be necessary if you don't have
     a core software's tarball already). Maneage will build pre-defined
     versions of both and will use them. But for the very first packages,
     they are necessary. In the process, by setting the `PS1` environment
     variable, we'll define a color-coding for the interactive shell prompt
     (red for root and purple for the user).

     ```shell
     su
     echo 'export PS1="[\[\033[01;31m\]\u@\h \W\[\033[32m\]\[\033[00m\]]# "' >> ~/.bashrc
     source ~/.bashrc
     apt update
     apt install -y gcc g++ wget
     exit
     echo 'export PS1="[\[\033[01;35m\]\u@\h \W\[\033[32m\]\[\033[00m\]]$ "' >> ~/.bashrc
     source ~/.bashrc
     ```

 10. Now that the compiler is ready, we can start Maneage's
     configuration. So let's go into the project source directory and run
     these commands to build the software environment.

     ```shell
     cd source
     ./project configure --input-dir=/home/maneager/data \
                         --build-dir=/home/maneager/build \
                         --software-dir=/home/maneager/tarballs-software
     ```

 11. After the configuration finishes successfully, it will say so. It will
     then ask you to run `./project make`. **But don't do that
     yet**. Keep this Docker container open and don't exit the container or
     terminal. Open a new terminal, and follow the steps described in the
     sub-section above to preserve (or "commit") the built container as a
     Docker image. Let's assume you call it `MY-PROJECT-ENV`. After the new
     image is made, you should be able to see the new image in the list of
     images with this command (in yet another terminal):

     ```shell
     docker image list      # In the other terminal.
     ```

 12. Now that you have safely "committed" your current Docker container
     into a separate Docker image, you can **exit the container** safely
     with the `exit` command. Don't worry, you won't loose the built
     software environment: it is all now saved separately within the Docker
     image.

 13. Re-open your `docker-run` script and change `MANEAGEBASE` to
     `MY-PROJECT-ENV` (or any other name you set for the environment you
     committed above).

     ```shell
     emacs docker-run
     ```

 14. That is it! You can now always easily enter your container (only for
     the software environemnt) with the command below. Within the
     container, any file you save/edit in the `source` directory of the
     docker container is the same file on your host OS and any file you
     build in your `build/analysis` directory (within the Maneage'd
     project) will be on your host OS. You can even use your container's
     Git to store the history of your project in your host OS. See the next
     step in case you want to move your built software environment to
     another computer.

     ```shell
     ./docker-run
     ```

 15. In case you want to store the image as a single file as backup or to
     move to another computer, you can run the commands below. They will
     produce a single `project-env.tar.gz` file.

     ```shell
     docker save -o my-project-env.tar MY-PROJECT-ENV
     gzip --best project-env.tar
     ```

 16. To load the tarball above into a clean docker environment (for example
     on another system) copy the `my-project-env.tar.gz` file there and run
     the command below. You can then create the `docker-run` script for
     that system and run it to enter. Just don't forget that if your
     `analysis_dir` directory is empty on the new/clean system. So you
     should first run the same `./project configure ...` command above in
     the docker image so it connects the environment to your source. Don't
     worry, it won't build any software and should finish in a second or
     two. Afterwards, you can safely run `./project make` and continue
     working like you did on the old system.

     ```shell
     docker load --input my-project-env.tar.gz
     ```





#### Deleting all Docker images

After doing your tests/work, you may no longer need the multi-gigabyte
files images, so its best to just delete them. To do this, just run the two
commands below to first stop all running containers and then to delete all
the images:

```shell
docker ps -a -q | xargs docker rm
docker images -a -q | xargs docker rmi -f
```





### Copyright information

This file and `.file-metadata` (a binary file, used by Metastore to store
file dates when doing Git checkouts) are part of the reproducible project
mentioned above and share the same copyright notice (at the start of this
file) and license notice (below).

This project is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option)
any later version.

This project is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along
with this project.  If not, see <https://www.gnu.org/licenses/>.
