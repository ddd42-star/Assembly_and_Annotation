# Assembly and Annotation Project

NGS technologies allow researchers to sequence genomes and transcriptomes of almost any organism within a few days. However, the assembly and annotation is still very challenging and requires a deep understanding of assembly algorithms and sequencing technologies.

### Overview
In this course we will assemble and annotate genome from Arabidopsis thaliana. The raw data come from

* Qichao Lian et al. **A pan-genome of 69 Arabidopsis thaliana accessions reveals a conserved genome structure throughout the global species range.** Nature Genetics. 2024;56:982-991. Available from: [https://www.nature.com/articles/s41588-024-01715-9](https://www.nature.com/articles/s41588-024-01715-9)

The accession used for this analysis is *Db-1*

### Datasets

* Whole genome PacBio HiFi reads
* Whole transcriptome Illumina RNA-seq (accession Sha)


## Assembly

### Step 1: Download Illumina Rna seq and Pacbio HIFI
Run the script in SLURM batch script:
``` 
sbatch 01_download_fastqc.sh 
```

### Step 2: Basic read statistics FASTQC
Run the script in SLURM batch script:
``` 
sbatch 02_quality_control.sh <Pacbio or Illumina seq> 
```

### Step 3: Basic read statistics FASTP
Run the script in SLURM batch script:
``` 
sbatch 03_run_fastp.sh <illmina_seq_1> <illumina_seq_2> <pacbio_seq> 
```

### Step 4: K-mer counting
Run the script in SLURM batch script:
``` 
sbatch 04_kmer_count.sh <pacbio trimmed .fastq>
```

### Step 5: Run assembly Flyer
Run the script in SLURM batch script:
``` 
sbatch 05_run_flyer.sh <pacbio trimmed .fastq> 
```

### Step 6: Run assembly Hifiasm
Run the script in SLURM batch script:
``` 
sbatch 06_run_hifiasm.sh  <pacbio trimmed .fastq>
```

### Step 7: Run assembly LJA
Run the script in SLURM batch script:
``` 
sbatch 07_run_lja.sh <pacbio trimmed .fastq>

Note: The software LJA doesn't work for the accession number Db-1
```

### Step 8: Run assembly Trinity
Run the script in SLURM batch script:
``` 
sbatch 08_run_trinity.sh <Illumina Rna seq trimmed 1 .fastq> <Illumina Rna seq trimmed 2 .fastq>
```

### Step 9: Assembly quality BUSCO
Run the script in SLURM batch script:
``` 
sbatch 09_run_BUSCO.sh <genome assembly .fa> <folder name>
 ```

### Step 10: Plot BUSCO result
Run the script in SLURM batch script:
``` 
sbatch 10_plot_BUSCO.sh <flye stats> <hifiasm stats> <lja stats> <trinity stats>
 ```


### Step 11: Assembly quality QUAST
Run the script in SLURM batch script:
``` 
sbatch 11_run_QUAST.sh <genome assembly flye .fa> <genome assembly hifiasm .fa> <genome assembly lja .fa>
 ```
### Step 12: Assembly quality MERCURY
``` 
Find best kkmer
sbatch 12_run_bset_kkmer_MERCURY.sh


sbatch 12_run_MERCURY.sh <genome assembly flye .fa> <genome assembly hifiasm .fa> <genome assembly lja .fa> <Pacbio .fastq>
 ```

### Step 13: Assembly quality comparison
Run the script in SLURM batch script:
``` 
sbatch 13_comparison.sh <genome assembly flye .fa> <genome assembly hifiasm .fa> <genome assembly lja .fa>
```

## Annotation
For this part I choose the assembly obtained from FLYE.
### Step 14: Run EDTA (Transposable Elements annotation)
Run the script in SLURM batch script:
``` 
sbatch 14_run_EDTA.sh <genome assembly flye .fa>
```

### Step 15: Full length LTRs identity
Run the scripts:
``` 
sbatch 15_run_TEsorter.sh <assembly.fasta.mod.LTR.intact.fa>

Rscript 15_LTRS_identity.R
```

### Step 16: Visualizing and comparing TE annotations from EDTA
Run the script in R:
```
sbatch 16_run_fai.sh <assembly.fasta>

Rscript 16_circle_gypsy_copia.R
```

### Step 17: Refining TE Classification with TEsorter
```
sbatch 17_run_TEsorter.sh <assembly.fasta.mod.EDTA.TElib.fa>
```

Run:
```
Rscript 17_abundance_hist.R 
```

to visualize only the clades for the accession *Db-1*

or run:
```
Rscript 17_abundance_hist_multiple.R
```

to visualize the comparison of clades found in *Db-1*, *St0*, *Kar1*, *Had-6bn*, *Rubezhnoe1*

### Step 18: Dynamics of Transposable Elements (TEs)
```
sbatch 18_run_dynamics_TE.sh <assembly.fasta.mod.EDTA.anno/assembly.fasta.mod.out>

Rscript 18_te_landscape.R
```

### Step 19: Phylogenetics
```
sbatch 19_run_phylogenetic.sh
```
Note: Once obtained the ID of all clades, create the file [color.txt](https://itol.embl.de/help/dataset_color_strip_template.txt) and the file [abundance.txt](https://itol.embl.de/help/dataset_simplebar_template.txt). The go on [interactive tree of life](https://itol.embl.de/) and upload the trees for copia and gipsy with their annotation (color + abundance)


### Step 20: Maker
```
sbatch 20_run_maker.sh
```

### Step 21: Filtering and Refining gene annotations
```
sbatch 21_run_filtering_gene_annotation.sh
```

### Step 22: QC annotation - BUSCO
```
sbatch 22_run_BUSCO_gene_annotation.sh

and than

sbatch 22_run_busco_plot_annotation.sh
```

### Step 23: QC annotation - UNIPROT
```
sbatch 23_run_UNIPROT.sh
```

### Step 24: OMArk
```
sbatch 24_run_OMArk.sh
```

### Step 25: Genespace - preparation
```
sbatch 25_run_prepare_genespace.sh
```
Once genespace prepared the subdirectory, copy other accession number gff and fasta file to compare with other groups

### Step 26: Genespace
```
sbatch 26_run_Genespace.sh
```

### Step 27: Orthofinder
```
sbatch 27_orthofinde.sh
```