LSU_Amplicon_Pipeline
=====================

Scripts and data files for analyzing fungal LSU MiSeq data.

######The LSU analysis was completed following the [MOTHUR Tutorial for Fungal Community Analysis](http://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=3&cad=rja&uact=8&ved=0CDUQFjAC&url=http%3A%2F%2Fwww.bio.utk.edu%2Ffesin%2FFESIN2010%2FWorkshop2010%2FAmend%2FMothur_tutorial.pdf&ei=Op4gU9KgD8ONygHf4YHABg&usg=AFQjCNHEw42nzCoTvlYJkjJSk_F2OlQ9Wg&sig2=Hj3c2yL7MKHn3cnZGJ3big&bvm=bv.62788935,d.aWc) with a few modifications.

#####1. Parse Amplicons

Split ITS, LSU and 16S reads using Matt's dbcAmplicon python script: https://github.com/msettles/dbcAmplicons.
```bash
dbcAmplicons preprocess -b barcodeLookupTable.txt -p 16S_ITS_LSU_PrimerTable.txt -s ZanneAmplicons_MattPipeline.txt -u -U -v -1 Undetermined_S0_L001_R1_001.fastq -2 MariyaAmy002_S1_L001_R1_001.fastq -3 MariyaAmy002_S1_L001_R2_001.fastq -4 Undetermined_S0_L001_R2_001.fastq &
```
The -s flag gives the name of a sample sheet file. The sample sheet used for the Tyson year 3 harvest is included in this repository (Tyson_samplesheet.txt).
     
