#!/usr/local/bin/python

import sys 
import string
import db
import accessionlib
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

inFile = open('igtc.txt', 'r')
cellFile = open('igtc.cell', 'w')
accFile = open('igtc.acc', 'w')

cKey = db.sql('select max(_CellLine_key) + 1 from ALL_CellLine', 'auto')[0]['']
sKey = db.sql('select _Strain_key from PRB_Strain where strain = "Not Applicable"', 'auto')[0]['_Strain_key']
aKey = db.sql('select max(_Accession_key) + 1 from ACC_Accession', 'auto')[0]['']

for line in inFile.readlines():

    tokens = string.split(line[:-1], '\t')
    cellLine = tokens[0]
    provider = tokens[1]

    cellFile.write(str(cKey) + TAB + \
		  cellLine + TAB + \
		  str(sKey) + TAB + \
		  provider + TAB + \
		  "1" + TAB + \
		  "1000" + TAB + \
		  "1000" + TAB + \
		  loaddate + TAB + \
		  loaddate + CRT)

    prefixPart, numericPart = accessionlib.split_accnum(cellLine)

    accFile.write(str(aKey) + TAB + \
		  cellLine + TAB + \
		  prefixPart + TAB + \
		  str(numericPart) + TAB + \
		  "66" + TAB + \
		  str(cKey) + TAB + \
		  "28" + TAB + \
		  "0" + TAB + \
		  "1" + TAB + \
		  "1000" + TAB + \
		  "1000" + TAB + \
		  loaddate + TAB + \
		  loaddate + CRT)

    cKey = cKey + 1
    aKey = aKey + 1

