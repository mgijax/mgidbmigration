#!/usr/local/bin/python
#   read in acedb classes from an acedb file
# $Source$
# $Author$
# $Date$
# $Revision$
# $Log$
##################################################
import sys
import os
import string, regex, regsub
"""
This module defines a package of python classes for loading and looking at
the contents of a ACEDB database exported as a text file.

An ACEDB exported text file is organized into ACEDB classes:
    // Class Foo

    <lines for rcd 1 in Foo>

    <lines for rcd 2 in Foo>

    <lines for rcd 3 in Foo>

    ...

    <blank line ending the class>
    // Class Blah
    ...

There seem to be at least 3 types of ACEDB classes that differ in the format
of their records. The only type we deal with currently  are records that
consist of a list of "tag and value-tuples". These look like:

    Foo : "rcd name"
    Tag1 val1 val2 ... valn
    Tag2 val1 val2 ... valm
    etc.
    <blank line>

The tags can be repeated:
    Tag1 "some value" ...
    Tag1 "some other value" ...

Tag names can be the name of another acedb class. The first value of such a tag
appears to be the name of a record from that acedb class. (this appears to be
how one record references another in a different acedb class)
(actually, it also appears that tags that are not the name of a class can have
values that are the names of objects in some acedb class, for instance,
"Positive_tissue".)

A tag can have an empty list of values.
Values appear to be (unquoted) numbers, dates, words, or double quoted (")
strings.

(the other two types of ACEDB classes that I know about are LongText and
DNA, sometime we should add code to handle those)

This module provides the following python classes:

    AcedbFile
	- lets you load specific classes from the file and will return
	  an AcedbClass object of a given Acedb class name that has been loaded
    
    AcedbClass
	- can iterate through the records of the class or get a specific
	   record by name (i.e. rcdkey)
    
    AcedbRcd
	- represents an individual tag and value-tuple record in a class
	- can iterate of the different tag names in the rcd
	- can iterate over the different value-tuples for a specific tag
	- can get the first value-tuple for a specific tag
    
    AcedbValSeq
	- represents a list of value-tuples for a tag from an AcedbRcd
	- can iterate of the list
	- can append a value-tuple to the list
    AcedbHitTbl
	- represents hits between two AcedbClasses
"""

#----------------------------------------------------------------------------

class AcedbFile:			# an ACEdb file
    # Concept:
    #  a AcedbFile represents text file exported from ACEDB
    #  When you construct an AcedbFile, you give it the filename,
    #   then you have operations like:
    #    loadAcedbClasses()
    #    gimmeClass( "name")
    #
    # Implementation:
    #  straightfoward representation using a dictionary mapping loaded class
    #     names to AcedbClass objects (one for each loaded class)

    def __init__ (self,
		  filename	# the name of the file
		  ):
        
	self.filename = filename
	self.classes = {}	# dictionary mapping loaded class names to
				#   AcedbClass objects
    # end __init__() 
    #----------------------------------------------------------------------
    
    def loadAcedbClasses (self,
			  classlist	# list or tuple of class names to load
			  ):
        # Purpose: Read the Acedb file and load the specified classes.
	#          If classlist is empty, then load all classes in the file.
	# Returns: string	- "" if loaded ok
	#			- "error msg" if some error

        try:		# open the file
            thefile = open( self.filename, "r", -1)
        except IOError :
            return  "Cannot open file '%s'\n" % self.filename

	if (len(classlist) == 0):	# no class names given
	    # compile regexp to match *any* // Class line
	    classfind_regex = regex.compile( " // Class \([a-zA-Z0-9_]*\)")
	else:
	    # compile regexp to match *only the selected* // Class lines
	    classfind_regex = regex.compile(
				" // Class \(" +
				    string.join(classlist,"\|") + "\)")

        try:		# read the lines
            curline = thefile.readline()
	    while (curline != ""):	# not eof
	        if ( classfind_regex.match( curline) != -1 ):
					    # found the start of a class that
					    #  we wish to load
	            classname = classfind_regex.group(1)
		    curclass = AcedbClass( classname)
		    curline = thefile.readline()	# skip blankline
		    curclass.load( thefile)
		    self.classes[ classname] = curclass

		curline = thefile.readline()
	    # end while
	    thefile.close()
        except IOError :
	    thefile.close()
            return  "Error reading file '%s'\n" % self.filename
	
	return ""
        
    # end loadAcedbClasses() 
    #----------------------------------------------------------------------

    def gimmeClass (self,
		  classname	# the name AcedbClass to return
		  ):
	# Purpose: return the AcedbClass whose name is 'classname' or
	#	   None if the class is not loaded from this AcedbFile.

	if self.classes.has_key( classname):
	    return self.classes[ classname]
	else:
	    return None
    # end gimmeClass() 
    #----------------------------------------------------------------------
    
