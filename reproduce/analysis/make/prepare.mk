# Basic preparations, called by `./project prepare'.
#
# Copyright (C) 2019 Mohammad Akhlaghi <mohammad@akhlaghi.org>
#
# This Makefile is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# This Makefile is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details. See <http://www.gnu.org/licenses/>.





# Final-target
#
# Without this file, `./project make' won't work.
$(BDIR)/software/preparation-done.txt:

        # If you need to add preparations define targets above to do the
        # preparations. Recall that before this file, `top-prepare.mk'
        # loads `initialize.mk' and `download.mk', so you can safely assume
        # everything that is defined there in this Makefile.
        #
        # TIP: the targets can actually be automatically generated
        # Makefiles that are used by `./project make'. They can include
        # variables, or actual rules. Just make sure that those Makefiles
        # aren't written in the source directory! Even though they are
        # Makefiles, they are automatically built, so they should be
        # somewhere under $(BDIR).
	@touch $@
