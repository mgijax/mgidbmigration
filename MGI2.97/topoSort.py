#!/usr/local/bin/python

# $Header$
# $Name$

#
# Program: topoSort.py
#
# Original Author: Geoff Davis, Lori Corbani
#
# Purpose:
#
# 	Classes to read/write GXD Anatomical Dictionary
#
# Requirements Satisfied by This Program:
#
# Usage:
#
# Envvars:
#
# Inputs:
#
# Outputs:
#
# Exit Codes:
#
# Assumes:
#
# Bugs:
#
# Implementation:
#
#    Modules:
#
# Modification History:
#
# 05/07/2003	lec
#	- TR 3432; originally mgihome/admin/gen_anatdictionary
#

import sys		# standard Python libraries
import os
import string
import db
import mgi_utils
 
## globals 

# a list of all the stage records from GXD_TheilerStage
stages = []

# a dictionary of lists of structures, each list keyed by parent key
structures = {} 

## Class definitions

class Structure:
	'''
	# A building block of stage trees
	'''
	extent = {}	 # a mapping from structure keys to structures

	def __init__(self,name,stgn,depth):
		'''
		# requires:
		#    name: Name of this structure (string).
		#    stgn: Stage number (integer). 
		#    depth: Depth of this node in the hierarchy (integer). Depth 0
		#           is the depth of a Stage node. 
		#
		# effects: constructor
		# modifies: all instance variables. 
		# returns: nothing 
		# exceptions: none
		'''
		self.name = name 
		self.stagenum = stgn
		self.depth = depth
		self.parent = None
		self.edinburghKey = None 
		self.mgiKey = None
		self.children = []
		self.printName = None
		self.GOName = None

	def setName(self, name):
		'''
		# requires: 
		#    name: name of this Structure
		# effects: sets the Name for self.
		# modifies: self.name
		# returns: nothing
		# exceptions: none
		'''
		self.name = name

	def getName(self):
		'''
		# requires: nothing
		# effects: returns the name of self. 
		# modifies: nothing
		# returns: self.name
		# exceptions: none
		'''
		return self.name

	def setPrintName(self, printName):
		'''
		# requires: 
		#    printName: printName of this Structure
		# effects: sets the printName for self.
		# modifies: self.printName
		# returns: nothing
		# exceptions: none
		'''
		self.printName = printName

	def getPrintName(self):
		'''
		# requires: nothing
		# effects: returns the printName of self. 
		# modifies: nothing
		# returns: self.printName
		# exceptions: none
		'''
		return self.printName

	def setGOName(self, printName):
		'''
		# requires: 
		#    printName: printName of this Structure
		# effects: sets the GOName for self.
		# modifies: self.GOName
		# returns: nothing
		# exceptions: none
		'''
		# split printName into a list
		l = string.split(printName, ';')
		# reverse the list
		l.reverse()
		# put it back together later with '\' delimiter
		# string.join(l, '\\,')

		if self.getParent() == None:
			goName = 'TS%d\,' % (self.getStageNum())
		else:
			goName = '< TS%d\,' % (self.getStageNum()) + string.join(l, '\\,')

			if self.getEBKey() != None:
				goName = goName + '; EMAP:%s' % (mgi_utils.prvalue(self.getEBKey()))

		self.GOName = goName

	def getGOName(self):
		'''
		# requires: nothing
		# effects: returns the GOName of self. 
		# modifies: nothing
		# returns: self.GOName
		# exceptions: none
		'''
		return self.GOName

	def getStageNum(self):
		'''
		# requires: nothing
		# effects: returns stage number of self.
		# modifies: nothing
		# returns: stage number of self (integer)
		# exceptions: none
		'''
		return self.stagenum

	def setMgiKey(self,key):
		'''
		# requires: 
		#    key: MGI key assigned to this Structure. 
		# effects: sets the MGI key for self.
		#	adds mapping to Structure.extent
		# modifies: self.mgiKey
		# returns: nothing
		# exceptions: none
		'''
		if Structure.extent.has_key( self.mgiKey ):
			del Structure.extent[ self.mgiKey ]
		self.mgiKey = key 
		Structure.extent[ self.mgiKey ] = self

	def getMgiKey(self):
		'''
		# requires: nothing
		# effects: returns the MGI key for self
		# modifies: nothing
		# returns: MGI key for self (integer)
		# exceptions: none 
		'''
		return self.mgiKey

	def setEBKey(self,key):
		'''
		# requires: 
		#    key: EB key assigned to this Structure. 
		# effects: sets the EB key for self.
		# modifies: self.edinburghKey
		# returns: nothing
		# exceptions: none
		'''
		self.edinburghKey = key 

	def getEBKey(self):
		'''
		# requires: nothing
		# effects: returns the EB key for self
		# modifies: nothing
		# returns: EB key for self (integer)
		# exceptions: none 
		'''
		return self.edinburghKey

	def addChild(self,child):
		'''
		# requires: 
		#   child: A Structure object.
		# effects: Adds 'child' as a child node of self and sets child's
		#          parent to be self. 
		# modifies: self.children
		# returns: nothing 
		# exceptions: none
		'''
		child.setParent(self)
		self.children.append(child)

	def getChildren(self):	
		'''
		# requires: nothing
		# effects: returns a list of children for self
		# modifies: nothing
		# returns: a list of Structures
		# exceptions: none
		'''
		return self.children

	def setParent(self,parent):
		'''
		# requires: 
		#   parent: Structure object.
		# effects: sets parent structure for self
		# modifies: self.parent
		# returns: nothing
		# exceptions: none
		'''
		self.parent = parent

	def getParent(self):
		'''
		# requires: nothing 
		# effects: returns parent structure for self
		# modifies: nothing
		# returns: a parent structure
		# exceptions: none
		'''
		return self.parent

	def getDepth(self):
		'''
		# requires: nothing
		# effects: returns depth of this structure in the hiearchy.
		# modifies: nothing
		# returns: integer depth
		# exceptions: none
		'''
		return self.depth 

