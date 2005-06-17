#!/usr/local/bin/python

#
#
# Translate the MLC image migration file to an input files for 
# the Image load.
#
# output file 1, Images:
#
# 1: PIX ID
# 2: Image Type
# 3: Thumbnail PIX ID
# 4: xDim
# 5: yDim
# 6: J:
# 7: Figure Label
# 8: Caption
# 9: Copyright
# 10: Created By
#
# output file 2, Image Pane Associations:
#
# 1: PIX ID
# 2: MGI:#### of object to associate
# 3: list of J: (pipe delimited)
# 4: Y if primary, N if secondary
# 5: Created By
#

import sys 
import os
import string
import getopt
import db
import reportlib
import mgi_utils
import jpeginfo

#globals

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

pixPrefix = "PIX:"
pixLogicalDB = 19
pixeldatadir = os.environ['PIXELDBDATA']

inFileName = 'tr5154/9.5_dpc_in_situ_results.txt'
inPixFileName = 'pixmlc.txt'
imageFileName = '/image.txt'
assocFileName = '/imagepaneassoc.txt'
inFile = ''
inPixFile = ''
imageFile = ''
assocFile = ''

# constants
jpegSuffix = '.jpg'
createdBy = os.environ['CREATEDBY']
paneLabel = ''
imageNote = ''

#
# Main
#

# pixFileName:pixID mapping
imgToPix = {}
inPixFile = open(inPixFileName, 'r')
for line in inPixFile.readlines():
    tokens = string.split(line[:-1], TAB)
    pixFileName = tokens[0]
    pixID = tokens[1]
    key = pixFileName
    value = pixID
    imgToPix[key] = value
inPixFile.close()

imageFile = reportlib.init(imageFileName, fileSuffix = '.txt', printHeading = 0)
assocFile = reportlib.init(assocFileName, fileSuffix = '.txt', printHeading = 0)

inFile = open(inFileName, 'r')

for line in inFile.readlines():

    tokens = string.split(line[:-1], TAB)
    fsImage = tokens[0]
    tnImage = tokens[1]
    objectID = tokens[2]
    imageRef = tokens[3]
    assocRef = tokens[4]
    fscaption = tokens[5]
    tncaption = tokens[6]
    copyright = tokens[7]

    fspix = imgToPix[fsImage]
    tnpix = imgToPix[tnImage]

    # get x and y image dimensions

    (xdim, ydim) = jpeginfo.getDimensions(pixeldatadir + '/' + imgToPix[fsImage] + jpegSuffix)
    (xdim, ydim) = jpeginfo.getDimensions(pixeldatadir + '/' + imgToPix[fsImage] + jpegSuffix)

    imageFile.write(imageRef + TAB + \
        TAB + \
        str(xdim) + TAB + \
        str(ydim) + TAB + \
	imgToPix[fsImage] + TAB + \
        copyright + TAB + \
        fscaption + CRT)

    assocFile.write(imgToPix[fsImage] + TAB + \
        paneLabel + CRT)
inFile.close()

reportlib.finish_nonps(imageFile)	# non-postscript file
reportlib.finish_nonps(assocFile)	# non-postscript file

