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
	echo "Usage: ${0##*/} version"
	exit 1
}

test -n "$1" || usage

version="$1"

test -f waf || usage

INSTALL_PATH="${PWD}/install"

rm --force "waf-${version}"
wget --output-document "waf-${version}" "https://waf.io/waf-${version}"

mv "waf-${version}" waf
chmod +x waf

git add waf
git commit -e -m "Update Waf to version ${version}."

for component in chirashi maki nigiri tekka
do
	(
		cd "${component}"

		cp ../waf .

		git add waf
		git commit -e -m "Update Waf to version ${version}."
	)
done

for component in chirashi maki nigiri tekka
do
	(
		local options

		options=''
		test "${component}" = 'maki' && options='--debug'

		cd "${component}"

		./waf distclean
		./waf configure --prefix="${INSTALL_PATH}" ${options}
		./waf clean
		./waf install
	)
done
