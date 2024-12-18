#!/usr/bin/env bash

#SBATCH --cpus-per-task=4
#SBATCH --mem=50G
#SBATCH --time=01:00:00
#SBATCH --job-name=phylogenetic
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=dario.bassi@students.unibe.ch
#SBATCH --output=/data/users/dbassi/assembly_and_annotation-course/outputs/output_phylogenetic_%j.o


WORKDIR=/data/users/dbassi/assembly_and_annotation-course
THREADS=$SLURM_CPUS_PER_TASK
CONTAINER_DIR=/data/courses/assembly-annotation-course/containers2/TEsorter_1.3.0.sif
BRASSICACEA=/data/courses/assembly-annotation-course/CDS_annotation/data/Brassicaceae_repbase_all_march2019.fasta
OUTPUT_DIR=$WORKDIR/EDTA_annotation/phylogenetic
INPUT_DIR=$WORKDIR/EDTA_annotation/TE_sorter


module load SeqKit/2.6.1
module load Clustal-Omega/1.2.4-GCC-10.3.0
module load FastTree/2.1.11-GCCcore-10.3.0

mkdir -p $OUTPUT_DIR


# copia
grep Ty1-RT $INPUT_DIR/Copia_sequences.fa.rexdb-plant.dom.faa > $OUTPUT_DIR/list_copia.txt #make a list of RT proteins to extract
sed -i 's/>//' $OUTPUT_DIR/list_copia.txt #remove ">" from the header
sed -i 's/ .\+//' $OUTPUT_DIR/list_copia.txt #remove all characters following "empty space" from the header
seqkit grep -f $OUTPUT_DIR/list_copia.txt $INPUT_DIR/Copia_sequences.fa.rexdb-plant.dom.faa -o $OUTPUT_DIR/Copia_RT.fasta
# gypsy
grep Ty3-RT $INPUT_DIR/Gypsy_sequences.fa.rexdb-plant.dom.faa > $OUTPUT_DIR/list_gypsy.txt #make a list of RT proteins to extract
sed -i 's/>//' $OUTPUT_DIR/list_gypsy.txt #remove ">" from the header
sed -i 's/ .\+//' $OUTPUT_DIR/list_gypsy.txt #remove all characters following "empty space" from the header
seqkit grep -f $OUTPUT_DIR/list_gypsy.txt $INPUT_DIR/Gypsy_sequences.fa.rexdb-plant.dom.faa -o $OUTPUT_DIR/Gypsy_RT.fasta

# gypsy brassica
grep Ty3-RT $INPUT_DIR/Gypsy_Brassicaceae_sequences.fa.rexdb-plant.dom.faa > $OUTPUT_DIR/list_brassica_gypsy.txt #make a list of RT proteins to extract
sed -i 's/>//' $OUTPUT_DIR/list_brassica_gypsy.txt #remove ">" from the header
sed -i 's/ .\+//' $OUTPUT_DIR/list_brassica_gypsy.txt #remove all characters following "empty space" from the header
seqkit grep -f $OUTPUT_DIR/list_brassica_gypsy.txt $INPUT_DIR/Gypsy_Brassicaceae_sequences.fa.rexdb-plant.dom.faa -o $OUTPUT_DIR/Brassica_RT_Gypsy.fasta
# copia brassica
grep Ty1-RT $INPUT_DIR/Copia_Brassicaceae_sequences.fa.rexdb-plant.dom.faa > $OUTPUT_DIR/list_brassica_copia.txt #make a list of RT proteins to extract
sed -i 's/>//' $OUTPUT_DIR/list_brassica_copia.txt #remove ">" from the header
sed -i 's/ .\+//' $OUTPUT_DIR/list_brassica_copia.txt #remove all characters following "empty space" from the header
seqkit grep -f $OUTPUT_DIR/list_brassica_copia.txt $INPUT_DIR/Copia_Brassicaceae_sequences.fa.rexdb-plant.dom.faa -o $OUTPUT_DIR/Brassica_RT_Copia.fasta

# Concatanate TEs fasta file from Brassicacea and Arabidopsis
COPIA_FASTA=$OUTPUT_DIR/Copia_RT.fasta
GYPSY_FASTA=$OUTPUT_DIR/Gypsy_RT.fasta
BRASSICA_RT_COPIA=$OUTPUT_DIR/Brassica_RT_Copia.fasta
BRASSICA_RT_GYPSY=$OUTPUT_DIR/Brassica_RT_Gypsy.fasta

# concatanate Copia/Gypsy + Brassica(Copia/Gypsy)
cat $BRASSICA_RT_COPIA $COPIA_FASTA > $OUTPUT_DIR/concatanate_copia.fasta
cat $BRASSICA_RT_GYPSY $GYPSY_FASTA > $OUTPUT_DIR/concatanate_gypsy.fasta

# Shorten identifiers of RT sequences and replace ":" with "_"
sed -i 's/#.\+//' $OUTPUT_DIR/concatanate_copia.fasta
sed -i 's/|.\+//' $OUTPUT_DIR/concatanate_copia.fasta

sed -i 's/#.\+//' $OUTPUT_DIR/concatanate_gypsy.fasta
sed -i 's/|.\+//' $OUTPUT_DIR/concatanate_gypsy.fasta


# Align the sequences with clustal omega

clustalo -i $OUTPUT_DIR/concatanate_gypsy.fasta -o $OUTPUT_DIR/gypsy_alignment.fasta 

