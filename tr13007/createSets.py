#!/usr/local/bin/python

#
#	Create MGI sets for GXD HT Experiments
#
# Inputs:
#
#   Created by Connie:
#   Expression Atlas Experiment File
#   RNA Seq Experiment File
#
# Outputs:
#
#	setload format files for the above two sets
#
# History
#
# 08/21/2019	sc

#

import sys
import os
import string
import accessionlib
import db
import mgi_utils
import loadlib

db.useOneConnection(1)

TAB = '\t'
CRT = '\n'

fpEAIn = open('/mgi/all/wts_projects/13000/13007/data/EAlinks2.txt', 'r')
fpEAOut =  open('/mgi/all/wts_projects/13000/13007/data/ea_setload/EAlinks.setload.txt', 'w')

fpRNASeqIn = open('/mgi/all/wts_projects/13000/13007/data/RNASeq_Experiments_from_Connie2.txt', 'r')
fpRNASeqOut = open('/mgi/all/wts_projects/13000/13007/data/rnaseq_setload/RNASeq_Experiments_from_Connie.setload.txt', 'w')

# create setload files
for id in fpEAIn.readlines():
   fpEAOut.write('%s%s%s' % (string.strip(id), TAB, CRT))
 
for id in fpRNASeqIn.readlines():
   fpRNASeqOut.write('%s%s%s' % (string.strip(id), TAB, CRT))

# invoke setload
db.useOneConnection(0)