def print_GOstructure_tree(snode, fd, indent):
	'''
	# requires: 
	#   snode: Structure node
	#   fd: the output file descriptor
	#   indent (string) characters used to indent nodes at greater depth
	# effects: recursively prints a text rep of the node snode, and its descendants,
	#	   in GO format
	# modifies: nothing
	# returns: nothing
	# exceptions: none
	#
	# Note: Doesn't attempt to sort the siblings according to anything but
	# a straight alpha-numeric sort.  
	'''

	snode.setGOName(snode.getPrintName())
	name = snode.getGOName()
	depth = snode.getDepth()

	# only print structure if it is a root node or has an edinburgh key
	if snode.getEBKey() != None or snode.getParent() == None:
		fd.write('%s%s\n' % (depth * indent , name))

	children = {}

	for child in snode.getChildren():
		children[child.getName()] = child

	childnames = children.keys()

	# note: we need to be more sophistocated about sorting.
	childnames.sort()

	for childname in childnames:
		print_GOstructure_tree(children[childname], fd, indent)

## functions

def structure_parser(t):
	'''
	# requires: 
	#        t['structure']: structure name (string)
	#        t['_Structure_key']: mgi structure key (integer)
	#        t['stage']: stage number (integer)
	#        t['treeDepth']: depth of structure (integer >= 1)
	#             (Stage nodes are at depth 0)
	#        t['edinburghKey']: Edinburgh identifier (integer) or None.
	#        t['_Parent_key']: Parent key of structure or None.
	#        t['printName']: Print Name of structure (string) or None.
	#        (global) structures: a dictionary object
	#
	# effects: receives tuples from a Sybase query of the GXD_Structure
	#          tables. 
	# modifies: structures 
	# returns: nothing 
	# exceptions: none
	'''
	global structures

	s = Structure(t['structure'],t['stage'],t['treeDepth'])

	s.setMgiKey(t['_Structure_key'])
	s.setEBKey(t['edinburghKey'])
	s.setPrintName(t['printName'])

	pkey = t['_Parent_key']
	
	if not structures.has_key(pkey):
		structures[pkey] = []

	structures[pkey].append(s)

def addChildren(s):
	'''
	# requires: 
	#    s: Structure object
	#    (global) structures: a dictionary of lists of Structure objects, keyed 
	#               by _Parent_key. 
	# effects: adds all children of s to s, then deletes these children from
	#          'structures'.
	# modifies: structures 
	# returns: nothing
	# exceptions: none
	'''
	global structures	

	mgikey = s.getMgiKey()

	if structures.has_key(mgikey):  # i.e., if a node has children
		children = structures[mgikey]

		del(structures[mgikey])

		for child in children:
			s.addChild(child)
			addChildren(child)

