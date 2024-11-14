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
Run the script in SLURM batch script:\
``` sbatch 01_download_fastqc.sh ```

### Step 2: Basic read statistics FASTQC
Run the script in SLURM batch script:\
Example:\
``` sbatch 02_quality_control.sh /data/users/dbassi/assembly_and_annotation-course/raw_data/<folder_seq>/<file_seq> ```

### Step 3: Basic read statistics FASTP
Run the script in SLURM batch script:\
Example:\
``` sbatch 03_run_fastp.sh <illmina_seq_1> <illumina_seq_2> <pacbio_seq> ```

### Step 4: K-mer counting
Run the script in SLURM batch script:\
Example:\
``` sbatch sbatch 04_kmer_count.sh /data/users/dbassi/assembly_and_annotation-course/raw_data/<assesor-id>/<pacbio hifi> ```

### Step 5: Run assembly Flyer
Run the script in SLURM batch script:\
Example:\
``` sbatch sbatch 05_run_flyer.sh /data/users/dbassi/assembly_and_annotation-course/raw_data/<assesor-id>/<pacbio hifi> ```

### Step 6: Run assembly Hifiasm
Run the script in SLURM batch script:\
Example:\
``` sbatch sbatch 06_run_hifiasm.sh /data/users/dbassi/assembly_and_annotation-course/raw_data/<assesor-id>/<pacbio hifi> ```

### Step 7: Run assembly LJA
Run the script in SLURM batch script:\
Example:\
``` sbatch sbatch 07_run_lja.sh /data/users/dbassi/assembly_and_annotation-course/raw_data/<assesor-id>/<pacbio hifi> ```

### Step 8: Run assembly Trinity
Run the script in SLURM batch script:\
Example:\
``` sbatch sbatch 08_run_trinity.sh /data/users/dbassi/assembly_and_annotation-course/raw_data/<assesor-id>/<pacbio hifi> ```


## Annotation