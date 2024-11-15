#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=MUMmer
#SBATCH --mail-user=dario.bassi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/dbassi/assembly_and_annotation-course/outputs/output_comparison_%j.o

WORKDIR=/data/users/dbassi/assembly_and_annotation-course
THREADS=$SLURM_CPUS_PER_TASK
OUTPUT_DIR=$WORKDIR/comparison
REFERENCES=/data/courses/assembly-annotation-course/references
REF_FILE=$REFERENCES/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
CONTAINER_DIR=/containers/apptainer/mummer4_gnuplot.sif

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

# assembly vs reference
apptainer exec --bind /data $CONTAINER_DIR \
nucmer --threads $THREADS --mincluster 1000 --breaklen 1000 --delta $OUTPUT_DIR/flye.delta $REF_FILE $ASSEMBLY_FLYE

apptainer exec --bind /data $CONTAINER_DIR \
nucmer --threads $THREADS --mincluster 1000 --breaklen 1000 --delta $OUTPUT_DIR/hifiasm.delta $REF_FILE $ASSEMBLY_HIFIASM

#apptainer exec --bind /data $CONTAINER_DIR \
#nucmer --threads $THREADS --mincluster 1000 --breaklen 1000 --delta $OUTPUT_DIR/lja.delta $REF_FILE $ASSEMBLY_LJA

# mummerplots
apptainer exec --bind /data $CONTAINER_DIR \
mummerplot -R $REF_FILE -Q $ASSEMBLY_FLYE --fat --layout --filter --breaklen 1000 -t png --large -p $OUTPUT_DIR/flye_plot $OUTPUT_DIR/flye.delta

apptainer exec --bind /data $CONTAINER_DIR \
mummerplot -R $REF_FILE -Q $ASSEMBLY_HIFIASM --fat --layout --filter --breaklen 1000 -t png --large -p $OUTPUT_DIR/hifiasm_plot $OUTPUT_DIR/hifiasm.delta

#apptainer exec --bind /data $CONTAINER_DIR \
#mummerplot -R $REF_FILE -Q $ASSEMBLY_LJA --fat --layout --filter --breaklen 1000 -t png --large -p $OUTPUT_DIR/lja_plot $OUTPUT_DIR/lja.delta

# assemblies against each other
apptainer exec --bind /data $CONTAINER_DIR \
nucmer --threads $THREADS --mincluster 1000 --breaklen 1000 --delta $OUTPUT_DIR/flye_vs_hifiasm.delta $ASSEMBLY_FLYE $ASSEMBLY_HIFIASM
apptainer exec --bind /data $CONTAINER_DIR \
mummerplot -R $ASSEMBLY_FLYE -Q $ASSEMBLY_HIFIASM --fat --layout --filter --breaklen 1000 -t png --large -p $OUTPUT_DIR/flye_vs_hifiasm_plot $OUTPUT_DIR/flye_vs_hifiasm.delta

#apptainer exec --bind $WORK_DIR $CONTAINER_DIR \
#nucmer --threads $THREADS --mincluster 1000 --breaklen 1000 --delta $OUTPUT_DIR/flye_vs_lja.delta $INPUT_DIR/flye/assembly.fasta $INPUT_DIR/lja/assembly.fasta
#apptainer exec --bind $WORK_DIR $CONTAINER_DIR \
#mummerplot -R $INPUT_DIR/flye/assembly.fasta -Q $INPUT_DIR/lja/assembly.fasta --fat --layout --filter --breaklen 1000 -t png --large -p $OUTPUT_DIR/flye_vs_lja_plot $OUTPUT_DIR/flye_vs_lja.delta

#apptainer exec --bind $WORK_DIR $CONTAINER_DIR \
#nucmer --threads $THREADS --mincluster 1000 --breaklen 1000 --delta $OUTPUT_DIR/hifiasm_vs_lja.delta $INPUT_DIR/hifiasm/PacBioHiFi_trimmed.asm.bp.p_ctg.fa $INPUT_DIR/lja/assembly.fasta
#apptainer exec --bind $WORK_DIR $CONTAINER_DIR \
#mummerplot -R $INPUT_DIR/hifiasm/PacBioHiFi_trimmed.asm.bp.p_ctg.fa -Q $INPUT_DIR/lja/assembly.fasta --fat --layout --filter --breaklen 1000 -t png --large -p $OUTPUT_DIR/hifiasm_vs_lja_plot $OUTPUT_DIR/hifiasm_vs_lja.delta

# commented out because i dont have the lja assembly!