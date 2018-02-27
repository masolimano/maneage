Introduction
============

This description is for *creators* of the reproduction pipeline. See
`README` on instructions for running it.

This project contains a **fully working template** for a high-level
research reproduction pipeline as defined in the link below. If this page
is inaccessible at the time of reading, please see the end of this file
which contains a portion of the introduction in this webpage. Some
[slides](http://akhlaghi.org/pdf/reproduction-pipeline.pdf) are also
available to help demonstrate the concept implemented here.

  http://akhlaghi.org/reproducible-science.html

This template is created with the aim of supporting reproducible research
by making it easy to start a project in this framework. As shown below, it
is very easy to customize this template pipeline for any particular
research/job and expand it as it starts and evolves. It can be run with no
modification (as described in `README`) as a demonstration and customized
by editing the existing rules and adding new rules as well as adding new
Makefiles as the research/project grows.

This file will continue with a discussion of why Make is a suitable (maybe
perfect) language/framework for a research reproduction pipeline and how to
master Make easily (and freely). An introduction is then given to the
general architecture of the pipeline. It is followed by a checklist of
steps that are necessary to start customizing this pipeline for your
research. The main body finishs with some tips and guidelines on how to
manage or extend the pipeline as your research grows based on our
experiences with it so far. As discussed above, in the appendix, a short
introduction on the necessity of reproducible science is given. Please
share your thoughts and suggestions on this pipeline so we can implement
them and make it even more easier to use and more robust/generic.



Why Make?
---------

When batch processing is necessary (no manual intervention, as in a
reproduction pipeline), shell scripts are usually the first solution that
comes to mind. However, the problem with scripts for a scientific
reproduction pipeline is the complexity and non-linearity. A script will
start from the top/start every time it is run. So if you have gone through
90% of a research project and want to run the remaining 10% that you have
newly added, you have to run the whole script from the start again and wait
until you see the effects of the last few steps (for the possible errors,
or better solutions and etc). It is possible to manually ignore/comment
parts of a script to only do a special part. However, such checks/comments
will only add to the complexity of the script and they are prone to very
serious bugs in the end (when trying to reproduce from scratch). Such bugs
are very hard to notice during the work and frustrating to find in the end.

The Make paradigm, on the other hand, starts from the end: the final
*target*. It builds a dependency tree internally, and finds where it should
start each time the pipeline is run. Therefore, in the scenario above, a
researcher that has just added the final 10% of steps of her research to
her Makefile, will only have run those extra steps. As commonly happens in
a research context, in Make, it is also trivial to change the processing of
any intermediate (already written) *rule* (or step) in the middle of an
already written analysis: the next time Make is run, only rules affected by
the changes/additions will be re-run, not the whole analysis.

This greatly speeds up the processing (enabling creative changes), while
keeping all the dependencies clearly documented (as part of the Make
language), and most importantly, enabling full reproducibility from scratch
with no changes in the pipeline code that was working during the
research. Since the dependencies are also clearly demarcated, Make can
identify independent steps and run them in parallel (further speeding up
the process). Make was designed for this purpose and it is how huge
projects like all Unix-like operating systems (including GNU/Linux or Mac
OS operating systems) and their core components are built. Therefore, Make
is a highly mature paradigm/system with robust and highly efficient
implementations in various operating systems perfectly suited for a complex
non-linear research project.

Make is a small language with the aim of defining *rules* containing
*targets*, *prerequisites* and *recipes*. It comes with some nice features
like functions or automatic-variables to greatly facilitate the management
of text (filenames for example) or any of those constructs. For a more
detailed (yet still general) introduction see Wikipedia:

  https://en.wikipedia.org/wiki/Make_(software)

Many implementations of Make exist and all should be usable with this
pipeline. This pipeline has been created and tested mainly with GNU Make
which is the most common implementation. But if you see parts specific to
GNU Make, please inform us to correct it.



How can I learn Make?
---------------------

The best place to learn Make from scratch is the GNU Make manual. It is an
excellent and non-technical (in its first chapters) book to help get
started. It is freely available and always up to date with the current
release. It also clearly explains which features are specific to GNU Make
and which are general in all implementations. So the first few chapters
regarding the generalities are useful for all implementations.

The first link below points to the GNU Make manual in various formats and
in the second, you can get it in PDF (which may be easier to read in the
first time).

  https://www.gnu.org/software/make/manual/

  https://www.gnu.org/software/make/manual/make.pdf

If you use GNU Make, you also have the whole GNU Make manual on the
command-line with the following command (you can come out of the "Info"
environment by pressing `q`). If you don't know Info, we strongly recommend
running `$ info info` anywhere on your command-line to learn it easily in
less than an hour. Info greatly simplifies your access (without taking your
hands off the keyboard!) to many manuals that are installed on your system,
allowing you to be more efficient.

```shell
  $ info make
```

If you use the Emacs text editor, you will find the Info version of the
Make manual there also.



Published works using this pipeline
-----------------------------------

The links below will guide you to some of the works that have already been
published using the method of this pipeline. Note that this pipeline is
evolving, so some small details may be different in them, but they can be
used as a good working model to build your own.

 - Section 7.3 of Bacon et al. (2017, A&A 608, A1): The version controlled
   reproduction pipeline is available [on
   Gitlab](https://gitlab.com/makhlaghi/muse-udf-origin-only-hst-magnitudes)
   and a snapshot of the pipeline along with all the necessary input
   datasets and outputs is available in
   [zenodo.1164774](https://doi.org/10.5281/zenodo.1164774).

 - Section 4 of Bacon et al. (2017, A&A, 608, A1): The version controlled
   reproduction pipeline is available [on
   Gitlab](https://gitlab.com/makhlaghi/muse-udf-photometry-astrometry) and
   a snapshot of the pipeline along with all the necessary input datasets
   is available in
   [zenodo.1163746](https://doi.org/10.5281/zenodo.1163746).





Reproduction pipeline architecture
==================================

In order to adopt this pipeline to your research, it is important to first
understand its architecture so you can navigate your way in the directories
and understand how to implement your research project within its
framework. In short, when the user runs `make` to start the processing, the
first file that is read is the top-level `Makefile`. Therefore, we'll start
our navigation with this file. This file is heavily commented so hopefully
the descriptions in each comment will be enough to understand the general
details. As you read this section, please also look at the contents of the
mentioned files and directories to fully understand what is being said.

Before starting to look into the top Makefile, it is important to recall
that Make defines dependencies by files. Therefore, the input and output of
every step must be a file. Also recall that Make will use the modification
date of the prerequisite and target files to see if the a target must be
re-built or not. Therefore during the processing _many_ intermediate files
will be created (see the tips section below on a good strategy to deal with
large/huge files). Therefore, in configuration time, the user can define a
top-level build directory variable (or `$(BDIR)`) to host all the
intermediate files. This directory doesn't need to be version controlled or
even synchronized or backed-up in other servers: its contents are all
products of the pipeline after all, and can be easily re-created any
time. As you define targets, it is thus important to place them all under
sub-directories of `$(BDIR)`.

Let's start reviewing the processing with the top Makefile. Please open and
inspect it as we go along here. The first step is to define the ultimate
target (`paper.pdf`). You shouldn't modify this line. The rule to build
`paper.pdf` is in another Makefile that will be imported into this top
Makefile later. Don't forget that Make goes over all the process once (to
define dependencies and etc) and then starts its execution. So it is fine
to define the rule to build `paper.pdf` at a later stage (this is the
beauty of Make after all).

Having defined the top target, we will import all the necessary
Makefiles. As you see in `Makefile`, first we include all
`reproduce/config/pipeline/*.mk`. The configuration of each logical step of
the pipeline is placed here as a separate file. These Makefiles must only
contain raw Make variables (pipeline configurations). By raw we mean that
the Make variables in these files must not depend on any other variables
because we don't want to assume any order in read them. It is very
important to *not* define any rule or other Make construct in any of these
_configuration-Makefiles_ (see the next paragraph for Makefiles with
rules). This will enable you to set the respective files in this directory
as a prerequisite to any target that depends on their variable
values. Therefore, if you change any of the values, all targets that depend
on those values will be re-built.

Once all the raw variables have been imported into the top Makefile, we are
ready to import the Makefiles containing the details of the processing
steps (Makefiles containing rules, let's call these
_workhorse-Makefiles_). But *order is important* in this phase because the
prerequisites of most rules will be other rules that will be defined at a
lower level (not a fixed name like `paper.pdf`). The lower-level rules must
be imported into Make before the higher-level ones. Hence, we can't use a
simple wildcard like when we imported configuration-Makefiles above. All
these Makefiles are defined in `reproduce/src/make`, therefore, the top
Makefile uses the `foreach` function to read them in a specific order.

The main body of this pipeline is thus going to be managed within the
workhorse-Makefiles of `reproduce/src/make`. If you set clear-to-understand
names for thse workhorse-Makefiles and follow the convention of the top
Makefile that you only include one workhorse-Makefile per line, the
`foreach` loop of the top Makefile that imports them will become very easy
to read and understand by eye. This will let you know which step you are
taking before or after another without much thought (in a few months
especially). Projects will scale up very fast. Thus if you don't start and
continue with a clean and robust management strategy, in the end it will
become very dirty and hard to manage/understand (even for yourself). As a
general rule of thumb, break your rules into as many logically-similar but
independent steps as possible.

All processing steps ultimately (usually after many rules) end up in some
number, image, figure, or table that must be included in the paper. After
all, if you don't want to report the value of a processing, why would you
do it in the first place? Therefore if the targets in a workhorse-Makefile
aren't directly a prerequisite of other workhorse-Makefiles, they should be
a pre-requisite of an intermediate LaTeX macro file that is produced as the
highest-level target of that workhorse-Makefile.

The last part of the top-level Makefile is the rule to build
`tex/pipeline.tex`. This file is the connection between the processing
steps of the pipeline and the creation of the final PDF. In
`reproduce/src/make/paper.mk`, you will notice that `paper.pdf` (final
target of the whole reproduction pipeline) depends on
`tex/pipeline.tex`. This file is thus the connection of these two very
high-level different phases of the reproduction pipeline. Therefore, to
keep the over-all management clean, the rule to create this bridge between
the processing and paper-writing phases is defined in the top-level
Makefile.

But `tex/pipeline.tex` is only a merging/concatenation of LaTeX macros
defined as the output of each high-level processing step. In some cases you
want tables and images to also be included in the final PDF. To keep these
necessary LaTeX inputs, you can define other directories under
`$(BDIR)/tex` in the relevant workhorse-Makefile. One of the LaTeX macros
that `reproduce/src/make/initialize.mk` creates is the location of the
build directory, so you can easily guide LaTeX to look into the proper
directory through the `\bdir` macro. If the target of the rule that creates
these other LaTeX inputs isn't a prerequisite of other rules, add it as a
pre-requisite of `tex/pipeline.tex`.

During the research, it often happens that you want to test a step that is
not a prerequisite of any higher-level operation. In such cases, you can
(temporarily) define the target of that rule as a prerequisite of
`tex/pipeline.tex`. If your test gives a promising result and you want to
include it in your research, set it as prerequisites to other rules and
remove it from the list of prerequisites for `tex/pipeline.tex`. In fact,
this is how a project is designed to grow in this framework.



Summary
-------

Based on the explanation above, some major design points you should have in
mind are listed below.

 - Define new `reproduce/src/make/XXXXXX.mk` workhorse-Makefile(s) with
   good and human-friendly name(s) replacing `XXXXXX`.

 - Add `XXXXXX`, as a new line, to the loop which includes the
   workhorse-Makefiles in the top-level `Makefile`.

 - Do not use any constant numbers (or important names like filter names)
   in the workhorse-Makefiles. Define such constants as logically-grouped
   separate configuration-Makefiles in `reproduce/config/pipeline`. Then
   set the respective configuration-Makefiles file as a pre-requisite to
   any rule that uses the variable defined in it.

 - To be executed, any target should either be a prerequisite of another
   rule (possibly in another Makefile), or a file that is directly imported
   into LaTeX as fixed macros for inclusion in text or LaTeX settings (in
   `$(BDIR)/tex/macros`), images, plots or tables (in other `$(BDIR)/tex`
   sub-directories). In any cases, through any number of intermediate
   prerequisites, all processing steps should end in (be a prerequisite of)
   `tex/pipeline.tex`.





Checklist to customize the pipeline
===================================

Take the following steps to fully customize this pipeline for your research
project. After finishing the list, be sure to run `./configure` and `make`
to see if everything works correctly before expanding it. If you notice
anything missing or any in-correct part (probably a change that has not
been explained here), please let us know to correct it.

 - **Get this repository** (if you don't already have it): Arguably the
     easiest way to start is to clone this repository as shown below:

     ```shell
     $ git clone https://gitlab.com/makhlaghi/reproduction-pipeline-template.git
     $ mv reproduction-pipeline-template your-project-name
     $ cd your-project-name
     ```

 - **Copyright**, **name** and **date**: Go over the following files and
     add your name and email to the copyright notice: `configure`,
     `Makefile` and `reproduce/src/make/*.mk`. When making new files,
     always remember to add a similar copyright statement at the top of the
     file.

 - **Title**, **short description** and **author** of project: In this raw
     skeleton, the title or short description of your project should be
     added in the following two files: `Makefile` (the first line), and
     `tex/preamble-style.tex` (the last few lines, along with the names of
     you and your colleagues). In both cases, the texts you should replace
     are all in capital letters to make them easier to identify. Of course,
     if you use a different LaTeX method of managing the title and authors,
     please feel free to use your own methods, just find a way to keep the
     pipeline version in a nicely visible place.

 - **Gnuastro**: GNU Astronomy Utilities (Gnuastro) is currently a
     dependency of the pipeline and without it, the pipeline will complain
     and abort. The main reason for this is to demonstrate how critically
     important it is to version your software. If you don't want to install
     Gnuastro please follow the instructions in the list below. If you have
     installed Gnuastro and tried the pipeline, but don't need Gnuastro in
     your pipeline, also follow the list below. If you do want to use
     Gnuastro in your pipeline, be sure to un-comment the `onlyversion`
     option in `reproduce/config/gnuastro/gnuastro.conf` file and set it to
     your version of Gnuastro. This will force you to keep the pipeline in
     match with the version of Gnuastro you are using all the time and also
     allow commits to be exactly reproducible also (for example if you
     update to a new version of Gnuastro during your research project). If
     you will be using Gnuastro, you can also remove the "marks" (comments)
     put in the relevant files of the list below to make them more
     readable.

   - Delete the description about Gnuastro in `README`.
   - Delete marked part(s) in `configure`.
   - Delete marked parts in `reproduce/src/make/initialize.mk`.
   - Delete `and Gnuastro \gnuastroversion` from `tex/preamble-style`.

 - **Other dependencies**: If there are any more of the dependencies that
     you don't use (or others that you need), then remove (or add) them in
     the respective parts of `configure`. It is commented thoroughly and
     reading over the comments should guide you on what to add/remove and
     where. Note that it is always good to have an option to download the
     necessary datasets in case the user doesn't have them. But in case
     your pipeline doesn't need any downloads, you can also remove the
     sections of `configure' that are for `flock' and the downloader.

 - **`README`**: Go through this top-level instruction file and make it fit
     to your pipeline: update the text and etc. Don't forget that your
     colleagues or anyone else, will first be drawn to read this file, so
     make it as easy as possible for them to understand your
     work. Therefore, also check and update `README` one last time when you
     are ready to publish your work (and its reproduction pipeline).

 - **First input dataset**: The user manages the top-level directory of the
     input data through the variables set in
     `reproduce/config/pipeline/LOCAL.mk.in` (the user actually edits a
     `LOCAL.mk` file that is created by `configure` from the `.mk.in` file,
     but the `.mk` file is not under version control). So open this file
     and replace `SURVEY` in the variable name and value with the name of
     your input survey or dataset (all in capital letters), for example if
     you are working on data from the XDF survey, replace `SURVEY` with
     `XDF`. Don't change anything else in the value, just the the all-caps
     name. Afterwards, change any occurrence of `SURVEY` in the whole
     pipeline with the new name. You can find the occurrences with a simple
     command like the ones shown below. We follow the Make convention here
     that all `ONLY-CAPITAL` variables are those directly set by the user
     and all `small-caps` variables are set by the pipeline designer. All
     variables that also depend on this survey have a `survey` in their
     name. Hence, also correct all these occurrences to your new name in
     small-caps. Of course, ignore those occurrences that are irrelevant,
     like those in this file. Note that in the raw version of this template
     no target depends on these files, so they are ignored. Afterwards, set
     the webpage and correct the filenames in
     `reproduce/src/make/download.mk` if necessary.

     ```shell
     $ grep -r SURVEY ./
     $ grep -r survey ./
     ```

 - **Other input datasets**: Add any other input datasets that may be
     necessary for your research to the pipeline based on the example
     above.

 - **Delete `README.md`**: This `README.md` is designed for this template,
     not your reproduction pipeline. So to avoid later confusion, delete it
     from your own repository. You may want to keep a copy outside for the
     notes and discussions below until you are sufficiently familiar with
     it and don't need it any more.

 - **Initiate a new Git repo**: You probably don't want to mix the history
     of this template reproduction pipeline with your own reproduction
     pipeline. You have already made some small changes in the previous
     step, so let's re-initiate history before continuing. But before doing
     that, keep the output of `git describe` in a place and write it in
     your first commit message to document what point in this pipeline's
     history you started from. Since the pipeline is highly integrated with
     your particular research, it may not be easy to merge the changes
     later. Having the commit information that you started from, will allow
     you to check and manually apply any changes that don't interfere with
     your implemented pipeline. After this step, you can commit your
     changes into your newly initiated history as you like.

     ```shell
     $ git describe          # The point in this history you started from.
     $ git clean -fxd        # Remove any possibly created extra files.
     $ rm -rf .git           # Completely remove this history.
     $ git init              # Initiate a new history.
     $ git add --all         # Stage everything that is here.
     $ git commit            # Make your first commit (mention the first output).
     $ git tag -a v0         # Tag this as the zero-th version of your pipeline.
     ```

 - **Start your exciting research**: You are now ready to add flesh and
     blood to this raw skeleton by further modifying and adding your
     exciting research steps. You can use the "published works" section in
     the introduction as some fully working models to learn from.

 - **Feedback**: As you use the pipeline you will notice many things that
     if implemented from the start would have been very useful for your
     work. This can be in the actual file structure of the pipeline or in
     useful implementation and usage tips like below. In any case, since
     this concept is still evolving, please share your thoughts and
     suggestions, so we can add them here for everyone's benefit.





Tips on expanding this template (designing your pipeline)
=========================================================

The following is a list of design points, tips, or recommendations that
have been learned after some experience with this pipeline. Please don't
hesitate to share any experience you gain after using this pipeline with
us. In this way, we can add it here for the benefit of others.

 - **Modularity**: Modularity is the key to easy and clean growth of a
     project. So it is always best to break up a job into as many
     sub-components as reasonable. Here are some tips to stay modular.

   - *Short recipes*: if you see the recipe of a rule becoming more than a
      handful of lines which involve significant processing, it is probably
      a good sign that you should break up the rule into its main
      components. Try to only have one major processing step per rule.

   - *Context-based (many) Makefiles*: This pipeline is designed to allow
      the easy inclusion of many Makefiles (in `reproduce/src/make/*.mk`)
      for maximal modularity. So keep the rules for closely related parts
      of the processing in separate Makefiles.

   - *Descriptive names*: Be very clear and descriptive with the naming of
      the files and the variables because a few months after the
      processing, it will be very hard to remember what each one was
      for. Also this helps others (your collaborators or other people
      reading the pipeline after it is published) to more easily understand
      your work and find their way around.

   - *Naming convention*: As the project grows, following a single standard
      or convention in naming the files is very useful. Try best to use
      multiple word filenames for anything that is non-trivial (separating
      the words with a `-`). For example if you have a Makefile for
      creating a catalog and another two for processing it under models A
      and B, you can name them like this: `catalog-create.mk`,
      `catalog-model-a.mk` and `catalog-model-b.mk`. In this way, when
      listing the contents of `reproduce/src/make` to see all the
      Makefiles, those related to the catalog will all be close to each
      other and thus easily found. This also helps in auto-completions by
      the shell or text editors like Emacs.

   - *Source directories*: If you need to add files in other languages for
      example in shell, Python, AWK or C, keep them in a separate directory
      under `reproduce/src`, with the appropriate name.

   - *Configuration files*: If your research uses special programs as part
      of the processing, put all their configuration files in a devoted
      directory (with the program's name) within
      `reproduce/config`. Similar to the `reproduce/config/gnuastro`
      directory (which is put in the template as a demo in case you use GNU
      Astronomy Utilities). It is much cleaner and readable (thus less
      buggy) to avoid mixing the configuration files, even if there is no
      technical necessity.


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
      writing the pipeline it is very tempting to just steam ahead with
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
        $ info make "automatic variables
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
      needed by the pipeline (in the last rule that needs it). Below is a
      simple demonstration of doing this, where we use Gnuastro's
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
     to define a wrapper in `reproduce/src/make/initialize.mk`. This
     wrapper will replace `$(subst .txt,,XXXXX)`. Therefore, it will be
     possible to greatly simplify this repetitive statement and make the
     code even more readable throughout the whole pipeline.


 - **Dependencies**: It is critically important to exactly document, keep
   and check the versions of the programs you are using in the pipeline.

   - *Check versions*: In `reproduce/src/make/initialize.mk`, check the
      versions of the programs you are using.

   - *Keep the source tarball of dependencies*: keep a tarball of the
      necessary version of all your dependencies (and also a copy of the
      higher-level libraries they depend on). Software evolves very fast
      and only in a few years, a feature might be changed or removed from
      the mainstream version or the software server might go down. To be
      safe, keep a copy of the tarballs. Software tarballs are rarely over
      a few megabytes, very insignificant compared to the data. If you
      intend to release the pipeline in a place like Zenodo, then you can
      create your submission early (before public release) and upload/keep
      all the necessary tarballs (and data)
      there. [zenodo.1163746](https://doi.org/10.5281/zenodo.1163746) is
      one example of how the data, Gnuastro (main software used) and all
      major Gnuastro's dependencies have been uploaded with the pipeline.

   - *Keep your input data*: The input data is also critical to the
      pipeline, so like the above for software, make sure you have a backup
      of them

 - **Version control**: It is important (and extremely useful) to have the
   history of your pipeline under version control. So try to make commits
   regularly (after any meaningful change/step/result), while not
   forgetting the following notes.

   - *Tags*: To help manage the history, tag all major commits. This helps
      make a more human-friendly output of `git describe`: for example
      `v1-4-gaafdb04` states that we are on commit `aafdb04` which is 4
      commits after tag `v1`. The output of `git describe` is included in
      your final PDF as part of this pipeline. Also, if you use
      reproducibility-friendly software like Gnuastro, this value will also
      be included in all output files, see the description of `COMMIT` in
      [Output
      headers](https://www.gnu.org/software/gnuastro/manual/html_node/Output-headers.html).
      In the checklist above, we tagged the first commit of your pipeline
      with `v0`. Here is one suggestion on when to tag: when you have fully
      adopted the pipeline and have got the first (initial) results, you
      can make a `v1` tag. Subsequently when you first start reporting the
      results to your colleagues, you can tag the commit as `v2`. Afterwards
      when you submit to a paper, it can be tagged `v3` and so on.





Appendix: Necessity of exact reproduction in scientific research
================================================================

In case [the link above](http://akhlaghi.org/reproducible-science.html) is
not accessible at the time of reading, here is a copy of the introduction
of that link, describing the necessity for a reproduction pipeline like
this (copied on February 7th, 2018):

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