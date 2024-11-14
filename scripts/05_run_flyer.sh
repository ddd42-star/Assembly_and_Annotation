#!/usr/bin/env bash

#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --job-name=flye
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=dario.bassi@students.unibe.ch
#SBATCH --output=/data/users/dbassi/assembly_and_annotation-course/outputs/output_flyer_%j.o

WORKDIR=/data/users/dbassi/assembly_and_annotation-course
THREADS=$SLURM_CPUS_PER_TASK

# Check if FASTQ_FILE is provided as an argument, otherwise exit with usage message
if [ -z "$1" ]; then
  echo "Usage: $0 <path_to_fastq_file>"
  exit 1
fi

GENOMIC_INPUT=$1
ASSEMBLIES_DIR=$WORKDIR/assemblies/flye-assembly

# create directory for the assemblies
mkdir -p ${ASSEMBLIES_DIR}

apptainer exec --bind /data /containers/apptainer/flye_2.9.5.sif flye --pacbio-hifi ${GENOMIC_INPUT} -t $THREADS -o $ASSEMBLIES_DIR 