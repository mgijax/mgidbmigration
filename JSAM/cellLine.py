#!/usr/local/bin/python

import os
import string
import db

TAB = '\t'
CRT = '\n'

outFile = open('cellLine.in', 'w')

results = db.sql('select distinct cellLine from PRB_Source where cellLine is not null', 'auto')
for r in results:
    outFile.write(r['cellLine'] + TAB + TAB + TAB + TAB + CRT)

outFile.write('Not Specified' + TAB + TAB + 'NS' + TAB + 'Not Specified' + TAB + CRT)
outFile.write('Not Applicable' + TAB + TAB + 'NA' + TAB + 'Not Applicable' + TAB + CRT)
outFile.write('Not Resolved' + TAB + TAB + 'NR' + TAB + 'Not Resolved' + TAB + CRT)

# pick up good cell line names from translation as well

inFile = open('translationload/cellline.badgood', 'r')
for line in inFile.readlines():
    tokens = string.split(line[:-1], '\t')
    if tokens[2] != 'FALSE':
        outFile.write(tokens[2] + TAB + TAB + TAB + TAB + CRT)
inFile.close()

outFile.close()

