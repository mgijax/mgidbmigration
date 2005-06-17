#!/usr/local/bin/python

#
#
# Translate the MLC image migration file to input files for imageload.py.
#
# input file:
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

pixeldatadir = os.environ['PIXELDBDATA']

inFileName = 'cindy smith'
inPixFileName = 'pixmlc.txt'
imageFileName = '/image.txt'
assocFileName = '/imagepaneassoc.txt'
inFile = ''
inPixFile = ''
imageFile = ''
assocFile = ''

# constants
jpegSuffix = '.jpg'
createdBy = 'csmith'
figureLabel = '1'
paneLabel = ''
fullSize = 'Full Size'
thumbnail = 'Thumbnail'

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

imageFile = reportlib.init(imageFileName, fileExt = '.txt', printHeading = 0)
assocFile = reportlib.init(assocFileName, fileExt = '.txt', printHeading = 0)

inFile = open(inFileName, 'r')

for line in inFile.readlines():

    tokens = string.split(line[:-1], TAB)
    fsImage = tokens[0]
    tnImage = tokens[1]
    fscaption = tokens[2]
    tncaption = tokens[3]
    copyright = tokens[4]
    imageRef = tokens[5]

    objectID = tokens[6]
    assocRef = tokens[7]
    isPrimary = tokens[8]

    fspix = imgToPix[fsImage]
    tnpix = imgToPix[tnImage]

    (xdim, ydim) = jpeginfo.getDimensions(pixeldatadir + '/' + imgToPix[fsImage] + jpegSuffix)
    (xdim, ydim) = jpeginfo.getDimensions(pixeldatadir + '/' + imgToPix[fsImage] + jpegSuffix)

    imageFile.write(fspix + TAB + \
                    fullSize + TAB + \
                    tnpix + TAB + \
                    str(xdim) + TAB + \
                    str(ydim) + TAB + \
		    imageRef + TAB + \
		    figureLabel + TAB + \
		    fscaption + TAB + \
                    copyright + TAB + \
                    createdBy + CRT)

    (xdim, ydim) = jpeginfo.getDimensions(pixeldatadir + '/' + imgToPix[tnImage] + jpegSuffix)
    (xdim, ydim) = jpeginfo.getDimensions(pixeldatadir + '/' + imgToPix[tnImage] + jpegSuffix)

    imageFile.write(tnpix + TAB + \
                    thumbnail + TAB + \
                    TAB + \
                    str(xdim) + TAB + \
                    str(ydim) + TAB + \
		    imageRef + TAB + \
		    figureLabel + TAB + \
		    tncaption + TAB + \
                    TAB + \
                    createdBy + CRT)

    assocFile.write(fspix + TAB + \
		    objectID + TAB + \
		    assocRef + TAB + \
		    isPrimary + TAB + \
		    createdBy + CRT)

inFile.close()

reportlib.finish_nonps(imageFile)	# non-postscript file
reportlib.finish_nonps(assocFile)	# non-postscript file

