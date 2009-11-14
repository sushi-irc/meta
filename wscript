#!/usr/bin/env python

APPNAME = 'sushi'
VERSION = '1.1.0'

srcdir = '.'
blddir = 'build'

def configure (conf):
	conf.sub_config('maki')

def build (bld):
	bld.add_subdirs('maki')
