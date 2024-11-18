#!/usr/bin/env bash

#SBATCH --mail-user=dario.bassi@students.unibe.ch
#SBATCH --output=/data/users/dbassi/annotation_course/outputs/output_edta_%j.o

#SBATCH --cpus-per-task=32
#SBATCH --mem=100G
#SBATCH --time=2-00:00:00
#SBATCH --job-name=EDTA
#SBATCH --partition=pibu_el8

WORKDIR=/data/users/dbassi/assembly_and_annotation-course
THREADS=$SLURM_CPUS_PER_TASK


# Check if FASTQ_FILE is provided as an argument, otherwise exit with usage message
if [ -z "$1" ]; then
  echo "Usage: $0 <path_to_fastq_file>"
  exit 1
fi

GENOME=$1
OUTPUT_DIR=$WORKDIR/EDTA_annotation

mkdir -p ${$OUTPUT_DIR}

cd $OUTPUT_DIR

apptainer exec \
--bind /usr/bin/which:/usr/bin/which \
--bind /data \
/data/courses/assembly-annotation-course/containers2/EDTA_v1.9.6.sif \
EDTA.pl \
--genome $GENOME \
--species others \
--step all \
--cds /data/courses/assembly-annotation-course/CDS_annotation/data/TAIR10_cds_20110103_representative_gene_model_updated \
--anno 1 \
--threads $THREADS

#module load Anaconda3/2022.05


#conda env create -f EDTA_2.2.x.yml
#conda activate EDTA2
#perl EDTA.pl \
# --genome $GENOME \ # The genome FASTA file
# --species others \ # Specify 'others' for non Rice or Maize genomes
# --step all \ # Run all steps of TE annotation
# --cds /data/courses/assembly-annotation-course/CDS_annotation/data/TAIR10_cds_20110103_representative_gene_model_updated \ # CDS file for gene masking
# --anno 1 \ # Perform whole-genome TE annotation
# --threads $THREADS # Number of threads for multi-core processing


