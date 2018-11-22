Reproduction pipeline for paper XXXXXXX
=======================================

This is the reproduction pipeline for the paper titled "**XXXXXX**", by
XXXXXXXX et al. (**IN PREPARATION**).

To reproduce our results, the only dependency is **Wget**, and a minimal
Unix-based building environment including a C compiler (already available
on your system if you have ever built and installed a software from
source). Note that **Git is not mandatory**: if you don't have Git to run
the first command below, go to the URL given in the command on your
browser, and download them manually (there is a button to download a
compressed tarball of the project).

```shell
$ git clone XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
$ ./configure
$ .local/bin/make -j8
```

For a general introduction to reproducible science as implemented in this
pipeline, please see the [principles of reproducible
science](http://akhlaghi.org/reproducible-science.html), and a
[reproducible paper
template](https://gitlab.com/makhlaghi/reproducible-paper) that is based on
it.





Running the pipeline
--------------------

This pipeline was designed to have as few dependencies as possible.

1. Necessary dependencies:

   1.1: Minimal software building tools like C compiler, Make, and other
        tools found on any Unix-like operating system (GNU/Linux, BSD, Mac
        OS, and others). All necessary dependencies will be built from
        source (for use only within this pipeline) by the `./configure'
        script (next step).

   1.2: (OPTIONAL) Tarball of dependencies. If they are already present (in
        a directory given at configuration time), they will be
        used. Otherwise, *GNU Wget* will be used to download any necessary
        tarball. The necessary tarballs are also collected in the link
        below for easy download:

          https://gitlab.com/makhlaghi/reproducible-paper-dependencies

2. Configure the environment (top-level directories in particular) and
   build all the necessary software for use in the next step. It is
   recommended to set directories outside the current directory. Please
   read the description of each necessary input clearly and set the best
   value. Note that the configure script also downloads, builds and locally
   installs (only for this pipeline, no root previlages necessary) many
   programs (pipeline dependencies). So it may take a while to complete.

     ```shell
     $ ./configure
     ```

3. Run the following command (local build of the Make software) to
   reproduce all the analysis and build the final `paper.pdf` on *8*
   threads. If your CPU has a different number of threads, change the
   number (you can see the number of threads available to your operating
   system by running `./.local/bin/nproc`)

     ```shell
     $ .local/bin/make -j8
     ```
