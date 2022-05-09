# Build the project's Xorg dependencies.
#
# ------------------------------------------------------------------------
#                      !!!!! IMPORTANT NOTES !!!!!
#
# This Makefile will be loaded into 'high-level.mk', which is called by the
# './project configure' script. It is not included into the project
# afterwards.
#
# This Makefile contains instructions to build all the Xorg-related
# software within the project. The build instructions here are taken from
# Linux From Scratch:
#     http://www.linuxfromscratch.org/blfs/view/svn/x/xorg7.html
#
# ------------------------------------------------------------------------
#
# Copyright (C) 2021-2022 Mohammad Akhlaghi <mohammad@akhlaghi.org>
# Copyright (C) 2021-2022 Raul Infante-Sainz <infantesainz@gmail.com>
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





# Environment variables
export XORG_PREFIX=$(idir)

# Common configuration options for all Xorg programs
export XORG_CONFIG = --disable-static --prefix=$(XORG_PREFIX) \
                     --sysconfdir=$(idir)/etc --localstatedir=$(idir)/var





# This is the basic Xorg configuration script. Note that '$(idir)/etc' was
# built in 'basic.mk'.
$(idir)/etc/profile.d:; mkdir
$(idir)/etc/profile.d/xorg.sh: | $(idir)/etc/profile.d
	echo "export XORG_PREFIX=\"$(XORG_PREFIX)\""  > $@
	echo "export XORG_CONFIG=\"$(XORG_CONFIG)\"" >> $@
	chmod 644 $@

# A set of m4 macros used in all Xorg packages.
$(ibidir)/util-macros-$(util-macros-version): \
                      $(idir)/etc/profile.d/xorg.sh \
                      $(ibidir)/automake-$(automake-version)
	tarball=util-macros-$(util-macros-version).tar.lz
	$(call import-source, $(util-macros-url), $(util-macros-checksum))
	$(call gbuild, util-macros-$(util-macros-version),,$(XORG_CONFIG),V=1)
	echo "util-macros (Xorg) $(util-macros-version)" > $@

# Necessaary headers to define the Xorg protocols.
$(ibidir)/xorgproto-$(xorgproto-version): \
                    $(ibidir)/util-macros-$(util-macros-version)
	tarball=xorgproto-$(xorgproto-version).tar.lz
	$(call import-source, $(xorg-proto-url), $(xorgproto-checksum))
	$(call gbuild, xorgproto-$(xorgproto-version),,$(XORG_CONFIG),V=1)
	echo "xorgproto $(xorgproto-version)" > $@

# Necessaary headers to define the Xorg protocols.
$(ibidir)/libxau-$(libxau-version): $(ibidir)/xorgproto-$(xorgproto-version)
	tarball=libXau-$(libxau-version).tar.lz
	$(call import-source, $(libaxu-url), $(libxau-checksum))
	$(call gbuild, libXau-$(libxau-version),,$(XORG_CONFIG), V=1)
	echo "libXau (Xorg) $(libxau-version)" > $@

# Library implementing the X Display Manager Control Protocol.
$(ibidir)/libxdmcp-$(libxdmcp-version): $(ibidir)/libxau-$(libxau-version)
	tarball=libXdmcp-$(libxdmcp-version).tar.bz2
	$(call import-source, $(libxdmcp-url), $(libxdmcp-checksum))
	$(call gbuild, libXdmcp-$(libxdmcp-version),,$(XORG_CONFIG), V=1)
	echo "libXdmcp (Xorg) $(libxdmcp-version)" > $@

# XML-XCB protocol descriptions
$(ibidir)/xcb-proto-$(xcb-proto-version): \
                    $(ibidir)/python-$(python-version) \
                    $(ibidir)/libxml2-$(libxml2-version)
	tarball=xcb-proto-$(xcb-proto-version).tar.lz
	$(call import-source, $(xcb-proto-url), $(xcb-proto-checksum))
	$(call gbuild, xcb-proto-$(xcb-proto-version),,$(XORG_CONFIG), V=1)
	echo "XCB-proto (Xorg) $(xcb-proto-version)" > $@

# Interface to the X Window System protocol, replaces current Xlib interface.
$(ibidir)/libxcb-$(libxcb-version): \
                 $(ibidir)/libxdmcp-$(libxdmcp-version) \
                 $(ibidir)/xcb-proto-$(xcb-proto-version) \
                 $(ibidir)/libpthread-stubs-$(libpthread-stubs-version)
	tarball=libxcb-$(libxcb-version).tar.lz
	$(call import-source, $(libxcb-url), $(libxcb-checksum))
	$(call gbuild, libxcb-$(libxcb-version),, \
	               $(XORG_CONFIG) --without-doxygen, \
	               V=1 -j$(numthreads))
	echo "libxcb (Xorg) $(libxcb-version)" > $@

