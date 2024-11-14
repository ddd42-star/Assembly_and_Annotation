#!/usr/bin/env bash

#SBATCH --time=02:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=fastqc
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/dbassi/assembly_and_annotation-course/outputs/output_kmer_%j.o

# define working directory
WORKDIR=/data/users/dbassi/assembly_and_annotation-course
THREADS=$SLURM_CPUS_PER_TASK
OUTPUT_DIR=$WORKDIR/read_QC/kkmer

# Check if FASTQ_FILE is provided as an argument, otherwise exit with usage message
if [ -z "$1" ]; then
  echo "Usage: $0 <path_to_fastq_file>"
  exit 1
fi

# Running Jellyfish on PackBio Hifi
# make directories
mkdir -p ${OUTPUT_DIR}

# load FASTQC
module load Jellyfish/2.3.0-GCC-10.3.0
# assign variable
PACBIO_FILE=$1

echo "Starting count"
# Running Jellyfish count on Pacbio count
jellyfish count -C -m 21 -s 5G -t $THREADS -o $OUTPUT_DIR/pacbio_count.jf <(zcat ${PACBIO_FILE})
echo "Count finished!"

echo "Starting histogram"
# Running Jellyfish histo
jellyfish histo -t $THREADS $OUTPUT_DIR/pacbio_count.jf > $OUTPUT_DIR/pacbio_kkmer.histo

echo "Histogram created"