#
#  Purpose:
#
#

import sys
import os
import db
import mgi_utils


TAB =  '\t'
CRT = '\n'

header = 'build=GRCm39;'
strand = ''
collection = 'QTL'
display = 'MGI'
mbIDs = ''

inFile = open('MGI_C4AM_master.original.txt', 'r')
mgiMasterFile = open('MGI_C4AM_master.new.txt', 'w')
qtlMasterFile = open('QTL_master.txt', 'w')
mgiQtlFile = open('MGI_QTL.txt', 'w')

mgiMasterFile.write('%s%s' % (header, CRT))
qtlMasterFile.write('%s%s' % (header, CRT))
mgiQtlFile.write('%s%s' % (header, CRT))

lineNum = 0
for line in inFile.readlines():

        if lineNum == 0:
                lineNum += 1
                continue

        lineNum += 1
        tokens = line[:-1].split(TAB)
        if tokens[8] != 'QTL':
            mgiMasterFile.write('%s' % (line))
            mgiQtlFile.write('%s' % (line))
        else:
            mgiID = tokens[0]
            chromosome = tokens[1]
            start = tokens[2]
            end = tokens[3]
            qtlLine = ('%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s' % (mgiID, TAB, chromosome, TAB, start, TAB, end, TAB, strand, TAB, collection, TAB, display, TAB, mbIDs, CRT))
            qtlMasterFile.write(qtlLine)
            mgiQtlFile.write(qtlLine)

inFile.close()
mgiMasterFile.close()
qtlMasterFile.close()

sys.exit(0)

