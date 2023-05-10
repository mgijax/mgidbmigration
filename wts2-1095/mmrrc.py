#
# update MMRRC accession ids with those in mmrrc_catalog_data-2.txt
#
 
import sys 
import os
import db

db.setTrace()

updateSQL = ""

inFile = open('mmrrcNew', 'r')
for mmrrcTo in inFile.readlines():
    mmrrcTo = mmrrcTo[:-1]
    mmrrc = mmrrcTo[:-1].split('-')
    mmrrcFrom = mmrrc[0]
    updateSQL = '''update ACC_Accession set accid = '%s', prefixpart = '%s', numericpart = null, _modifiedby_key = 1001, modification_date = now() where _logicaldb_key = 38 and accid = '%s';\n''' \
        % (mmrrcTo, mmrrcTo, mmrrcFrom)
    print(updateSQL)
    #db.sql(updateSQL, None)
    #db.commit()
inFile.close()

