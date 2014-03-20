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
cat unpaired_N.fasta paired.fasta > both.fasta
```
#####3. Create Groups
You will need to create a groups file before running mothur. The groups file links sequence header names with a sample name and can be generated using the makeGroups.py python script. This script requires the same sample file used for amplicon parsing above and your concatonated fasta file. 
```bash
python makeGroups.py -s ZanneAmplicons_MattPipeline.txt -i both.fasta 
```

######The following commands can be run in batch mode from the LSU_mothur_script.sh rather than interactivly in the mothur shell as described below.

#####4. Sequence Processing and Cleanup

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

*Note: mothur has many parameters for quality screening sequence using the [trim.seqs()](http://www.mothur.org/wiki/Trim.seqs) command. Quality screening should be based on the results of the summary.seqs() command for each particular set of sequences.* 

```
mothur > trim.seqs(fasta=Zanne-LSU_aligned.fasta, length=600, maxambig=1, maxhomop=11)

      Output File Names:
      Zanne-LSU_aligned.trim.fasta
      Zanne-LSU_aligned.scrap.fasta
```
Collapse all identical sequences.
     
```
mothur > unique.seqs(fasta=Zanne-LSU_aligned.trim.fasta)
      
      Output File Names: 
      Zanne-LSU_aligned.trim.names
      Zanne-LSU_aligned.trim.unique.fasta
```
#####5. Alignment

Align LSU sequences to a reference LSU alignment. \n",
  
######The reference LSU alignment was generated from the James et al. (2006) Combined data set, 214 taxa, nucleotides alignment available on the [AFTOL website](http://wasabi.lutzonilab.net/pub/alignments/download_alignments). Non fungal taxa were removed from the alignment and the remaining sequences were trimmed down to only the LSU region flanked by the LROR and LR3 primers. Taxa missing this region were removed. The Final alignment can be downladed [here] (https://www.dropbox.com/s/uxstqgyt93wokn4/James_2006_FungiOnly_LSU_LR0R_LR3.fasta.tgz).

```
mothur > align.seqs(candidate=Zanne_LSU_aligned.trim.unique.fasta, template=James_2006_FungiOnly_LSU_LR0R_LR3.fasta, flip=T, processors=10)\n",

      Some of you sequences generated alignments that eliminated too many bases, a list is provided in Zanne_LSU_aligned.trim.unique.flip.accnos. If the reverse compliment proved to be better it was reported.
      It took 2664 secs to align 5252010 sequences.
      
      
      Output File Names: 
      Zanne_LSU_aligned.trim.unique.align
      Zanne_LSU_aligned.trim.unique.align.report
      Zanne_LSU_aligned.trim.unique.flip.accnos
```

#####6. Check for Chimeras

Use chimera slayer and the referance LSU alignment to check for chimeric LSU sequences.
    
```
mothur > chimera.slayer(fasta=Zanne_LSU_aligned.trim.unique.align, template=James_2006_FungiOnly_LSU_LR0R_LR3.fasta, processors=10, blastlocation=/usr/bin/)
      
      It took 29884 secs to check 5252010 sequences.
      
      Output File Names:
      Zanne_LSU_aligned.trim.unique.slayer.chimeras
      Zanne_LSU_aligned.trim.unique.slayer.accnos
```
Remove chimeric sequences from analysis files. 
```
mothur > remove.seqs(accnos=Zanne_LSU_aligned.trim.unique.slayer.accnos, name=Zanne-LSU_aligned.trim.names)
    
      Output File Names:
      Zanne-LSU_aligned.trim.pick.names
      
mothur > remove.seqs(accnos=Zanne_LSU_aligned.trim.unique.slayer.accnos, group=LSU.groups)
      
      Output File Names: 
      LSU.pick.groups
      
mothur > remove.seqs(accnos=Zanne_LSU_aligned.trim.unique.slayer.accnos, fasta=Zanne_LSU_aligned.trim.unique.align)
      
      Output File Names: 
      Zanne_LSU_aligned.trim.unique.pick.align