def build_tree():
	'''
	# requires: 
	#    (global) structures: a dictionary of lists of Structure objects, keyed 
	#               by _Parent_key. 
	# effects: builds a structure tree from the Structures held in the
	#          global 'structures' dictionary.  If no structures exist,
	#          prints an error message and exits with status code 0.
	# modifies: structures 
	# returns: a Structure object that is the root of a structure tree. 
	# exceptions: none
	'''
	global structures

	if len(structures.keys()) == 0:
		sys.stderr.write('No structures available for this stage\n')
		sys.exit(0)

	toplevelnodes = structures[None]
	stageNum = toplevelnodes[0].getStageNum()
	if len(toplevelnodes) > 1:
		sys.stderr.write( "ERROR: multiple top level nodes for stage %d\n" % stageNum )
		sys.exit(-1)

	del(structures[None])

	stagen = toplevelnodes[0]
	addChildren(stagen)

	return stagen

def clear():
	'''
	# requires: nothing
	# effects: clears global index structures so that we can load the next stage
	# modifies:
	#	structures
	#	Structure.extent
	# returns: nothing
	# exceptions: none
	'''
	global structures

	structures = {}
	Structure.extent = {}

def doOneStage(stagenum):
	'''
	# requires:
	#	stagenum (string) the stage to load/print
	# effects: 
	#	Loads the hierarchy for the specified stage
	# modifies:
	#	structures
	#	Structure.extent
	# returns: a Structure object that is the root of a structure tree. 
	# exceptions: none
	'''

	# query the db for Structure information

	cmd = '''select gs.*, gsn.structure, ts.stage
		 from GXD_Structure gs, GXD_StructureName gsn, GXD_TheilerStage ts
		 where gs._Stage_key = ts._Stage_key
			 and gs._StructureName_key = gsn._StructureName_key
		 and ts.stage = %s
	      ''' % stagenum

	db.sql(cmd,structure_parser)

	return(build_tree())

def doOneWIStage(stagenum, fd, indent):
	'''
	# requires:
	#	stagenum (string) the stage to load/print
	#	fd (file descriptor) the output file
	#	indent (string) characters used to indent nodes at greater depth
	# effects: 
	#	Loads the hierarchy for the specified stage and writes it to the global output file
	# modifies:
	#	structures
	#	Structure.extent
	# returns: nothing
	# exceptions:
	#	Dies with an error message if the output file cannot 
	#	be opened for writing
	'''

	print_WIstructure_tree(doOneStage(stagenum), fd, indent)

def doOneGOStage(stagenum, fd, indent):
	'''
	# requires:
	#	stagenum (string) the stage to load/print
	#	fd (file descriptor) the output file
	#	indent (string) characters used to indent nodes at greater depth
	# effects: 
	#	Loads the hierarchy for the specified stage and writes it to the global output file
	# modifies:
	#	structures
	#	Structure.extent
	# returns: nothing
	# exceptions:
	#	Dies with an error message if the output file cannot 
	#	be opened for writing
	'''

	print_GOstructure_tree(doOneStage(stagenum), fd, indent)

def doOneTopoStage(stagenum, fd):

	set_topoSort_byNode(doOneStage(stagenum), fd)

def set_topoSort_byNode(snode, fd):
	'''
	# requires: 
	#   snode: Structure node
	# effects: recursively updates the topoSort value or each snode and its descendents
	# modifies: nothing
	# returns: nothing
	# exceptions: none
	'''

	global topoSort

	fd.write('/* TS:%d:%s */\n' % (snode.getStageNum(), snode.getPrintName()))
	fd.write('update GXD_Structure set topoSort = %d ' % (topoSort) + \
	    'where _Structure_key = %d ' % (snode.getMgiKey()) + '\ngo\n\n')

	topoSort = topoSort + 1

	children = {}

	for child in snode.getChildren():
		children[child.getName()] = child

	childnames = children.keys()

	# note: we need to be more sophistocated about sorting.
	childnames.sort()

	for childname in childnames:
		set_topoSort_byNode(children[childname], fd)

def getStageDefs():
	'''
	# requires: nothing
	# effects: loads all the records from GXD_TheilerStage
	# modifies: stages
	# returns: nothing
	# exceptions: none
	'''
	global stages
	cmd = '''
		select _Stage_key, stage, description
		from GXD_TheilerStage
		order by stage
		'''
	stages = db.sql(cmd , 'auto')

def set_topoSort():

	fd = open('topoSort.csh', 'w')

	header = '''#!/bin/csh -f

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
  
cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go
'''

	footer = '''

checkpoint
go

quit

EOSQL

date >> $LOG
'''

	fd.write(header)

	getStageDefs()
	for stageRec in stages:
		doOneTopoStage(stageRec['_Stage_key'], fd)
		clear()

	fd.write(footer)
	fd.close()

## Main ##

topoSort = 1
set_topoSort()

