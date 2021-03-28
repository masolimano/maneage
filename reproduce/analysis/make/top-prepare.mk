# Do basic preparations to optimize the project's running.
#
# NOTE: This file is very similar to `top-make.mk', so the large comments
# are not included here. Please see that file for thorough comments on each
# step.
#
# Copyright (C) 2019-2021 Mohammad Akhlaghi <mohammad@akhlaghi.org>
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





# Load the local configuration (created after running
# `./project configure').
include reproduce/software/config/LOCAL.conf





# Ultimate target of this project
# -------------------------------
#
# See `top-make.mk' for complete explanation.
ifeq (x$(maneage_group_name),x$(GROUP-NAME))
all: $(BDIR)/software/preparation-done.mk
	@echo "Project preparation is complete.";
else
all:
	@if [ "x$(GROUP-NAME)" = x ]; then \
	  echo "Project is NOT configured for groups, please run"; \
	  echo "   $$ ./project prepare"; \
	else \
	  echo "Project is configured for groups, please run"; \
	  echo "   $$ ./project prepare --group=$(GROUP-NAME) -j8"; \
	fi
	exit 1
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
