#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=faidx
#SBATCH --time=01:00:00
#SBATCH --mem=4G

# load modules
module load SAMtools/1.13-GCC-10.3.0

# set variables
WORKDIR=/data/users/dbassi/assembly_and_annotation-course
THREADS=$SLURM_CPUS_PER_TASK


# Check if FASTQ_FILE is provided as an argument, otherwise exit with usage message
if [ -z "$1" ]; then 
  echo "Usage: $0 <path_to_fastq_file>"
  exit 1
fi

ASSEMBLY_FLYE=$1

cd $WORKDIR

samtools faidx $ASSEMBLY_FLYE