# End class AcedbFile ------------------------------------------------------

class AcedbClass:
    # Concept:
    #  An AcedbClass is a collection of records of the same type from an
    #   Acedb file.
    #  For the moment, this only applies to classes whose records
    #   are a collection of tag and value-tuples.
    #  (there appear to be some other types of classes in ACEDB files, for
    #   instance the LongText class and the DNA class have different record
    #   formats -- This implementation of AcedbClass will not handle those)
    #  Can do things like:
    #    load a class (from a file)
    #    gimmeRecord( name) - get the record from the class whose key is name
    #    iterate over the records in the class
    # Implementation:
    #   dictionary mapping record keys to AcedbRcd objects (one for each record
    #    in the class.

    def __init__ (self,
		  name = ''	# the class name
		  ):
        # construct an empty AcedbClass object with the specified class name
        self.name = name
	self.rcds = {}		# empty dictionary of records, eventually
				#    indexed by record keys

	self.curRcdIndex = -1	# index of self.rcds.keys[] of the most
				#   recent rcd returned by the first() or
				#   next() methods.
				# I.e. this is the internal state variable
				#    of the first() - next() iterator methods

    # end __init__() 
    #----------------------------------------------------------------------

    def load (self,
	      fileptr		# the open file to read from
	      ):
        # Purpose: load the class from the open file specified by fileptr.
	# Assumes: The next line to read from the file is the first line of the
	#            first record in the class (or blank if the class is empty).
	#	   The class object itself is currently empty (has not been
	#	     loaded).
	# Effects: Reads all the lines of the file corresponding to the records
	#	     of the class and the blank line after the last record
	#	     and builds up the class representation to hold the read
	#	     records.
	#	   If the first line read is blank, we read that
	#	     line and assume the class has no records.

	#print "loading class", self.name
	rcdstart = regex.compile(self.name + ' : "\([^"]+\)"')
				# a regex that matches the
				#  first line of a new record in the class
				#  and assigns \1 the record key from the line

	firstline = fileptr.readline()
	while (rcdstart.match(firstline) != -1): # 1st line looks like the
						      #  start of a rcd
	    rcdkey = rcdstart.group(1)
	    currcd = AcedbRcd( rcdkey)
	    currcd.load( fileptr)
	    self.rcds[ rcdkey] = currcd

	    firstline = fileptr.readline()

    # end load() 
    #-----------------------------------------------------------------------

    def rcdKeyList (self
		  ):
	# Purpose: return a alphabetically sorted list of all the rcd keys
	#	     in this class.

	thelist = self.rcds.keys()
	thelist.sort()
	return thelist
    # end rcdKeyList() 
    #----------------------------------------------------------------------

    def gimmeRcd (self,
		  rcdname	# the name (key) of the rcd to return
		  ):
	# Purpose: return the AcedbRcd whose key is 'rcdname' or
	#	   None if there is no record in the class by that key. 

	if self.rcds.has_key( rcdname):
	    return self.rcds[ rcdname]
	else:
	    return None
    # end gimmeRcd() 
    #----------------------------------------------------------------------
    
    def first (self
	      ):
	# Purpose: Return the first record in the class or None if
	#	     the class has no records.
	#	   This method along w/ the next() method provide a
	#	     simple iterator abstraction. Note that the order
	#	     of the rcds returned is arbitrary but consistent.

	self.curRcdIndex = -1
	return self.next()
    # end first() 
    #----------------------------------------------------------------------
    
    def next (self
	      ):
	# Purpose: Return the next record in the class or None if the
	#		most recently returned rcd was the last one.
	#	   See first()

	self.curRcdIndex = self.curRcdIndex + 1
	if self.curRcdIndex < len(self.rcds.keys()):	# still more
	    return self.rcds[ self.rcds.keys()[ self.curRcdIndex]]
	else:	# none left
	    return None
    # end next() 
    #----------------------------------------------------------------------
    	
    def save (self,
	      fileptr		# the open file to write to
	      ):
        # Purpose: save the class to the open file specified by fileptr.
	# Assumes: nothing
	# Effects: see Purpose

	fileptr.write( "%s\n" % (self.name,))		# write class name
	fileptr.write( "%d\n" % (len(self.rcds),) )	# # of rcds

	for rcd in self.rcds.keys():			# for each rcd
	    fileptr.write( "%s\n" % (rcd,))		# write rcd key
	    self.rcds[rcd].save( fileptr)		# write the rcd
	    
	#end for

    # end save() 
    #-----------------------------------------------------------------------
    def restore (self,
	      fileptr		# the open file to read from
	      ):
        # Purpose: restore the class from the open file specified by fileptr.
	# Assumes: The file is one that was created by the save methods and
	#	   The next line to read from the file is the first line of the
	#            saved class.
	#	   The class object itself is currently empty (has not been
	#	     loaded).
	# Effects: Reads all the lines of the file corresponding to the class
	#		and ...

	self.name = fileptr.readline()[0:-1]		# read class name
	numrcds =   string.atoi( fileptr.readline())	# # of rcds

	for r in range( numrcds):			# for each rcd
	    rcd = fileptr.readline()[0:-1]		# read rcd key
	    newrcd = AcedbRcd( rcd)
	    newrcd.restore( fileptr)
	    self.rcds[rcd] = newrcd
	    
	#end for

    # end restore() 
    #-----------------------------------------------------------------------
    
