Directory containing LaTeX-related files
----------------------------------------

Copyright (C) 2018-2020 Mohammad Akhlaghi <mohammad@akhlaghi.org>\
See the end of the file for license conditions.

This directory contains directories to various components the LaTeX part of
the project. In a running project, it will contain the atleast the
following sub-directories. Note that

- The `src/` directory contains the LaTeX files that are loaded into
  `paper.tex`. This includes the necessary preambles, the LaTeX source
  files to build tables or figures (for example with TiKZ or PGFPlots), and
  etc.  These files are under version-control and an integral part of the
  project's source.

- The `build/` directory contains all the built products (not source!) that
  are created during the analysis and are necessary for building the
  paper. This includes figures, plots, images, table source contents and
  etc. Note that this directory is not under version control.

- The `tikz/` directory is only relevant if some of the project's figures
  are built with the LaTeX packages of TiKZ or PGFPlots. It points to the
  directory containing the figures (in PDF) that were built by these tools.
  Note that this directory is not under version control.

The latter two directory and its contents are not under version control, so
if you have just cloned the project or are viewing its contents on a
browser, they don't exist. They will be created after the project is
configured for the running system.

When the full project is build from scratch (building the software,
downloading necessary datasets, running the analysis and building the
paper's PDF), the latter two directories will be symbolic links to special
places under the Build directory.

However, when the distributed tarball is used to only build the PDF paper
(without doing any analysis), the latter two directories will not be
symbolic links and will contain the necessary components for the paper to
be built.





### Copyright information

This file is part of Maneage. Maneage is free software: you can
redistribute it and/or modify it under the terms of the GNU General Public
License as published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.

Maneage is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
details. See <http://www.gnu.org/licenses/>.
