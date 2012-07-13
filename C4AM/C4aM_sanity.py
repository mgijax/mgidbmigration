#!/usr/local/bin/python

import db
import sys
import os

print 'Server: %s' % os.environ['MGD_DBSERVER']
print 'Database: %s' % os.environ['MGD_DBNAME']
# test that an input filename 
inFile = ''
if (len(sys.argv) < 1):
    print 'Please provide load filename';
    sys.exit(1);

fileName = sys.argv[1]
print 'Input File: %s' % fileName
try:
    inFile = open(fileName, 'r');
except:
    print 'Input file %s does not exist'  % inFile
    sys.exit(1)

# sql to get count of MAP_Coord_Feature records
countSql = """select count(c._Feature_key)
	from ACC_Accession a, dbo.MAP_Coord_Feature c
	where a.accid = '%s'
	and a._MGIType_key = 2
	and a._LogicalDB_key = 1
	and a.preferred = 1
	and a._Object_key = c._Object_key""";

# sql to get coordinates from MRK_Location_Cache
coordSql = """select mlc.chromosome, mlc.startCoordinate, 
		mlc.endCoordinate, mlc.strand, mlc.provider
	from ACC_Accession a, MRK_Location_Cache mlc
	where a.accid = '%s'
	and a._MGIType_key = 2
	and a._LogicalDB_key = 1
	and a.preferred = 1
	and a._Object_key = mlc._Marker_key""";
	
def xstr(s):
	if s is None:
		return '';
	return str(s);

result = 0;

for line in inFile:
	fields = line.split('\t')
	id = fields[0].strip(' ');
	
	failure = False;
	fileCoords = '';
	
	count = '';
	msg = [];
	
	# this line starts with an mgi id, perform tests
	if (id.find('MGI:') != -1):
		countResult = db.sql(countSql % id, 'auto');
		count = countResult[0][''];
		
		# grab coordinate fields from input file
		fileCoords = '%s:%s-%s%s %s' % (fields[1].strip(), fields[2].strip(), 
			fields[3].strip(), fields[4].strip(), fields[6].strip());
		
		# if file coords
		if (len(fileCoords) > (len(fields[6].strip()) + 3)):
			if (count != 1):
				failure = True;
				msg.append('incorrect feature count: %d' % count);
			coords = '';
			
			# if coordinates in file, test they match those in db
			coordResult = db.sql(coordSql % id, 'auto');
			
			# should only be 1 coordinate in MRK_Location_Cache
			if (len(coordResult) == 1):
				strand = '';
				if (coordResult[0]['strand'] != None):
					strand = coordResult[0]['strand'];
				start = '';
				if (coordResult[0]['startCoordinate'] != None):
					start = int(coordResult[0]['startCoordinate']);
				end = '';
				if (coordResult[0]['endCoordinate'] != None):
					end = int(coordResult[0]['endCoordinate']);
				dataChrom = coordResult[0]['chromosome'];
				dataCoords = '%s:%s-%s%s %s' % (dataChrom, 
					str(start), str(end), strand, coordResult[0]['provider']);
				
				if (fields[1].strip() != dataChrom):
					failure = True;
					msg.append('mismatched chromosome: marker is on %s not %s' % (dataChrom, fields[1].strip()));
				elif (dataCoords != fileCoords):
					failure = True;
					msg.append('new coordinates missing: dataCoords %s' % dataCoords);
			else:
				failure = True;
				msg.append('no coordinates');
		
		# if chromosome field blank, verify count = 0
		else:
			if (count > 0):
				failure = True;
				msg.append('incorrect feature count: %d' % count);
				
		if (failure):
			result = 1;
			print '%s:\t%s\t%s' % (id, 'fail', '\n\t\t\t'.join(msg));
		else:
			print '%s:\t%s' % (id, 'pass');

sys.exit(result);
