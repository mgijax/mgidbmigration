#!/usr/local/bin/python

import sys
import os
import string
import db

passwordFileName = os.environ['DBPASSWORDFILE']

db.useOneConnection(1)
db.set_sqlUser('mgd_dbo')
db.set_sqlPassword(string.strip(open(passwordFileName, 'r').readline()))
db.set_sqlLogFunction(db.sqlLogAll)

fp = open('promoter_cleanup_completed.txt', 'r')

for line in fp.readlines():
     tokens = string.split(line[:-1], '\t')
     accID = tokens[0]
     notes = tokens[2]

     results = db.sql('select _Object_key from ACC_Accession where accid = "%s"' % (accID), 'auto')
     for r in results:
	 key = r['_Object_key']

	 # delete promoter notes
	 db.sql('delete from ALL_Note where _NoteType_key = 3 and _Allele_key = %s' % (key), None)

	 # delete molecular notes
	 db.sql('delete from ALL_Note where _NoteType_key = 2 and _Allele_key = %s' % (key), None)

	 # add new molecular notes

         noteSeq = 1
	 cmds = []
      
         while len(notes) > 255:
	     cmds.append('insert into ALL_Note values(%s,2,%d,0,"%s",getdate(),getdate())' % (key, noteSeq, notes[:255]))
             newnotes = notes[255:]
             notes = newnotes
             noteSeq = noteSeq + 1

         if len(notes) > 0:
	     cmds.append('insert into ALL_Note values(%s,2,%d,0,"%s",getdate(),getdate())' % (key, noteSeq, notes[:255]))

	 db.sql(cmds, None)

fp.close()

db.sql('delete from ALL_NoteType where noteType = "Promoter"', None)

db.useOneConnection(0)
