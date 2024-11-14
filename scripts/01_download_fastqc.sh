#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/dbassi/assembly_and_annotation-course/outputs/output_download_%j.o

# enter folder
cd /data/users/dbassi/assembly_and_annotation-course

mkdir -p raw_data

# enter the new directory
cd raw_data

# create the soft link for the raw data
ln -s /data/courses/assembly-annotation-course/raw_data/Db-1 ./ # change Accession number
ln -s /data/courses/assembly-annotation-course/raw_data/RNAseq_Sha ./

# checks that you get 2 folders with the name of the accession number and RNAseq_Sha
# with inside the fastq files