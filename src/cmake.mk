# This file is part of MXE.
# See index.html for further information.

PKG             := cmake
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3.0.2
$(PKG)_CHECKSUM := 379472e3578902a1d6f8b68a9987773151d6f21a
$(PKG)_SUBDIR   := cmake-$($(PKG)_VERSION)
$(PKG)_FILE     := cmake-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := http://www.cmake.org/files/v$(call SHORT_PKG_VERSION,$(PKG))/$($(PKG)_FILE)
$(PKG)_DEPS     :=

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://www.cmake.org/cmake/resources/software.html' | \
    $(SED) -n 's,.*cmake-\([0-9.]*\)\.tar.*,\1,p' | \
    $(SORT) -V | \
    tail -1
endef

define $(PKG)_BUILD_$(BUILD)
    mkdir '$(1).build'
    cd    '$(1).build' && '$(1)/configure' \
        --prefix='$(PREFIX)/$(TARGET)'
    $(MAKE) -C '$(1).build' -j '$(JOBS)'
    $(MAKE) -C '$(1).build' -j 1 install
endef
