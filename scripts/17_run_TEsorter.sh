#!/usr/bin/env bash

#SBATCH --cpus-per-task=32
#SBATCH --mem=100G
#SBATCH --time=2-00:00:00
#SBATCH --job-name=EDTA
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=dario.bassi@students.unibe.ch
#SBATCH --output=/data/users/dbassi/assembly_and_annotation-course/outputs/output_quast_%j.o


WORKDIR=/data/users/dbassi/assembly_and_annotation-course
THREADS=$SLURM_CPUS_PER_TASK

module load SeqKit/2.6.1

CONTAINER_DIR=/data/courses/assembly-annotation-course/CDS_annotation/containers/TEsorter_1.3.0.sif

module load SeqKit/2.6.1

# Check if FASTQ_FILE is provided as an argument, otherwise exit with usage message
if [ -z "$1" ]; then 
  echo "Usage: $0 <path_to_fastq_file>"
  exit 1
fi

ASSEMBLY_FLYE=$1

# Extract Copia sequences
seqkit grep -r -p "Copia" $ASSEMBLY_FLYE > Copia_sequences.fa
# Extract Gypsy sequences
seqkit grep -r -p "Gypsy" $ASSEMBLY_FLYE > Gypsy_sequences.fa

apptainer exec -C --bind /data -H ${pwd}:/work --writable-tmpfs -u $CONTAINER_DIR TEsorter Copia_sequences.fa -db rexdb-plant
apptainer exec -C --bind /data -H ${pwd}:/work --writable-tmpfs -u $CONTAINER_DIR TEsorter Gypsy_sequences.fa -db rexdb-plant


# run TEsorter on the Brassicaceae-specific TE library
# Repeat TEsorter analysis using the Brassicaceae TE database as input file.
seqkit grep -r -p "Copia" /data/courses/assembly-annotation-course/CDS_annotation/data/Brassicaceae_repbase_all_march2019.fasta > Copia_Brassicaceae_sequences.fa
seqkit grep -r -p "Gypsy" /data/courses/assembly-annotation-course/CDS_annotation/data/Brassicaceae_repbase_all_march2019.fasta > Gypsy_Brassicaceae_sequences.fa

apptainer exec --bind $WORKDIR -H ${pwd}:/work $CONTAINER_DIR \
TEsorter Copia_Brassicaceae_sequences.fa -db rexdb-plant

apptainer exec --bind $WORKDIR -H ${pwd}:/work $CONTAINER_DIR \
TEsorter Gypsy_Brassicaceae_sequences.fa -db rexdb-plant