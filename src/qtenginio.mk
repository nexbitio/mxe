# This file is part of MXE.
# See index.html for further information.

PKG             := qtenginio
$(PKG)_IGNORE   :=
$(PKG)_VERSION   = $(qtbase_VERSION)
$(PKG)_CHECKSUM := 14b961bea8cf2f2d4510283d6120038dbf90d29d
$(PKG)_SUBDIR    = $(subst qtbase,qtenginio,$(qtbase_SUBDIR))
$(PKG)_FILE      = $(subst qtbase,qtenginio,$(qtbase_FILE))
$(PKG)_URL       = $(subst qtbase,qtenginio,$(qtbase_URL))
$(PKG)_DEPS     := gcc qtbase

define $(PKG)_UPDATE
    echo $(qtbase_VERSION)
endef

define $(PKG)_BUILD
    # invoke qmake with removed debug options as a workaround for
    # https://bugreports.qt-project.org/browse/QTBUG-30898
    cd '$(1)' && '$(PREFIX)/$(TARGET)/qt5/bin/qmake' CONFIG-='debug debug_and_release'
    $(MAKE) -C '$(1)' -j '$(JOBS)'
    $(MAKE) -C '$(1)' -j 1 install
endef
