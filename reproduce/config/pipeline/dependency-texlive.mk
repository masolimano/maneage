# Necessary packages to install in TeX Live.
#
# If any extra TeX package is necessary to build your paper, just add its
# name to this variable (you can check in `ctan.org' to find the official
# name).
#
# Note on `tex' and `fancyhdr': These two packages are installed along with
# the basic installation scheme that we used to install tlmgr, they will be
# ignored in the `tlmgr install' command, but will be used later when we
# want their versions.
texlive-packages = tex fancyhdr ec newtx fontaxes xkeyval etoolbox xcolor \
                   setspace caption footmisc datetime fmtcount titlesec   \
                   preprint ulem biblatex biber logreq pgf pgfplots fp    \
                   courier tex-gyre txfonts times