clustalo -i $OUTPUT_DIR/concatanate_copia.fasta -o $OUTPUT_DIR/copia_alignment.fasta

# Infer approximately-maximum-likelihood phylogenetic tree with FastTree

FastTree -out $OUTPUT_DIR/tree_gypsy $OUTPUT_DIR/gypsy_alignment.fasta 

FastTree -out $OUTPUT_DIR/tree_copia $OUTPUT_DIR/copia_alignment.fasta


GYPSY_DIR=$INPUT_DIR/Gypsy_sequences.fa.rexdb-plant.cls.tsv
COPIA_DIR=$INPUT_DIR/Copia_sequences.fa.rexdb-plant.cls.tsv
GYPSY_BRASS=$INPUT_DIR/Gypsy_Brassicaceae_sequences.fa.rexdb-plant.cls.tsv
COPIA_BRASS=$INPUT_DIR/Copia_Brassicaceae_sequences.fa.rexdb-plant.cls.tsv

SUMMARY_DIR=/data/users/dbassi/assembly_and_annotation-course/EDTA_annotation/assembly.fasta.mod.EDTA.TEanno.sum

COLOR_DIR=/data/users/dbassi/assembly_and_annotation-course/EDTA_annotation/color_strips

mkdir -p $COLOR_DIR
cd $COLOR_DIR

grep -h -e "Athila" $GYPSY_DIR $GYPSY_BRASS | cut -f 1 | sed 's/:/_/' | sed 's/#.*//' | sed 's/$/ #1f77b4 Athila/' > Athila_ID.txt
grep -h -e "Ale" $COPIA_DIR $COPIA_BRASS | cut -f 1 | sed 's/:/_/' | sed 's/#.*//' | sed 's/$/ #1f77b4 Ale/' > Ale_ID.txt
grep -h -e "Angela" $COPIA_DIR $COPIA_BRASS | cut -f 1 | sed 's/:/_/' | sed 's/#.*//' | sed 's/$/ #ff7f0e Angela/' > Angela_ID.txt
grep -h -e "Bianca" $COPIA_DIR $COPIA_BRASS | cut -f 1 | sed 's/:/_/' | sed 's/#.*//' | sed 's/$/ #2ca02c Bianca/' > Bianca_ID.txt
grep -h -e "Ikeros" $COPIA_DIR $COPIA_BRASS | cut -f 1 | sed 's/:/_/' | sed 's/#.*//' | sed 's/$/ #d62728 Ikeros/' > Ikeros_ID.txt
grep -h -e "Ivana" $COPIA_DIR $COPIA_BRASS | cut -f 1 | sed 's/:/_/' | sed 's/#.*//' | sed 's/$/ #9467bd Ivana/' > Ivana_ID.txt
grep -h -e "SIRE" $COPIA_DIR $COPIA_BRASS | cut -f 1 | sed 's/:/_/' | sed 's/#.*//' | sed 's/$/ #8c564b SIRE/' > SIRE_ID.txt
grep -h -e "Tork" $COPIA_DIR $COPIA_BRASS | cut -f 1 | sed 's/:/_/' | sed 's/#.*//' | sed 's/$/ #e377c2 Tork/' > Tork_ID.txt
grep -h -e "CRM" $GYPSY_DIR $GYPSY_BRASS | cut -f 1 | sed 's/:/_/' | sed 's/#.*//' | sed 's/$/ #ff7f0e CRM/' > CRM_ID.txt
grep -h -e "Reina" $GYPSY_DIR $GYPSY_BRASS | cut -f 1 | sed 's/:/_/' | sed 's/#.*//' | sed 's/$/ #2ca02c Reina/' > Reina_ID.txt
grep -h -e "Retand" $GYPSY_DIR $GYPSY_BRASS | cut -f 1 | sed 's/:/_/' | sed 's/#.*//' | sed 's/$/ #d62728 Retand/' > Retand_ID.txt
grep -h -e "Tekay" $GYPSY_DIR $GYPSY_BRASS | cut -f 1 | sed 's/:/_/' | sed 's/#.*//' | sed 's/$/ #9467bd Tekay/' > Tekay_ID.txt
grep -h -e "unknown" $GYPSY_DIR $GYPSY_BRASS | cut -f 1 | sed 's/:/_/' | sed 's/#.*//' | sed 's/$/ #8c564b unknown/' > unknown_ID.txt
grep -h -e "mixture" $GYPSY_DIR $GYPSY_BRASS | cut -f 1 | sed 's/:/_/' | sed 's/#.*//' | sed 's/$/ #bcbd22 mixture/' > mixture_ID.txt
grep -h -e "Alesia" $COPIA_DIR $COPIA_BRASS | cut -f 1 | sed 's/:/_/' | sed 's/#.*//' | sed 's/$/ #17becf Alesia/' > Alesia_ID.txt
grep -h -e "TAR" $GYPSY_DIR $GYPSY_BRASS | cut -f 1 | sed 's/:/_/' | sed 's/#.*//' | sed 's/$/ #7f7f7f TAR/' > TAR_ID.txt

# summary counts file
#tail -n +35 $SUMMARY_DIR | head -n -48 | awk '{print $1 "," $2}' > counts.txt
# another option
awk '{if($1 ~ /TE_/ && $2 ~ /^[0-9]+$/) print $1 "," $2}' $SUMMARY_DIR > TE_abundance.txt