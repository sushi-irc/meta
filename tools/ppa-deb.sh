#!/bin/sh

# Copyright (c) 2010 Michael Kuhn
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

set -e

usage ()
{
	echo "Usage: ${0##*/} tarball version distribution"
	exit 1
}

test -z "$1" && usage
test -z "$2" && usage
test -z "$3" && usage

tarball="$1"
version="$2"
distribution="$3"

temp="$(mktemp -d)"
directory="$(tar tf "${tarball}" | head -n 1)"
directory="${directory%/}"
upstream_version="${version%%-*}"
suffix="${tarball#*.}"

cp "${tarball}" "${temp}/sushi_${upstream_version}.orig.${suffix}"
tar xCf "${temp}" "${tarball}"
cp -a "${temp}/${directory}/tools/packaging/debian" "${temp}/${directory}"

(
	cd "${temp}/${directory}"

	# Hack
	if [ "${distribution}" = "jaunty" ]
	then
		sed -i "/ libgupnp-igd-1.0-dev,$/d" debian/control
	fi

	dch -v "${version}" -D "${distribution}" "PPA package for ${distribution}."
	dpkg-buildpackage -S -sa -nc
)

echo
echo dput ppa:sushi.maintainers/development-version "${temp}/*.changes"
echo rm -rf "${temp}"
