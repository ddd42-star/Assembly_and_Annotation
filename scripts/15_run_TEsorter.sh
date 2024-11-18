#!/usr/bin/env bash

#SBATCH --cpus-per-task=4
#SBATCH --mem=50G
#SBATCH --time=01:00:00
#SBATCH --job-name=EDTA
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=dario.bassi@students.unibe.ch
#SBATCH --output=/data/users/dbassi/assembly_and_annotation-course/outputs/output_TEsorter_%j.o

WORKDIR=/data/users/dbassi/assembly_and_annotation-course
THREADS=$SLURM_CPUS_PER_TASK
CONTAINER_DIR=/data/courses/assembly-annotation-course/containers2/TEsorter_1.3.0.sif
OUTPUT_DIR=$WORKDIR/EDTA_annotation


# Check if FASTQ_FILE is provided as an argument, otherwise exit with usage message
if [ -z "$1" ]; then 
  echo "Usage: $0 <path_to_fastq_file>"
  exit 1
fi

ASSEMBLY_DIR=$1

mkdir -p $OUTPUT_DIR

cd $OUTPUT_DIR

apptainer exec -C --bind $WORKDIR -H ${pwd}:/work \
--writable-tmpfs -u $CONTAINER_DIR TEsorter $ASSEMBLY_DIR -db rexdb-plant