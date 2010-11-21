#!/usr/bin/env python
# coding: UTF-8
"""
Copyright (c) 2008-2009 Michael Kuhn
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

from dbus.mainloop.glib import DBusGMainLoop
import dbus
import gobject

class Bot:
	def __init__ (self):
		DBusGMainLoop(set_as_default=True)

		self.loop = gobject.MainLoop()

		proxy = dbus.SessionBus().get_object("de.ikkoku.sushi", "/de/ikkoku/sushi")

		self.sushi = dbus.Interface(proxy, "de.ikkoku.sushi")

		self.sushi.connect_to_signal("message", self.message)

	def run (self):
		self.loop.run()

	def message (self, time, server, from_str, channel, message):
		nick = from_str.split("!")[0]

		if message == "!sushi":
			self.sushi.message(server, channel, "%s: http://sushi.ikkoku.de/" % (nick))
		elif message == "!quit":
			self.sushi.shutdown("")
			self.loop.quit()

Bot().run()
