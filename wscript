#!/usr/bin/env python

APPNAME = 'sushi'
VERSION = '1.4.0'

top = '.'
out = 'build'

def options (ctx):
	ctx.recurse('maki')
	ctx.recurse('tekka')

def configure (ctx):
	ctx.recurse('maki')
	ctx.recurse('nigiri')
	ctx.recurse('plugins')
	ctx.recurse('tekka')

def build (ctx):
	ctx.recurse('maki')
	ctx.recurse('nigiri')
	ctx.recurse('plugins')
	ctx.recurse('tekka')
