#!/bin/python

#Script to generate groups file for mothur analysis.

import csv
import os

#Create a dictionary linking sample namer to barcode names.
SampletoBarcode = {}

i=0
with open('LookupTable.csv', 'rb') as csvfile:
    LookUpReader = csv.reader(csvfile, delimiter='\t')
    for row in LookUpReader:
        sample = "_".join(row[0].split())
        if sample == "Neg"
            sample = sample+str(i)
            SampletoBarcode[row[1]] = sample
            i+=1
        else:
            sample = sample
            SampletoBarcode[row[1]] = sample

#Loop through the mothur input file, extract sequence headers and write the groups file.
sequence = 0
  
with open('Zanne-LSU_aligned.fasta', 'r') as R1file:
    with open('LSU.groups', 'w') as Groupsfile:
        while 1:
            SequenceHeader1= R1file.readline()
            Sequence1= R1file.readline()
            if SequenceHeader1 == '': #exit loop when end of file is reached
                break
            barcode = SequenceHeader1.split(":")[7].strip('\n')
            #mothur replaces ':' with '_'
            Groupsfile.write('%s\t%s' %('_'.join(SequenceHeader1.strip(">").strip('\n').split(":")),SampletoBarcode[barcode]))

