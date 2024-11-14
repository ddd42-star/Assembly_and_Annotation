#!/usr/bin/env bash

#SBATCH --cpus-per-task=64
#SBATCH --mem=200G
#SBATCH --time=3-00:00:00
#SBATCH --job-name=hifiasm
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=dario.bassi@students.unibe.ch
#SBATCH --output=/data/users/dbassi/assembly_and_annotation-course/outputs/output_hifiasm_%j.o


WORKDIR=/data/users/dbassi/assembly_and_annotation-course
THREADS=$SLURM_CPUS_PER_TASK

# Check if FASTQ_FILE is provided as an argument, otherwise exit with usage message
if [ -z "$1" ]; then
  echo "Usage: $0 <path_to_fastq_file>"
  exit 1
fi

GENOMIC_INPUT=$1
ASSEMBLIES_DIR=$WORKDIR/assemblies/hifiasm-assembly

# create directory for the assemblies
mkdir -p ${ASSEMBLIES_DIR}

apptainer exec --bind /data /containers/apptainer/hifiasm_0.19.8.sif hifiasm -o $ASSEMBLIES_DIR/pacbio.asm -t $THREADS $GENOMIC_INPUT

# change output to fasta format
awk '/^S/{print ">"$2;print $3}' $ASSEMBLIES_DIR/pacbio.asm.bp.p_ctg.gfa > $ASSEMBLIES_DIR/pacbio.asm.bp.p_ctg.fa

