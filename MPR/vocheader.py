#!/usr/local/bin/python

import sys 
import string
import db
import reportlib
import loadlib

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

loaddate = loadlib.loaddate

#
# Main
#

fp = reportlib.init('vocheader', printHeading = 0)

annotHeaderKey = 1000

results = db.sql('select distinct a._Object_key, h._Term_key, h.sequenceNum ' + \
	'from VOC_Annot a, VOC_Term t, VOC_VocabDAG vd, DAG_Node d, DAG_Closure dc, DAG_Node dh, VOC_Term h ' + \
	'where a._AnnotType_key = 1002 ' + \
	'and a._Term_key = t._Term_key ' + \
	'and t._Vocab_key = vd._Vocab_key ' + \
	'and vd._DAG_key = d._DAG_key ' + \
	'and t._Term_key = d._Object_key ' + \
	'and d._Node_key = dc._Descendent_key ' + \
	'and dc._Ancestor_key = dh._Node_key ' + \
	'and dh._Label_key = 3 ' + \
	'and dh._Object_key = h._Term_key ' + \
	'union ' + \
	'select distinct a._Object_key, h._Term_key, h.sequenceNum ' + \
	'from VOC_Annot a, VOC_Term t, VOC_VocabDAG vd, DAG_Node d, DAG_Closure dc, DAG_Node dh, VOC_Term h ' + \
	'where a._AnnotType_key = 1002 ' + \
	'and a._Term_key = t._Term_key ' + \
	'and t._Vocab_key = vd._Vocab_key ' + \
	'and vd._DAG_key = d._DAG_key ' + \
	'and t._Term_key = d._Object_key ' + \
	'and d._Node_key = dc._Descendent_key ' + \
	'and dc._Descendent_key = dh._Node_key ' + \
	'and dh._Label_key = 3 ' + \
	'and dh._Object_key = h._Term_key ' + \
	'order by h.sequenceNum', 'auto')

headers = {}
for r in results:
    key = r['_Object_key']

    if headers.has_key(key):
	headers[key] = headers[key] + 1
    else:
	headers[key] = 1

for r in results:

    key = r['_Object_key']

    if headers[key] > 1:
	approvedBy = '1000'
	approvedDate = loaddate
    else:
	approvedBy = ''
	approvedDate = ''

    if r['sequenceNum'] == None:
	sequenceNum = 1
    else:
	sequenceNum = r['sequenceNum']

    fp.write(str(annotHeaderKey) + TAB + \
	"1002" + TAB + \
	str(key) + TAB + \
	str(r['_Term_key']) + TAB + \
	str(sequenceNum) + TAB + \
	"1000" + TAB + "1000" + TAB + \
	approvedBy + TAB + \
	approvedDate + TAB + \
	loaddate + TAB + loaddate + CRT)

    annotHeaderKey = annotHeaderKey + 1

reportlib.finish_nonps(fp)	# non-postscript file

