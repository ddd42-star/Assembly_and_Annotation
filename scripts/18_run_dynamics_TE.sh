#!/usr/bin/env bash

#SBATCH --cpus-per-task=4
#SBATCH --mem=50G
#SBATCH --time=10:00:00
#SBATCH --job-name=EDTA
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=dario.bassi@students.unibe.ch
#SBATCH --output=/data/users/dbassi/assembly_and_annotation-course/outputs/output_TE_dynamics_%j.o


WORKDIR=/data/users/dbassi/assembly_and_annotation-course
THREADS=$SLURM_CPUS_PER_TASK
CONTAINER_DIR=/data/courses/assembly-annotation-course/containers2/TEsorter_1.3.0.sif



module add BioPerl/1.7.8-GCCcore-10.3.0

# Check if FASTQ_FILE is provided as an argument, otherwise exit with usage message
if [ -z "$1" ]; then
  echo "Usage: $0 <path_to_fastq_file>"
  exit 1
fi

ASSEMBLY_FLYE=$1  # $WORKDIR/EDTA_annotation/assembly.fasta.mod.EDTA.anno/assembly.fasta.mod.out

perl $WORKDIR/scripts/18_parseRM.pl -i $ASSEMBLY_FLYE -l 50,1 -v