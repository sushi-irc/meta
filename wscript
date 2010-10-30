#!/usr/bin/env python

APPNAME = 'sushi'
VERSION = '1.4.0'

srcdir = '.'
blddir = 'build'

def set_options (ctx):
	ctx.sub_options('tekka')

def configure (conf):
	conf.sub_config('maki')
	conf.sub_config('nigiri')
	conf.sub_config('plugins')
	conf.sub_config('tekka')

def build (bld):
	bld.add_subdirs('maki')
	bld.add_subdirs('nigiri')
	bld.add_subdirs('plugins')
	bld.add_subdirs('tekka')
