#!/bin/sh

# Copyright (c) 2008-2009 Michael Kuhn
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

bump_version ()
{
	file="$1"
	version="$2"

	sed -i "/VERSION = /s/^.*$/VERSION = '${version}'/" "${file}"
}

usage ()
{
	echo "Usage: ${0##*/} [branch] release"
	exit 1
}

test -z "$1" && usage

if [ ! -f ./tools/release.sh ]
then
	echo 'Not in top-level directory.'
	exit 1
fi

if [ $# -lt 2 ]
then
	branch='master'
	release="$1"
else
	branch="$1"
	release="$2"
fi

sushi_release="sushi-${release}"

rm -fv "${sushi_release}.tar" "${sushi_release}.tar.bz2" "${sushi_release}.tar.gz"

git checkout "${branch}"
git tag "${release}"
git archive --prefix="${sushi_release}/" "${release}" > "${sushi_release}.tar"

for component in maki tekka nigiri plugins
do
	component_release="${component}-${release}"

	cd "../${component}"

	git checkout "${branch}"
	git tag "${release}"
	git archive --prefix="${sushi_release}/${component}/" "${release}" > "../suite/${component_release}.tar"

	bump_version wscript "${release}"

	git checkout master

	cd ../suite

	tar Avf "${sushi_release}.tar" "${component_release}.tar"
	rm -fv "${component_release}.tar"
done

git checkout master

bzip2 -k "${sushi_release}.tar"
gzip "${sushi_release}.tar"
