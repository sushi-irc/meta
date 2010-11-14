#!/usr/bin/env python

APPNAME = 'sushi'
VERSION = '1.4.0'

top = '.'
out = 'build'

def options (ctx):
	ctx.recurse('maki')
	ctx.recurse('tekka')

def configure (conf):
	conf.recurse('maki')
	conf.recurse('nigiri')
	conf.recurse('plugins')
	conf.recurse('tekka')

def build (bld):
	bld.recurse('maki')
	bld.recurse('nigiri')
	bld.recurse('plugins')
	bld.recurse('tekka')
