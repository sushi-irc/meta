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
git archive --prefix="${sushi_release}/" "${release}" | tar xf -

for component in maki tekka nigiri plugins
do
	(
		cd "${component}"

		git checkout "${branch}"
		git tag "${release}"
		git archive --prefix="${sushi_release}/${component}/" "${release}" | tar xCf .. -

		git checkout master
	)
done

# Deduplicate waf
for component in maki tekka nigiri plugins
do
	(
		cd "${sushi_release}/${component}"

		rm -f waf
		ln -s ../waf waf
	)
done

git checkout master

tar cf "${sushi_release}.tar" "${sushi_release}"
bzip2 -k "${sushi_release}.tar"
gzip "${sushi_release}.tar"
