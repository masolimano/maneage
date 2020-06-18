# Generic configurable recipes to build packages with GNU Build system or
# CMake. This is Makefile is not intended to be run directly, it will be
# imported into 'basic.mk' and 'high-level.mk'. They should be activated
# with Make's 'Call' function.
#
# Copyright (C) 2018-2020 Mohammad Akhlaghi <mohammad@akhlaghi.org>
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





# Import/download project's source
# --------------------------------
#
# Copy/Download the raw tarball into an '.unchecked' suffix. Then calculate
# its checksum and if it is correct, remove the extra suffix.
#
# Arguments:
#   1: The optional URL to use for this tarball.
#   2: The expeced checksum of the tarball.
#
# Necessary shell variables
#   'tarball': This is the name of the actual tarball file without a
#   directory.
import-source = final=$(tdir)/$$tarball; \
	url=$(strip $(1)); \
	exp_checksum="$(strip $(2))"; \
	if [ -f $$final ]; then \
	  echo "$(tdir)/$$tarball: already present in project."; \
	else \
	  unchecked="$$final.unchecked"; \
	  rm -f "$$unchecked"; \
	  if [ -f $(DEPENDENCIES-DIR)/$$tarball ]; then \
	    cp $(DEPENDENCIES-DIR)/$$tarball "$$unchecked"; \
	  else \
	    if [ x"$$url" = x ]; then \
	      bservers="$(backupservers)"; \
	      tarballurl=$(topbackupserver)/$$tarball; \
	    else \
	      bservers="$(backupservers_all)"; \
	      tarballurl=$$url/$$tarball; \
	    fi; \
	    if [ -f $(ibdir)/wget ]; then \
	      downloader="wget --no-use-server-timestamps -O"; \
	    else \
	      downloader="$(DOWNLOADER)"; \
	    fi; \
	    touch $(lockdir)/download; \
	    $(downloadwrapper) "$$downloader" $(lockdir)/download \
	                       $$tarballurl "$$unchecked" "$$bservers"; \
	  fi; \
	  if [ x"$$exp_checksum" = x"NO-CHECK-SUM" ]; then \
	    mv "$$unchecked" "$$final"; \
	  else \
	    if type sha512sum > /dev/null 2>/dev/null; then \
	      checksum=$$(sha512sum "$$unchecked" | awk '{print $$1}'); \
	      if [ x"$$checksum" = x"$$exp_checksum" ]; then \
	        mv "$$unchecked" "$$final"; \
	      else \
	        echo "ERROR: Non-matching checksum for '$$tarball'."; \
	        echo "Checksum should be: $$exp_checksum"; \
	        echo "Checksum is:        $$checksum"; \
	        exit 1; \
	      fi; \
	    else mv "$$unchecked" "$$final"; \
	    fi; \
	  fi; \
	fi





# Unpack a tarball
# ----------------
#
# Unpack a tarball in the current directory. The issue is that until we
# install GNU Tar within Maneage, we have to use the host's Tar
# implementation and in some cases, they don't recognize '.lz'.
uncompress = csuffix=$$(echo $$utarball \
	                     | sed -e's/\./ /g' \
	                     | awk '{print $$NF}'); \
	if [ x$$csuffix = xlz ]; then \
	  intarrm=1; \
	  intar=$$(echo $$utarball | sed -e's/.lz//'); \
	  lzip -c -d $$utarball > $$intar; \
	else \
	  intarrm=0; \
	  intar=$$utarball; \
	fi; \
	if tar xf $$intar; then \
	  if [ x$$intarrm = x1 ]; then rm $$intar; fi; \
	else \
	  echo; echo "Tar error"; exit 1; \
	fi






