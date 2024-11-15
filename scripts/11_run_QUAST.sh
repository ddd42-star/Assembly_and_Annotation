#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=100G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=Flye_quast
#SBATCH --mail-user=dario.bassi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --partition=pibu_el8

WORKDIR=/data/users/dbassi/assembly_and_annotation-course
THREADS=$SLURM_CPUS_PER_TASK
OUTPUT_DIR=$WORKDIR/evaluation
REFERENCES=/data/courses/assembly-annotation-course/references

# Check if FASTQ_FILE is provided as an argument, otherwise exit with usage message
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Usage: $0 <path_to_fastq_file>"
  exit 1
fi

ASSEMBLY_FLYE=$1
ASSEMBLY_HIFIASM=$2
ASSEMBLY_LJA=$3

# create output directory
mkdir -p ${OUTPUT_DIR}

# create soft links for references
ln -s $REFERENCES/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa ${OUTPUT_DIR}
ln -s $REFERENCES/Arabidopsis_thaliana.TAIR10.57.gff3 ${OUTPUT_DIR}

REFERENCES_FA=$OUTPUT_DIR/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
REFERENCES_GFF=$OUTPUT_DIR/Arabidopsis_thaliana.TAIR10.57.gff3

module load QUAST/5.0.2-foss-2021a

# evaluation without references

ASSEMBLIES=(
    "${ASSEMBLY_FLYE}"
    "${ASSEMBLY_HIFIASM}"
    "${ASSEMBLY_LJA}"
)

LABELS="fly,hifiasm,lja"

quast\
 "${ASSEMBLIES[@]}" \
-o $OUTPUT_DIR/no_reference \
--eukaryote \
--large \
-t $THREADS \
--labels $LABELS \
--no-sv

# evaluation with references

quast\
 "${ASSEMBLIES[@]}" \
-o $OUTPUT_DIR/with_reference \
-r ${REFERENCES_FA} \
--features ${REFERENCES_GFF}  \
--eukaryote \
--large \
-t $THREADS \
--labels $LABELS \
--no-sv