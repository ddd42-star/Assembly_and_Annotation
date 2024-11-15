#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=100G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=busco
#SBATCH --mail-user=dario.bassi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/dbassi/assembly_and_annotation-course/outputs/output_busco_%j.o


WORKDIR=/data/users/dbassi/assembly_and_annotation-course
THREADS=$SLURM_CPUS_PER_TASK

# Check if FASTQ_FILE is provided as an argument, otherwise exit with usage message
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <path_to_fastq_file>"
  exit 1
fi

GENOME=$1
ASSEMBLIES_DIR=$WORKDIR/$2
OUTPUT_DIR=$WORKDIR/$2/out

# create directory for the assemblies
mkdir -p ${OUTPUT_DIR}

module load BUSCO/5.4.2-foss-2021a

busco \
 -i ${GENOME} \
 -o $OUTPUT_DIR \
 -m genome \
 -l brassicales_odb10 \
 --cpu $THREADS \
 -f 