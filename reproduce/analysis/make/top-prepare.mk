# Do basic preparations to optimize the project's running.
#
# NOTE: This file is very similar to `top-make.mk', so the large comments
# are not included here. Please see that file for thorough comments on each
# step.
#
# Copyright (C) 2019-2020 Mohammad Akhlaghi <mohammad@akhlaghi.org>
#
# This Makefile is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# This Makefile is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.





# Load the local configuration (created after running
# `./project configure').
include reproduce/software/config/installation/LOCAL.conf





# Ultimate target of this project
# -------------------------------
#
# See `top-make.mk' for complete explanation.
ifeq (x$(reproducible_paper_group_name),x$(GROUP-NAME))
all: $(BDIR)/software/preparation-done.mk
	@echo "";
	echo "----------------"
	echo "Project preparation has been completed without any errors."
	echo ""
	echo "Please run the following command to start building the project."
	echo "(Replace '8' with the number of CPU threads on your system)"
	echo ""
	if [ "x$(GROUP-NAME)" = x ]; then \
	  echo "   $$ ./project make"; \
	else \
	  echo "   $$ ./project make --group=$(GROUP-NAME) -j8"; \
	fi
	echo ""
else
all:
	@if [ "x$(GROUP-NAME)" = x ]; then \
	  echo "Project is NOT configured for groups, please run"; \
	  echo "   $$ ./project prepare"; \
	else \
	  echo "Project is configured for groups, please run"; \
	  echo "   $$ ./project prepare --group=$(GROUP-NAME) -j8"; \
	fi
endif





# Define source Makefiles
# -----------------------
#
# See `top-make.mk' for complete explanation.
#
# To ensure that `prepare' and `make' have the same basic definitions and
# environment and that all `downloads' are managed in one place, both
# `./project prepare' and `./project make' will first read `initialize.mk'
# and `downloads.mk'.
makesrc = initialize \
          download \
          prepare





# Include all analysis Makefiles
# ------------------------------
#
# See `top-make.mk' for complete explanation.
project-phase = prepare
include reproduce/analysis/config/*.conf
include $(foreach s,$(makesrc), reproduce/analysis/make/$(s).mk)
