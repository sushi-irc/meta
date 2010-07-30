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
	echo "Usage: ${0##*/} repository-path path"
	exit 1
}

opt_ppa=""

test "$1" = "--ppa" && shift && opt_ppa="true"

test -z "$1" && usage
test -z "$2" && usage

repository_path="$1"
path="$2"

temp="$(mktemp -d)"
date="$(date '+%Y%m%d')"
sushi_release="sushi-${date}"

rm -fv "${temp}/${sushi_release}.tar" "${temp}/${sushi_release}.tar.bz2" "${temp}/${sushi_release}.tar.gz"

GIT_DIR="${repository_path}/suite" \
	git archive --prefix="${sushi_release}/" master | tar xCf "${temp}" -

for component in maki tekka nigiri plugins
do
	GIT_DIR="${repository_path}/${component}" \
		git archive --prefix="${sushi_release}/${component}/" master | tar xCf "${temp}" -
done

# Deduplicate waf
for component in maki tekka nigiri plugins
do
	(cd "${temp}/${sushi_release}/${component}" && rm -f waf && ln -s ../waf waf)
done

tar cCf "${temp}" "${temp}/${sushi_release}.tar" "${sushi_release}"
bzip2 -k "${temp}/${sushi_release}.tar"
gzip "${temp}/${sushi_release}.tar"

find "${path}/" -type f -mtime +7 -print -delete
mv -v "${temp}/${sushi_release}.tar.bz2" "${temp}/${sushi_release}.tar.gz" "${path}/"
rm -rf "${temp}"

if [ -n "${opt_ppa}" ]
then
	directory="${0%/*}"

	# FIXME Do not hardcode version
	"${directory}/ppa-deb.sh" "${path}/${sushi_release}.tar.bz2" "1.3.0~git${date}" karmic
	"${directory}/ppa-deb.sh" "${path}/${sushi_release}.tar.bz2" "1.3.0~git${date}" lucid
	"${directory}/ppa-deb.sh" "${path}/${sushi_release}.tar.bz2" "1.3.0~git${date}" maverick
fi