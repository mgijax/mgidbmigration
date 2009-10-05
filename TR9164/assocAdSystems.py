#!/usr/local/bin/python

# input: parses file containing AdSystem -> AdTerms/AdStages

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


def associateSystems ():

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

    # open the file, and read in the lines of the file
    try:
        fp = open(sys.argv[5], 'r')
        lines = fp.readlines()
        fp.close()
    except:
        bailout ('Error: cannot read from %s' % sys.argv[5])

    ###########################################################
    # If we made it this far, we're probably good...lets roll
    ###########################################################

    # reset all structures to default (-1)
    print "Setting Defaults"
    results = db.sql ('update GXD_Structure set _System_key = -1', 'auto')

    # get the vocab key for Anatomical Systems
    results = db.sql ('select _Vocab_key from VOC_Vocab where name = "Anatomical Systems"', 'auto')
    anatomicalSystemVocabKey = results[0]['_Vocab_key']


    # SQL strings we'll be using
    findStructureKey = '''select s._Structure_key
        from GXD_Structure s, GXD_StructureName sn
        where s._Structure_key = sn._Structure_key
         and sn.structure = '%s'
         and s._Stage_key = %d
         order by sn.mgiAdded'''

    updateSystemKey = '''update GXD_Structure
        set _System_key = %d, inheritSystem = %d
        where _Structure_key = %d'''

    # gather distinct structure names
    #distinctStructures = {} 
    #results = db.sql ('select distinct(structure) from GXD_StructureName', 'auto')
    #for r in results:
    #    distinctStructures[r['structure']] = 0

    # gather the roll-up terms, and their keys
    rollUpSystems = {} 
    cmd = 'select term, _Term_key from VOC_Term where _Vocab_key = %s' % (anatomicalSystemVocabKey)
    results = db.sql (cmd, 'auto')
    for r in results:
        rollUpSystems[r['term']] = r['_Term_key']

    ##########################################################################
    # go through the file, line by line, associating a structure
    # to a high-level term
    ##########################################################################
    print "Updating _System_key for structures"
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

        inputTs = columns[0]
        inputStructure = columns[1]
        inputSystem = columns[2]

        cmd = findStructureKey % (inputStructure, int(inputTs))
        results = db.sql (cmd, 'auto')
        structurKey = results[0]['_Structure_key']
        #print "--" + inputTs + "-" + inputStructure +" " + str(structurKey)

        
        systemKey = rollUpSystems[inputSystem]

        cmd = updateSystemKey % (systemKey, 0, structurKey)
        results = db.sql (cmd, 'auto')

    ##########################################################################
    # now, for each structure that doesn't have a _System_key != -1, find 
    # it's closest parent with one, and assign that one
    ##########################################################################

    # pull in _Structure_key, _System_key and _Parent_key from GXD_Structure 
    # table.  Build reference mappings 
    unassignedStructures = {} 
    parentKeys = {} # structureKey -> parentKey 
    systems = {} # structureKey -> systemKey (for those with a system)
    results = db.sql ('select _Structure_key, _System_key, _Parent_key from GXD_Structure', 'auto')
    for r in results:
        structureKey    = r['_Structure_key']
        systemKey       = r['_System_key']
        parentKey       = r['_Parent_key']

        parentKeys[structureKey] = parentKey

        if (systemKey == -1): #this one doesn't have a system assigned
            unassignedStructures[structureKey] = 0
        else:
            systems[structureKey] = systemKey
#            print systemKey

    for structureKey in unassignedStructures:

        lookupKey = structureKey
        needsSystemKey = 1
        while (needsSystemKey == 1):

          #check the parents
          if systems.has_key(lookupKey): #the parent has a system
          
              #update database
              #print "Found System " + str(lookupKey) + "->" + str(systemKey)
              systemKey = systems[lookupKey]
              needsSystemKey = -1
              cmd = updateSystemKey % (systemKey, 1, structureKey)
              results = db.sql (cmd, 'auto')


          else: #this structure has no system - check it's parent
              #print "No System " + str(lookupKey)
              lookupKey = parentKeys[lookupKey]

          # if parent_key is empty, we hit the top of tree; exit
          if (lookupKey == None): 
              break

    ##########################################################################
    # for any structure not yet assigned, stick in default
    ##########################################################################
    earlyEmbryoStages = '(1,2,3,4,5,6,7,8,9,10)'
    earlyEmbryoSystemKey = str(rollUpSystems['early embryo'])
    embryoOtherStages = '(11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27)'
    embryoOtherSystemKey = str(rollUpSystems['embryo-other'])
    postnatalOtherStages = '(28)'
    postnatalOtherSystemKey = str(rollUpSystems['postnatal-other'])

    updateSystemKeyStageDefaults = '''
      update GXD_Structure
      set _System_key = %s
      where _System_key = -1
        and _Stage_key in %s'''

    cmd = updateSystemKeyStageDefaults % (earlyEmbryoSystemKey, earlyEmbryoStages)
    results = db.sql (cmd, 'auto')
    cmd = updateSystemKeyStageDefaults % (embryoOtherSystemKey, embryoOtherStages)
    results = db.sql (cmd, 'auto')
    cmd = updateSystemKeyStageDefaults % (postnatalOtherSystemKey, postnatalOtherStages)
    results = db.sql (cmd, 'auto')


def main():

    report ('Start processing...')

    associateSystems()

    return

if __name__ == '__main__':
    main()
