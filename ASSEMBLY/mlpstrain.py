#!/usr/local/bin/python

import os
import string
import db

TAB = '\t'
CRT = '\n'

outFile1 = open('species.in', 'w')
results = db.sql('select species from MLP_Species', 'auto')
for r in results:
    outFile1.write(r['species'] + TAB + TAB + TAB + TAB + CRT)
outFile1.close()

outFile2 = open('straintype.in', 'w')
results = db.sql('select strainType from MLP_StrainType', 'auto')
for r in results:
    outFile2.write(r['strainType'] + TAB + TAB + TAB + TAB + CRT)
outFile2.close()