# End class AcedbClass ------------------------------------------------------

class AcedbRcd:
    # Concept:
    #   An AcedbRcd is one record from a class in an Acedb file.
    #   (currently) a record is a collection of tag value-tuples.
    #   Can do operations like:
    #     load the record (from an Acedb file)
    #     iterate over the tags in the record
    #     iterate over the value-tuples for a specific tag in the record
    # Implementation:
    #   dictionary mapping tag names to a AcedbValSeq holding the list
    #	  of value-tuples for the tag.

    def __init__ (self,
		  rcdkey	# the key of the record (w/ the "'s stripped)
		  ):
        # construct an empty AcedbRcd object 
	self.rcdkey = rcdkey
	self.tags = {}		# empty dictionary of value lists,
				#    indexed by tag names

	self.curTagIndex = -1	# index of self.rcds.keys[] of the most
				#   recent tagname returned by the
				#   firstTagName() or nextTagName() methods.
				# I.e. this is the internal state variable
				#    of the first-next TagName iterator methods
    # end __init__() 
    #----------------------------------------------------------------------

    def load (self,
	      fileptr		# the open file to read from
	      ):
        # Purpose: load the tag-value lines for a record from the open file
	#		specified by fileptr.
	# Assumes: The next line to read from the file is the first line of
	#            tag-value lines (i.e. the record "header" line has already
	#		been read).
	#	   The record object itself is currently empty (has not been
	#	     loaded).
	# Effects: Reads all the lines of the file corresponding to the
	#	     tag-value lines of the record and the blank line ending
	#		them.
	#	     and builds up the record representation to hold the read
	#	     lines.
	#	   If the first line read is blank, we read that
	#	     line and assume the class has no tag-value lines.

	#print "loading record:", self.rcdkey
	curline = fileptr.readline()
	while (curline != "" and		# not eof (should not happen)
	       regex.match("^[ 	]*$", curline) == -1):
						# and not a blank line
	    words = string.split(curline, None, 1)
	    tagname = words[0]
	    if ( not self.tags.has_key( tagname)):	# have a new tag
		#print "found new tag", tagname
	        curvalseq = AcedbValSeq( tagname)
		self.tags[ tagname] = curvalseq
	    else:				# have a tag we've already seen
		#print "found existing tag", tagname
	        curvalseq = self.tags[ tagname]
	    
	    curvalseq.appendval( words[1])

	    curline = fileptr.readline()
	# end while
        
    # end load() 
    #-----------------------------------------------------------------------
    
    def gimmeTagValue (self,
		       tagname	# the tag whose value to return
	      ):
	# Purpose: Return the first value tuple for tag 'tagname'
	#           or None if there is no tag by that name in this rcd.
	#	   If this tag has multiple value tuples in this rcd,
	#	     one will be arbitrarily (but consistently) returned.
	# Assumes: AcedbValSeq is implemented by a list of tuples vals[]
	#	   (i.e. this is a "friend" of the AcedbValSeq class)

	if self.tags.has_key( tagname):		# tag is defined
	    return self.tags[ tagname].vals[0]
	else:					# tag not defined
	    return None
    # end gimmeTagValue() 
    #----------------------------------------------------------------------
    
    def firstTagValue (self,
		       tagname	# the tag name you want values for
	      ):
	# Purpose: Return the first value tuple for tag 'tagname'
	#           or None if there is no tag by that name in this rcd.
	#	   This method along w/ the next() method provide a
	#	     simple iterator abstraction. Note that the order
	#	     of the tuples returned is arbitrary but consistent.

	if self.tags.has_key( tagname):		# tag is defined
	    return self.tags[ tagname].first()
	else:					# tag not defined
	    return None
    # end firstTagValue() 
    #----------------------------------------------------------------------
    
    def nextTagValue (self,
		       tagname	# the tag name you want values for
	      ):
	# Purpose: Return the next value tuple for tag 'tagname'
	#               assocated w/ the rcd or None if
	#		most recently returned tuple was the last one.
	#	   See firstTagValue()

	if self.tags.has_key( tagname):		# tag is defined
	    return self.tags[ tagname].next()
	else:					# tag not defined
	    return None

    # end nextTagValue() 
    #----------------------------------------------------------------------
    
    def firstTagName (self
	      ):
	# Purpose: Return the first tagname associated w/ the rcd or None if
	#	     the rcd has no tag-value pairs associated w/ it.
	#	   This method along w/ the next() method provide a
	#	     simple iterator abstraction. Note that the order
	#	     of the tagnames returned is arbitrary but consistent.

	self.curTagIndex = -1
	return self.nextTagName()
    # end firstTagName() 
    #----------------------------------------------------------------------
    
    def nextTagName (self
	      ):
	# Purpose: Return the next tagname assocated w/ the rcd or None if
	#		most recently returned tagname was the last one.
	#	   See firstTagName()

	self.curTagIndex = self.curTagIndex + 1
	if self.curTagIndex < len(self.tags.keys()):	# still more
	    return self.tags.keys()[ self.curTagIndex]
	else:	# none left
	    return None
    # end nextTagName() 
    #----------------------------------------------------------------------
    
    def theText (self,
	      ):
        # Purpose: return text string representation of this record
	# Assumes: nothing
	# Effects: see Purpose

	Text = "%s\n" % (self.rcdkey,)

	taglist = self.tags.keys()
	taglist.sort()

	for tag in taglist:			# for each tag
	    tagval = self.tags[tag]
	    Text = Text + tagval.theText()
	#end for

	return Text

    # end theText() 
    #-----------------------------------------------------------------------
    
    def save (self,
	      fileptr		# the open file to write to
	      ):
        # Purpose: save the rcd to the open file specified by fileptr.
	# Assumes: nothing
	# Effects: see Purpose

	fileptr.write( "%s\n" % (self.rcdkey,))		# write rcd key
	fileptr.write( "%d\n" % (len(self.tags),) )	# # of tags

	for tag in self.tags.keys():			# for each tag
	    fileptr.write( "%s\n" % (tag,))		# write tag name
	    self.tags[tag].save( fileptr)		# write the vals
	    
	#end for

    # end save() 
    #-----------------------------------------------------------------------

    def restore (self,
	      fileptr		# the open file to read from
	      ):
        # Purpose: restore the class from the open file specified by fileptr.
	# Assumes: The file is one that was created by the save methods and
	#	   The next line to read from the file is the first line of the
	#            saved class.
	#	   The class object itself is currently empty (has not been
	#	     loaded).
	# Effects: Reads all the lines of the file corresponding to the class
	#		and ...

	self.rcdkey = fileptr.readline()[0:-1]		# read class name
	numtags =   string.atoi( fileptr.readline())	# # of rcds

	for t in range( numtags):			# for each rcd
	    tag = fileptr.readline()[0:-1]		# read rcd key
	    newval = AcedbValSeq( tag)
	    newval.restore( fileptr)
	    self.tags[tag] = newval
	    
	#end for

    # end restore() 
    #-----------------------------------------------------------------------
