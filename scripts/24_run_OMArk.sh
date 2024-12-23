#!/usr/bin/env bash

#SBATCH --cpus-per-task=4
#SBATCH --mem=50G
#SBATCH --time=10:00:00
#SBATCH --job-name=omark
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=dario.bassi@students.unibe.ch
#SBATCH --output=/data/users/dbassi/assembly_and_annotation-course/outputs/output_omark_%j.o

PROTEIN=/data/users/dbassi/assembly_and_annotation-course/maker/final/assembly.all.maker.proteins.fasta.renamed.filtered.fasta
WORKDIR=/data/users/dbassi/assembly_and_annotation-course
OUTPUT_DIR=$WORKDIR/omark

module add Anaconda3/2022.05
# create a conda environment and activate it
#conda create -n OMArk bioconda::omark bioconda::omamer
# IMPORTANT: run it in a active job
conda activate /data/courses/assembly-annotation-course/CDS_annotation/containers/OMArk_conda
# or install the new environtment
module add Anaconda3/2022.05
conda config --add channels conda-forge
conda config --set channel_priority strict
conda install alive-progress
conda install mamba
conda create -n -y OMArk bioconda::omark bioconda::omamer
conda activate OMArk
# install LUCA.h5
mkdir -p $OUTPUT_DIR

cd $OUTPUT_DIR

wget https://omabrowser.org/All/LUCA.h5

omamer search --db LUCA.h5 --query $PROTEIN --out $OUTPUT_DIR/assembly.all.maker.proteins.fasta.renamed.filtered.omamer

# prepare file
touch isoform_list.txt
awk 'BEGIN { FS=OFS="\t" }
    # Skip lines starting with "!"
    /^!/ { next }

    # Extract prefix and ID, store in array grouped by prefix
    {
        split($1, id_parts, "-")
        prefix = id_parts[1] "-" id_parts[2]
        grouped_ids[prefix] = (grouped_ids[prefix] ? grouped_ids[prefix] ";" : "") $1
    }

    # After processing all lines, output grouped IDs
    END {
        for (prefix in grouped_ids) {
            print grouped_ids[prefix]
        }
    }' assembly.all.maker.proteins.fasta.renamed.filtered.omamer > isoform_list.txt 

# run omark
omark -f assembly.all.maker.proteins.fasta.renamed.filtered.omamer \
 -of $PROTEIN \
 -i isoform_list.txt \
 -d LUCA.h5 \
 -o omark_output


# download script
# /data/courses/assembly-annotationcourse/CDS_annotation/softwares/OMArk-0.3.0/utils/omark_contextualize.py

# fragment
python /data/users/dbassi/assembly_and_annotation-course/scripts/omark_contextualize.py fragment -m assembly.all.maker.proteins.fasta.renamed.filtered.omamer -o omark_output/ 
# missing
python /data/users/dbassi/assembly_and_annotation-course/scripts/omark_contextualize.py missing -m assembly.all.maker.proteins.fasta.renamed.filtered.omamer -o omark_output/


# download miniprot
git clone https://github.com/lh3/miniprot
cd miniprot && make

#miniprot -I --gff --outs=0.95 {GENOMIC_FASTA} {SEQ_FASTA} > {MINIPROT_OUTPUT}

miniprot -I --gff --outs=0.95 /data/users/dbassi/assembly_and_annotation-course/assemblies/flye-assembly/assembly.fasta /data/users/dbassi/assembly_and_annotation-course/omark/fragment_output.fa > miniprot_fragment_correction.gff

miniprot -I --gff --outs=0.95 /data/users/dbassi/assembly_and_annotation-course/assemblies/flye-assembly/assembly.fasta /data/users/dbassi/assembly_and_annotation-course/omark/missing_output.fa > miniprot_fragment_correction.gff