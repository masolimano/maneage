Reproducible source for XXXXXXXXXXXXXXXXX
=========================================

Copyright (C) 2018-2020 Mohammad Akhlaghi <mohammad@akhlaghi.org>\
See the end of the file for license conditions.

This is the reproducible project source for the paper titled "**XXX XXXXX
XXXXXX**", by XXXXX XXXXXX, YYYYYY YYYYY and ZZZZZZ ZZZZZ that is published
in XXXXX XXXXX.

To reproduce the results and final paper, the only dependency is a minimal
Unix-based building environment including a C compiler (already available
on your system if you have ever built and installed a software from source)
and a downloader (Wget or cURL). Note that **Git is not mandatory**: if you
don't have Git to run the first command below, go to the URL given in the
command on your browser, and download the project's source (there is a
button to download a compressed tarball of the project). If you have
received this source from arXiv, please see the respective section below.

```shell
$ git clone XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
$ cd XXXXXXXXXXXXXXXXXX
$ ./project configure
$ ./project prepare
$ ./project make
```

To learn more about the purpose, principles and technicalities of this
reproducible paper, please see `README-hacking.md`. For a general
introduction to reproducible science as implemented in this project, please
see the [principles of reproducible
science](http://akhlaghi.org/reproducible-science.html), and a
[reproducible paper
template](https://gitlab.com/makhlaghi/reproducible-paper) that is based on
it.





Building the project
--------------------

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
        collected in the archived project on Zenodo (link below) [[TO
        AUTHORS: UPLOAD THE SOFTWARE TARBALLS WITH YOUR DATA AND PROJECT
        SOURCE TO ZENODO OR OTHER SIMILAR SERVICES. THEN ADD THE DOI/LINK
        HERE.DON'T FORGET THAT THE SOFTWARE ARE A CRITICAL PART OF YOUR
        WORK.]]. Just unpack that tarball, and when `./project configure`
        asks for the "software tarball directory", give the address of the
        unpacked directory that has all the tarballs.
          https://doi.org/10.5281/zenodo.3408481

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

3. In some cases, the project's analysis may need some preparations to
   optimize its processing. This is usually mainly related to input data,
   and some very basic calculations that can help the management of the
   overall lproject in the main/next step. To do the basic preparations,
   please run this command to do the preparation on `8` threads. If your
   CPU has a different number of threads, change the number (you can see
   the number of threads available to your operating system by running
   `./.local/bin/nproc`)

     ```shell
     $ ./project prepare -j8
     ```

4. Run the following command to reproduce all the analysis and build the
   final `paper.pdf` on `8` threads. If your CPU has a different number of
   threads, change the number (you can see the number of threads available
   to your operating system by running `./.local/bin/nproc`)

     ```shell
     $ ./project make -j8
     ```





Source from arXiv
-----------------
If the paper is also published on arXiv, it is highly likely that the
authors also uploaded/published the full reproducible paper template there
along with the LaTeX sources. If you have downloaded (or plan to download)
this source from arXiv, some minor extra steps are necessary:

1. If the arXiv code for the paper is 1234.56789, then the downloaded
   source will be called `1234.56789` (no special identification
   suffix). However, it is actually a `.tar.gz` file. So take these steps
   to unpack it to see its contents.

     ```shell
     $ arxiv=1234.56789
     $ mv $arxiv $arxiv.tar.gz
     $ mkdir $arxiv
     $ cd $arxiv
     $ tar xf ../$arxiv.tar.gz
     ```

2. arXiv removes the executable flag from the files (for its own
   security). So before following the standard procedure of projects
   described in the sections above, its necessary to set the executable
   flag of the main project management file with this command:

     ```shell
     $ chmod +x project
     ```

3. Remove extra files. In order to make sure arXiv can build the paper
   (resolve conflicts due to different versions of LaTeX packages), it is
   sometimes necessary to copy raw LaTeX package files in the tarball
   uploaded to arXiv. Later, we will implement a feature to automatically
   delete these extra files, but for now, the project's top directory
   should only have the following contents (where `reproduce` and `tex` are
   directories). You can safely remove any other file/directory.

     ```shell
     $ ls
     COPYING  paper.tex  project  README-hacking.md  README.md  reproduce  tex
     ```

4. To build the figures from scratch, you need to make the following
   corrections to the LaTeX source files below.

   4.1: `paper.tex`: uncomment (remove the starting `%`) of the line
         containing `\newcommand{\makepdf}{}`. See the comments above it
         for more information.

   4.2: `tex/src/preamble-pgfplots.tex`: set the `tikzsetexternalprefix`
        variable value to `tikz/`, so it looks like this:
        `\tikzsetexternalprefix{tikz/}`.

5. In order to let arXiv build the LaTeX paper without bothering to run the
   analysis pipeline it was necessary to create and fill the two
   `tex/build` and `tex/tikz` subdirectories. But to do a clean build of
   the project, it is necessary for these to be symbolic links to the build
   directory. So when you are first configuring the project, run it with
   `--clean-texdir` (only once is enough, they will be deleted permanently
   after that), for example:

     ```shell
     $ ./project configure --clean-texdir
     ```





Copyright information
---------------------

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