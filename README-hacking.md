Maneage: managing data lineage
==============================

Copyright (C) 2018-2022 Mohammad Akhlaghi <mohammad@akhlaghi.org>\
Copyright (C) 2020-2022 Raul Infante-Sainz <infantesainz@gmail.com>\
See the end of the file for license conditions.

Maneage is a **fully working template** for doing reproducible research (or
writing a reproducible paper) as defined in the link below. If the link
below is not accessible at the time of reading, please see the appendix at
the end of this file for a portion of its introduction. Some
[slides](http://akhlaghi.org/pdf/reproducible-paper.pdf) are also available
to help demonstrate the concept implemented here.

  http://akhlaghi.org/reproducible-science.html

Maneage is created with the aim of supporting reproducible research by
making it easy to start a project in this framework. As shown below, it is
very easy to customize Maneage for any particular (research) project and
expand it as it starts and evolves. It can be run with no modification (as
described in `README.md`) as a demonstration and customized for use in any
project as fully described below.

A project designed using Maneage will download and build all the necessary
libraries and programs for working in a closed environment (highly
independent of the host operating system) with fixed versions of the
necessary dependencies. The tarballs for building the local environment are
also collected in a [separate
repository](http://git.maneage.org/tarballs-software.git/tree/). The final
output of the project is [a
paper](http://git.maneage.org/output-raw.git/plain/paper.pdf).  Notice the
last paragraph of the Acknowledgments where all the necessary software are
mentioned with their versions.

Below, we start with a discussion of why Make was chosen as the high-level
language/framework for project management and how to learn and master Make
easily (and freely). The general architecture and design of the project is
then discussed to help you navigate the files and their contents. This is
followed by a checklist for the easy/fast customization of Maneage to your
exciting research. We continue with some tips and guidelines on how to
manage or extend your project as it grows based on our experiences with it
so far. There is also a publication checklist, describing the recommended
steps to publish your data/code. The main body concludes with a description
of possible future improvements that are planned for Maneage (but not yet
implemented). As discussed above, we end with a short introduction on the
necessity of reproducible science in the appendix.

Please don't forget to share your thoughts, suggestions and
criticisms. Maintaining and designing Maneage is itself a separate project,
so please join us if you are interested. Once it is mature enough, we will
describe it in a paper (written by all contributors) for a formal
introduction to the community.





Why Make?
---------

When batch processing is necessary (no manual intervention, as in a
reproducible project), shell scripts are usually the first solution that
come to mind. However, the inherent complexity and non-linearity of
progress in a scientific project (where experimentation is key) make it
hard to manage the script(s) as the project evolves. For example, a script
will start from the top/start every time it is run. So if you have already
completed 90% of a research project and want to run the remaining 10% that
you have newly added, you have to run the whole script from the start
again. Only then will you see the effects of the last new steps (to find
possible errors, or better solutions and etc).

It is possible to manually ignore/comment parts of a script to only do a
special part. However, such checks/comments will only add to the complexity
of the script and will discourage you to play-with/change an already
completed part of the project when an idea suddenly comes up. It is also
prone to very serious bugs in the end (when trying to reproduce from
scratch). Such bugs are very hard to notice during the work and frustrating
to find in the end.

The Make paradigm, on the other hand, starts from the end: the final
*target*. It builds a dependency tree internally, and finds where it should
start each time the project is run. Therefore, in the scenario above, a
researcher that has just added the final 10% of steps of her research to
her Makefile, will only have to run those extra steps. With Make, it is
also trivial to change the processing of any intermediate (already written)
*rule* (or step) in the middle of an already written analysis: the next
time Make is run, only rules that are affected by the changes/additions
will be re-run, not the whole analysis/project.

This greatly speeds up the processing (enabling creative changes), while
keeping all the dependencies clearly documented (as part of the Make
language), and most importantly, enabling full reproducibility from scratch
with no changes in the project code that was working during the
research. This will allow robust results and let the scientists get to what
they do best: experiment and be critical to the methods/analysis without
having to waste energy and time on technical problems that come up as a
result of that experimentation in scripts.

Since the dependencies are clearly demarcated in Make, it can identify
independent steps and run them in parallel. This further speeds up the
processing. Make was designed for this purpose. It is how huge projects
like all Unix-like operating systems (including GNU/Linux or Mac OS
operating systems) and their core components are built. Therefore, Make is
a highly mature paradigm/system with robust and highly efficient
implementations in various operating systems perfectly suited for a complex
non-linear research project.

Make is a small language with the aim of defining *rules* containing
*targets*, *prerequisites* and *recipes*. It comes with some nice features
like functions or automatic-variables to greatly facilitate the management
of text (filenames for example) or any of those constructs. For a more
detailed (yet still general) introduction see the article on Wikipedia:

  https://en.wikipedia.org/wiki/Make_(software)

Make is a +40 year old software that is still evolving, therefore many
implementations of Make exist. The only difference in them is some extra
features over the [standard
definition](https://pubs.opengroup.org/onlinepubs/009695399/utilities/make.html)
(which is shared in all of them). Maneage is primarily written in GNU Make
(which it installs itself, you don't have to have it on your system). GNU
Make is the most common, most actively developed, and most advanced
implementation. Just note that Maneage downloads, builds, internally
installs, and uses its own dependencies (including GNU Make), so you don't
have to have it installed before you try it out.





How can I learn Make?
---------------------

The GNU Make book/manual (links below) is arguably the best place to learn
Make. It is an excellent and non-technical book to help get started (it is
only non-technical in its first few chapters to get you started easily). It
is freely available and always up to date with the current GNU Make
release. It also clearly explains which features are specific to GNU Make
and which are general in all implementations. So the first few chapters
regarding the generalities are useful for all implementations.

The first link below points to the GNU Make manual in various formats and
in the second, you can download it in PDF (which may be easier for a first
time reading).

  https://www.gnu.org/software/make/manual/

  https://www.gnu.org/software/make/manual/make.pdf

If you use GNU Make, you also have the whole GNU Make manual on the
command-line with the following command (you can come out of the "Info"
environment by pressing `q`).

```shell
  $ info make
```

If you aren't familiar with the Info documentation format, we strongly
recommend running `$ info info` and reading along. In less than an hour,
you will become highly proficient in it (it is very simple and has a great
manual for itself). Info greatly simplifies your access (without taking
your hands off the keyboard!) to many manuals that are installed on your
system, allowing you to be much more efficient as you work. If you use the
GNU Emacs text editor (or any of its variants), you also have access to all
Info manuals while you are writing your projects (again, without taking
your hands off the keyboard!).





Published works using Maneage
-----------------------------

The list below shows some of the works that have already been published
with (earlier versions of) Maneage, and some that have been recently
submitted for peer review. The previous version of Maneage was called
"Reproducible paper template", with a separate git tree. Maneage is
evolving rapidly, so some details will differ between the different
versions. The more recent papers will tend to be the most useful as good
working examples.

 - Borkowska & Roukema
   ([2022](https://ui.adsabs.harvard.edu/abs/2021arXiv211214174B), MNRAS
   Submitted, arXiv:2112.14174): The live version of the controlled source
   is [at Codeberg](https://codeberg.org/boud/gevcurvtest); the main input
   dataset, a software snapshot, the software tarballs, the project outputs
   and editing history are available at
   [zenodo.5806027](https://doi.org/10.5281/zenodo.5806027); and the
   archived git history is available at [swh:1:rev:54398b720ddbac269ede30bf1e27fe27f07567f7](https://archive.softwareheritage.org/browse/revision/54398b720ddbac269ede30bf1e27fe27f07567f7).

 - Peper & Roukema
   ([2021](https://ui.adsabs.harvard.edu/abs/2021MNRAS.505.1223P), MNRAS,
   505, 1223, DOI:10.1093/mnras/stab1342, arXiv:2010.03742): The live
   version of the controlled source is [at
   Codeberg](https://codeberg.org/boud/elaphrocentre); the main input
   dataset, a software snapshot, the software tarballs, the project outputs
   and editing history are available at
   [zenodo.4699702](https://zenodo.org/record/4699702); and the archived
   git history is available at
   [swh:1:rev:a029edd32d5cd41dbdac145189d9b1a08421114e](https://archive.softwareheritage.org/swh:1:rev:a029edd32d5cd41dbdac145189d9b1a08421114e).

 - Roukema ([2021](https://ui.adsabs.harvard.edu/abs/2021PeerJ...911856R),
   PeerJ, 9:e11856, arXiv:2007.11779): The live version of the controlled
   source is [at Codeberg](https://codeberg.org/boud/subpoisson); the main
   input dataset, a software snapshot, the software tarballs, the project
   outputs and editing history are available at
   [zenodo.4765705](https://zenodo.org/record/4765705); and the archived
   git history is available at
   [swh:1:rev:72242ca8eade9659031ea00394a30e0cc5cc1c37](https://archive.softwareheritage.org/swh:1:rev:72242ca8eade9659031ea00394a30e0cc5cc1c37).

 - Akhlaghi et
   al. ([2021](https://ui.adsabs.harvard.edu/abs/2021CSE....23c..82A),
   CiSE, 23(3), 82 DOI:10.1109/MCSE.2021.3072860 arXiv:2006.03018): The
   project's version controlled source is [on
   Gitlab](https://gitlab.com/makhlaghi/maneage-paper), necessary software,
   outputs and backup of history are available at
   [zenodo.3872248](https://doi.org/10.5281/zenodo.3872248); and the
   archived git history is available at
   [swh:1:dir:45a9e282a86145fe9babef529c8fce52ffe8d717](https://archive.softwareheritage.org/swh:1:dir:45a9e282a86145fe9babef529c8fce52ffe8d717).

 - Infante-Sainz et
   al. ([2020](https://ui.adsabs.harvard.edu/abs/2020MNRAS.491.5317I),
   MNRAS, 491, 5317): The version controlled project source is available
   [on GitLab](https://gitlab.com/infantesainz/sdss-extended-psfs-paper)
   and is also archived on Zenodo with all the necessary software tarballs:
   [zenodo.3524937](https://zenodo.org/record/3524937).

 - Akhlaghi ([2019](https://arxiv.org/abs/1909.11230), IAU Symposium
   355). The version controlled project source is available
   [on GitLab](https://gitlab.com/makhlaghi/iau-symposium-355) and is also
   archived on Zenodo with all the necessary software tarballs:
   [zenodo.3408481](https://doi.org/10.5281/zenodo.3408481).

 - Section 7.3 of Bacon et
   al. ([2017](http://adsabs.harvard.edu/abs/2017A%26A...608A...1B), A&A
   608, A1): The version controlled project source is available [on
   GitLab](https://gitlab.com/makhlaghi/muse-udf-origin-only-hst-magnitudes)
   and a snapshot of the project along with all the necessary input
   datasets and outputs is available in
   [zenodo.1164774](https://doi.org/10.5281/zenodo.1164774).

 - Section 4 of Bacon et
   al. ([2017](http://adsabs.harvard.edu/abs/2017A%26A...608A...1B), A&A,
   608, A1): The version controlled project is available [on
   GitLab](https://gitlab.com/makhlaghi/muse-udf-photometry-astrometry) and
   a snapshot of the project along with all the necessary input datasets is
   available in [zenodo.1163746](https://doi.org/10.5281/zenodo.1163746).

 - Akhlaghi & Ichikawa
   ([2015](http://adsabs.harvard.edu/abs/2015ApJS..220....1A), ApJS, 220,
   1): The version controlled project is available [on
   GitLab](https://gitlab.com/makhlaghi/NoiseChisel-paper). This is the
   very first (and much less mature!) incarnation of Maneage: the history
   of Maneage started more than two years after this paper was
   published. It is a very rudimentary/initial implementation, thus it is
   only included here for historical reasons. However, the project source
   is complete, accurate and uploaded to arXiv along with the paper.





Citation
--------

If you use Maneage in your project please cite Akhlaghi et
al. ([2020](https://arxiv.org/abs/2006.03018), arXiv:2006.03018). It has
been submitted and is under peer review.

Also, when your paper is published, don't forget to add a notice in your
own paper (in coordination with the publishing editor) that the paper is
fully reproducible and possibly add a sentence or paragraph in the end of
the paper shortly describing the concept. This will help spread the word
and encourage other scientists to also manage and publish their projects in
a reproducible manner.










Project architecture
====================

In order to customize Maneage to your research, it is important to first
understand its architecture so you can navigate your way in the directories
and understand how to implement your research project within its framework:
where to add new files and which existing files to modify for what
purpose. But if this the first time you are using Maneage, before reading
this theoretical discussion, please run Maneage once from scratch without
any changes (described in `README.md`). You will see how it works (note that
the configure step builds all necessary software, so it can take long, but
you can continue reading while its working).

The project has two top-level directories: `reproduce` and
`tex`. `reproduce` hosts all the software building and analysis
steps. `tex` contains all the final paper's components to be compiled into
a PDF using LaTeX.

The `reproduce` directory has two sub-directories: `software` and
`analysis`. As the name says, the former contains all the instructions to
download, build and install (independent of the host operating system) the
necessary software (these are called by the `./project configure`
command). The latter contains instructions on how to use those software to
do your project's analysis.

After it finishes, `./project configure` will create the following symbolic
links in the project's top source directory: `.build` which points to the
top build directory and `.local` for easy access to the custom built
software installation directory. With these you can easily access the build
directory and project-specific software from your top source directory. For
example if you run `.local/bin/ls` you will be using the `ls` of Maneage,
which is probably different from your system's `ls` (run them both with
`--version` to check).

Once the project is configured for your system, `./project make` will do
the basic preparations and run the project's analysis with the custom
version of software. The `project` script is just a wrapper, and with the
`make` argument, it will first call `top-prepare.mk` and `top-make.mk`
(both are in the `reproduce/analysis/make` directory).

In terms of organization, `top-prepare.mk` and `top-make.mk` have an
identical design, only minor differences. So, let's continue Maneage's
architecture with `top-make.mk`. Once you understand that, you'll clearly
understand `top-prepare.mk` also. These very high-level files are
relatively short and heavily commented so hopefully the descriptions in
each comment will be enough to understand the general details. As you read
this section, please also look at the contents of the mentioned files and
directories to fully understand what is going on.

Before starting to look into the top `top-make.mk`, it is important to
recall that Make defines dependencies by files. Therefore, the
input/prerequisite and output of every step/rule must be a file. Also
recall that Make will use the modification date of the prerequisite(s) and
target files to see if the target must be re-built or not. Therefore during
the processing, _many_ intermediate files will be created (see the tips
section below on a good strategy to deal with large/huge files).

To keep the source and (intermediate) built files separate, the user _must_
define a top-level build directory variable (or `$(BDIR)`) to host all the
intermediate files (you defined it during `./project configure`). This
directory doesn't need to be version controlled or even synchronized, or
backed-up in other servers: its contents are all products, and can be
easily re-created any time. As you define targets for your new rules, it is
thus important to place them all under sub-directories of `$(BDIR)`. As
mentioned above, you always have fast access to this "build"-directory with
the `.build` symbolic link. Also, beware to *never* make any manual change
in the files of the build-directory, just delete them (so they are
re-built).

In this architecture, we have two types of Makefiles that are loaded into
the top `Makefile`: _configuration-Makefiles_ (only independent
variables/configurations) and _workhorse-Makefiles_ (Makefiles that
actually contain analysis/processing rules).

The configuration-Makefiles are those that satisfy these two wildcards:
`reproduce/software/config/*.conf` (for building the necessary software
when you run `./project configure`) and `reproduce/analysis/config/*.conf`
(for the high-level analysis, when you run `./project make`). These
Makefiles don't actually have any rules, they just have values for various
free parameters throughout the configuration or analysis. Open a few of
them to see for yourself. These Makefiles must only contain raw Make
variables (project configurations). By "raw" we mean that the Make
variables in these files must not depend on variables in any other
configuration-Makefile. This is because we don't want to assume any order
in reading them. It is also very important to *not* define any rule, or
other Make construct, in these configuration-Makefiles.

Following this rule-of-thumb enables you to set these configure-Makefiles
as a prerequisite to any target that depends on their variable
values. Therefore, if you change any of their values, all targets that
depend on those values will be re-built. This is very convenient as your
project scales up and gets more complex.

The workhorse-Makefiles are those satisfying this wildcard
`reproduce/software/make/*.mk` and `reproduce/analysis/make/*.mk`. They
contain the details of the processing steps (Makefiles containing
rules). Therefore, in this phase *order is important*, because the
prerequisites of most rules will be the targets of other rules that will be
defined prior to them (not a fixed name like `paper.pdf`). The lower-level
rules must be imported into Make before the higher-level ones.

All processing steps are assumed to ultimately (usually after many rules)
end up in some number, image, figure, or table that will be included in the
paper. The writing of these results into the final report/paper is managed
through separate LaTeX files that only contain macros (a name given to a
number/string to be used in the LaTeX source, which will be replaced when
compiling it to the final PDF). So the last target in a workhorse-Makefile
is a `.tex` file (with the same base-name as the Makefile, but in
`$(BDIR)/tex/macros`). As a result, if the targets in a workhorse-Makefile
aren't directly a prerequisite of other workhorse-Makefile targets, they
can be a prerequisite of that intermediate LaTeX macro file and thus be
called when necessary. Otherwise, they will be ignored by Make.

Maneage also has a mode to share the build directory between several
users of a Unix group (when working on large computer clusters). In this
scenario, each user can have their own cloned project source, but share the
large built files between each other. To do this, it is necessary for all
built files to give full permission to group members while not allowing any
other users access to the contents. Therefore the `./project configure` and
`./project make` steps must be called with special conditions which are
managed in the `--group` option.

Let's see how this design is implemented. Please open and inspect
`top-make.mk` it as we go along here. The first step (un-commented line) is
to import the local configuration (your answers to the questions of
`./project configure`). They are defined in the configuration-Makefile
`reproduce/software/config/LOCAL.conf` which was also built by `./project
configure` (based on the `LOCAL.conf.in` template of the same directory).

The next non-commented set of the top `Makefile` defines the ultimate
target of the whole project (`paper.pdf`). But to avoid mistakes, a sanity
check is necessary to see if Make is being run with the same group settings
as the configure script (for example when the project is configured for
group access using the `./for-group` script, but Make isn't). Therefore we
use a Make conditional to define the `all` target based on the group
permissions.

Having defined the top/ultimate target, our next step is to include all the
other necessary Makefiles. However, order matters in the importing of
workhorse-Makefiles and each must also have a TeX macro file with the same
base name (without a suffix). Therefore, the next step in the top-level
Makefile is to define the `makesrc` variable to keep the base names
(without a `.mk` suffix) of the workhorse-Makefiles that must be imported,
in the proper order.

Finally, we import all the necessary remaining Makefiles: 1) All the
analysis configuration-Makefiles with a wildcard. 2) The software
configuration-Makefile that contains their version (just in case its
necessary). 3) All workhorse-Makefiles in the proper order using a Make
`foreach` loop.

In short, to keep things modular, readable and manageable, follow these
recommendations: 1) Set clear-to-understand names for the
configuration-Makefiles, and workhorse-Makefiles, 2) Only import other
Makefiles from top Makefile. These will let you know/remember generally
which step you are taking before or after another. Projects will scale up
very fast. Thus if you don't start and continue with a clean and robust
convention like this, in the end it will become very dirty and hard to
manage/understand (even for yourself). As a general rule of thumb, break
your rules into as many logically-similar but independent steps as
possible.

The `reproduce/analysis/make/paper.mk` Makefile must be the final Makefile
that is included. This workhorse Makefile ends with the rule to build
`paper.pdf` (final target of the whole project). If you look in it, you
will notice that this Makefile starts with a rule to create
`$(mtexdir)/project.tex` (`mtexdir` is just a shorthand name for
`$(BDIR)/tex/macros` mentioned before). As you see, the only dependency of
`$(mtexdir)/project.tex` is `$(mtexdir)/verify.tex` (which is the last
analysis step: it verifies all the generated results).  Therefore,
`$(mtexdir)/project.tex` is _the connection_ between the
processing/analysis steps of the project, and the steps to build the final
PDF.

During the research, it often happens that you want to test a step that is
not a prerequisite of any higher-level operation. In such cases, you can
(temporarily) define that processing as a rule in the most relevant
workhorse-Makefile and set its target as a prerequisite of its TeX
macro. If your test gives a promising result and you want to include it in
your research, set it as prerequisites to other rules and remove it from
the list of prerequisites for TeX macro file. In fact, this is how a
project is designed to grow in this framework.





File modification dates (meta data)
-----------------------------------

While Git does an excellent job at keeping a history of the contents of
files, it makes no effort in keeping the file meta data, and in particular
the dates of files. Therefore when you checkout to a different branch,
files that are re-written by Git will have a newer date than the other
project files. However, file dates are important in the current design of
Maneage: Make checks the dates of the prerequisite files and target files
to see if the target should be re-built.

To fix this problem, for Maneage we use a forked version of
[Metastore](https://github.com/mohammad-akhlaghi/metastore). Metastore use
a binary database file (which is called `.file-metadata`) to keep the
modification dates of all the files under version control. This file is
also under version control, but is hidden (because it shouldn't be modified
by hand). During the project's configuration, Maneage installs to Git hooks
to run Metastore 1) before making a commit to update its database with the
file dates in a branch, and 2) after doing a checkout, to reset the
file-dates after the checkout is complete and re-set the file dates back to
what they were.

In practice, Metastore should work almost fully invisibly within your
project. The only place you might notice its presence is that you'll see
`.file-metadata` in the list of modified/staged files (commonly after
merging your branches). Since its a binary file, Git also won't show you
the changed contents. In a merge, you can simply accept any changes with
`git add -u`. But if Git is telling you that it has changed without a merge
(for example if you started a commit, but canceled it in the middle), you
can just do `git checkout .file-metadata` and set it back to its original
state.





Summary
-------

Based on the explanation above, some major design points you should have in
mind are listed below.

 - Define new `reproduce/analysis/make/XXXXXX.mk` workhorse-Makefile(s)
   with good and human-friendly name(s) replacing `XXXXXX`.

 - Add `XXXXXX`, as a new line, to the values in `makesrc` of the top-level
   `Makefile`.

 - Do not use any constant numbers (or important names like filter names)
   in the workhorse-Makefiles or paper's LaTeX source. Define such
   constants as logically-grouped, separate configuration-Makefiles in
   `reproduce/analysis/config/XXXXX.conf`. Then set this
   configuration-Makefiles file as a prerequisite to any rule that uses
   the variable defined in it.

 - Through any number of intermediate prerequisites, all processing steps
   should end in (be a prerequisite of) `$(mtexdir)/verify.tex` (defined in
   `reproduce/analysis/make/verify.mk`). `$(mtexdir)/verify.tex` is the sole
   dependency of `$(mtexdir)/project.tex`, which is the bridge between the
   processing steps and PDF-building steps of the project.










Customization checklist
=======================

Take the following steps to fully customize Maneage for your research
project. After finishing the list, be sure to run `./project configure` and
`project make` to see if everything works correctly. If you notice anything
missing or any in-correct part (probably a change that has not been
explained here), please let us know to correct it.

As described above, the concept of reproducibility (during a project)
heavily relies on [version
control](https://en.wikipedia.org/wiki/Version_control). Currently Maneage
uses Git as its main version control system. If you are not already
familiar with Git, please read the first three chapters of the [ProGit
book](https://git-scm.com/book/en/v2) which provides a wonderful practical
understanding of the basics. You can read later chapters as you get more
advanced in later stages of your work.

First custom commit
-------------------

 1. **Get this repository and its history** (if you don't already have it):
     Arguably the easiest way to start is to clone Maneage and prepare for
     your customizations as shown below. After the cloning first you rename
     the default `origin` remote server to specify that this is Maneage's
     remote server. This will allow you to use the conventional `origin`
     name for your own project as shown in the next steps. Second, you will
     create and go into the conventional `main` branch to start
     committing in your project later.

     ```shell
     $ git clone https://git.maneage.org/project.git    # Clone/copy the project and its history.
     $ mv project my-project                            # Change the name to your project's name.
     $ cd my-project                                    # Go into the cloned directory.
     $ git remote rename origin origin-maneage          # Rename current/only remote to "origin-maneage".
     $ git checkout -b main                             # Create and enter your own "main" branch.
     $ pwd                                              # Just to confirm where you are.
     ```

 2. **Prepare to build project**: The `./project configure` command of the
     next step will build the different software packages within the
     "build" directory (that you will specify). Nothing else on your system
     will be touched. However, since it takes long, it is useful to see
     what it is being built at every instant (its almost impossible to tell
     from the torrent of commands that are produced!). So open another
     terminal on your desktop and navigate to the same project directory
     that you cloned (output of last command above). Then run the following
     command. Once every second, this command will just print the date
     (possibly followed by a non-existent directory notice). But as soon as
     the next step starts building software, you'll see the names of
     software get printed as they are being built. Once any software is
     installed in the project build directory it will be removed. Again,
     don't worry, nothing will be installed outside the build directory.

     ```shell
     # On another terminal (go to top project source directory, last command above)
     $ ./project --check-config
     ```

 3. **Test Maneage**: Before making any changes, it is important to test it
     and see if everything works properly with the commands below. If there
     is any problem in the `./project configure` or `./project make` steps,
     please contact us to fix the problem before continuing. Since the
     building of dependencies in configuration can take long, you can take
     the next few steps (editing the files) while its working (they don't
     affect the configuration). After `./project make` is finished, open
     `paper.pdf`. If it looks fine, you are ready to start customizing the
     Maneage for your project. But before that, clean all the extra Maneage
     outputs with `make clean` as shown below.

     ```shell
     $ ./project configure           # Build the project's software environment (can take an hour or so).
     $ ./project make                # Do the processing and build paper (just a simple demo).

     # Open 'paper.pdf' and see if everything is ok.
     ```

 4. **Setup the remote**: You can use any [hosting
     facility](https://en.wikipedia.org/wiki/Comparison_of_source_code_hosting_facilities)
     that supports Git to keep an online copy of your project's version
     controlled history. We recommend [GitLab](https://gitlab.com) because
     it is [more ethical (although not
     perfect)](https://www.gnu.org/software/repo-criteria-evaluation.html),
     and later you can also host GitLab on your own server. Anyway, create
     an account in your favorite hosting facility (if you don't already
     have one), and define a new project there. Please make sure *the newly
     created project is empty* (some services ask to include a `README` in
     a new project which is bad in this scenario, and will not allow you to
     push to it). It will give you a URL (usually starting with `git@` and
     ending in `.git`), put this URL in place of `XXXXXXXXXX` in the first
     command below. With the second command, "push" your `main` branch to
     your `origin` remote, and (with the `--set-upstream` option) set them
     to track/follow each other. However, the `maneage` branch is currently
     tracking/following your `origin-maneage` remote (automatically set
     when you cloned Maneage). So when pushing the `maneage` branch to your
     `origin` remote, you _shouldn't_ use `--set-upstream`. With the last
     command, you can actually check this (which local and remote branches
     are tracking each other).

     ```shell
     git remote add origin XXXXXXXXXX        # Newly created repo is now called 'origin'.
     git push --set-upstream origin main     # Push 'main' branch to 'origin' (with tracking).
     git push origin maneage                 # Push 'maneage' branch to 'origin' (no tracking).
     ```

 5. **Title**, **short description** and **author**: You can start adding
     your name (with your possible coauthors) and tentative abstract in
     `paper.tex`. You should see the relevant place in the preamble (prior
     to `\begin{document}`. Just note that some core project metadata like
     the project title are actually set in
     `reproduce/analysis/config/metadata.conf`. So set your project title
     in there. After you are done, run the `./project make` command again
     to see your changes in the final PDF and make sure that your changes
     don't cause a crash in LaTeX. Of course, if you use a different LaTeX
     package/style for managing the title and authors (in particular a
     specific journal's style), please feel free to use it your own methods
     after finishing this checklist and doing your first commit.

 6. **Delete dummy parts**: Maneage contains some parts that are only for
     the initial/test run, mainly as a demonstration of important steps,
     which you can use as a reference to use in your own project. But they
     not for any real analysis, so you should remove these parts as
     described below:

     - `paper.tex`: 1) Delete the text of the abstract (from
       `\includeabstract{` to `\vspace{0.25cm}`) and write your own (a
       single sentence can be enough now, you can complete it later). 2)
       Add some keywords under it in the keywords part. 3) Delete
       everything between `%% Start of main body.` and `%% End of main
       body.`. 4) Remove the notice in the "Acknowledgments" section (in
       `\new{}`) and Acknowledge your funding sources (this can also be
       done later). Just don't delete the existing acknowledgment
       statement: Maneage is possible thanks to funding from several
       grants. Since Maneage is being used in your work, it is necessary to
       acknowledge them in your work also.

     - `reproduce/analysis/make/top-make.mk`: Delete the `delete-me` line
       in the `makesrc` definition. Just make sure there is no empty line
       between the `download \` and `verify \` lines (they should be
       directly under each other).

     - `reproduce/analysis/make/verify.mk`: In the final recipe, under the
       commented line `Verify TeX macros`, remove the full line that
       contains `delete-me`, and set the value of `s` in the line for
       `download` to `XXXXX` (any temporary string, you'll fix it in the
       end of your project, when its complete).

     - Delete all `delete-me*` files in the following directories:

       ```shell
       $ rm tex/src/delete-me*
       $ rm reproduce/analysis/make/delete-me*
       $ rm reproduce/analysis/config/delete-me*
       ```

     - `reproduce/analysis/config/verify-outputs.conf`: Disable
       verification of outputs by changing the `yes` (the value of
       `verify-outputs`) to `no`. Later, when you are ready to submit your
       paper, or publish the dataset, activate verification and make the
       proper corrections in this file (described under the "Other basic
       customizations" section below). This is a critical step and only
       takes a few minutes when your project is finished. So DON'T FORGET
       to activate it in the end.

     - Re-make the project (after a cleaning) to see if you haven't
       introduced any errors.

       ```shell
       $ ./project make clean
       $ ./project make
       ```

 7. **Ignore changes in some Maneage files**: One of the main advantages of
     Maneage is that you can later update your infra-structure by merging
     your `main` branch with the `maneage` branch. This is good for many
     low-level features that you will likely never modify yourself. But it
     is not desired for some files like `paper.tex` (you don't want changes
     in Maneage's default `paper.tex` to cause conflicts with all the text
     you have already written for your project). You need to tell Git to
     ignore changes in such files from the `maneage` branch during the
     merge, and just keep your own branch's version. The commands below
     show how you can avert such future conflicts and frustrations with
     some known files. Note that only the first `echo` command has a `>`
     (to write over the file), the rest are `>>` (to append to it). If you
     want to avoid any other set of files to be imported from Maneage into
     your project's branch, you can follow a similar strategy (it should
     happen rarely, if at all!). Generally be very careful about adding
     files to `.gitattributes` because it affects the whole file and if a
     wrong file is ignored, Maneage may break after a merge (some
     inter-dependent files may not get updated together). We recommend only
     doing it when you encounter the same conflict in more than one merge,
     and are sure that it won't affect other files. In such cases please
     let us know so we can improve the design of Maneage and modularize
     those components to be easily added here.

     ```shell
     $ echo "paper.tex merge=ours" > .gitattributes
     $ echo "tex/src/*.tex merge=ours" >> .gitattributes
     $ echo "reproduce/analysis/config/*.conf merge=ours" >> .gitattributes
     $ echo "reproduce/software/config/TARGETS.conf merge=ours" >> .gitattributes
     $ echo "reproduce/software/config/texlive-packages.conf merge=ours" >> .gitattributes
     $ git add .gitattributes
     ```

 8. **Copyright and License notice**: It is necessary that _all_ the
     "copyright-able" files in your project (those larger than 10 lines)
     have a copyright and license notice. Please take a moment to look at
     several existing files to see a few examples. The copyright notice is
     usually close to the start of the file, it is the line starting with
     `Copyright (C)` and containing a year and the author's name (like the
     examples below). The License notice is a short description of the
     copyright license, usually one or two paragraphs with a URL to the
     full license. Don't forget to add these _two_ notices to *any new
     file* you add in your project (you can just copy-and-paste). When you
     modify an existing Maneage file (which already has the notices), just
     add a copyright notice in your name under the existing one(s), like
     the line with capital letters below. To start with, add this line with
     your name and email address to `paper.tex`,
     `tex/src/preamble-project.tex`, `reproduce/analysis/make/top-make.mk`,
     and generally, all the files you modified in the previous step.

     ```
     Copyright (C) 2018-2022 Existing Name <existing@email.address>
     Copyright (C) 2022 YOUR NAME <YOUR@EMAIL.ADDRESS>
     ```

 9. **Configure Git for fist time**: If this is the first time you are
     running Git on this system, then you have to configure it with some
     basic information in order to have essential information in the commit
     messages (ignore this step if you have already done it). Git will
     include your name and e-mail address information in each commit. You
     can also specify your favorite text editor for making the commit
     (`emacs`, `vim`, `nano`, and etc.).

     ```shell
     $ git config --global user.name "YourName YourSurname"
     $ git config --global user.email your-email@example.com
     $ git config --global core.editor nano
     ```

 10. **Your first commit**: You have already made some small and basic
     changes in the steps above and you are in your project's `main`
     branch. So, you can officially make your first commit in your
     project's history and push it. But before that, you need to make sure
     that there are no problems in the project. This is a good habit to
     always re-build the system before a commit to be sure it works as
     expected.

     ```shell
     $ git status                 # See which files you have changed.
     $ git diff                   # Check the lines you have added/changed.
     $ ./project make             # Make sure everything builds successfully.
     $ git add -u                 # Put all tracked changes in staging area.
     $ git status                 # Make sure everything is fine.
     $ git diff --cached          # Confirm all the changes that will be committed.
     $ git commit                 # Your first commit: put a good description!
     $ git push                   # Push your commit to your remote.
     ```

 11. **Read the publication checklist**: The publication checklist below is
     very similar to this one, but for the final phase of your project. For
     now, you don't have to do any of its steps, but reading it will give
     you good insight into the later stages of your project. If you already
     know how you want to publish your project, you can implement many of
     those steps from the start and during the actual project (in
     particular how to organize your data files that go into the plots).
     Making it much easier to complete that checklist when you are ready
     for submission.

 12. **Start your exciting research**: You are now ready to add flesh and
     blood to this raw skeleton by further modifying and adding your
     exciting research steps. You can use the "published works" section in
     the introduction (above) as some fully working models to learn
     from. Also, don't hesitate to contact us if you have any
     questions.


Other basic customizations
--------------------------

 - **High-level software**: Maneage installs all the software that your
     project needs. You can specify which software your project needs in
     `reproduce/software/config/TARGETS.conf`. The necessary software are
     classified into two classes: 1) programs or libraries (usually written
     in C/C++) which are run directly by the operating system. 2) Python
     modules/libraries that are run within Python. By default
     `TARGETS.conf` only has GNU Astronomy Utilities (Gnuastro) as one
     scientific program and Astropy as one scientific Python module. Both
     have many dependencies which will be installed into your project
     during the configuration step. To see a list of software that are
     currently ready to be built in Maneage, see
     `reproduce/software/config/versions.conf` (which has their versions
     also), the comments in `TARGETS.conf` describe how to use the software
     name from `versions.conf`. Currently the raw pipeline just uses
     Gnuastro to make the demonstration plots. Therefore if you don't need
     Gnuastro, go through the analysis steps in `reproduce/analysis` and
     remove all its use cases (clearly marked).

 - **Input datasets**: The input datasets are managed through the
     `reproduce/analysis/config/INPUTS.conf` file. It is best to gather the
     following information regarding all the input datasets into this one
     central file: 1) the SHA256 checksum of the file, 2) the URL where the
     file can be downloaded online. Please read the comments at the start
     of `reproduce/analysis/config/INPUTS.conf` carefully.

 - **`README.md`**: Correct all the `XXXXX` place holders (name of your
     project, your own name, address of your project's online/remote
     repository, link to download dependencies and etc). Generally, read
     over the text and update it where necessary to fit your project. Don't
     forget that this is the first file that is displayed on your online
     repository and also your colleagues will first be drawn to read this
     file. Therefore, make it as easy as possible for them to start
     with. Also check and update this file one last time when you are ready
     to publish your project's paper/source.

 - **Verify outputs**: During the initial customization checklist, you
     disabled verification. This is natural because during the project you
     need to make changes all the time and its a waste of time to enable
     verification every time. But at significant moments of the project
     (for example before submission to a journal, or publication) it is
     necessary. When you activate verification, before building the paper,
     all the specified datasets will be compared with their respective
     checksum and if any file's checksum is different from the one recorded
     in the project, it will stop and print the problematic file and its
     expected and calculated checksums. First set the value of
     `verify-outputs` variable in
     `reproduce/analysis/config/verify-outputs.conf` to `yes`. Then go to
     `reproduce/analysis/make/verify.mk`. The verification of all the files
     is only done in one recipe. First the files that go into the
     plots/figures are checked, then the LaTeX macros. Validation of the
     former (inputs to plots/figures) should be done manually. If its the
     first time you are doing this, you can see two examples of the dummy
     steps (with `delete-me`, you can use them if you like). These two
     examples should be removed before you can run the project. For the
     latter, you just have to update the checksums. The important thing to
     consider is that a simple checksum can be problematic because some
     file generators print their run-time date in the file (for example as
     commented lines in a text table). When checking text files, this
     Makefile already has this function:
     `verify-txt-no-comments-leading-space`. As the name suggests, it will
     remove comment lines and empty lines before calculating the MD5
     checksum. For FITS formats (common in astronomy, fortunately there is
     a `DATASUM` definition which will return the checksum independent of
     the headers. You can use the provided function(s), or define one for
     your special formats.

 - **Feedback**: As you use Maneage you will notice many things that if
     implemented from the start would have been very useful for your
     work. This can be in the actual scripting and architecture of Maneage,
     or useful implementation and usage tips, like those below. In any
     case, please share your thoughts and suggestions with us, so we can
     add them here for everyone's benefit.

 - **Re-preparation**: Automatic preparation is only run in the first run
     of the project on a system, to re-do the preparation you have to use
     the option below. Here is the reason for this: when its necessary, the
     preparation process can be slow and will unnecessarily slow down the
     whole project while the project is under development (focus is on the
     analysis that is done after preparation). Because of this, preparation
     will be done automatically for the first time that the project is run
     (when `.build/software/preparation-done.mk` doesn't exist). After the
     preparation process completes once, future runs of `./project make`
     will not do the preparation process anymore (will not call
     `top-prepare.mk`). They will only call `top-make.mk` for the
     analysis. To manually invoke the preparation process after the first
     attempt, the `./project make` script should be run with the
     `--prepare-redo` option, or you can delete the special file above.

     ```shell
     $ ./project make --prepare-redo
     ```

 - **Pre-publication**: add notice on reproducibility**: Add a notice
     somewhere prominent in the first page within your paper, informing the
     reader that your research is fully reproducible. For example in the
     end of the abstract, or under the keywords with a title like
     "reproducible paper". This will encourage them to publish their own
     works in this manner also and also will help spread the word.










Publication checklist
=====================

Once your project is complete and you are ready to submit/publish the
project, we recommend the following steps to ensure the maximum FAIRness of
all your hard work (Findability, Accessibility, Interoperability, and
Reusability). This list may seem long, and may take a day or so to
complete, but please consider the fact that you have spent months/years on
your project, so it is a very small step in your over-all project! Most of
it is about organizing things that you can do during your project. So its
good to have a look at these from the start of your project.

As you will notice, when you complete this checklist, your projects source
will be present in multiple places: Zenodo, SoftwareHeritage, arXiv, your
own Git repositories. This is a major advantage of Maneaged(!)  projects:
because their source is very small (a few hundred kilobytes), there is
effectively no cost in keeping multiple redundancies on different servers,
just in case one (or more) of them are discontinued in the (near/far)
future.

 - **Reserve a DOI for your datasets**: There are multiple data servers
   that give this functionality, one of the most well known and
   (currently!) well-funded is [Zenodo](https://zenodo.org) so we'll focus
   on it here. Of course, you can use any other service that provides a
   similar functionality. Once you complete these steps, you can start
   using/citing your dataset's DOI in the source of your project to
   finalize the rest of the points. With Zenodo, you can even use the given
   identifier for things like downloading.

   * *Start new upload*: After you log in to Zenodo, you can start a new
     upload by clicking on the "New Upload button".

   * *Reserve DOI*: Under the "Basic information" --> "Digital Object
     Identifier", click on the "Reserve DOI" button.

   * *Fill basic info*: You need to at least fill in the "required fields"
     (marked with a red star). You will always be able to change any
     metadata (even after you "Publish"), so don't worry too much about
     values in the fields, at this phase, its just important that they are
     not empty.

   * *Save your project but do not yet publish*: Press the "Save" button
     (at the top or bottom of the page). Do not yet press "Publish" though,
     since that would make the project public, and freeze the DOI with any
     possible file you may have uploaded already. We will get to the
     publication phase in the next steps.

 - **Record the metadata**: Maneage comes with a file to store all the
   project's metadata: `reproduce/analysis/config/metadata.conf`. Open this
   file and store all the information that you currently have: for example
   the Zenodo DOI, project's Git repository, Copyright owner and license of
   the data after it becomes public. Keep the empty fields in mind and
   after obtaining them, don't forget to fill them up.

 - **Request archival on SoftwareHeritage**: [Software
   Heritage](https://archive.softwareheritage.org/save/) is an online
   project to archive source code and their development histories. It
   provides wonderful features for archiving source code (not data!) and
   also for citing special parts of a project's source in any point of its
   history. So it blends elegantly with the purpose of Maneage. Once you
   make your project's Git repository publicly accessible (no login
   required to clone it), you can request that SoftwareHeritage archives
   it. Its good if you do this as soon as you make your Git repository
   public. When you are ready, just register your repository's address (the
   same one you give to `git clone`) to in [SoftwareHeritage's save
   form](https://archive.softwareheritage.org/save).

 - **Run a spell-check on `paper.tex`**: we all forget ;-)!

 - **Zenodo/SoftwareHeritage links in paper**: put links to the Zenodo-DOI
   (and SoftwareHeritage source when you make it public) in your
   paper. Somewhere close to the start, maybe under the keywords/abstract,
   highlighting that they are supplements for reproducibility. These help
   readers easily access these resources for supplementary material
   directly from your PDF paper (sources on SoftwareHeritage and
   data/software on Zenodo). These links are more trusted/reliable in terms
   of longevity than Git repositories or private webpages.

 - **Identify and properly format output data**: If you have a plot, figure
   or table in your paper, you need to verify that data later and publish
   that data with the paper (see the steps below for both). But before
   going to those steps, its good if you polish your datasets with the
   recommendations below:

   * *Keep published data in a special place*: it helps if you keep the
     to-be-published data files in a special sub-directory under your build
     directory. In this way, irrespective of which subMakefile builds a
     published dataset, they won't be lost/scatterred in the middle of all
     the project's intermediate-built files.

   * *In plain-text*: If the data are in tabular form (for example the X
     and Y values in your plots), store them as a simple plain-text file
     (for example with columns separated by white-space characters) or in
     the more formal [Comma-separated
     values](https://en.wikipedia.org/wiki/Comma-separated_values) or CSV,
     format). Generally, its best to set the suffixes to `.txt` (because
     most browsers/OSs will automatically know they are plain-text and open
     them without needing any other software). If you have other types of
     data (for example images, or very large tables with millions of
     rows/columns that can be inconvenient in plain-text), feel free to use
     custom binary formats, but later, in the description of your project
     on the server, add a note, explaining what software they should use to
     open them.

   * *Descriptive names*: In some papers there are many files and having
     cryptic names will only confuse your readers (actually, yourself in
     two years!). So set the names of the files to be as descriptive as
     possible, so simply by reading the name of the file, someone who has
     read the paper will understand what figure it corresponds to. In
     particular, don't set names like `figure-3.txt`! In a few months you
     will forget the order of the figures! Even worse, after the referee
     report, you may need to re-arrange some figures and you will be forced
     to rename everything related to each figure (which is very frustrating
     and prone to errors).

   * *Good metadata*: Raw data are not too useful merely as a series of raw
     numbers! So don't forget to have **good metadata in every file**. If
     its a plain-text file, usually lines starting with a `#` are
     ignored. So in the command that generates each dataset, add some extra
     information (the more the better!) about the dataset as lines starting
     with `#`. Based on `reproduce/analysis/config/metadata.conf`, in
     `initialize.mk`, Maneage will produce a default set of basic
     information for plain-text data and will put it in the
     `$(print-general-metadata)` variable. It is thus recommended to print
     this variable into your plain-text file before printing the actual
     data (so it shows on top of the file). For a real-world example, see
     its usage in `reproduce/analysis/make/delete-me.mk` (in the `maneage`
     branch). If you are publishing your data in binary formats, please add
     all the metadata you see in `$(print-general-metadata)` into each
     dataset file (for example keywords in the FITS format). If there are
     many files, its easy to define a tiny shell-script to do the job on
     each dataset.

 - **Link to figure datasets in caption**: all the datasets that go into
   the plots should be uploaded directly to Zenodo so they can be
   viewed/downloaded with a simple link in the caption. For example see the
   last sentence of the caption of Figure 1 in
   [arXiv:2006.03018v1](https://arxiv.org/pdf/2006.03018v1.pdf), it points
   to [the
   data](https://zenodo.org/record/3872248/files/tools-per-year.txt) that
   was used to create that figure's top plot. As you see, this will allow
   your paper's readers (again, most probably your future-self!) to
   directly access the numbers of each visualization (plot/figure) with a
   simple click in a trusted server. This also shows the major advantage of
   having your data as simple plain-text where possible, as described
   above. To help you keep all your to-be-visualized datasets in a single
   place, Maneage has the two `tex-publish-dir` and `data-publish-dir`
   directories that are defined in `reproduce/analysis/make/initialize.mk`,
   see the comments above their definition for more.

 - **Verification step**: It is very important to automatically verify the
   outptus of your project. Recall from the customization checklist (above)
   that you can activate verification by setting the `verify-outputs`
   variable to `yes` in `reproduce/analysis/config/verify-outputs.conf`. So
   please activate it and look into the `reproduce/analysis/make/verify.mk`
   to add the necessary steps to automatically verify your outputs. *Tip*:
   you don't have to generate the checksums manually, just give a wrong
   value (for example `XXXX`) so Maneage crashes! In the error message it
   will then print the actual and expected checksums and you can take the
   value from there. Outputs that must be verified can be listed as:

   * *subMakefile LaTeX macro files*: these LaTeX macros put numbers into
     the text. You don't want your readers (actually: yourself in two
     years!) to have to painfully find and check, by eye, all those tiny
     numbers buried deep in the ocean of words!

   * *Final data files* (for tables, figures, or plots, or as data
     release). These are the same files described above. If you have
     followed the guidelines above and stored them as plain-text with
     comments on top, you can use the provided function
     `verify-txt-no-comments-leading-space` which takes the filename and
     checksum as arguments to avoid the commented lines (which may change)
     and only verify the data. If your data are in other formats, be sure
     to verify them without metadata that may change (like date and etc).

 - **Fill `README.md`**: The `README.md` is *the first place* your readers
   are going to look into. It already has a default text with place-holders
   in the form of `XXXXXX`. Please go through its first few paragraphs and
   replace the place-holders with the relevant information/links or feel
   free to add/remove anything else. The rest is just basic information
   that is useful for any Maneage'd project. Just don't forget to tell your
   readers in `README.md` that they can learn about this system in the
   `README-hacking.md` file (ideally close to the top).

 - **Confirm if your project builds from scratch**: Before publishing
   anything, you should see if your project can indeed reproduce itself!
   You may be mistakenly using temporarily created files that aren't built
   when teh project is built from scratch (this happens a lot and is very
   dangerous for the integrity of your project!). So, go to a temporary
   directory, clone your project from its repository and try configuring
   and building it from scratch in a new-temporary build-directory. It is
   important to ignore the original directory you developed your project on
   (source and build): you may have files there that you forgot to import
   into Git or depended on in the build (it happens!). Ideally, it would be
   good to try it on a different computer.

 - **Confirm if `./project make dist` works**: The special target `dist`
   tells the project to build a tarball that is ready to compile the LaTeX
   PDF without having to do the analysis and build software. This is very
   useful for servers like arXiv, or some journals. This tarball is also
   one of the deliverables you want to publish on Zenodo. Once the tarball
   is created, copy it to a temporary directory outside of Maneage, unpack
   it and run `make` (completely ignoring Maneage's `./project` script). If
   you plan to submit your paper to arXiv, the best test is to actually
   start a test submission on arXiv to upload the tarball there to see if
   it can build your PDF. Once it works, you can delete that temporary
   submission for now. Afterwards, try configuring and building it with the
   tarball by running its `./project` (from scratch and without the Git
   history!). If there is a problem in any of these tests, you can modify
   what goes into this tarball in `reproduce/analysis/make/initialize.mk`:
   go through the steps and add the necessary components until the checks
   pass.

 - **Upload all deliverables to Zenodo**: With the datasets ready, you can
   now upload the following deliverables to Zenodo. Except for the data
   files, put the Git hash of your Maneaged project at the moment of
   publication in the filename of other uploaded files. The output files
   shouldn't have a hash in their names because their URL (that goes in the
   caption of the figures/tables) should be known prior to a commit,
   creating a cyclic dependency! Ideally the hash should be placed just
   before the final suffix, for example `paper-XXXXXXX.pdf` (where
   `XXXXXXX` is the Git hash). This will clearly identify the point in
   history that your file was created.

     * **paper-XXXXXXX.pdf**: you shouldn't just download data to the data
       server, also upload your paper's PDF so its there with the other raw
       formats. It will greatly help yourself and others. Most datacenters
       (like Zenodo) actually also have a PDF viewer that will load
       automatically before the list of data files. For example see
       [zenodo.3408481](https://doi.org/10.5281/zenodo.3408481).

     * **`project-XXXXXXX.tar.gz`**: Or the output of `make dist` as
       described above.

     * **`project-git.bundle`** This is the full Git history of the project
       in one file (which you can actually clone from later!). Its
       necessary to publish this with your dataset too because Git
       repositories make no promise on longevity. The way to "bundle" a Git
       history is described below, in summary, its this command:
       ```shell
       $ git bundle create my-project-git.bundle --all
       ```

     * **`software-XXXXXXX.tar.gz`**: This is effectively a copy of all the
       software source code tarballs in your project's
       `.build/software/tarballs`. It is necessary to upload these with
       your project to avoid relying on third party servers. In the future
       any one of those servers may go down and if so, your project won't
       be buildable. You can generate this tarball easily with `make
       dist-software`.

     * All the figure (and other) output datasets of the project. Don't
       rename these files, let them have the same descriptive name
       mentioned above. Also recall that a link to all these files is also
       in the caption of the respective figure.

 - **Upload to [arXiv](https://arxiv.org)**: or to any other pre-print
   server (if you want to). Of course, you can also do this after the
   initial/final submission to your desired journal. But we'll just add the
   necessary points for arXiv submission here:

     * *Necessary links in comments*: put a link to your project's Git
       repository, Zenodo-DOI (this is not your paper's DOI, its the
       data/resources DOI), and/or SoftwareHeritage link in the comments.

 - *Update `metadata.conf`*: Once you have your final arXiv ID (formated
    as: `1234.56789`) put it in `reproduce/analysis/config/metadata.conf`.

 - **Submission to a journal**: different journals accept submissions in
   different formats, some accept LaTeX, some only want a PDF, or etc. It
   would be good if you highlight in the cover-letter that your work is
   reproducible and provide the Zenodo and Software Heritage links (if they
   are public). If not, you can mention that everything is ready for such a
   submission after acceptance.

 - **Future versions**: Both Zenodo and arXiv allow uploading new versions
   after your first publication. So it is recommended to put more recent
   versions of your published projects later (for example after applying
   the changes suggested by the referee). In Zenodo (unlike arXiv), you
   only need to publish a new version if the uploaded files have
   changed. You can always update the project's metadata with no effect on
   the DOI (so you don't need to upload a new version if you just want to
   update the metadata).

 - **After acceptance (before publication)**: Congratulations on the
   acceptance! The main science content of your paper can't be changed any
   more, but the paper will now go to the publication editor (for language
   and style). Your approval of the final proof is necessary before the
   paper is finally published. Use this period to finalize the final
   metadata of your project: the journal's DOI. Some journals associate
   your paper's DOI during this process. So before approving the final
   proof do these steps:

     * Add the Journal DOI in `reproduce/analysis/config/metadata.conf`,
       and re-build your final data products, so this important metadata is
       added.

     * Once you get the final proof, and if everything is OK for you,
       implement all the good language corrections/edits they have made
       inside your own copy here and commit it into your project. This will
       be the final commit of your project before publication.

     * Submit your final project as a new version to Zenodo (and
       arXiv). The Zenodo one is most important because your plots will
       link to it and you want the commit hash in the data files that
       readers will get from Zenodo to be the same hash as the paper.

     * Tell the journal's publication editor to correct the hash and Zenodo
       ID in your final proof confirmation (so the links point to the
       correct place). Recall that on every new version upload in Zenodo,
       you get a new DOI (or Zenodo ID).






Tips for designing your project
===============================

The following is a list of design points, tips, or recommendations that
have been learned after some experience with this type of project
management. Please don't hesitate to share any experience you gain after
using it with us. In this way, we can add it here (with full giving credit)
for the benefit of others.

 - **Modularity**: Modularity is the key to easy and clean growth of a
     project. So it is always best to break up a job into as many
     sub-components as reasonable. Here are some tips to stay modular.

   - *Short recipes*: if you see the recipe of a rule becoming more than a
      handful of lines which involve significant processing, it is probably
      a good sign that you should break up the rule into its main
      components. Try to only have one major processing step per rule.

   - *Context-based (many) Makefiles*: For maximum modularity, this design
      allows easy inclusion of many Makefiles: in
      `reproduce/analysis/make/*.mk` for analysis steps, and
      `reproduce/software/make/*.mk` for building software. So keep the
      rules for closely related parts of the processing in separate
      Makefiles.

   - *Descriptive names*: Be very clear and descriptive with the naming of
      the files and the variables because a few months after the
      processing, it will be very hard to remember what each one was
      for. Also this helps others (your collaborators or other people
      reading the project source after it is published) to more easily
      understand your work and find their way around.

   - *Naming convention*: As the project grows, following a single standard
      or convention in naming the files is very useful. Try best to use
      multiple word filenames for anything that is non-trivial (separating
      the words with a `-`). For example if you have a Makefile for
      creating a catalog and another two for processing it under models A
      and B, you can name them like this: `catalog-create.mk`,
      `catalog-model-a.mk` and `catalog-model-b.mk`. In this way, when
      listing the contents of `reproduce/analysis/make` to see all the
      Makefiles, those related to the catalog will all be close to each
      other and thus easily found. This also helps in auto-completions by
      the shell or text editors like Emacs.

   - *Source directories*: If you need to add files in other languages for
      example in shell, Python, AWK or C, keep the files in the same
      language in a separate directory under `reproduce/analysis`, with the
      appropriate name.

   - *Configuration files*: If your research uses special programs as part
      of the processing, put all their configuration files in a devoted
      directory (with the program's name) within
      `reproduce/software/config`. It is much cleaner and readable (thus
      less buggy) to avoid mixing the configuration files, even if there is
      no technical necessity.


 - **Contents**: It is good practice to follow the following
     recommendations on the contents of your files, whether they are source
     code for a program, Makefiles, scripts or configuration files
     (copyrights aren't necessary for the latter).

   - *Copyright*: Always start a file containing programming constructs
      with a copyright statement like the ones that Maneage starts with
      (for example in the top level `Makefile`).

   - *Comments*: Comments are vital for readability (by yourself in two
      months, or others). Describe everything you can about why you are
      doing something, how you are doing it, and what you expect the result
      to be. Write the comments as if it was what you would say to describe
      the variable, recipe or rule to a friend sitting beside you. When
      writing the project it is very tempting to just steam ahead with
      commands and codes, but be patient and write comments before the
      rules or recipes. This will also allow you to think more about what
      you should be doing. Also, in several months when you come back to
      the code, you will appreciate the effort of writing them. Just don't
      forget to also read and update the comment first if you later want to
      make changes to the code (variable, recipe or rule). As a general
      rule of thumb: first the comments, then the code.

   - *File title*: In general, it is good practice to start all files with
      a single line description of what that particular file does. If
      further information about the totality of the file is necessary, add
      it after a blank line. This will help a fast inspection where you
      don't care about the details, but just want to remember/see what that
      file is (generally) for. This information must of course be commented
      (its for a human), but this is kept separate from the general
      recommendation on comments, because this is a comment for the whole
      file, not each step within it.


 - **Make programming**: Here are some experiences that we have come to
     learn over the years in using Make and are useful/handy in research
     contexts.

   - *Environment of each recipe*: If you need to define a special
      environment (or aliases, or scripts to run) for all the recipes in
      your Makefiles, you can use a Bash startup file
      `reproduce/software/shell/bashrc.sh`. This file is loaded before every
      Make recipe is run, just like the `.bashrc` in your home directory is
      loaded every time you start a new interactive, non-login terminal. See
      the comments in that file for more.

   - *Automatic variables*: These are wonderful and very useful Make
      constructs that greatly shrink the text, while helping in
      read-ability, robustness (less bugs in typos for example) and
      generalization. For example even when a rule only has one target or
      one prerequisite, always use `$@` instead of the target's name, `$<`
      instead of the first prerequisite, `$^` instead of the full list of
      prerequisites and etc. You can see the full list of automatic
      variables
      [here](https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html). If
      you use GNU Make, you can also see this page on your command-line:

        ```shell
        $ info make "automatic variables"
        ```

   - *Debug*: Since Make doesn't follow the common top-down paradigm, it
      can be a little hard to get accustomed to why you get an error or
      un-expected behavior. In such cases, run Make with the `-d`
      option. With this option, Make prints a full list of exactly which
      prerequisites are being checked for which targets. Looking
      (patiently) through this output and searching for the faulty
      file/step will clearly show you any mistake you might have made in
      defining the targets or prerequisites.

   - *Large files*: If you are dealing with very large files (thus having
      multiple copies of them for intermediate steps is not possible), one
      solution is the following strategy (Also see the next item on "Fast
      access to temporary files"). Set a small plain text file as the
      actual target and delete the large file when it is no longer needed
      by the project (in the last rule that needs it). Below is a simple
      demonstration of doing this. In it, we use Gnuastro's Arithmetic
      program to add all pixels of the input image with 2 and create
      `large1.fits`. We then subtract 2 from `large1.fits` to create
      `large2.fits` and delete `large1.fits` in the same rule (when its no
      longer needed). We can later do the same with `large2.fits` when it
      is no longer needed and so on.
        ```
        large1.fits.txt: input.fits
                astarithmetic $< 2 + --output=$(subst .txt,,$@)
                echo "done" > $@
        large2.fits.txt: large1.fits.txt
                astarithmetic $(subst .txt,,$<) 2 - --output=$(subst .txt,,$@)
                rm $(subst .txt,,$<)
                echo "done" > $@
        ```
     A more advanced Make programmer will use Make's [call
     function](https://www.gnu.org/software/make/manual/html_node/Call-Function.html)
     to define a wrapper in `reproduce/analysis/make/initialize.mk`. This
     wrapper will replace `$(subst .txt,,XXXXX)`. Therefore, it will be
     possible to greatly simplify this repetitive statement and make the
     code even more readable throughout the whole project.

   - *Fast access to temporary files*: Most Unix-like operating systems
      will give you a special shared-memory device (directory): on systems
      using the GNU C Library (all GNU/Linux system), it is `/dev/shm`. The
      contents of this directory are actually in your RAM, not in your
      persistence storage like the HDD or SSD. Reading and writing from/to
      the RAM is much faster than persistent storage, so if you have enough
      RAM available, it can be very beneficial for large temporary files to
      be put there. You can use the `mktemp` program to give the temporary
      files a randomly-set name, and use text files as targets to keep that
      name (as described in the item above under "Large files") for later
      deletion. For example, see the minimal working example Makefile below
      (which you can actually put in a `Makefile` and run if you have an
      `input.fits` in the same directory, and Gnuastro is installed).
        ```
        .ONESHELL:
        .SHELLFLAGS = -ec
        all: mean-std.txt
        shm-maneage := /dev/shm/$(shell whoami)-maneage-XXXXXXXXXX
        large1.txt: input.fits
                out=$$(mktemp $(shm-maneage))
                astarithmetic $< 2 + --output=$$out.fits
                echo "$$out" > $@
        large2.txt: large1.txt
                input=$$(cat $<)
                out=$$(mktemp $(shm-maneage))
                astarithmetic $$input.fits 2 - --output=$$out.fits
                rm $$input.fits $$input
                echo "$$out" > $@
        mean-std.txt: large2.txt
                input=$$(cat $<)
                aststatistics $$input.fits --mean --std > $@
                rm $$input.fits $$input
        ```
      The important point here is that the temporary name template
      (`shm-maneage`) has no suffix. So you can add the suffix
      corresponding to your desired format afterwards (for example
      `$$out.fits`, or `$$out.txt`). But more importantly, when `mktemp`
      sets the random name, it also checks if no file exists with that name
      and creates a file with that exact name at that moment. So at the end
      of each recipe above, you'll have two files in your `/dev/shm`, one
      empty file with no suffix one with a suffix. The role of the file
      without a suffix is just to ensure that the randomly set name will
      not be used by other calls to `mktemp` (when running in parallel) and
      it should be deleted with the file containing a suffix. This is the
      reason behind the `rm $$input.fits $$input` command above: to make
      sure that first the file with a suffix is deleted, then the core
      random file (note that when working in parallel on powerful systems,
      in the time between deleting two files of a single `rm` command, many
      things can happen!). When using Maneage, you can put the definition
      of `shm-maneage` in `reproduce/analysis/make/initialize.mk` to be
      usable in all the different Makefiles of your analysis, and you won't
      need the three lines above it. **Finally, BE RESPONSIBLE:** after you
      are finished, be sure to clean up any possibly remaining files (due
      to crashes in the processing while you are working), otherwise your
      RAM may fill up very fast. You can do it easily with a command like
      this on your command-line: `rm -f /dev/shm/$(whoami)-*`.


 - **Software tarballs and raw inputs**: It is critically important to
     document the raw inputs to your project (software tarballs and raw
     input data):

   - *Keep the source tarball of dependencies*: After configuration
      finishes, the `.build/software/tarballs` directory will contain all
      the software tarballs that were necessary for your project. You can
      mirror the contents of this directory to keep a backup of all the
      software tarballs used in your project (possibly as another version
      controlled repository) that is also published with your project. Note
      that software web-pages are not written in stone and can suddenly go
      offline or not be accessible in some conditions. This backup is thus
      very important. If you intend to release your project in a place like
      Zenodo, you can upload/keep all the necessary tarballs (and data)
      there with your
      project. [zenodo.1163746](https://doi.org/10.5281/zenodo.1163746) is
      one example of how the data, Gnuastro (main software used) and all
      major Gnuastro's dependencies have been uploaded with the project's
      source. Just note that this is only possible for [free
      software](https://www.gnu.org/philosophy/free-sw.html).

   - *Keep your input data*: The input data is also critical to the
      project's reproducibility, so like the above for software, make sure
      you have a backup of them, or their persistent identifiers (PIDs).

 - **Version control**: Version control is a critical component of
     Maneage. Here are some tips to help in effectively using it.

   - *Regular commits*: It is important (and extremely useful) to have the
      history of your project under version control. So try to make commits
      regularly (after any meaningful change/step/result).

   - *Keep Maneage up-to-date*: In time, Maneage is going to become more
      and more mature and robust (thanks to your feedback and the feedback
      of other users). Bugs will be fixed and new/improved features will be
      added. So every once and a while, you can run the commands below to
      pull new work that is done in Maneage. If the changes are useful for
      your work, you can merge them with your project to benefit from
      them. Just pay **very close attention** to resolving possible
      **conflicts** which might happen in the merge. In particular the
      "semantic conflicts" that don't show up in Git, but can potentially
      break your project, for example updates to software versions, or to
      internal Maneage structure. Hence read the commit messages of `git
      log` carefully to **see what has changed**. The best way to check is
      to first complete the steps below, then build your project from
      scratch (from `./project configure` in a new build-directory).

        ```shell
        # Go to the 'maneage' branch and import updates.
        $ git checkout maneage
        $ git pull                            # Get recent work in Maneage

        # Read all the commit messages of the newly imported
        # features/changes. In particular pay close attention to the ones
        # starting with 'IMPORTANT': these may cause a crash in your
        # project (changing something fundamental in Maneage).
        #
        # Replace the XXXXXXX..YYYYYYY with hashs mentioned close to start
        # of the 'git pull' command outputs.
        $ git log XXXXXXX..YYYYYYY --reverse

        # Have a look at the commits in the 'maneage' branch in relation
        # with your project.
        $ git log --oneline --graph --all # General view of branches.

        # Go to your 'main' branch and import all the updates into
        # 'main', don't worry about the printed outputs (in particular
        # the 'CONFLICT's), we'll clean them up in the next step.
        $ git checkout main
        $ git merge maneage

        # Ignore conflicting Maneage files that you had previously deleted
        # in the customization checklist (mostly demonstration files).
        $ git status             # Just for a check
        $ git status --porcelain | awk '/^DU/{system("git rm "$NF)}'
        $ git status             # Just for a check

        # If any files have conflicts, open a text editor and correct the
        # conflict (placed in between '<<<<<<<', '=======' and '>>>>>>>'.
        # Once all conflicts in a file are remoted, the file will be
        # automatically removed from the "Unmerged paths", so run this
        # command after correcting the conflicts of each file just to make
        # sure things are clean.
        git status

        # TIP: If you want the changes in one file to be only from a
        # special branch ('maneage' or 'main', completely ignoring
        # changes in the other), use this command:
        # $ git checkout <BRANCH-NAME> -- <FILENAME>

        # When there are no more "Unmerged paths", you can commit the
        # merge. In the commit message, Explain any conflicts that you
        # fixed.
        git commit

        # Do a clean build of your project (to check for "Semanic
        # conflicts" (not detected as a conflict by Git, but may cause a
        # crash in your project). You can backup your build directory
        # before running the 'distclean' target.
        #
        # Any error in the build will be due to low-level changes in
        # Maneage, so look closely at the commit messages in the Maneage
        # branch and especially those where the title starts with
        # 'IMPORTANT'.
        ./project make distclean  # will DELETE ALL your build-directory!!
        ./project configure -e
        ./project make

        # When everything is OK, before continuing with your project's
        # work, don't forget to push both your 'main' branch and your
        # updated 'maneage' branch to your remote server.
        git push
        git push origin maneage
        ```

   - *Adding Maneage to a fork of your project*: As you and your colleagues
      continue your project, it will be necessary to have separate
      forks/clones of it. But when you clone your own project on a
      different system, or a colleague clones it to collaborate with you,
      the clone won't have the `origin-maneage` remote that you started the
      project with. As shown in the previous item above, you need this
      remote to be able to pull recent updates from Maneage. The steps
      below will setup the `origin-maneage` remote, and a local `maneage`
      branch to track it, on the new clone.

        ```shell
        $ git remote add origin-maneage https://git.maneage.org/project.git
        $ git fetch origin-maneage
        $ git checkout -b maneage --track origin-maneage/maneage
        ```

   - *Commit message*: The commit message is a very important and useful
      aspect of version control. To make the commit message useful for
      others (or yourself, one year later), it is good to follow a
      consistent style. Maneage already has a consistent formatting
      (described below), which you can also follow in your project if you
      like. You can see many examples by running `git log` in the `maneage`
      branch. If you intend to push commits to Maneage, for the consistency
      of Maneage, it is necessary to follow these guidelines. 1) No line
      should be more than 75 characters (to enable easy reading of the
      message when you run `git log` on the standard 80-character
      terminal). 2) The first line is the title of the commit and should
      summarize it (so `git log --oneline` can be useful). The title should
      also not end with a point (`.`, because its a short single sentence,
      so a point is not necessary and only wastes space). 3) After the
      title, leave an empty line and start the body of your message
      (possibly containing many paragraphs). 4) Describe the context of
      your commit (the problem it is trying to solve) as much as possible,
      then go onto how you solved it. One suggestion is to start the main
      body of your commit with "Until now ...", and continue describing the
      problem in the first paragraph(s). Afterwards, start the next
      paragraph with "With this commit ...".

   - *Project outputs*: During your research, it is possible to checkout a
      specific commit and reproduce its results. However, the processing
      can be time consuming. Therefore, it is useful to also keep track of
      the final outputs of your project (at minimum, the paper's PDF) in
      important points of history.  However, keeping a snapshot of these
      (most probably large volume) outputs in the main history of the
      project can unreasonably bloat it. It is thus recommended to make a
      separate Git repo to keep those files and keep your project's source
      as small as possible. For example if your project is called
      `my-exciting-project`, the name of the outputs repository can be
      `my-exciting-project-output`. This enables easy sharing of the output
      files with your co-authors (with necessary permissions) and not
      having to bloat your email archive with extra attachments also (you
      can just share the link to the online repo in your
      communications). After the research is published, you can also
      release the outputs repository, or you can just delete it if it is
      too large or un-necessary (it was just for convenience, and fully
      reproducible after all). For example Maneage's output is available
      for demonstration in [a
      separate](http://git.maneage.org/output-raw.git/) repository.

   - *Full Git history in one file*: When you are publishing your project
      (for example to Zenodo for long term preservation), it is more
      convenient to have the whole project's Git history into one file to
      save with your datasets. After all, you can't be sure that your
      current Git server (for example GitLab, Github, or Bitbucket) will be
      active forever. While they are good for the immediate future, you
      can't rely on them for archival purposes. Fortunately keeping your
      whole history in one file is easy with Git using the following
      commands. To learn more about it, run `git help bundle`.

     - "bundle" your project's history into one file (just don't forget to
       change `my-project-git.bundle` to a descriptive name of your
       project):

        ```shell
        $ git bundle create my-project-git.bundle --all
        ```

      - You can easily upload `my-project-git.bundle` anywhere. Later, if
        you need to un-bundle it, you can use the following command.

        ```shell
        $ git clone my-project-git.bundle
        ```










Future improvements
===================

This is an evolving project and as time goes on, it will evolve and become
more robust. Some of the most prominent issues we plan to implement in the
future are listed below, please join us if you are interested.

Package management
------------------

It is important to have control of the environment of the project. Maneage
currently builds the higher-level programs (for example GNU Bash, GNU Make,
GNU AWK and domain-specific software) it needs, then sets `PATH` so the
analysis is done only with the project's built software. But currently the
configuration of each program is in the Makefile rules that build it. This
is not good because a change in the build configuration does not
automatically cause a re-build. Also, each separate project on a system
needs to have its own built tools (that can waste a lot of space).

A good solution is based on the [Nix package
manager](https://nixos.org/nix/about.html): a separate file is present for
each software, containing all the necessary info to build it (including its
URL, its tarball MD5 hash, dependencies, configuration parameters, build
steps and etc). Using this file, a script can automatically generate the
Make rules to download, build and install program and its dependencies
(along with the dependencies of those dependencies and etc).

All the software are installed in a "store". Each installed file (library
or executable) is prefixed by a hash of this configuration (and the OS
architecture) and the standard program name. For example (from the Nix
webpage):

```
/nix/store/b6gvzjyb2pg0kjfwrjmg1vfhh54ad73z-firefox-33.1/
```

The important thing is that the "store" is *not* in the project's search
path. After the complete installation of the software, symbolic links are
made to populate each project's program and library search paths without a
hash. This hash will be unique to that particular software and its
particular configuration. So simply by searching for this hash in the
installed directory, we can find the installed files of that software to
generate the links.

This scenario has several advantages: 1) a change in a software's build
configuration triggers a rebuild. 2) a single "store" can be used in many
projects, thus saving space and configuration time for new projects (that
commonly have large overlaps in lower-level programs).







Appendix: Necessity of exact reproduction in scientific research
================================================================

In case [the link above](http://akhlaghi.org/reproducible-science.html) is
not accessible at the time of reading, here is a copy of the introduction
of that link, describing the necessity for a reproducible project like this
(copied on February 7th, 2018):

The most important element of a "scientific" statement/result is the fact
that others should be able to falsify it. The Tsunami of data that has
engulfed astronomers in the last two decades, combined with faster
processors and faster internet connections has made it much more easier to
obtain a result. However, these factors have also increased the complexity
of a scientific analysis, such that it is no longer possible to describe
all the steps of an analysis in the published paper. Citing this
difficulty, many authors suffice to describing the generalities of their
analysis in their papers.

However, It is impossible to falsify (or even study) a result if you can't
exactly reproduce it. The complexity of modern science makes it vitally
important to exactly reproduce the final result. Because even a small
deviation can be due to many different parts of an analysis. Nature is
already a black box which we are trying so hard to comprehend. Not letting
other scientists see the exact steps taken to reach a result, or not
allowing them to modify it (do experiments on it) is a self-imposed black
box, which only exacerbates our ignorance.

Other scientists should be able to reproduce, check and experiment on the
results of anything that is to carry the "scientific" label. Any result
that is not reproducible (due to incomplete information by the author) is
not scientific: the readers have to have faith in the subjective experience
of the authors in the very important choice of configuration values and
order of operations: this is contrary to the scientific spirit.





Copyright information
---------------------
This file is part of Maneage (https://maneage.org).

This file is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation, either version 3 of the License, or (at your
option) any later version.

This file is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License along
with this file.  If not, see <http://www.gnu.org/licenses/>.
