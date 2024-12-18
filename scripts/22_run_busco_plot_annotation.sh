#!/usr/bin/env bash

#SBATCH --time=01:00:00
#SBATCH --mem=10G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=plot_busco
#SBATCH --mail-user=dario.bassi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/dbassi/assembly_and_annotation-course/outputs/output_plot_busco_%j.o

WORKDIR=/data/users/dbassi/assembly_and_annotation-course
THREADS=$SLURM_CPUS_PER_TASK
OUTPUT_DIR=$WORKDIR/quality_control_annotation/busco_plots

module load BUSCO/5.4.2-foss-2021a

mkdir -p ${OUTPUT_DIR}

cp /data/users/dbassi/assembly_and_annotation-course/quality_control_annotation/busco_protein_output/short_summary.specific.brassicales_odb10.busco_protein_output.txt $OUTPUT_DIR/short_summary.specific.brassicales_odb10.protein.txt
cp /data/users/dbassi/assembly_and_annotation-course/quality_control_annotation/busco_transcirpt_output/short_summary.specific.brassicales_odb10.busco_transcirpt_output.txt $OUTPUT_DIR/short_summary.specific.brassicales_odb10.transcript.txt
#cp ${LJA_ASSEMBLY} $OUTPUT_DIR/short_summary.specific.brassicales_odb10.lja.txt
cp ${TRINITY_ASSEMBLY} $OUTPUT_DIR/short_summary.specific.brassicales_odb10.trinity.txt

# download the generate_plot.py script from  GitHub
cd $OUTPUT_DIR
wget https://gitlab.com/ezlab/busco/-/raw/master/scripts/generate_plot.py

python3 generate_plot.py -wd $OUTPUT_DIR