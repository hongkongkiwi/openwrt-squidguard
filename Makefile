#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/uclibc++.mk

PKG_NAME:=squidGuard
PKG_VERSION:=1.5-beta
PKG_RELEASE:=0

PKG_LICENSE:=GNU
PKG_MAINTAINER:=Andy Savage <andy@savage.hk>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.squidguard.org/Downloads/Devel/
PKG_MD5SUM:=85216992d14acb29d6f345608f21f268

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/squidguard/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  URL:=http://www.squidguard.org/
endef

define Package/squidguard
  $(call Package/squidGuard/Default)
  MENU:=1
  DEPENDS:=+libdb47 +squid +libpthread
  TITLE:=Combined filter, redirector and access controller plugin for Squid
endef

define Package/squidguard/description
SquidGuard is a URL redirector used to use blacklists with the 
proxysoftware Squid. There are two big advantages to squidguard: 
it is fast and it is free.
endef

CONFIGURE_ARGS += \
	--prefix=/usr \
	--libexecdir=/usr/lib/squidguard \
	--sysconfdir=/etc/squidguard \
	--localstatedir=/var/squidguard \
	--libdir=/usr/lib \
	--datarootdir=/usr/share/squidguard \
	--datadir=/usr/share/squidguard \
	--infodir=/usr/lib/squidguard/info \	
	--with-db=$(STAGING_DIR)/usr \
	--with-sg-config=/etc/squidguard/squidguard.conf \
	--with-sg-logdir=DIR \
	--with-sg-dbhome=DIR \
	--with-squiduser=squid

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" all
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" install
endef

define Package/squidguard/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/squid $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/usr/lib/squid
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/squid/ssl_crtd $(1)/usr/lib/squid

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/squid.config $(1)/etc/config/squid

	$(INSTALL_DIR) $(1)/etc/squid
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/squid/mime.conf $(1)/etc/squid/
	$(INSTALL_CONF) ./files/squid.conf $(1)/etc/squid/

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/squid.init $(1)/etc/init.d/squid

	$(INSTALL_DIR) $(1)/usr/share/squid/icons/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/squid/icons/* $(1)/usr/share/squid/icons/

	$(INSTALL_DIR) $(1)/usr/share/squid/errors/templates/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/squid/errors/templates/* $(1)/usr/share/squid/errors/templates/
endef

$(eval $(call BuildPackage,squidguard))
