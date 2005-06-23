#!/usr/local/bin/python

#
#
# Translate the MLC image migration file to input files for imageload.py.
#
# input file:
#
# 1: Full Size Image File
# 2: Thumbnail Image File
# 3. Allele MGI ID
# 4: Is Primary (yes or no)
# 5: J: for Image
# 6: J: for Annotation
# 7: TN caption
# 8: FS caption
# 9: FS copyright
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

inFileName = 'MLC_image_migr.txt'
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
pixPrefix = 'PIX:'

imagesProcessed = []

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

# 1: Full Size Image File
# 2: Thumbnail Image File
# 3. Allele MGI ID
# 4: Is Primary (yes or no)
# 5: J: for Image
# 6: J: for Annotation
# 7: TN caption
# 8: FS caption
# 9: FS copyright

    fsImage = tokens[0]
    tnImage = tokens[1]

    tncaption = tokens[6]
    fscaption = tokens[7]
    copyright = tokens[8]

    imageRef = tokens[4]

    objectID = tokens[2]
    isPrimary = tokens[3]
    assocRef = tokens[5]

    fspix = pixPrefix + imgToPix[fsImage]
    tnpix = pixPrefix + imgToPix[tnImage]

    (xdim, ydim) = jpeginfo.getDimensions(pixeldatadir + '/' + imgToPix[fsImage] + jpegSuffix)
    (xdim, ydim) = jpeginfo.getDimensions(pixeldatadir + '/' + imgToPix[fsImage] + jpegSuffix)

    if fspix not in imagesProcessed:

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

        imagesProcessed.append(fspix)

    assocFile.write(fspix + TAB + \
		    objectID + TAB + \
		    assocRef + TAB + \
		    isPrimary + TAB + \
		    createdBy + CRT)

inFile.close()

reportlib.finish_nonps(imageFile)	# non-postscript file
reportlib.finish_nonps(assocFile)	# non-postscript file

