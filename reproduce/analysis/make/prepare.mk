# Basic preparations, called by `./project prepare'.
#
# Copyright (C) 2019-2020 Mohammad Akhlaghi <mohammad@akhlaghi.org>
#
# This Makefile is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This Makefile is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this Makefile.  If not, see <http://www.gnu.org/licenses/>.





# Final-target
#
# Without this file, `./project make' won't work.
prepare-dep = $(subst prepare, ,$(makesrc))
$(BDIR)/software/preparation-done.mk: \
                $(foreach s, $(prepare-dep), $(mtexdir)/$(s).tex)

        # If you need to add preparations define targets above to do the
        # preparations, then set the value below to `yes'. Recall that just
        # like `./project make', before loading this file, `./project
        # prepare' loads loads `initialize.mk' and `download.mk', so you
        # can safely assume everything that is defined there in the
        # preparation phase also.
        #
        # TIP: the targets can actually be automatically generated
        # Makefiles that are used by `./project make'. They can include
        # variables, or automatically generated rules. Just make sure that
        # those Makefiles aren't written in the source directory. Even
        # though they are Makefiles, they are automatically built, so they
        # don't belong in the source. `$(prepdir)' has been defined for
        # this purpose (see `initialize.mk'), we recommend that you put all
        # automatically generated Makefiles under this directory. In the
        # `make' phase, `initialize.mk' will automatically load all the
        # `*.mk' files. If you need to load your generated
        # configuration-makefiles before automatically generated Makefiles
        # containing rules, you can use some naming convension like
        # `conf-*.mk' and `rule-*.mk', or you can put them in
        # subdirectories.
	@echo "include-prepare-results = no" > $@
