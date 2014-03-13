#This is a batch file of MOTHUR commands for processing MiSeq LSU amplicon data. If the LSU data was generated as part of a MiSeq run where multiple amplicons were sequenced for the same sample you will first need to parse the LSU reads from the other amplicons using the dbcAmplicon python script: https://github.com/msettles/dbcAmplicons. The parsed LSU reads should be assembled or concatonated using PandaSeq. The MOTHUR analysis is performed on assembled/concatonated reads. Before running the MOTHUR analysis you will need to create a groups file. The groups file links sequence header names #with a sample name. The python script makeGroups.py will do this.   

#The LSU analysis was completed following the MOTHUR Tutorial for Fungal Community Analysis (http://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=3&cad=rja&uact=8&ved=0CDUQFjAC&url=http%3A%2F%2Fwww.bio.utk.edu%2Ffesin%2FFESIN2010%2FWorkshop2010%2FAmend%2FMothur_tutorial.pdf&ei=Op4gU9KgD8ONygHf4YHABg&usg=AFQjCNHEw42nzCoTvlYJkjJSk_F2OlQ9Wg&sig2=Hj3c2yL7MKHn3cnZGJ3big&bvm=bv.62788935,d.aWc) with a few modifications.

#REPLACE "YOUR-LSU-FILE" WITH THE NAME OF YOUR LSU SEQUENCE FILE

#Sequence Processing and Cleanup
#Look at the quality of LSU sequences.
summary.seqs(fasta=YOUR-LSU-FILE, processors=10)

#Clean up sequences by removing all sequences that are shorter than 300 bp, have more than 1 ambiguity or homopolymers that are longer than 8 bases.
trim.seqs(fasta=current, minlength=300, maxambig=1, maxhomop=8)

#Collapse all identical sequences.
unique.seqs(fasta=current)

#Alignment
#Align sequences to a reference LSU alignment. 
      
#The reference LSU alignment was generated from the James et al. (2006) Combined data set, 214 taxa, nucleotides alignment available on the AFTOL website: http://wasabi.lutzonilab.net/pub/alignments/download_alignments. Non fungal taxa were removed from the alignment and the remaining sequences were trimmed down to only the LSU region flanked by the LROR and LR3 primers. Taxa missing this region were removed. The Final alignment can be downladed here: https://www.dropbox.com/s/uxstqgyt93wokn4/James_2006_FungiOnly_LSU_LR0R_LR3.fasta.tgz.
     
align.seqs(candidate=current, template=James_2006_FungiOnly_LSU_LR0R_LR3.fasta, flip=T, processors=10)
      
#Check for Chimeras
#Use chimera slayer and the referance LSU alignment to check for chimeric LSU sequences.
     
chimera.slayer(fasta=current, template=James_2006_FungiOnly_LSU_LR0R_LR3.fasta, processors=10, blastlocation=/usr/bin/)
 
#Remove chimeric sequences from analysis files.

remove.seqs(accnos=current, name=current)
remove.seqs(accnos=current, group=LSU.groups)
remove.seqs(accnos=current, fasta=current)

#Clean Alignment
#It is best to inspect the alignment stats and make decisions for screening the alignment based on this inspection. To summarize alignment statistics run: summary.seqs(fasta=MY-ALIGNMENT-FILE, processors=15)
      
#Without inspecting the alignment before filtering out poorly aligned sequences this command can be used to optamize the alignment based on the starting position of 90% of the aligned sequences.

screen.seqs(fasta=current, optimize=start, criteria=90)     

#Remove regions with only gaps from the alignment.

filter.seqs()

#Extract sequence names maintained in filtered alignment and subset mothur files to only those names.

list.seqs()

get.seqs(accnos=current, name=current)
get.seqs(accnos=current, groups=current)

#Phylogenetic Analysis
#Reconstruct a neighbor joining tree for downstream analysis. This did not work with a 5 million sequence alignment on a 30 gb ram computer. 

clearcut(fasta=current, DNA=t, verbose=t)