```
     
#####7. Clean Alignment

Check quality of alignment with chimeras removed.   
```
mothur > summary.seqs(fasta=Zanne_LSU_aligned.trim.unique.pick.align, processors=15)
      
      Using 15 processors.
      
                      Start   End     NBases  Ambigs  Polymer NumSeqs
      Minimum:        0       0       0       0       1       1
      2.5%-tile:      1       264     195     0       4       129794
      25%-tile:       18      644     520     0       4       1297937
      Median:         18      686     543     0       5       2595874
      75%-tile:       18      954     565     1       5       3893810
      97.5%-tile:     53      954     569     1       7       5061953
      Maximum:        972     972     575     1       11      5191746
      Mean:   25.6089 756.843 517.662 0.420943        4.85864
      # of Seqs:      5191746
```
Remove sequences that align after base 53 or are less than 500 bp long.

*Note: mothur has many parameters for quality screening alignments using the [screen.seqs()](http://www.mothur.org/wiki/Screen.seqs) command. Quality screening should be based on the results of the summary.seqs() command for each particular alignment.* 

```
mothur > screen.seqs(fasta=Zanne_LSU_aligned.trim.unique.pick.align, start=53, minlength=500)

      Output File Names: 
      Zanne_LSU_aligned.trim.unique.pick.good.align
      Zanne_LSU_aligned.trim.unique.pick.bad.accnos
      
      It took 51 secs to screen 5191746 sequences.
      
mothur > summary.seqs(fasta=Zanne_LSU_aligned.trim.unique.pick.good.align)
      
      Using 15 processors
      
                      Start   End     NBases  Ambigs  Polymer NumSeqs
      Minimum:        1       609     500     0       3       1
      2.5%-tile:      18      632     507     0       4       106087
      25%-tile:       18      654     530     0       4       1060862
      Median:         18      721     555     1       5       2121723
      75%-tile:       18      954     566     1       5       3182584
      97.5%-tile:     44      954     569     1       7       4137359
      Maximum:        53      972     575     1       11      4243445
      Mean:   20.5771 806.123 547.62  0.508047        4.92197
      # of Seqs:      4243445
```
Remove regions with only gaps from the alignment
```
mothur > filter.seqs(fasta=Zanne_LSU_aligned.trim.unique.pick.good.align)
      
      Length of filtered alignment: 771
      Number of columns removed: 201
      Length of the original alignment: 972
      Number of sequences used to construct filter: 4243445
      
      Output File Names: 
      Zanne_LSU_aligned.filter
      Zanne_LSU_aligned.trim.unique.pick.good.filter.fasta
      
mothur > summary.seqs(fasta=Zanne_LSU_aligned.trim.unique.pick.good.filter.fasta)
      
      Using 15 processors
      
                      Start   End     NBases  Ambigs  Polymer NumSeqs
      Minimum:        1       605     500     0       3       1
      2.5%-tile:      18      628     507     0       4       106087
      25%-tile:       18      650     530     0       4       1060862
      Median:         18      717     555     1       5       2121723
      75%-tile:       18      754     566     1       5       3182584
      97.5%-tile:     44      754     569     1       7       4137359
      Maximum:        53      771     575     1       11      4243445
      Mean:   20.5771 706.101 547.62  0.508047        4.92197
      # of Seqs:      4243445
     
      Output File Names: 
      Zanne_LSU_aligned.trim.unique.pick.good.filter.summary
```
Extract sequence names maintained in filtered alignment and subset mothur files to only those names.
```
mothur > list.seqs(fasta=Zanne_LSU_aligned.trim.unique.pick.good.filter.fasta)
    
      Output File Names: 
      Zanne_LSU_aligned.trim.unique.pick.good.filter.accnos
      
mothur > get.seqs(accnos=Zanne_LSU_aligned.trim.unique.pick.good.filter.accnos, name=Zanne-LSU_aligned.trim.names) 
     
      Output File Names:
      Zanne-LSU_aligned.trim.pick.names
      
mothur > get.seqs(accnos=Zanne_LSU_aligned.trim.unique.pick.good.filter.accnos, group=LSU.groups)
      
      Output File Names: 
      LSU.pick.groups
```
      
#####8. Phylogenetic Analysis
Reconstruct a neighbor joining tree from the LSU alignment. 

*Note: this command did not sucessfully run on a 30 gb ram server for a 5 million sequence alignment.*
```
mothur > clearcut(fasta=Zanne_LSU_aligned.trim.unique.pick.good.filter.fasta, DNA=t, verbose=t)
```
