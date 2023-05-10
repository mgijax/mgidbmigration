#
# reset VOC_Evidence_Property primary key starting at 1
#
 
import sys 
import os

newKey = 1

inFile = open('VOC_Evidence_Property.sort', 'r')
outFile = open('VOC_Evidence_Property.new', 'w')

for line in inFile.readlines():
    tokens = line[:-1].split('&')
    new5 = tokens[5].replace('\\', '')
    outFile.write(str(newKey) + '&' \
                + tokens[1] + '&' \
                + tokens[2] + '&' \
                + tokens[3] + '&' \
                + tokens[4] + '&' \
                + new5 + '&' \
                + tokens[6] + '&' \
                + tokens[7] + '&' \
                + tokens[8] + '&' \
                + tokens[9] + '\n')
    newKey += 1
        
inFile.close()
outFile.close()