# End class AcedbRcd ------------------------------------------------------

class AcedbValSeq:
    # Concept:
    #   An AcedbValSeq is a sequence of value tuples for a specific tag in a
    #   record of an Acedb file.
    #   Can do operations like:
    #    append a new tuple to the sequence
    #    iterate over the sequence
    # Implementation:
    #   just a list of tuples
    # class AcedbRcd is a "friend" of this class

			# valparse is a regex that matches either a
			#   quoted (") string (possibly w/ embedded spaces),
			#   or just a word consisting of any non-white space
			#   characters.
			# it sets valparse.group(1) to the matched string.
    valparse = regex.compile('^[ 	]*\("[^"]*"\|[^" 	]+\)')

    def __init__ (self,
		  tagname	# the tag name this sequence of values is for
		  ):
        # construct an empty AcedbValSeq object 
	self.tagname = tagname
	self.vals = []	# empty list of value tuples
	self.curValIndex = -1	# index of self.vals[] of the most
				#   recent tuple returned by the first() or
				#   next() methods.
				# = -1 if first() has not been called
				# I.e. this is the internal state variable
				#    of the first() - next() iterator methods
    # end __init__() 
    #----------------------------------------------------------------------

    def appendval (self,
	           valstring	# string holding the values
	      ):
        # Purpose: Break the valstring into a tuple of values and 
	#           append a tuple of values to this ValSeq
	# Assumes: nothing
	# Effects: see purpose
	#
	# The values in valstring are individual "words" (in the unix sense)
	#    or quoted strings (which may have embedded spaces).
	#    the quotes are stripped off.

	valstring = string.rstrip( valstring)
	valtuple = []
	matchlen = AcedbValSeq.valparse.match( valstring)
	while ( matchlen != -1):	# still have a val
	    valtuple.append( rmquotes( AcedbValSeq.valparse.group(1)) )
	    valstring = valstring[ matchlen:]
	    matchlen = AcedbValSeq.valparse.match( valstring)
	# end while

	self.vals.append( tuple(valtuple))
	#print "appending",  valtuple
    # end appendval() 
    #-----------------------------------------------------------------------
    
    def first (self
	      ):
	# Purpose: Return the first value tuple in the sequence.
	#	   This method along w/ the next() method provide a
	#	     simple iterator abstraction.

	self.curValIndex = -1
	return self.next()
    # end first() 
    #----------------------------------------------------------------------
    
    def next (self
	      ):
	# Purpose: Return the next tuple in the class or None if the
	#		most recently returned tuple was the last one.
	#	   See first()

	self.curValIndex = self.curValIndex + 1
	if self.curValIndex < len(self.vals):	# still more
	    return self.vals[ self.curValIndex]
	else:	# none left
	    return None
    # end next() 
    #----------------------------------------------------------------------
    
    def theText (self
	      ):
	# Purpose: Return a text representation of this val sequence

	Text = ""
	for valtup in self.vals:
	    Text = Text + "%s = %s\n"  \
			    % (self.tagname, string.join( valtup," "))
	#end for
	return Text
    # end theText() 
    #----------------------------------------------------------------------
    
    def save (self,
	      fileptr		# the open file to write to
	      ):
        # Purpose: save the valseq to the open file specified by fileptr.
	# Assumes: nothing
	# Effects: see Purpose

	fileptr.write( "%s\n" % (self.tagname,))	# write tagname
	fileptr.write( "%d\n" % (len(self.vals),) )	# # of tuples

	for tup in self.vals:				# for each tuple
	    fileptr.write( "%d\n" % (len(tup),) )
	    for val in tup:
		fileptr.write( "%s\n" % (val,))		# write value
	    #end for
	    
	#end for

    # end save() 
    #-----------------------------------------------------------------------

    def restore (self,
	      fileptr		# the open file to read from
	      ):
        # Purpose: restore the class from the open file specified by fileptr.
	# Assumes: The file is one that was created by the save methods and
	#	   The next line to read from the file is the first line of the
	#            saved class.
	#	   The class object itself is currently empty (has not been
	#	     loaded).
	# Effects: Reads all the lines of the file corresponding to the class
	#		and ...

	self.tagname = fileptr.readline()[0:-1]		# read class name
	numvaltups =   string.atoi( fileptr.readline())	# # of rcds

	for t in range( numvaltups):			# for each rcd
	    tuplen = string.atoi( fileptr.readline())		# read rcd key
	    newlist = []
	    for v in range( tuplen):
	        newlist.append ( fileptr.readline()[0:-1] )
	    #end for
	    self.vals.append( tuple(newlist) )
	    
	#end for

    # end restore() 
    #-----------------------------------------------------------------------
    
