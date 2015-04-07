################################################################################
#
# wsapi
#
################################################################################

WSAPI_FCGI_VERSION = 1.6.1-1
WSAPI_FCGI_LICENSE = MIT
WSAPI_DEPENDENCIES = libfcgi
WSAPI_FCGI_SITE = http://www.luarocks.org/repositories/rocks
WSAPI_FCGI_SOURCE = wsapi-fcgi-$(WSAPI_FCGI_VERSION).src.rock
WSAPI_FCGI_SUBDIR = wsapi-$(shell echo "$(WSAPI_FCGI_VERSION)" | sed -e "s/-[0-9]$$//")

$(eval $(luarocks-package))
