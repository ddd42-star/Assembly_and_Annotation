#!/usr/bin/env bash

#SBATCH --time=02:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=fastqc
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/dbassi/assembly_and_annotation-course/outputs/output_fastqc_%j.o
# define working directory

WORKDIR=/data/users/dbassi/assembly_and_annotation-course
WORK_QC=$WORKDIR/read_QC
THREADS=$SLURM_CPUS_PER_TASK
# Check if FASTQ_FILE is provided as an argument, otherwise exit with usage message
if [ -z "$1" ]; then
  echo "Usage: $0 <path_to_fastq_file>"
  exit 1
fi

# enter main folder
cd $WORKDIR

# make directories
mkdir -p $WORK_QC

# load FASTQC
module load FastQC/0.11.9-Java-11

# make variales name
FILES_QC=$1

fastqc -o $WORK_QC -t $THREADS $FILES_QC