$(ibidir)/libpthread-stubs-$(libpthread-stubs-version): \
                      $(ibidir)/automake-$(automake-version)
	tarball=libpthread-stubs-$(libpthread-stubs-version).tar.lz
	$(call import-source, $(libpthread-stubs-url), $(libpthread-stubs-checksum))
	$(call gbuild, libpthread-stubs-$(libpthread-stubs-version),, V=1)
	echo "libpthread-stubs (Xorg) $(libpthread-stubs-version)" > $@

# Library for configuring fonts, it needs util-linux for libuuid.
$(ibidir)/fontconfig-$(fontconfig-version): \
                     $(ibidir)/gperf-$(gperf-version) \
                     $(ibidir)/expat-$(expat-version) \
                     $(ibidir)/python-$(python-version) \
                     $(ibidir)/libxml2-$(libxml2-version) \
                     $(ibidir)/freetype-$(freetype-version) \
                     $(ibidir)/util-linux-$(util-linux-version)
#	Import the source.
	tarball=fontconfig-$(fontconfig-version).tar.lz
	$(call import-source, $(fontconfig-url), $(fontconfig-checksum))

#	Add the extra environment variables for using 'libuuid' of
#	'util-linux'.
	ulidir=$(idir)/util-linux
	export LDFLAGS="-L$$ulidir/lib $(LDFLAGS)"
	export CPPFLAGS="-I$$ulidir/include $(CPPFLAGS)"
	export PKG_CONFIG_PATH=$(PKG_CONFIG_PATH):$$ulidir/lib/pkgconfig

#	Build it.
	$(call gbuild, fontconfig-$(fontconfig-version),, \
	               $(XORG_CONFIG) --sysconfdir=$(idir)/etc \
	               --disable-docs, V=1 -j$(numthreads))
	echo "Fontconfig $(fontconfig-version)" > $@

$(ibidir)/xtrans-$(xtrans-version): \
                 $(ibidir)/libxcb-$(libxcb-version) \
                 $(ibidir)/fontconfig-$(fontconfig-version)
	tarball=xtrans-$(xtrans-version).tar.lz
	$(call import-source, $(xtrans-url), $(xtrans-checksum))
	$(call gbuild, xtrans-$(xtrans-version),,$(XORG_CONFIG), V=1)
	echo "xtrans (Xorg) $(xtrans-version)" > $@

$(ibidir)/libx11-$(libx11-version): $(ibidir)/xtrans-$(xtrans-version)
	tarball=libX11-$(libx11-version).tar.lz
	$(call import-source, $(libx11-url), $(libx11-checksum))
	$(call gbuild, libX11-$(libx11-version),,$(XORG_CONFIG), \
	               -j$(numthreads) V=1)
	echo "X11 library $(libx11-version)" > $@

$(ibidir)/libxext-$(libxext-version): $(ibidir)/libx11-$(libx11-version)
	tarball=libXext-$(libxext-version).tar.lz
	$(call import-source, $(libxext-url), $(libxext-checksum))
	$(call gbuild, libXext-$(libxext-version),,$(XORG_CONFIG), \
	               -j$(numthreads) V=1)
	echo "libXext $(libxext-version)" > $@

$(ibidir)/libice-$(libice-version): $(ibidir)/libxext-$(libxext-version)
	tarball=libICE-$(libice-version).tar.lz
	$(call import-source, $(libice-url), $(libice-checksum))
	$(call gbuild, libICE-$(libice-version),, \
	               $(XORG_CONFIG) ICE_LIBS=-lpthread, \
	               -j$(numthreads) V=1)
	echo "libICE $(libice-version)" > $@

$(ibidir)/libsm-$(libsm-version): $(ibidir)/libice-$(libice-version)
	tarball=libSM-$(libsm-version).tar.lz
	$(call import-source, $(libsm-url), $(libsm-checksum))
	$(call gbuild, libSM-$(libsm-version),, \
	               $(XORG_CONFIG), -j$(numthreads) V=1)
	echo "libSM $(libsm-version)" > $@

$(ibidir)/libxt-$(libxt-version): $(ibidir)/libsm-$(libsm-version)
	tarball=libXt-$(libxt-version).tar.lz
	$(call import-source, $(libxt-url), $(libxt-checksum))
	$(call gbuild, libXt-$(libxt-version),, \
	               $(XORG_CONFIG), -j$(numthreads) V=1)
	echo "libXt $(libxt-version)" > $@
