#!/usr/bin/env bash

#SBATCH --cpus-per-task=4
#SBATCH --mem=50G
#SBATCH --time=10:00:00
#SBATCH --job-name=omark
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=dario.bassi@students.unibe.ch
#SBATCH --output=/data/users/dbassi/assembly_and_annotation-course/outputs/output_prep_genespace_%j.o

# load module
module load R/4.1.0-foss-2021a
module load UCSC-Utils/448-foss-2021a
module load MariaDB/10.6.4-GCC-10.3.0

WORKDIR=/data/users/dbassi/assembly_and_annotation-course
RSCRIPT=/data/users/dbassi/assembly_and_annotation-course/scripts/27_parse_Orthofinder.R


Rscript $RSCRIPT