# GNU Build system
# ----------------
#
# Arguments:
#  1: Directory name after unpacking.
#  2: Set to 'static' for a static build.
#  3: Extra configuration options.
#  4: Extra options/arguments to pass to Make.
#  5: Step to run between 'make' and 'make install': usually 'make check'.
#  6: The configuration script ('configure' by default).
#  7: Arguments for 'make install'.
#
# NOTE: Unfortunately the configure script of 'zlib' doesn't recognize
# 'SHELL'. So we'll have to remove it from the call to the configure
# script.
#
# NOTE: A program might not contain any configure script. In this case,
# we'll just pass a non-relevant function like 'pwd'. So SED should be used
# to modify 'confscript' or to set 'configop'.
gbuild = if [ x$(static_build) = xyes ] && [ "x$(2)" = xstatic ]; then \
	   export LDFLAGS="$$LDFLAGS -static"; \
	 fi; \
	 check="$(5)"; \
	 if [ x"$$check" = x ]; then check="echo Skipping-check"; fi; \
	 cd $(ddir); \
	 rm -rf $(1); \
	 if [ x"$$gbuild_tar" = x ]; then utarball=$(tdir)/$$tarball; \
	 else                             utarball=$$gbuild_tar;      \
	 fi; \
	 $(call uncompress); \
	 cd $(1); \
	          \
	 if   [ x"$(strip $(6))" = x ]; then confscript=./configure; \
	 else confscript="$(strip $(6))"; \
	 fi; \
	     \
	 if   [ -f $(ibdir)/bash ]; then \
	   if [ -f "$$confscript" ]; then \
	     sed -e's|\#\! /bin/sh|\#\! $(ibdir)/bash|' \
	         -e's|\#\!/bin/sh|\#\! $(ibdir)/bash|' \
	         $$confscript > $$confscript-tmp; \
	     mv $$confscript-tmp $$confscript; \
	     chmod +x $$confscript; \
	   fi; \
	   shellop="SHELL=$(ibdir)/bash"; \
	 elif [ -f /bin/bash ]; then shellop="SHELL=/bin/bash"; \
	 else shellop="SHELL=/bin/sh"; \
	 fi; \
	     \
	 if [ -f "$$confscript" ]; then \
	   if [ x"$(strip $(1))" = x"zlib-$(zlib-version)" ]; then \
	     configop="--prefix=$(idir)"; \
	   else configop="$$shellop --prefix=$(idir)"; \
	   fi; \
	 fi; \
	     \
	 echo; echo "Using '$$confscript' to configure:"; echo; \
	 echo "$$confscript $(3) $$configop"; echo; \
	 if [ x$$configure_in_different_directory = x1 ]; then \
	   mkdir build; \
	   cd build; \
	   ../$$confscript $(3) $$configop; \
	   make "$$shellop" $(4); \
	   $$check; \
	   make "$$shellop" install $(7); \
	   cd ../..; \
	 else \
	   $$confscript $(3) $$configop; \
	   make "$$shellop" $(4); \
	   $$check; \
	   make "$$shellop" install $(7); \
	   cd ..; \
	 fi; \
	 rm -rf $(1)




# CMake
# -----
#
# According to the link below, in CMake '/bin/sh' is hardcoded, so there is
# no way to change it unfortunately!
#
# https://stackoverflow.com/questions/21167014/how-to-set-shell-variable-in-makefiles-generated-by-cmake
cbuild = if [ x$(static_build) = xyes ] && [ $(2)x = staticx ]; then \
	   export LDFLAGS="$$LDFLAGS -static"; \
	   opts="-DBUILD_SHARED_LIBS=OFF"; \
	 fi; \
	 cd $(ddir); \
	 rm -rf $(1); \
	 utarball=$(tdir)/$$tarball; \
	 $(call uncompress); \
	 cd $(1); \
	 rm -rf project-build; \
	 mkdir project-build; \
	 cd project-build; \
	 cmake .. -DCMAKE_LIBRARY_PATH=$(ildir) \
	          -DCMAKE_INSTALL_PREFIX=$(idir) \
	          -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON $$opts $(3); \
	 make; \
	 make install; \
	 cd ../..; \
	 rm -rf $(1)
