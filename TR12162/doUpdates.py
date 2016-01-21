#!/usr/local/bin/python

#
#	Update property prefixes NCBI:NN_9999 --> RefSeq:NN_9999
#
# Inputs:
#
#	database
#
# Outputs:
#
#	inline updates
#
# History
#
# 01/15/2016	sc

#

import sys
import os
import string
import accessionlib
import db
import mgi_utils
import loadlib

db.useOneConnection(1)

updateString = "update VOC_Evidence_Property set value = '%s' where _EvidenceProperty_key = %s"

print 'Querying for set to update'
results = db.sql('''select vp._EvidenceProperty_key, vp.value
from VOC_Evidence ve, VOC_Annot a, VOC_Evidence_Property vp
where a._AnnotType_key = 1000 -- GO/Marker
and a._Annot_key = ve._Annot_key
and ve._AnnotEvidence_key = vp._AnnotEvidence_key
and vp.value like '%NCBI:%_%'
and vp._PropertyTerm_key != 6481779 -- text''', 'auto')

print 'Doing updates'
ct = 0
for r in results:
    ct+=1
    key = r['_EvidenceProperty_key']
    value = r['value']
    newValue = string.replace(value, 'NCBI:', 'RefSeq:')
    db.sql(updateString %(newValue, key))
    print updateString %(newValue, key)
db.commit()
print 'updated %s records' % ct
print 'Done doing updates' 

db.useOneConnection(1)
