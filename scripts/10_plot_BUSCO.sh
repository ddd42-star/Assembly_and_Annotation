#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=100G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=plot_busco
#SBATCH --mail-user=dario.bassi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --partition=pibu_el8


WORKDIR=/data/users/dbassi/assembly_and_annotation-course
THREADS=$SLURM_CPUS_PER_TASK
OUTPUT_DIR=$WORK_DIR/busco_plots
FLYE_ASSEMBLY=$1
HIFIASM_ASSEMBLY=$2
LJA_ASSEMBLY=$3
TRINITY_ASSEMBLY=$4

# Check if FASTQ_FILE is provided as an argument, otherwise exit with usage message
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
  echo "Usage: $0 <path_to_fastq_file>"
  exit 1
fi

module load BUSCO/5.4.2-foss-2021a

mkdir -p ${OUTPUT_DIR}

cp ${FLYE_ASSEMBLY} $OUTPUT_DIR/short_summary.specific.brassicales_odb10.flye.txt
cp ${HIFIASM_ASSEMBLY} $OUTPUT_DIR/short_summary.specific.brassicales_odb10.hifiasm.txt
cp ${LJA_ASSEMBLY} $OUTPUT_DIR/short_summary.specific.brassicales_odb10.lja.txt
cp ${TRINITY_ASSEMBLY} $OUTPUT_DIR/short_summary.specific.brassicales_odb10.trinity.txt

# download the generate_plot.py script from  GitHub
cd $OUTPUT_DIR
wget https://gitlab.com/ezlab/busco/-/raw/master/scripts/generate_plot.py

python3 generate_plot.py -wd $OUTPUT_DIR