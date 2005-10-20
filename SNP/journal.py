#!/usr/local/bin/python

#
# Generate a file for noteload of copyright notes for journals
#

import sys 
import string
import db
import reportlib

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

journals = {'Dev Biol' : 'Reprinted with permission from Elsevier from \\DXDOI(||) \\Elsevier(||)',
            'Development' : 'This image is from * and is displayed with the permission of The Company of Biologists Limited who owns the Copyright.',
	    'Dev Dyn' : 'This image is from * and is displayed with the permission of Wiley-Liss, Inc. who owns the Copyright.',
	    'Gene Expr Patterns' : 'Reprinted with permission from Elsevier from \\DXDOI(||) \\Elsevier(||)',
	    'Brain Res Gene Expr Patterns' : 'Reprinted with permission from Elsevier from \\DXDOI(||) \\Elsevier(||)',
	    'Mech Dev' : 'Reprinted with permission from Elsevier from \\DXDOI(||) \\Elsevier(||)',
	    'PLoS Biol': 'This image is from *, an open-access article distributed under the terms of the Creative Commons Attribution License.',
	    'PLoS Genet': 'This image is from *, an open-access article distributed under the terms of the Creative Commons Attribution License.',
	    'PLoS Med': 'This image is from *, an open-access article distributed under the terms of the Creative Commons Attribution License.',
	    'BMC Biochem': 'This image is from *, an open-access article, licensee BioMed Central Ltd.',
	    'BMC Biol': 'This image is from *, an open-access article, licensee BioMed Central Ltd.',
	    'BMC Biotechnol': 'This image is from *, an open-access article, licensee BioMed Central Ltd.',
	    'BMC Cancer': 'This image is from *, an open-access article, licensee BioMed Central Ltd.',
	    'BMC Cell Biol': 'This image is from *, an open-access article, licensee BioMed Central Ltd.',
	    'BMC Complement Altern Med': 'This image is from *, an open-access article, licensee BioMed Central Ltd.',
	    'BMC Dev Biol': 'This image is from *, an open-access article, licensee BioMed Central Ltd.',
	    'BMC Evol Biol': 'This image is from *, an open-access article, licensee BioMed Central Ltd.',
	    'BMC Genet': 'This image is from *, an open-access article, licensee BioMed Central Ltd.',
	    'BMC Genomics': 'This image is from *, an open-access article, licensee BioMed Central Ltd.',
	    'BMC Med': 'This image is from *, an open-access article, licensee BioMed Central Ltd.',
	    'BMC Mol Biol': 'This image is from *, an open-access article, licensee BioMed Central Ltd.',
	    'BMC Neurosci': 'This image is from *, an open-access article, licensee BioMed Central Ltd.',
	    'BMC Ophthalmol': 'This image is from *, an open-access article, licensee BioMed Central Ltd.',
	    'Cell Death Differ': 'This image is from * and is displayed with the permission of <A HREF="http://www.nature.com/">The Nature Publishing Group</A> who owns the Copyright.',
	    'Oncogene': 'This image is from * and is displayed with the permission of <A HREF="http://www.nature.com/">The Nature Publishing Group</A> who owns the Copyright.',
	    'Nature': 'This image is from * and is displayed with the permission of <A HREF="http://www.nature.com/">The Nature Publishing Group</A> who owns the Copyright.',
	    'Nat Cell Biol': 'This image is from * and is displayed with the permission of <A HREF="http://www.nature.com/">The Nature Publishing Group</A> who owns the Copyright.',
	    'Nat Genet': 'This image is from * and is displayed with the permission of <A HREF="http://www.nature.com/">The Nature Publishing Group</A> who owns the Copyright.',
	    'Nat Immunol': 'This image is from * and is displayed with the permission of <A HREF="http://www.nature.com/">The Nature Publishing Group</A> who owns the Copyright.',
	    'Nat Med': 'This image is from * and is displayed with the permission of <A HREF="http://www.nature.com/">The Nature Publishing Group</A> who owns the Copyright.',
	    'Nat Neurosci': 'This image is from * and is displayed with the permission of <A HREF="http://www.nature.com/">The Nature Publishing Group</A> who owns the Copyright.',
	    'Nat Struct Biol': 'This image is from * and is displayed with the permission of <A HREF="http://www.nature.com/">The Nature Publishing Group</A> who owns the Copyright.',
	    'Nat Biotechnol': 'This image is from * and is displayed with the permission of <A HREF="http://www.nature.com/">The Nature Publishing Group</A> who owns the Copyright.',
	    'Nat Rev Cancer': 'This image is from * and is displayed with the permission of <A HREF="http://www.nature.com/">The Nature Publishing Group</A> who owns the Copyright.',
	    'Nat Rev Genet': 'This image is from * and is displayed with the permission of <A HREF="http://www.nature.com/">The Nature Publishing Group</A> who owns the Copyright.',
	    'Nat Rev Immunol': 'This image is from * and is displayed with the permission of <A HREF="http://www.nature.com/">The Nature Publishing Group</A> who owns the Copyright.',
	    'Nat Rev Mol Cell Biol': 'This image is from * and is displayed with the permission of <A HREF="http://www.nature.com/">The Nature Publishing Group</A> who owns the Copyright.',
	    'Nat Rev Neurosci': 'This image is from * and is displayed with the permission of <A HREF="http://www.nature.com/">The Nature Publishing Group</A> who owns the Copyright.',
	    'Biotechnology': 'This image is from * and is displayed with the permission of <A HREF="http://www.nature.com/">The Nature Publishing Group</A> who owns the Copyright.'
	}

#
# Main
#

fp = reportlib.init('journal', printHeading = 0)

results = db.sql('select a.accID, t.term ' + \
	'from VOC_Vocab v, VOC_Term t, ACC_Accession a ' + \
	'where v.name = "Journal" ' + \
	'and v._Vocab_key = t._Vocab_key ' + \
	'and t._Term_key = a._Object_key ' + \
	'and a._MGIType_key = 13 ' + \
	'and a._LogicalDB_key = 1' + \
	'and a.preferred = 1', 'auto')

for r in results:

    fp.write(r['accID'] + TAB + journals[r['term']] + CRT)

reportlib.finish_nonps(fp)	# non-postscript file

