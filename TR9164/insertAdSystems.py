#!/usr/local/bin/python

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


def insertSystems ():

    ###########################################################
    # ensure proper commandline usage
    ###########################################################
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

    # open the file, and read in the lines of the file
    try:
        fp = open(sys.argv[5], 'r')
        lines = fp.readlines()
        fp.close()
    except:
        bailout ('Error: cannot read from %s' % sys.argv[5])

    ###########################################################
    # Reset any prior loads of Anatomical Systems vocab
    ###########################################################
    try:
      results = db.sql ('select _Vocab_key from VOC_Vocab where name = "Anatomical Systems"', 'auto')
      anatomicalSystemVocabKey = results[0]['_Vocab_key']

      if (anatomicalSystemVocabKey != None): 
        print "Removing old vocab entries"

        results = db.sql ('delete from Voc_Term where _Vocab_key = %s' % anatomicalSystemVocabKey, 'auto')
        results = db.sql ('delete from Voc_Vocab where _Vocab_key = %s' % anatomicalSystemVocabKey, 'auto')
    except:
      print "No prior Anatomical Systems vocab to remove"


    ###########################################################
    # Gather/Prep data we'll need downstream
    ###########################################################
    print "Gathering DB data we'll need"

    # determine the _Vocab_key we'll use for this vocab
    results = db.sql ('select max(_Vocab_key) from VOC_Vocab', 'auto')
    vocabKey = int(results[0]['']) + 1

    # determine the _Term_key we'll start with
    results = db.sql ('select max(_Term_key) from VOC_Term', 'auto')
    termKey = int(results[0][''])

    # determine the _Ref_key for J# creating this vocab
    results = db.sql ('select _Refs_key from BIB_View where jnumID = "J:147419"', 'auto')
    refKey = int(results[0]['_Refs_key'])

    # Voc Term requires a sequence number; we'll increment as we go
    sequenceNum = 0

    ##########################################################################
    # go through the file, line by line, gathering distinct Anatomical Systems
    ##########################################################################
    print "Gathering Anatomical Systems from input file"
    adSystems = {}
    for line in lines:

        # clean the end of the line, if needed
        if line[-1] == '\n':
            line = line[:-1]
        if line[-1] == '\r':
            line = line[:-1]

        # split the line by tabs
        columns = line.split('\t')
        if len(columns) != 3:
            report ('Warning: Incorrect # of data items on line -> "%s"' % (line))
            continue

        # storing as a dictionary key to enforce uniqueness
        adSystems[columns[2]] = 0

    ###########################################################
    # Insert vocab entry into Voc_Vocab
    ###########################################################

    insertVocVocab = '''insert into VOC_Vocab
      (_Vocab_key, _Refs_key, _LogicalDB_key, isSimple, isPrivate, name)
      values (%s, %s, -1, 1, 1, "Anatomical Systems")'''
    cmd = insertVocVocab % (vocabKey, refKey)
    results = db.sql (cmd, 'auto')

    ###########################################################
    # Insert each term into Voc_Term
    ###########################################################

    insertVocTerm = '''insert into VOC_Term
      (_Term_key, 
      _Vocab_key, 
      term, 
      abbreviation,
      sequenceNum,
      isObsolete,
      _CreatedBy_key,
      _ModifiedBy_key)
      values (%s, %s, "%s", null, %s, 0, 1000, 1000)'''

    adSystemsList = adSystems.keys()
    adSystemsList.sort()
    for adSystem in adSystemsList:

        # increment values that need incrementing
        termKey = termKey + 1
        sequenceNum = sequenceNum +1

        # make the insertion
        cmd = insertVocTerm % (str(termKey), str(vocabKey), adSystem, str(sequenceNum))
        results = db.sql (cmd, 'auto')

        
def main():

    report ('Start processing...')

    insertSystems()

    return

if __name__ == '__main__':
    main()
