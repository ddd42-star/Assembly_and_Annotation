#!/usr/bin/env bash

#SBATCH --cpus-per-task=16
#SBATCH --mem=100G
#SBATCH --time=2-00:00:00
#SBATCH --job-name=LJA
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=dario.bassi@students.unibe.ch
#SBATCH --output=/data/users/dbassi/assembly_and_annotation-course/outputs/output_lja_%j.o


WORKDIR=/data/users/dbassi/assembly_and_annotation-course
THREADS=$SLURM_CPUS_PER_TASK

# Check if FASTQ_FILE is provided as an argument, otherwise exit with usage message
if [ -z "$1" ]; then
  echo "Usage: $0 <path_to_fastq_file>"
  exit 1
fi

GENOMIC_INPUT=$1
ASSEMBLIES_DIR=$WORKDIR/assemblies/lja-assembly

# create directory for the assemblies
mkdir -p ${ASSEMBLIES_DIR}

apptainer exec \
--bind /data \
/containers/apptainer/lja-0.2.sif \
lja \
-o $ASSEMBLIES_DIR \
--reads $GENOMIC_INPUT \
-t $THREADS

# NOTE
# This script normally does, but with my accession number (Db-1) it cannot build the De Bruji Graph
# See this issue already present the github (https://github.com/AntonBankevich/LJA/issues/21#issuecomment-1074238528)
# I tried to use the 'bug_fix' branch from the repository, but it still didn't work. (git clone https://github.com/AntonBankevich/LJA.git)

