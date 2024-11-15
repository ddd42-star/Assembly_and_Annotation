#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=100G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=Flye_quast
#SBATCH --mail-user=dario.bassi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/dbassi/assembly_and_annotation-course/outputs/output_mercury_%j.o


WORKDIR=/data/users/dbassi/assembly_and_annotation-course
THREADS=$SLURM_CPUS_PER_TASK
OUTPUT_DIR=$WORKDIR/evaluation/mercury

# Check if FASTQ_FILE is provided as an argument, otherwise exit with usage message
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
  echo "Usage: $0 <path_to_fastq_file>"
  exit 1
fi

ASSEMBLY_FLYE=$1
ASSEMBLY_HIFIASM=$2
ASSEMBLY_LJA=$3
PACBIO=$4

# create output directory
mkdir -p ${OUTPUT_DIR}

CONTAINER_DIR=/containers/apptainer/merqury_1.3.sif

export MERQURY="/usr/local/share/merqury"

mkdir -p $OUTPUT_DIR 
# Count k-mer frequencies
# k=19 based on  output
K=19
apptainer exec --bind $WORKDIR $CONTAINER_DIR \
meryl k=$K count ${PACBIO} output $OUTPUT_DIR/genome.meryl

cd $OUTPUT_DIR

apptainer exec --bind $WORKDIR $CONTAINER_DIR \
sh $MERQURY/merqury.sh $OUTPUT_DIR/genome.meryl ${ASSEMBLY_FLYE} flye

apptainer exec --bind $WORKDIR $CONTAINER_DIR \
sh $MERQURY/merqury.sh $OUTPUT_DIR/genome.meryl ${ASSEMBLY_HIFIASM} hifiasm

apptainer exec --bind $WORKDIR $CONTAINER_DIR \
sh $MERQURY/merqury.sh $OUTPUT_DIR/genome.meryl ${ASSEMBLY_LJA} lja