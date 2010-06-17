#!/bin/sh

# This script is run by Xcode during the build phase to generate information about
# the build in C header file format.  When run it produces a file which is included by main.m.
# Copy and paste this file into into Xcodes script window.

# for finding Fossil
PATH=$PATH:/usr/local/bin

OF=XXXX-Tempfile.h
echo '// *** This file is automatically generated - do not edit ***' >${OF}
echo 'char buildinfo[]=' >>${OF}
printf '"Unique identifier identifying the source code\\n"\n' >> ${OF}
printf '" used to generate this build of %s:\\n"\n' "$PRODUCT_NAME">>${OF}
if test -f ../manifest.uuid 
 then 
printf '"%s\\n"\n'  `cat ../manifest.uuid` >>${OF}
 fi
printf '"\\n"\n' >>${OF}
printf '"Built on: %s\\n\\n"\n' "`date`" >> ${OF}
printf '"   === Version control status ===\\n"\n' >>${OF}
lines=0
fossil status  | \
	while read i
		do	
			printf '"%s\\n"\n' "$i"
		done  >> ${OF}
if expr `fossil status | wc -l` '!=' 6
	then 
		echo ERROR files not checked into Fossil
		exit 1
	fi
	
		
printf '"\\n"\n' >>${OF}
printf '"Archs: %s\\n"\n' "${ARCHS}" >>${OF} 
printf '"Build Style: %s\\n"\n' "${BUILD_STYLE}" >>${OF}
printf '"Build Variants: %s\\n"\n' "${BUILD_VARIANTS}" >>${OF}
printf '"Debugging Symbols:%s\\n"\n' "${DEBUGGING_SYMBOLS}" >>${OF}
printf '"Debug Information Format: %s\\n"\n' "${DEBUG_INFORMATION_FORMAT}" >>${OF}
printf '"GCC Version: %s\\n"\n' "${GCC_VERSION}" >>${OF}
printf '"MacOSX Deployment Target: %s\\n"\n' "${MACOSX_DEPLOYMENT_TARGET}" >>${OF}
printf '"Build Machine OSX Version Actual: %s\\n"\n' "${MAC_OS_X_VERSION_ACTUAL}" >>${OF}
printf '"Build Machine OSX Version Major: %s\\n"\n' "${MAC_OS_X_VERSION_MAJOR}" >>${OF}
printf '"Build Machine OSX Version Minor: %s\\n"\n' "${MAC_OS_X_VERSION_MINOR}" >>${OF}
printf '"Product Name: %s\\n"\n' "${PRODUCT_NAME}" >>${OF}
printf '"SDK Root: %s\\n"\n' "${SDKROOT}" >>${OF}
printf '"SDK Name: %s\\n"\n' "${SDK_NAME}" >>${OF}
printf '"Xcode Version Actual: %s\\n"\n' "${XCODE_VERSION_ACTUAL}" >>${OF}
printf '"Xcode Version Major: %s\\n"\n' "${XCODE_VERSION_MAJOR}" >>${OF}
printf '"Xcode Version Minor: %s\\n"\n' "${XCODE_VERSION_MINOR}" >>${OF}
echo \; >>${OF}
