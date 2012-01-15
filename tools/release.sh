#!/bin/sh

# Copyright (c) 2008-2010 Michael Kuhn
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
	echo "Usage: ${0##*/} [branch] release"
	exit 1
}

tag_release ()
{
	tag="$1"

	if echo "${tag}" | grep '^[0-9]\+\.[0-9]\+\.[0-9]\+$' > /dev/null
	then
		git tag "${tag}"
	fi
}

test $# -lt 1 && usage

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

rm -f "${sushi_release}.tar" "${sushi_release}.tar.xz" "${sushi_release}.tar.bz2" "${sushi_release}.tar.gz"
rm -f "${sushi_release}+dfsg.tar" "${sushi_release}+dfsg.tar.xz" "${sushi_release}+dfsg.tar.bz2" "${sushi_release}+dfsg.tar.gz"
rm -fr "${sushi_release}"

git checkout "${branch}"
tag_release "${release}"
git archive --prefix="${sushi_release}/" "${branch}" | tar xf -

for component in maki tekka nigiri chirashi
do
	(
		cd "${component}"

		git checkout "${branch}"
		tag_release "${release}"
		git archive --prefix="${sushi_release}/${component}/" "${branch}" | tar xCf .. -

		git checkout master
	)
done

git checkout master

# Deduplicate Waf
for component in maki tekka nigiri chirashi
do
	(
		cd "${sushi_release}/${component}"

		rm -f waf
		ln -s ../waf
	)
done

tar cf "${sushi_release}.tar" "${sushi_release}"
xz -k "${sushi_release}.tar"
bzip2 -k "${sushi_release}.tar"
gzip "${sushi_release}.tar"

### Debian

rm -fr "${sushi_release}/maki/documentation/irc"

# Unpack Waf (http://wiki.debian.org/UnpackWaf)
(
	cd "${sushi_release}"

	./waf --help > /dev/null
	mv .waf-*/waflib waflib
	rmdir .waf-*
	find waflib -name '*.pyc' -delete
	sed -i '/^#==>$/,$d' waf
)

# Link waflib
for component in maki tekka nigiri chirashi
do
	(
		cd "${sushi_release}/${component}"

		ln -s ../waflib
	)
done

tar cf "${sushi_release}+dfsg.tar" "${sushi_release}"
xz -k "${sushi_release}+dfsg.tar"
bzip2 -k "${sushi_release}+dfsg.tar"
gzip "${sushi_release}+dfsg.tar"
