#!/usr/local/bin/python

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
paneFileName = '/imagepane.txt'
inFile = ''
inPixFile = ''
imageFile = ''
paneFile = ''

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
paneFile = reportlib.init(paneFileName, fileSuffix = '.txt', printHeading = 0)

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

#    (xdim, ydim) = jpeginfo.getDimensions(pixeldatadir + '/' + imgToPix[fsImage] + jpegSuffix)
#    (xdim, ydim) = jpeginfo.getDimensions(pixeldatadir + '/' + imgToPix[fsImage] + jpegSuffix)
#        str(xdim) + TAB + \
#        str(ydim) + TAB + \
#	imgToPix[fsImage] + TAB + \

    imageFile.write(imageRef + TAB + \
        TAB + \
        TAB + \
	TAB + \
        TAB + \
        copyright + TAB + \
        fscaption + CRT)

    paneFile.write(imgToPix[fsImage] + TAB + \
        paneLabel + CRT)
inFile.close()

reportlib.finish_nonps(imageFile)	# non-postscript file
reportlib.finish_nonps(paneFile)	# non-postscript file

