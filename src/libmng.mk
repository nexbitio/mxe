# This file is part of MXE.
# See index.html for further information.

PKG             := libmng
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.0.3
$(PKG)_CHECKSUM := 0f141482ffcef6f8cd4413f945a59310ac2e49af
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := http://$(SOURCEFORGE_MIRROR)/project/$(PKG)/$(PKG)-devel/$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc zlib jpeg lcms

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://sourceforge.net/projects/libmng/files/libmng-devel/' | \
    $(SED) -n 's,.*/\([0-9][^"]*\)/".*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    echo 'Requires: zlib lcms2 jpeg' >> '$(1)/libmng.pc.in'
    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS)
    $(MAKE) -C '$(1)' -j '$(JOBS)' install
endef
