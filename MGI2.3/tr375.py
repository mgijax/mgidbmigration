#!/usr/local/bin/python

'''
#
# tr375.py 10/04/99
#
# Usage:
#       tr375.py
#
# TR 375
#
# Import MLCTopsheetMarkers.tab into MGD.
#
# If second column contains an "R", then set the BIB_Refs.isReviewArticle
# column = 1.
#
# Add reference/primary symbols pair to MRK_Reference, setting auto = 0.
#
'''
 
import sys 
import string
import os
import accessionlib
import mgdlib

EXECUTE = 1

#
# Main
#

mgdlib.set_sqlUser('mgd_dbo')
mgdlib.set_sqlPassword(string.strip(open('/opt/sybase/admin/.mgd_dbo_password', 'r').readline()))
#mgdlib.set_sqlLogFunction(mgdlib.sqlLogAll)

fd = open('MLCTopsheetMarkers.tab', 'r')
line = fd.readline()
line = string.strip(fd.readline())

while line:
	ok = 1
	tokens = string.split(line, '\t')
	jnum = tokens[0]

	if tokens[1] == 'R':
		isReview = 1
	else:
		isReview = 0

	# columns w/ 1*M are primary symbols
	markers = []
	for i in range (2,12):
		if len(tokens) > i and len(tokens[i]) > 0:
			markers.append(tokens[i])

	# get key for jnum
	refsKey = accessionlib.get_Object_key('J:' + jnum, 'Reference')

	if refsKey is None:
		print 'Invalid Reference J:' + jnum
		ok = 0

	if ok:
		# get marker keys
		for m in markers:
			cmd = 'select _Current_key, current_symbol from MRK_Current_View where symbol = "%s"' % m
			results = mgdlib.sql(cmd, 'auto')

			if len(results) == 0:
				print 'Invalid Marker ' + m
				ok = 0

			if ok:
				markerKey = results[0]['_Current_key']

				cmd = 'select auto from MRK_Reference where ' + \
					'_Refs_key = %d and _Marker_key = %d' % (refsKey, markerKey)
				results = mgdlib.sql(cmd, 'auto')

				if len(results) == 0:
					cmd = 'insert into MRK_Reference values(%d,%d,0,getdate(),getdate())' % (markerKey, refsKey)
					mgdlib.sql(cmd, None, execute = EXECUTE)
				else:
					isAuto = results[0]['auto']
					if isAuto:
						cmd = 'update MRK_Reference set auto = 0 where ' + \
						'_Refs_key = %d and _Marker_key = %d' % (refsKey, markerKey)
						mgdlib.sql(cmd, None, execute = EXECUTE)

		if isReview:
			cmd = 'update BIB_Refs set isReviewArticle = 1 where _Refs_key = %d' % refsKey
			mgdlib.sql(cmd, None, execute = EXECUTE)

	line = string.strip(fd.readline())

fd.close()

cmd = "dump tran %s with no_log" % (os.environ['MGD'])
mgdlib.sql(cmd, None, execute = EXECUTE)
