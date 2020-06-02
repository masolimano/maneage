Reproducible source for XXXXXXXXXXXXXXXXX
-------------------------------------------------------------------------

Copyright (C) 2018-2020 Mohammad Akhlaghi <mohammad@akhlaghi.org>\
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
