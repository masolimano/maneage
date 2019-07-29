Reproducible paper template
===========================

Copyright (C) 2018-2019 Mohammad Akhlaghi <mohammad@akhlaghi.org>
See the end of the file for license conditions.

This project contains a **fully working template** for doing reproducible
research (or writing a reproducible paper) as defined in the link below. If
the link below is not accessible at the time of reading, please see the
appendix at the end of this file for a portion of its introduction. Some
[slides](http://akhlaghi.org/pdf/reproducible-paper.pdf) are also available
to help demonstrate the concept implemented here.

  http://akhlaghi.org/reproducible-science.html

This template is created with the aim of supporting reproducible research
by making it easy to start a project in this framework. As shown below, it
is very easy to customize this reproducible paper template for any
particular (research) project and expand it as it starts and evolves. It
can be run with no modification (as described in `README.md`) as a
demonstration and customized for use in any project as fully described
below.

A project designed using this template will download and build all the
necessary libraries and programs for working in a closed environment
(highly independent of the host operating system) with fixed versions of
the necessary dependencies. The tarballs for building the local environment
are also collected in a [separate
repository](https://gitlab.com/makhlaghi/reproducible-paper-dependencies). The
final output of the project is [a
paper](https://gitlab.com/makhlaghi/reproducible-paper-output/raw/master/paper.pdf).
Notice the last paragraph of the Acknowledgments where all the necessary
software are mentioned with their versions.

Below, we start with a discussion of why Make was chosen as the high-level
language/framework for project management and how to learn and master Make
easily (and freely). The general architecture and design of the project is
then discussed to help you navigate the files and their contents. This is
followed by a checklist for the easy/fast customization of this template to
your exciting research. We continue with some tips and guidelines on how to
manage or extend your project as it grows based on our experiences with it
so far. The main body concludes with a description of possible future
improvements that are planned for the template (but not yet
implemented). As discussed above, we end with a short introduction on the
necessity of reproducible science in the appendix.

Please don't forget to share your thoughts, suggestions and criticisms on
this template. Maintaining and designing this template is itself a separate
project, so please join us if you are interested. Once it is mature enough,
we will describe it in a paper (written by all contributors) for a formal
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
(which is shared in all of them). This template has been created for GNU
Make which is the most common, most actively developed, and most advanced
implementation. Just note that this template downloads, builds, internally
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





Published works using this template
-----------------------------------

The links below will guide you to some of the works that have already been
published with (earlier versions of) this template. Note that this template
is evolving, so some small details may be different in them, but they can
be used as a good working model to build your own.

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
   very first (and much less mature!) implementation of this template: the
   history of this template started more than two years after this paper
   was published. It is a very rudimentary/initial implementation, thus it
   is only included here for historical reasons. However, the project
   source is complete, accurate and uploaded to arXiv along with the paper.





Citation
--------

A paper will be published to fully describe this reproducible paper
template. Until then, if you used this template in your work, please cite
the paper that implemented its first version: Akhlaghi & Ichikawa
([2015](http://adsabs.harvard.edu/abs/2015ApJS..220....1A), ApJS, 220, 1).

The experience gained with this template after several more implementations
will be used to make it robust enough for a complete and useful paper to
introduce to the community afterwards.

Also, when your paper is published, don't forget to add a notice in your
own paper (in coordination with the publishing editor) that the paper is
fully reproducible and possibly add a sentence or paragraph in the end of
the paper shortly describing the concept. This will help spread the word
and encourage other scientists to also manage and publish their projects in
a reproducible manner.










Project architecture
====================

In order to customize this template to your research, it is important to
first understand its architecture so you can navigate your way in the
directories and understand how to implement your research project within
its framework: where to add new files and which existing files to modify
for what purpose. But before reading this theoretical discussion, please
run the template (described in `README.md`: first run `./project
configure`, then `./project make -j8`) without any change, just to see how
it works (note that the configure step builds all necessary software, so it
can take long, but you can read along while its working).

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
software installation directory.

Once the project is configured for your system, `./project make` will doing
the project's analysis with its own custom version of software. The process
is managed through Make and `./project make` will start with
`reproduce/analysis/make/top.mk` (called `top.mk` from now on).

Let's continue the template's architecture with this file. `top.mk` is
relatively short and heavily commented so hopefully the descriptions in
each comment will be enough to understand the general details. As you read
this section, please also look at the contents of the mentioned files and
directories to fully understand what is going on.

Before starting to look into the top `Makefile`, it is important to recall
that Make defines dependencies by files. Therefore, the input/prerequisite
and output of every step/rule must be a file. Also recall that Make will
use the modification date of the prerequisite(s) and target files to see if
the target must be re-built or not. Therefore during the processing, _many_
intermediate files will be created (see the tips section below on a good
strategy to deal with large/huge files).

To keep the source and (intermediate) built files separate, you _must_
define a top-level build directory variable (or `$(BDIR)`) to host all the
intermediate files (you defined it during `./project configure`). This
directory doesn't need to be version controlled or even synchronized, or
backed-up in other servers: its contents are all products, and can be
easily re-created any time. As you define targets for your new rules, it is
thus important to place them all under sub-directories of `$(BDIR)`. As
mentioned above, you always have fast access to this "build"-directory with
the `.build` symbolic link.

In this architecture, we have two types of Makefiles that are loaded into
the top `Makefile`: _configuration-Makefiles_ (only independent
variables/configurations) and _workhorse-Makefiles_ (Makefiles that
actually contain analysis/processing rules).

The configuration-Makefiles are those that satisfy these two wildcards:
`reproduce/software/config/installation/*.mk` (for building the necessary
software when you run `./project configure`) and
`reproduce/analysis/config/*.mk` (for the high-level analysis, when you run
`./project make`). These Makefiles don't actually have any rules, they just
have values for various free parameters throughout the configuration or
analysis. Open a few of them to see for yourself. These Makefiles must only
contain raw Make variables (project configurations). By "raw" we mean that
the Make variables in these files must not depend on variables in any other
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
can be a pre-requisite of that intermediate LaTeX macro file and thus be
called when necessary. Otherwise, they will be ignored by Make.

This template also has a mode to share the build directory between several
users of a Unix group (when working on large computer clusters). In this
scenario, each user can have their own cloned project source, but share the
large built files between each other. To do this, it is necessary for all
built files to give full permission to group members while not allowing any
other users access to the contents. Therefore the `./project configure` and
`./project make` steps must be called with special conditions which are
managed in the `--group` option.

Let's see how this design is implemented. Please open and inspect `top.mk`
it as we go along here. The first step (un-commented line) is to import the
local configuration (your answers to the questions of `./project
configure`). They are defined in the configuration-Makefile
`reproduce/software/config/installation/LOCAL.mk` which was also built by
`./project configure` (based on the `LOCAL.mk.in` template of the same
directory).

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
will notice that it starts with a rule to create `$(mtexdir)/project.tex`
(`mtexdir` is just a shorthand name for `$(BDIR)/tex/macros` mentioned
before).  `$(mtexdir)/project.tex` is the connection between the
processing/analysis steps of the project, and the steps to build the final
PDF. As you see, `$(mtexdir)/project.tex` only instructs LaTeX to import
the LaTeX macros of each high-level processing step during the analysis
(the separate work-horse Makefiles that you defined and included).

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

While git does an excellent job at keeping a history of the contents of
files, it makes no effort in keeping the file meta data, and in particular
the dates of files. Therefore when you checkout to a different branch,
files that are re-written by Git will have a newer date than the other
project files. However, file dates are important in the current design of
the template: Make uses file dates of the pre-requisits and targets to see
if the target should be re-built.

To fix this problem, for this template we use a forked version of
[Metastore](https://github.com/mohammad-akhlaghi/metastore). Metastore use
a binary database file (which is called `.file-metadata`) to keep the
modification dates of all the files under version control. This file is
also under version control, but is hidden (because it shouldn't be modified
by hand). During the project's configuration, the template installs to Git
hooks to run Metastore 1) before making a commit to update its database
with the file dates in a branch, and 2) after doing a checkout, to reset
the file-dates after the checkout is complete and re-set the file dates
back to what they were.

In practice, Metastore should work almost fully invisiablly within your
project. The only place you might notice its presence is that you'll see
`.file-metadata` in the list of modified/staged files (commonly after
merging your branches). Since its a binary file, Git also won't show you
the changed contents. In a merge, you can simply accept any changes with
`git add -u`. But if Git is telling you that it has changed without a merge
(for example if you started a commit, but cancelled it in the middle), you
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
   `reproduce/analysis/config/XXXXX.mk`. Then set this
   configuration-Makefiles file as a pre-requisite to any rule that uses
   the variable defined in it.

 - Through any number of intermediate prerequisites, all processing steps
   should end in (be a prerequisite of) `$(mtexdir)/project.tex` (defined
   in `reproduce/analysis/make/paper.mk`). `$(mtexdir)/project.tex` is the
   bridge between the processing steps and PDF-building steps.










Customization checklist
=======================

Take the following steps to fully customize this template for your research
project. After finishing the list, be sure to run `./project configure` and
`project make` to see if everything works correctly. If you notice anything
missing or any in-correct part (probably a change that has not been
explained here), please let us know to correct it.

As described above, the concept of reproducibility (during a project)
heavily relies on [version
control](https://en.wikipedia.org/wiki/Version_control). Currently this
template uses Git as its main version control system. If you are not
already familiar with Git, please read the first three chapters of the
[ProGit book](https://git-scm.com/book/en/v2) which provides a wonderful
practical understanding of the basics. You can read later chapters as you
get more advanced in later stages of your work.

 - **Get this repository and its history** (if you don't already have it):
     Arguably the easiest way to start is to clone this repository as shown
     below. As you see, after the cloning some further corrections to your
     clone's Git settings are necessary: first, you need to remove all
     possibly existing Git tags from the template's history. Then you need
     to rename the conventional `origin` remote server, and the `master`
     branch. This renaming allows you to use these standard names for your
     own customized project (which greatly helps because this convention is
     widely used).

     ```shell
     $ git clone git://git.sv.gnu.org/reproduce   # Clone/copy the project and its history.
     $ mv reproduce my-project                    # Change the name to your project's name.
     $ cd my-project                              # Go into the cloned directory.
     $ git tag | xargs git tag -d                 # Delete all template tags.
     $ git config remote.origin.tagopt --no-tags  # No tags in future fetch/pull from this template.
     $ git remote rename origin template-origin   # Rename current/only remote to "template-origin".
     $ git branch -m template                     # Rename current/only branch to "template".
     $ git checkout -b master                     # Create and enter new "master" branch.
     ```

 - **Test the template**: Before making any changes, it is important to
     test it and see if everything works properly with the commands
     below. If there is any problem in the `./project configure` or
     `./project make` steps, please contact us to fix the problem before
     continuing. Since the building of dependencies in configuration can
     take long, you can take the next few steps (editing the files) while
     its working (they don't affect the configuration). After `./project
     make` is finished, open `paper.pdf`. If it looks fine, you are ready
     to start customizing the template for your project. But before that,
     clean all the extra template outputs with `make clean` as shown below.

     ```shell
     $ ./project configure --host-cc # Configure project (except for GCC which can take long).
     $ ./project make                # Do the (mainly symbolic) processing and build paper

     # Open 'paper.pdf' and see if everything is ok.
     $ ./project make clean          # Delete high-level outputs (keep software)
     ```

 - **Setup the remote**: You can use any [hosting
     facility](https://en.wikipedia.org/wiki/Comparison_of_source_code_hosting_facilities)
     that supports Git to keep an online copy of your project's version
     controlled history. We recommend [GitLab](https://gitlab.com) because
     it is [more ethical (although not
     perfect)](https://www.gnu.org/software/repo-criteria-evaluation.html),
     and later you can also host GitLab on your own server. Anyway, create
     an account in your favorite hosting facility (if you don't already
     have one), and define a new project there. It will give you a URL
     (usually starting with `git@` and ending in `.git`), put this URL in
     place of `XXXXXXXXXX` in the first command below. With the second
     command, "push" your `master` branch to your `origin` remote, and
     (with the `--set-upstream` option) set them to track/follow each
     other. However, the `template` branch is currently tracking/following
     your `template-origin` remote (automatically set when you cloned the
     template). So when pushing the `template` branch to your `origin`
     remote, you _shouldn't_ use `--set-upstream`. With the last command,
     you can actually check this (which local and remote branches are
     tracking each other).

     ```shell
     git remote add origin XXXXXXXXXX        # Newly created repo is now called 'origin'.
     git push --set-upstream origin master   # Push 'master' branch to 'origin' (enable tracking).
     git push origin template                # Push 'template' branch to 'origin' (no tracking).
     git branch -vv                          # Just to check of the trackings.
     ```

 - **Title**, **short description** and **author** in source files: In this
     raw skeleton, the title or short description of your project should be
     added in the following two files: `reproduce/analysis/make/top.mk`
     (the first line), and `tex/src/preamble-header.tex`. In both cases,
     the texts you should replace are all in capital letters to make them
     easier to identify. Of course, if you use a different LaTeX method of
     managing the title and authors, please feel free to use your own
     methods after finishing this checklist and doing your first commit.

 - **High-level software**: The template installs all the software that
     your project needs. You can specify which software your project needs
     in the `reproduce/software/config/installation/TARGETS.mk`. The
     necessary software are classified into two classes: 1) programs or
     libraries (usually written in C/C++) which are run directly by the
     operating system. 2) Python modules/libraries that are run within
     Python. By default `TARGETS.mk` only has GNU Astronomy Utilities
     (Gnuastro) as one scientific program and Astropy as one scientific
     Python module. Both have many dependencies which will be installed
     into your project before they are. To see a list of software that are
     currently ready to be built in the template, see
     `reproduce/software/config/installation/versions.mk` (which has their
     versions also), the comments in `TARGETS.mk` describe how to use the
     software name from `versions.mk`. Currently the raw pipeline just uses
     Gnuastro to make the demonstration plots. Therefore if you don't need
     Gnuastro, go through the analysis steps in `reproduce/analysis` and
     remove all its use cases (clearly marked).

 - **Input dataset (can be done later)**: The input datasets are managed
     through the `reproduce/analysis/config/INPUTS.mk` file. It is best to
     gather all the information regarding all the input datasets into this
     one central file. To ensure that the proper dataset is being
     downloaded and used by the project, it is also recommended get an [MD5
     checksum](https://en.wikipedia.org/wiki/MD5) of the file and include
     that in `INPUTS.mk` so the project can check it automatically. The
     preparation/downloading of the input datasets is done in
     `reproduce/analysis/make/download.mk`. Have a look there to see how
     these values are to be used. This information about the input datasets
     is also used in the initial `configure` script (to inform the users),
     so also modify that file. You can find all occurrences of the template
     dataset with the command below and replace it with your input's
     dataset.

     ```shell
     $ grep -ir wfpc2 ./*
     ```

 - **Delete dummy parts (can be done later)**: The template contains some
     parts that are only for the initial/test run, mainly as a
     demonstration of important steps. They not for any real analysis. You
     can remove these parts in the file below

     - `paper.tex`: Delete the text of the abstract and the paper's main
       body, *except* the "Acknowledgments" section. This template was
       designed by funding from many grants, so its necessary to
       acknowledge them in your final research.

     - `Makefile`: Delete the lines containing `delete-me` in the `foreach`
       loop. Just make sure the other lines that end in `\` are immediately
       after each other (except the last line).

     - Delete all `delete-me*` files in the following directories:

       ```shell
       $ rm tex/src/delete-me*
       $ rm reproduce/analysis/make/delete-me*
       $ rm reproduce/analysis/config/delete-me*
       ```

 - **`README.md`**: Correct all the `XXXXX` place holders (name of your
     project, your own name, address of the template's online/remote
     repository, link to download dependencies and etc). Generally, read
     over the text and update it where necessary to fit your project. Don't
     forget that this is the first file that is displayed on your online
     repository and also your colleagues will first be drawn to read this
     file. Therefore, make it as easy as possible for them to start
     with. Also check and update this file one last time when you are ready
     to publish your project's paper/source.

 - **Copyright and License notice**: To be usable/modifiable by others
     after publication, _all_ the "copyright-able" files in your project
     (those larger than 10 lines) must have a copyright notice and license
     notice. Please take a moment to look at several existing files to see
     a few examples. The copyright notice is usually close to the start of
     the file, it is the line starting with `Copyright (C)` and containing
     a year and the author's name. The License notice is a short (or full,
     when its not too long, like the MIT license) description of the
     copyright license, usually less than three paragraphs. Don't forget to
     add these _two_ notices to any new file you add to this template for
     your project. When you modify an existing template file (which already
     has the notices), just add a copyright notice in your name under the
     existing one(s), like the line below:

     ```
     Copyright (C) 2018-2019 Mohammad Akhlaghi <mohammad@akhlaghi.org>
     Copyright (C) 2019 YOUR NAME <YOUR@EMAIL.ADDRESS>
     ```

 - **Your first commit**: You have already made some small and basic
     changes in the steps above and you are in the `master` branch. So, you
     can officially make your first commit in your project's history. But
     before that you need to make sure that there are no problems in the
     project (this is a good habit to always re-build the system before a
     commit to be sure it works as expected).

     ```shell
     $ ./project make clean       # Delete outputs ('make distclean' for everything)
     $ ./project make             # Build the project to ensure everything is fine.
     $ git add -u                 # Stage all the changes.
     $ git status                 # Make sure everything is fine.
     $ git commit                 # Your first commit, add a nice description.
     $ git tag -a v0              # Tag this as the zero-th version of your project.
     ```

 - **Push to the remote**: Push your first commit and its tag to your
     remote repository with these commands. Since we have setup your
     `master` branch to follow `origin/master`, you can just use `git push`
     from now on.

     ```shell
     $ git push
     $ git push --tags
     ```

 - **Start your exciting research**: You are now ready to add flesh and
     blood to this raw skeleton by further modifying and adding your
     exciting research steps. You can use the "published works" section in
     the introduction (above) as some fully working models to learn
     from. Also, don't hesitate to contact us if you have any
     questions.

 - **Feedback**: As you use the template you will notice many things that
     if implemented from the start would have been very useful for your
     work. This can be in the actual scripting and architecture of the
     template, or useful implementation and usage tips, like those
     below. In any case, please share your thoughts and suggestions with
     us, so we can add them here for everyone's benefit.

 - **Keep template up-to-date**: In time, this template is going to become
     more and more mature and robust (thanks to your feedback and the
     feedback of other users). Bugs will be fixed and new/improved features
     will be added. So every once and a while, you can run the commands
     below to pull new work that is done in this template. If the changes
     are useful for your work, you can merge them with your project to
     benefit from them. Just pay **very close attention** to resolving
     possible **conflicts** which might happen in the merge (updated
     settings that you have customized in the template).

     ```shell
     $ git checkout template
     $ git pull                            # Get recent work in the template
     $ git log XXXXXX..XXXXXX --reverse    # Inspect new work (replace XXXXXXs with hashs mentioned in output of previous command).
     $ git log --oneline --graph --decorate --all # General view of branches.
     $ git checkout master                 # Go to your top working branch.
     $ git merge template                  # Import all the work into master.
     ```

 - **Adding this template to a fork of your project**: As you and your
     colleagues continue your project, it will be necessary to have
     separate forks/clones of it. But when you clone your own project on a
     different system, or a colleague clones it to collaborate with you,
     the clone won't have the `template-origin` remote that you started the
     project with. As shown in the previous item above, you need this
     remote to be able to pull recent updates from the template. The steps
     below will setup the `template-origin` remote, and a local `template`
     branch to track it, on the new clone.

     ```shell
     $ git remote add template-origin git://git.sv.gnu.org/reproduce
     $ git fetch template-origin
     $ git checkout -b template --track template-origin/master
     ```

 - **Updating TeXLive**: Currently the only software package that the
     template doesn't build is TeXLive (since its not part of the analysis,
     only for demonstration: building the PDf). So when a new version of
     TeXLive comes (once every year), if you would like to build the paper,
     its necessary to update it in your project (otherwise the configure
     script will crash). To do that, just modify the years in
     `reproduce/software/config/installation/texlive.conf`, then delete
     `.build/software/tarballs/install-tl-unx.tar.gz`. The next time you
     run `./project configure`, the new TeXLive will be installed and used.

 - **Pre-publication: add notice on reproducibility**: Add a notice
     somewhere prominent in the first page within your paper, informing the
     reader that your research is fully reproducible. For example in the
     end of the abstract, or under the keywords with a title like
     "reproducible paper". This will encourage them to publish their own
     works in this manner also and also will help spread the word.








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
      `reproduce/software/config`. Similar to the
      `reproduce/software/config/gnuastro` directory (which is put in the
      template as a demo in case you use GNU Astronomy Utilities). It is
      much cleaner and readable (thus less buggy) to avoid mixing the
      configuration files, even if there is no technical necessity.


 - **Contents**: It is good practice to follow the following
     recommendations on the contents of your files, whether they are source
     code for a program, Makefiles, scripts or configuration files
     (copyrights aren't necessary for the latter).

   - *Copyright*: Always start a file containing programming constructs
      with a copyright statement like the ones that this template starts
      with (for example in the top level `Makefile`).

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
      solution is the following strategy. Set a small plain text file as
      the actual target and delete the large file when it is no longer
      needed by the project (in the last rule that needs it). Below is a
      simple demonstration of doing this. In it, we use Gnuastro's
      Arithmetic program to add all pixels of the input image with 2 and
      create `large1.fits`. We then subtract 2 from `large1.fits` to create
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
      source. Just note that this is only possible for free and open-source
      software.

   - *Keep your input data*: The input data is also critical to the
      project's reproducibility, so like the above for software, make sure
      you have a backup of them, or their persistent identifiers (PIDs).

 - **Version control**: It is important (and extremely useful) to have the
   history of your project under version control. So try to make commits
   regularly (after any meaningful change/step/result), while not
   forgetting the following notes.

   - *Commit message*: The commit message is a very important and useful
      aspect of version control. To make the commit message useful for
      others (or yourself, one year later), it is good to follow a
      consistent style. The template already has a consistent formatting
      (described below), which you can also follow in your project if you
      like. You can see many examples by running `git log` in the
      `template` branch. If you intend to push commits to the main
      template, for the consistency of the template, it is necessary to
      follow these guidelines. 1) No line should be more than 75 characters
      (to enable easy reading of the message when you run `git log` on the
      standard 80-character terminal). 2) The first line is the title of
      the commit and should summarize it (so `git log --oneline` can be
      useful). The title should also not end with a point (`.`, because its
      a short single sentence, so a point is not necessary and only wastes
      space). 3) After the title, leave an empty line and start the body of
      your message (possibly containing many paragraphs). 4) Describe the
      context of your commit (the problem it is trying to solve) as much as
      possible, then go onto how you solved it. One suggestion is to start
      the main body of your commit with "Until now ...", and continue
      describing the problem in the first paragraph(s). Afterwards, start
      the next paragraph with "With this commit ...".

   - *Tags*: To help manage the history, tag all major commits. This helps
      make a more human-friendly output of `git describe`: for example
      `v1-4-gaafdb04` states that we are on commit `aafdb04` which is 4
      commits after tag `v1`. The output of `git describe` is included in
      your final PDF as part of this project. Also, if you use
      reproducibility-friendly software like Gnuastro, this value will also
      be included in all output files, see the description of `COMMIT` in
      [Output
      headers](https://www.gnu.org/software/gnuastro/manual/html_node/Output-headers.html).
      In the checklist above, you tagged the first commit of your project
      with `v0`. Here is one suggestion on when to tag: when you have fully
      adopted the template and have got the first (initial) results, you
      can make a `v1` tag. Subsequently when you first start reporting the
      results to your colleagues, you can tag the commit as `v2` and
      increment the version on every later circulation, or referee
      submission.

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
      reproducible after all). For example this template's output is
      available for demonstration in the separate
      [reproducible-paper-output](https://gitlab.com/makhlaghi/reproducible-paper-output)
      repository.

 - **Inspecting status**: When you run `./project configure`, several
     programs and libraries start to get configured and build (in many
     cases, simultaneously). To understand the building process, or for
     debugging a strange situation, it is sometimes useful to know which
     programs are being built at every moment. To do this, you can look
     into the `.build/software/build-tmp` directory (from the top project
     directory). This temporary directory is only present while building
     the software. At every moment, it contains the unpacked source tarball
     directories of the all the packages that are being built. After a
     software is successfully installed in your project, it is removed from
     this directory. To automatically get a listing of this directory every
     second, you can run the command below (on another terminal while the
     software are being built). Press `CTRL-C` to stop it and return back
     to the command-line).

     ```shell
     $ while true; do echo; date; ls .build/software/build-tmp; sleep 1; done
     ```










Future improvements
===================

This is an evolving project and as time goes on, it will evolve and become
more robust. Some of the most prominent issues we plan to implement in the
future are listed below, please join us if you are interested.

Package management
------------------

It is important to have control of the environment of the project. The
current template builds the higher-level programs (for example GNU Bash,
GNU Make, GNU AWK and domain-specific software) it needs, then sets `PATH`
so the analysis is done only with the project's built software. But
currently the configuration of each program is in the Makefile rules that
build it. This is not good because a change in the build configuration does
not automatically cause a re-build. Also, each separate project on a system
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
This file is part of the reproducible paper template
   http://savannah.nongnu.org/projects/reproduce

This template is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option)
any later version.

This template is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along
with Template.  If not, see <https://www.gnu.org/licenses/>.