#!/bin/sh
# Build openempi .deb
MAINTAINER="Ryan Yates"
NAME="openempi"
DEPENDS="postgresql,tomcat7"
URL="http://www.openempi.org"
DESCRIPTION="Open Enterprise Master Patient Index"
OPENEMPI_FILENAME=openempi-entity-3.0.0-openempi-entity.tar.gz
OPENEMPI_SHA1="0e95ce0bda340859b76a3dfb0f3d801739b506ae"

download (){
curl "http://www.openempi.org/openempi-downloads/file_download/?username=odysseas@sysnetint.com&filename=$OPENEMPI_FILENAME" -o $OPENEMPI_FILENAME
}

extract (){
echo "extracting..."
tar zxf $OPENEMPI_FILENAME
}

checksum (){
	file_hash=`sha1sum $OPENEMPI_FILENAME | cut -d " " -f 1`
	if [ "$file_hash" = "$OPENEMPI_SHA1" ];
	then
		echo "Checksum verified."
		return 0
	else
		echo "Checksum failedi. Please remove $OPENEMPI_FILENAME and try again..."
		exit 1
	fi
}

package (){
	fpm -s dir\
        -t deb\
        -m "$MAINTAINER"\
        -n "$NAME"\
        -v 3.0.0\
        -d $DEPENDS\
        --url "$URL"\
        --description "$DESCRIPTION"\
        --after-install debian/postinst\
        ./openempi-entity-3.0.0/=/opt/openempi/ ./openempi-entity-3.0.0/openempi-entity-webapp-web-3.0.0.war=/var/lib/tomcat7/webapps/openempi-admin.war ./config/mpi-config.xml=/opt/openempi/conf/mpi-config.xml
}

# Main
# is fpm installed
command -v fpm >/dev/null 2>&1 || { echo "fpm not found, please install fpm.  Aborting." >&2; exit 1; }

if [ -e $OPENEMPI_FILENAME ];
then
	checksum
	extract
	package
else
	download
	checksum
	extract
	package
fi


