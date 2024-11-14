#!/usr/bin/env bash

#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --job-name=trinity
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=dario.bassi@students.unibe.ch
#SBATCH --output=/data/users/dbassi/assembly_and_annotation-course/outputs/output_trinity_%j.o

WORKDIR=/data/users/dbassi/assembly_and_annotation-course
THREADS=$SLURM_CPUS_PER_TASK

# Check if FASTQ_FILE is provided as an argument, otherwise exit with usage message
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Usage: $0 <path_to_fastq_file>"
  exit 1
fi

GENOMIC_INPUT=$1
ILLUMINA_F1=$2
ILLUMINA_F2=$3

ASSEMBLIES_DIR=$WORKDIR/assemblies/trinity-assembly

# create directory for the assemblies
mkdir -p ${ASSEMBLIES_DIR}

module load Trinity/2.15.1-foss-2021a

Trinity --seqType fq --left $ILLUMINA_F1 --right $ILLUMINA_F2 \
        --CPU $THREADS --max_memory 60G --output $ASSEMBLIES_DIR