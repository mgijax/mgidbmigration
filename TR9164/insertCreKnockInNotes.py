#!/usr/local/bin/python

# This script derives the promoter note values for Knock-in alleles.  It first
# identifies the alleles needing notes, gathers the marker symbol for that 
# allele's marker, and inserts the marker symbol as this allele's promoter.

import sys
import db
import re
import time

USAGE = '''Usage: %s <server> <db> <user> <pwd file> <input file>
    <server> : database server name
    <db> : database name
    <user> : database username
    <pwd file> : file containing password for <user>
''' % sys.argv[0]

START_TIME = time.time()    # time (in sec) at which script begins

# Curators have identified some knock-in alleles which don't have nomen
# matching "%(%cre%)%" or "%(%flp%)%"
# We'll simply add these to the list manually
CURATOR_IDENTIFIED_ALLELE_KEYS = ["56212"]

# Status key of 'approved' alleles
APPROVED_ALLELE_STATUS_KEY = "847114"

# Allele type key for knock-in alleles
KNOCKIN_ALLELE_TYPE_KEY = "847117"


def report (msg):
    elapsed = time.time() - START_TIME
    sys.stderr.write ('%7.3f %s\n' % (elapsed, msg))
    return

def bailout (msg, showUsage = True):
    if showUsage:
        report (USAGE)
    report (msg)
    sys.exit(1)


def insertNotes ():

    # list of allele keys, gathered in stages; cre, flp, and special
    alleleKeys = []
    
    # ensure we have the correct # of command-line options
    if len(sys.argv) != 5:
            bailout ('Error: wrong number of arguments')

    # make sure we have access to the password file
    try: 
            fp = open (sys.argv[4], 'r')
            password = fp.readline().strip()
            fp.close()
    except:
            bailout ('Error: cannot read password from %s' % sys.argv[4])

    # make sure we have access to the database
    try: 
            db.set_sqlLogin (sys.argv[3], password, sys.argv[1],
                    sys.argv[2])
            db.sql ('select count(1) from MGI_dbInfo', 'auto')
    except:
            bailout ('Error: database login failed')

    # SQL strings we'll be using
    gatherCreKnockIns = '''select _Allele_key from ALL_Allele
      where _Allele_Type_key = %s
       and _Allele_Status_key = %s
       and symbol like "%%(%%cre%%)%%"
      '''
    gatherFlpKnockIns = '''select _Allele_key from ALL_Allele
      where _Allele_Type_key = %s
       and _Allele_Status_key = %s
       and symbol like "%%(%%flp%%)%%"
      '''
    insertNote = '''insert MGI_Note 
      (_Note_key, _Object_key, _MGIType_key, _NoteType_key, _CreatedBy_key, _ModifiedBy_key)
      values (%d, %d, %d, %d, %d, %d )'''

    insertNoteChunk = '''insert MGI_NoteChunk
      (_Note_key, sequenceNum, note, _CreatedBy_key, _ModifiedBy_key)
      values (%d, %d, "%s", %d, %d )'''

    getPromoter = '''select mrk.symbol
      from MRK_Marker mrk, ALL_Allele aa
      where aa._Allele_key = %s
       and aa._Marker_key = mrk._Marker_key'''

    # gather and add alleles like "%%(%%cre%%)%%" 
    cmd = gatherCreKnockIns % (KNOCKIN_ALLELE_TYPE_KEY, APPROVED_ALLELE_STATUS_KEY)
    results = db.sql (cmd, 'auto')
    for row in results:
        alleleKeys.append(row['_Allele_key'])

    # gather and add alleles like "%%(%%flp%%)%%" 
    cmd = gatherFlpKnockIns % (KNOCKIN_ALLELE_TYPE_KEY, APPROVED_ALLELE_STATUS_KEY)
    results = db.sql (cmd, 'auto')
    for row in results:
        alleleKeys.append(row['_Allele_key'])

    # add list of those identified by curators
    for key in CURATOR_IDENTIFIED_ALLELE_KEYS:
        alleleKeys.append(key)

    # gather max note key; we'll increment in the following loop
    results = db.sql ('select max(_Note_key) from MGI_Note', 'auto')
    nextNoteKey = results[0]['']

    # gather the correct note type key for "Recombinase Driver"
    results = db.sql ('select _NoteType_key from MGI_NoteType where noteType = "Driver"', 'auto')
    noteTypeKey = results[0]['_NoteType_key']

    # Variables used during insertion
    cmd = '' 
    crePromoter  = ''
    count = 0

    # loop through the allele keys
    # 1) identify the promoter; for knock-in's , it's the marker
    # 2) insert the note stub
    # 3) insert the note chunk (expecting none over 8 chars)
    for alleleKey in alleleKeys:

        cmd = getPromoter % (alleleKey)
        results = db.sql (cmd, 'auto')
        crePromoter = results[0]['symbol']

        #increment to the next db_key to be inserted
        nextNoteKey = nextNoteKey + 1 

        # note stub
        cmd = insertNote % (int(nextNoteKey),
                            int(alleleKey),
                            11,
                            int(noteTypeKey),
                            1000,
                            1000)
        results = db.sql (cmd, 'auto')

        # note chunk
        cmd = insertNoteChunk % (int(nextNoteKey),
                            1,
                            crePromoter,
                            1000,
                            1000)
        results = db.sql (cmd, 'auto')

        count = count + 1

def main():

    report ('Start processing...')

    insertNotes()

    return

if __name__ == '__main__':
    main()
