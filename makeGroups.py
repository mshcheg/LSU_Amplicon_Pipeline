#!/bin/python

#Script to generate groups file for mothur analysis.

import csv
import os
import argparse

#Parse commandline arguments 
parser = argparse.ArgumentParser(description='Get input files.')
parser.add_argument('-s', '--sample', action="store", type=str, metavar="samplesfile", required=True, nargs=1, help='a sample file mapping barcodes to sample ids')
parser.add_argument('-i', '--infile', action="store", metavar='infile', type=str, required=True, nargs=1, help='an infput fasta file')

args = parser.parse_args()

#Create a dictionary linking sample namer to barcode names.
SampletoBarcode = {}

i=0
j=0
with open(args.sample[0], 'rb') as csvfile:
    LookUpReader = csv.reader(csvfile, delimiter='\t') 
    for row in LookUpReader:
        if i == 0:
            SampleIndex = row.index('SampleID')
            BarcodeIndex = row.index('BarcodeID')
            i = 1
        else:
            sample = "_".join(row[SampleIndex].split())
            barcode = row[BarcodeIndex]
            if sample == "Neg":
                sample = sample+str(i)
                SampletoBarcode[barcode] = sample
                i+=1
            else:
                sample = sample
                SampletoBarcode[barcode] = sample

#Loop through the mothur input file, extract sequence headers and write the groups file.
sequence = 0
with open(args.infile[0], 'r') as R1file:
    with open('LSU.groups', 'w') as Groupsfile:
        while 1:
            SequenceHeader1= R1file.readline()
            Sequence1= R1file.readline()
            if SequenceHeader1 == '': #exit loop when end of file is reached
                break
            barcode = SequenceHeader1.split(":")[7].strip('\n')
            #mothur replaces ':' with '_'
            Groupsfile.write('%s\t%s\n' %('_'.join(SequenceHeader1.strip(">").strip('\n').split(":")),SampletoBarcode[barcode]))