#####2. Assemble\Concatonate Paried End Reads
Paired end LSU reads were assembled using [PandaSeq](https://github.com/neufeld/pandaseq/wiki/PANDAseq-Assembler).
```bash
pandaseq -B -f Zanne-LSU_R1.fastq -r Zanne-LSU_R2.fastq -u Zanne-LSU_unpaired.fasta > Zanne-LSU_paired.fasta &
```
PandaSeq inserts a "-" between high-quality paired end reads that do not overlap. These sequences are placed in the unpaired.fastq file. Replace the "-" with an "N" for downstream analyses.

```bash
sed -i '/>HWI\\-/!s/\\-/N/' unpaired.fasta &
```
Combine overlapping and concatonated sequences into one file.
  
```bash
cat unpaired_N.fasta paired.fasta > both.fasta \n",
```
######These following commands can be run in batch mode from the LSU_mothur_script.sh rather than interactivly in the mothur shell as described below.

#####3.Sequence Processing and Cleanup

Look at the quality of LSU sequences.
      
```
mothur > summary.seqs(fasta=Zanne-LSU_aligned.fasta, processors=8)
    
Using 8 processors.

                      Start   End     NBases  Ambigs  Polymer NumSeqs
      Minimum:        1       283     283     0       3       1
      2.5%-tile:      1       491     491     0       4       135476
      25%-tile:       1       524     524     0       4       1354756
      Median:         1       555     555     0       5       2709512
      75%-tile:       1       566     566     1       5       4064268
      97.5%-tile:     1       569     569     1       11      5283548
      Maximum:        1       575     575     2       281     5419023
      Mean:   1       543.59  543.59  0.437255        5.21835
      # of Seqs:      5419023
```      

Clean up sequences by removing all sequences with more than 1 ambiguity and homopolymers that are longer than 11 bases.
Note: mothur has many p

      "\n",
      "```bash\n",
      "mothur > trim.seqs(fasta=Zanne-LSU_aligned.fasta, length=600, maxambig=1, maxhomop=11)\n",
      "\n",
      "Output File Names: \n",
      "Zanne-LSU_aligned.trim.fasta\n",
      "Zanne-LSU_aligned.scrap.fasta\n",
      "```\n",
      "Collapse all identical sequences. \n",
      "\n",
      "```bash\n",
      "mothur > unique.seqs(fasta=Zanne-LSU_aligned.trim.fasta)\n",
      "\n",
      "Output File Names: \n",
      "Zanne-LSU_aligned.trim.names\n",
      "Zanne-LSU_aligned.trim.unique.fasta\n",
      "```\n",
      "####Alignment \n",
      "Align LSU sequences to a reference LSU alignment. \n",
      "\n",
      "#####The reference LSU alignment was generated from the James et al. (2006) Combined data set, 214 taxa, nucleotides alignment available on the [AFTOL website](http://wasabi.lutzonilab.net/pub/alignments/download_alignments). Non fungal taxa were removed from the alignment and the remaining sequences were trimmed down to only the LSU region flanked by the LROR and LR3 primers. Taxa missing this region were removed. The Final alignment can be downladed [here] (https://www.dropbox.com/s/uxstqgyt93wokn4/James_2006_FungiOnly_LSU_LR0R_LR3.fasta.tgz).  \n",
      "\n",
      "```bash\n",
      "mothur > align.seqs(candidate=Zanne_LSU_aligned.trim.unique.fasta, template=James_2006_FungiOnly_LSU_LR0R_LR3.fasta, flip=T, processors=10)\n",
      "\n",
      "Some of you sequences generated alignments that eliminated too many bases, a list is provided in Zanne_LSU_aligned.trim.unique.flip.accnos. If the reverse compliment proved to be better it was reported.\n",
      "It took 2664 secs to align 5252010 sequences.\n",
      "\n",
      "\n",
      "Output File Names: \n",
      "Zanne_LSU_aligned.trim.unique.align\n",
      "Zanne_LSU_aligned.trim.unique.align.report\n",
      "Zanne_LSU_aligned.trim.unique.flip.accnos\n",
      "```\n",
      "####Check for Chimeras\n",
      "Use chimera slayer and the referance LSU alignment to check for chimeric LSU sequences. \n",
      "\n",
      "```bash\n",
      "mothur > chimera.slayer(fasta=Zanne_LSU_aligned.trim.unique.align, template=James_2006_FungiOnly_LSU_LR0R_LR3.fasta, processors=10, blastlocation=/usr/bin/)\n",
      "\n",
      "It took 29884 secs to check 5252010 sequences.\n",
      "\n",
      "Output File Names: \n",
      "Zanne_LSU_aligned.trim.unique.slayer.chimeras\n",
      "Zanne_LSU_aligned.trim.unique.slayer.accnos\n",
      "```\n",
      "\n",
      "Remove chimeric sequences from analysis files. \n",
      "\n",
      "#####You will need to create a groups file before this step. The groups file links sequence header names with a sample name. "
     ]
    },
    {
     "cell_type": "code",
     "collapsed": false,
     "input": [
      "#Generate groups file for mothur analysis\n",
      "\n",
      "import csv\n",
      "import os\n",
      "\n",
      "#>HWI-M01380:52:000000000-A64W5:1:1101:18312:1730:India402\n",
      "\n",
      "SampletoBarcode = {}\n",
      "\n",
      "#Create a dictionary linking sample namer to barcode names \n",
      "i=0\n",
      "with open('LookupTable.csv', 'rb') as csvfile:\n",
      "\tLookUpReader = csv.reader(csvfile, delimiter='\\t')\n",
      "\tfor row in LookUpReader:\n",
      "\t\tsample = \"_\".join(row[0].split())\n",
      "\t\tif sample == \"Neg\":\n",
      "\t\t\tsample = sample+str(i)\n",
      "\t\t\tSampletoBarcode[row[1]] = sample\t\t\t\n",
      "\t\t\ti+=1\n",
      "\t\telse:\n",
      "\t\t\tsample = sample\n",
      "\t\t\tSampletoBarcode[row[1]] = sample\n",
      "\n",
      "sequence = 0\n",
      "\n",
      "#Loop through the mothur input file, extract sequence headers and write the groups file\n",
      "with open('Zanne-LSU_aligned.fasta', 'r') as R1file:\n",
      "    with open('LSU.groups', 'w') as Groupsfile:\n",
      "        while 1:\n",
      "            SequenceHeader1= R1file.readline()\n",
      "    \t\tSequence1= R1file.readline()\n",
      "    \t\t\t\n",
      "            if SequenceHeader1 == '': #exit loop when end of file is reached\n",
      "        \t\tbreak\n",
      "\t\t\t\n",
      "            barcode = SequenceHeader1.split(\":\")[7].strip('\\n')\t\n",
      "#mothur replaces ':' with '_'\n",
      "            Groupsfile.write('%s\\t%s' %('_'.join(SequenceHeader1.strip(\">\").strip('\\n').split(\":\")),SampletoBarcode[barcode]))\t\t"
     ],
     "language": "python",
     "metadata": {},
     "outputs": []
    },
    {
     "cell_type": "markdown",
     "metadata": {},
     "source": [
      "```bash\n",
      "mothur > remove.seqs(accnos=Zanne_LSU_aligned.trim.unique.slayer.accnos, name=Zanne-LSU_aligned.trim.names)\n",
      "\n",
      "Output File Names: \n",
      "Zanne-LSU_aligned.trim.pick.names\n",
      "\n",
      "\n",
      "mothur > remove.seqs(accnos=Zanne_LSU_aligned.trim.unique.slayer.accnos, group=LSU.groups)\n",
      "\n",
      "Output File Names: \n",
      "LSU.pick.groups\n",
      "\n",
      "mothur > remove.seqs(accnos=Zanne_LSU_aligned.trim.unique.slayer.accnos, fasta=Zanne_LSU_aligned.trim.unique.align)\n",
      "\n",
      "Output File Names: \n",
      "Zanne_LSU_aligned.trim.unique.pick.align\n",
      "```\n",
      "####Clean Alignment\n",
      "Check quality of alignment with chimeras removed. \n",
      "\n",
      "```bash\n",
      "mothur > summary.seqs(fasta=Zanne_LSU_aligned.trim.unique.pick.align, processors=15)\n",
      "\n",
      "Using 15 processors.\n",
      "\n",
      "                Start   End     NBases  Ambigs  Polymer NumSeqs\n",
      "Minimum:        0       0       0       0       1       1\n",
      "2.5%-tile:      1       264     195     0       4       129794\n",
      "25%-tile:       18      644     520     0       4       1297937\n",
      "Median:         18      686     543     0       5       2595874\n",
      "75%-tile:       18      954     565     1       5       3893810\n",
      "97.5%-tile:     53      954     569     1       7       5061953\n",
      "Maximum:        972     972     575     1       11      5191746\n",
      "Mean:   25.6089 756.843 517.662 0.420943        4.85864\n",
      "# of Seqs:      5191746\n",
      "```\n",
      "Remove sequences that align after base 53 or are less than 500 bp long.\n",
      "\n",
      "```bash\n",
      "mothur > screen.seqs(fasta=Zanne_LSU_aligned.trim.unique.pick.align, start=53, minlength=500)\n",
      "\n",
      "Output File Names: \n",
      "Zanne_LSU_aligned.trim.unique.pick.good.align\n",
      "Zanne_LSU_aligned.trim.unique.pick.bad.accnos\n",
      "\n",
      "It took 51 secs to screen 5191746 sequences.\n",
      "\n",
      "mothur > summary.seqs(fasta=Zanne_LSU_aligned.trim.unique.pick.good.align)\n",
      "\n",
      "Using 15 processors.\n",
      "\n",
      "                Start   End     NBases  Ambigs  Polymer NumSeqs\n",
      "Minimum:        1       609     500     0       3       1\n",
      "2.5%-tile:      18      632     507     0       4       106087\n",
      "25%-tile:       18      654     530     0       4       1060862\n",
      "Median:         18      721     555     1       5       2121723\n",
      "75%-tile:       18      954     566     1       5       3182584\n",
      "97.5%-tile:     44      954     569     1       7       4137359\n",
      "Maximum:        53      972     575     1       11      4243445\n",
      "Mean:   20.5771 806.123 547.62  0.508047        4.92197\n",
      "# of Seqs:      4243445\n",
      "```\n",
      "Remove regions with only gaps from the alignment\n",
      "\n",
      "```bash\n",
      "mothur > filter.seqs(fasta=Zanne_LSU_aligned.trim.unique.pick.good.align)\n",
      "\n",
      "Length of filtered alignment: 771\n",
      "Number of columns removed: 201\n",
      "Length of the original alignment: 972\n",
      "Number of sequences used to construct filter: 4243445\n",
      "\n",
      "Output File Names: \n",
      "Zanne_LSU_aligned.filter\n",
      "Zanne_LSU_aligned.trim.unique.pick.good.filter.fasta\n",
      "\n",
      "mothur > summary.seqs(fasta=Zanne_LSU_aligned.trim.unique.pick.good.filter.fasta)\n",
      "\n",
      "Using 15 processors.\n",
      "\n",
      "                Start   End     NBases  Ambigs  Polymer NumSeqs\n",
      "Minimum:        1       605     500     0       3       1\n",
      "2.5%-tile:      18      628     507     0       4       106087\n",
      "25%-tile:       18      650     530     0       4       1060862\n",
      "Median:         18      717     555     1       5       2121723\n",
      "75%-tile:       18      754     566     1       5       3182584\n",
      "97.5%-tile:     44      754     569     1       7       4137359\n",
      "Maximum:        53      771     575     1       11      4243445\n",
      "Mean:   20.5771 706.101 547.62  0.508047        4.92197\n",
      "# of Seqs:      4243445\n",
      "\n",
      "Output File Names: \n",
      "Zanne_LSU_aligned.trim.unique.pick.good.filter.summary\n",
      "\n",
      "```\n",
      "Extract sequence names maintained in filtered alignment and subset mothur files to only those names.\n",
      "\n",
      "```bash\n",
      "mothur > list.seqs(fasta=Zanne_LSU_aligned.trim.unique.pick.good.filter.fasta)\n",
      "\n",
      "Output File Names: \n",
      "Zanne_LSU_aligned.trim.unique.pick.good.filter.accnos\n",
      "\n",
      "\n",
      "mothur > get.seqs(accnos=Zanne_LSU_aligned.trim.unique.pick.good.filter.accnos, name=Zanne-LSU_aligned.trim.names) \n",
      "\n",
      "Output File Names: \n",
      "Zanne-LSU_aligned.trim.pick.names\n",
      "\n",
      "\n",
      "mothur > get.seqs(accnos=Zanne_LSU_aligned.trim.unique.pick.good.filter.accnos, name=LSU.groups) \n",
      "\n",
      "Output File Names: \n",
      "LSU.pick.groups\n",
      "\n",
      "```\n",
      "\n",
      "####Phylogenetic Analysis\n",
      "Reconstruct a neighbor joining tree for downstream analysis \n",
      "\n",
      "```bash\n",
      "mothur > clearcut(fasta=Zanne_LSU_aligned.trim.unique.pick.good.filter.fasta, DNA=t, verbose=t)\n",
      "```"
     ]
    }
   ],
   "metadata": {}
  }
 ]
}
