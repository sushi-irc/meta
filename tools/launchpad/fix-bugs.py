#!/usr/bin/env python
# coding: UTF-8
"""
Copyright (c) 2009 Michael Kuhn
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE.
"""

import getopt
import sys

from xdg.BaseDirectory import xdg_config_home

from common import *

def fix_bugs (group, milestone, force=False):
	for p in group.projects:
		for m in p.all_milestones:
			if m.name != milestone:
				continue

			print '%s' % (m.title)

			for t in m.searchTasks():
				print '  %s' % (t.title)

				if force:
					t.status = 'Fix Released'
					t.lp_save()

			if force:
				m.is_active = False
				m.lp_save()

try:
	opts, args = getopt.getopt(sys.argv[1:], 'f', ['force'])
except:
	usage('[-f|--force] milestone')

if len(args) != 1:
	usage('[-f|--force] milestone')

l = get_launchpad()
s = l.project_groups['sushi']

force = ('-f', '') in opts or ('--force', '') in opts

fix_bugs(s, args[0], force)
