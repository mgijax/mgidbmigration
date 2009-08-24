#!/usr/local/bin/python

# input: parses file containing the transgenic alleles

import sys
import db
import re
import time

USAGE = '''Usage: %s <server> <db> <user> <pwd file> <input file>
    <server> : database server name
    <db> : database name
    <user> : database username
    <pwd file> : file containing password for <user>
    <input file> : path to tab-delimited file containing the CRE alleles
''' % sys.argv[0]

START_TIME = time.time()    # time (in sec) at which script begins

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

    # ensure proper commandline usage
    if len(sys.argv) != 6:
            bailout ('Error: wrong number of arguments')

    try: # make sure we have access to the password file
            fp = open (sys.argv[4], 'r')
            password = fp.readline().strip()
            fp.close()
    except:
            bailout ('Error: cannot read password from %s' % sys.argv[4])

    try: # make sure we have access to the database
            db.set_sqlLogin (sys.argv[3], password, sys.argv[1],
                    sys.argv[2])
            db.sql ('select count(1) from MGI_dbInfo', 'auto')
    except:
            bailout ('Error: database login failed')

    # open and read in the file
    try:
        fp = open(sys.argv[5], 'r')
        lines = fp.readlines()
        fp.close()
    except:
        bailout ('Error: cannot read from %s' % sys.argv[5])

    # SQL strings we'll be using
    insertNote = '''insert MGI_Note 
      (_Note_key, _Object_key, _MGIType_key, _NoteType_key, _CreatedBy_key, _ModifiedBy_key)
      values (%d, %d, %d, %d, %d, %d )'''
    insertNoteChunk = '''insert MGI_NoteChunk
      (_Note_key, sequenceNum, note, _CreatedBy_key, _ModifiedBy_key)
      values (%d, %d, "%s", %d, %d )'''

    # Other variables used
    cmd = '' 
    alleleKey    = ''
    alleleSymbol = ''
    crePromoter  = ''

    # gather max note key; we'll increment in the following loop
    results = db.sql ('select max(_Note_key) from MGI_Note', 'auto')
    nextNoteKey = results[0]['']
    

    # gather the correct note type key for "Recombinase Driver"
    results = db.sql ('select _NoteType_key from MGI_NoteType where noteType = "Driver"', 'auto')
    noteTypeKey = results[0]['_NoteType_key']



    # go through the file line by line, inserting the notes
    for line in lines:

        # clean the end of the line, if needed (resist Johnny Cash joke)
        if line[-1] == '\n':
            line = line[:-1]
        if line[-1] == '\r':
            line = line[:-1]

        # split the line by tabs
        columns = line.split('\t')
        if len(columns) != 3:
            report ('Warning: Incorrect # of data items on line -> "%s"' % (line))
            continue

        alleleKey = columns[0]
        alleleSymbol = columns[1]
        crePromoter = columns[2]
        

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





def main():

    report ('Start processing...')

    insertNotes()

    return

if __name__ == '__main__':
    main()
