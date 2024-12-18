#!/usr/bin/env bash

#SBATCH --cpus-per-task=4
#SBATCH --mem=50G
#SBATCH --time=10:00:00
#SBATCH --job-name=phylogenetic
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=dario.bassi@students.unibe.ch
#SBATCH --output=/data/users/dbassi/assembly_and_annotation-course/outputs/output_uniprot_%j.o


PROTEIN=/data/users/dbassi/assembly_and_annotation-course/maker/final/longest_proteins.fasta
GFF=/data/users/dbassi/assembly_and_annotation-course/maker/final/filtered.genes.renamed.final.gff3
TRANSCRIPT=/data/users/dbassi/assembly_and_annotation-course/maker/final/longest_transcripts.fasta
WORKDIR=/data/users/dbassi/assembly_and_annotation-course/quality_control_annotation
THREADS=$SLURM_CPUS_PER_TASK
COURSEDIR="/data/courses/assembly-annotation-course"
MAKERBIN="$COURSEDIR/CDS_annotation/softwares/Maker_v3.01.03/src/bin"


module load BLAST+/2.15.0-gompi-2021a

cd $WORKDIR


#makeblastb -in /data/courses/assembly-annotation-course/CDS_annotation/data/uniprot/uniprot_viridiplantae_reviewed.fa -dbtype prot
# this step is already done
blastp -query $PROTEIN -db /data/courses/assembly-annotation-course/CDS_annotation/data/uniprot/uniprot_viridiplantae_reviewed.fa -num_threads $THREADS -outfmt 6 -evalue 1e-10 -out uniprot_analisis

cp $PROTEIN maker_proteins.fasta.Uniprot
cp $GFF filtered.maker.gff3.Uniprot
$MAKERBIN/maker_functional_fasta /data/courses/assembly-annotation-course/CDS_annotation/data/uniprot/uniprot_viridiplantae_reviewed.fa uniprot_analisis $PROTEIN > maker_proteins.fasta.Uniprot
$MAKERBIN/maker_functional_gff /data/courses/assembly-annotation-course/CDS_annotation/data/uniprot/uniprot_viridiplantae_reviewed.fa uniprot_analisis $GFF > filtered.maker.gff3.Uniprot.gff3