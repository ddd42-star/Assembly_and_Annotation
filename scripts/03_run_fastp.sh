#!/usr/bin/env bash

#SBATCH --time=02:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=fastqc
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/dbassi/assembly_and_annotation-course/outputs/output_fastp_%j.o


# define working directory
WORKDIR=/data/users/dbassi/assembly_and_annotation-course
THREADS=$SLURM_CPUS_PER_TASK

# Check if FASTQ_FILE is provided as an argument, otherwise exit with usage message
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Usage: $0 <path_to_fastq_file>"
  exit 1
fi

# assign variable
ILLUMINA_RNASEQ_F1=$1
ILLUMINA_RNASEQ_F2=$2
PACBIO=$3

# create output dir
OUTPUT_DIR_ILLUMINA=$WORKDIR/read_QC/illumina_fastp
OUTPUT_DIR_PACBIO=$WORKDIR/read_QC/pacbio_fastp

# make directories
mkdir -p ${OUTPUT_DIR_ILLUMINA}
mkdir -p ${OUTPUT_DIR_PACBIO}

# load FASTQC
module load fastp/0.23.4-GCC-10.3.0

# get filename
ILLUMINA_RNASEQ_F1_without_extension="${ILLUMINA_RNASEQ_F1##*/}"  # Remove leading directories
ILLUMINA_RNASEQ_F1_without_extension="${ILLUMINA_RNASEQ_F1_without_extension%.txt}"  # Remove .txt extension

ILLUMINA_RNASEQ_F2_without_extension="${ILLUMINA_RNASEQ_F2##*/}"  # Remove leading directories
ILLUMINA_RNASEQ_F2_extension="${ILLUMINA_RNASEQ_F2_without_extension%.txt}"  # Remove .txt extension

PACBIO_without_extension="${PACBIO##*/}"  # Remove leading directories
PACBIO_without_extension="${PACBIO_without_extension%.txt}"  # Remove .txt extension

echo "Start trimming of Illumina Rna seq"

# run fastp for illumina seq (paired end)
fastp \
 --detect_adapter_for_pe \
 -q 25 \
 -w $THREADS \
 -f 13 -t 10 -F 13 -T 10 -D \
 -i ${ILLUMINA_RNASEQ_F1} \
 -I ${ILLUMINA_RNASEQ_F2} \
 -o ${OUTPUT_DIR_ILLUMINA}/${ILLUMINA_RNASEQ_F1_without_extension}.trimmed.fastp.gz \
 -O ${OUTPUT_DIR_ILLUMINA}/${ILLUMINA_RNASEQ_F2_without_extension}.trimmed.fastp.gz \
 --html ${OUTPUT_DIR_ILLUMINA}/fastp_report.html \
 --json ${OUTPUT_DIR_ILLUMINA}/fastp_report.json

echo "End trimming of Illumina Rna seq"

echo "Start trimming of Pacbio Hifi seq"

# run fastp for pacbio (no filtering!)
fastp \
 --disable_length_filtering \
 -w $THREADS \
 -i ${PACBIO} \
 -o ${OUTPUT_DIR_PACBIO}/${PACBIO_without_extension}.trimmed.fastp.gz \
 --html ${OUTPUT_DIR_PACBIO}/fastp_report.html \
 --json ${OUTPUT_DIR_PACBIO}/fastp_report.json

echo "End trimming of Pacbio Hifi seq"

