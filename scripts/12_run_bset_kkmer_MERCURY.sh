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
CONTAINER_DIR=/containers/apptainer/merqury_1.3.sif

export MERQURY="/usr/local/share/merqury"
# find best kmer size
apptainer exec --bind $WORKDIR $CONTAINER_DIR \
sh $MERQURY/best_k.sh 127857096

#genome: 127857096
#tolerable collision rate: 0.001
#18.4471 


