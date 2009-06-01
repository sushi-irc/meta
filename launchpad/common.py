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

import os
import sys
import webbrowser

from xdg.BaseDirectory import xdg_config_home

from launchpadlib.launchpad import Launchpad, EDGE_SERVICE_ROOT
from launchpadlib.credentials import Credentials

EDGE_WEB_ROOT = 'https://edge.launchpad.net/'

def usage (arguments):
	print >> sys.stderr, 'Usage: %s %s' % (sys.argv[0], arguments)
	sys.exit(1)

def get_launchpad ():
	c = Credentials('sushi')
	p = os.path.join(xdg_config_home, 'sushi', 'launchpad')

	try:
		f = open(p, 'r')
		c.load(f)
		f.close()
	except:
		u = c.get_request_token(web_root=EDGE_WEB_ROOT)

		webbrowser.open(u)
		print '%s should have opened in your web browser.' % (u)
		print 'After you have authorized, please press Enter.'
		sys.stdin.readline()

		c.exchange_request_token_for_access_token(EDGE_WEB_ROOT)

		f = open(p, 'w')
		c.save(f)
		f.close()

	l = Launchpad(c, EDGE_SERVICE_ROOT)

	return l