# End class AcedbValSeq ------------------------------------------------------

class AcedbHitTbl:
    # Concept:
    #  a AcedbHitTbl is a table representing hits
    #  THIS DOC NEEDS WORK. SHOULD MOVE THIS CLASS to the acedb.py file
    #
    # Implementation:
    #  %%

    def __init__ (self,
    ):
	# constructor for class AcedbHitTbl
	self.hittbl = {}
    # end __init__() 
    #-----------------------------------------------------------------------

    def build (self,
	       aceclass1,	# an acedb class
	       aceclass2,	# another acedb class
	       hitTags		# list of tag names in the tissue rcd that
				#    indicate a hit by an STS.
    ):
	# Purpose: build a table indexed by (class1 rcdkey, class2 rcdkey) pairs
	#	    that indicate the type of hit between a class1 rcd and a
	#	    class2 rcd.
	#	    (class1 rcdkey, class2 rcdkey) will not be defined in the
	#	    table if there is no hit.
	# Assumes: hitTags[] is a list of tag names in a class1 record
	#	    indicating types of hits between class1 and class2 records.
	#	    I.e if "foo" is a value in hitTags[], then there is a
	#	    "foo"-type hit between rcd1 and a class2 rcd whose rcdkey
	#	    is "STS234"
	#	    iff
	#	    foo ("STS234", ...)   is a tag value-tuple pair in rcd1
	# Effects: builds a dictionary  hittbl{}  that is used by the hittype()
	#		routine.

	rcd1 = aceclass1.first()
	while (rcd1 != None):	# for each record in aceclass1
	    for ht in hitTags:	# for each tag of interest
		value = rcd1.firstTagValue( ht)
		while (value != None):	# for each tag value-tuple
		    self.hittbl[ (rcd1.rcdkey, value[0]) ] = ht
		    value = rcd1.nextTagValue( ht)
		# end while
	    #end for
	    rcd1 = aceclass1.next()
	# end while
    # end build() 
    #-----------------------------------------------------------------------

    def hittype (self,
		 tisname,	# AcedbRcd for a Tissue
		 stsname,	# string, the name (rcdkey) of an STS AcedbRcd
		):
	# Purpose: return the hit type found between tissue named 'tisname'
	#	        and the STS named 'stsname'.
	# Assumes: hittbl{} was built by buildhittbl()
	# Returns: string	- the type of hit (the tag) if there is a hit
	#	   None	- if there is no hit between the tissue and the STS

	if (self.hittbl.has_key( (tisname, stsname)) ):
	    return self.hittbl[ (tisname, stsname)]
	else:
	    return None
	
    # end hittype() 
    #-----------------------------------------------------------------------
    
    def save (self,
	      fileptr		# the open file to write to
	      ):
        # Purpose: save the hittable to the open file specified by fileptr.
	# Assumes: nothing
	# Effects: see Purpose

	fileptr.write( "%d\n" % (len(self.hittbl),) )	# # of tuples

	for pair in self.hittbl.keys():				# for each tuple
	    fileptr.write( "%s\n%s\n" % pair )
	    fileptr.write( "%s\n"     % (self.hittbl[pair],) )
	    
	#end for

    # end save() 
    #-----------------------------------------------------------------------
    
    def restore (self,
	      fileptr		# the open file to write to
	      ):
        # Purpose: restore the hittable from the open file specified by fileptr.
	# Assumes: nothing
	# Effects: see Purpose

	numpairs = string.atoi( fileptr.readline())	# # of tuples

	for pr in range( numpairs):				# for each tuple
	    key1 = fileptr.readline()[0:-1]
	    key2 = fileptr.readline()[0:-1]
	    val  = fileptr.readline()[0:-1]
	    self.hittbl[(key1,key2)] = val
	    
	#end for

    # end restore() 
    #-----------------------------------------------------------------------
# End class AcedbHitTbl ------------------------------------------------------

# Utility functions that should be moved elsewhere:

def rmquotes (s		# input string
	    ):
    # Purpose: return a copy of the string s with quote characters removed.
    #          If s does not begin and end with a quote char, a copy of
    #            s itself (unchanged) is returned.
    if ((s[0] == '"' and s[-1] == '"') or (s[0] == "'" and s[-1] == "'")):
        return s[1:-1]
    else:
        return s
    
# end rmquotes() 
#-----------------------------------------------------------------------


# end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
