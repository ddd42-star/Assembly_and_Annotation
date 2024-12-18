#!/bin/bash
#SBATCH --time=7-0
#SBATCH --mem=64G
#SBATCH -p pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=50
#SBATCH --job-name=Maker_gene_annotation
#SBATCH --output=/data/users/dbassi/assembly_and_annotation-course/outputs/output_maker_%j.o


COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
WORKDIR=/data/users/dbassi/assembly_and_annotation-course
THREADS=$SLURM_CPUS_PER_TASK
OUTPUT_DIR=$WORKDIR/maker

REPEATMASKER_DIR="/data/courses/assembly-annotation-course/CDS_annotation/softwares/RepeatMasker"
export PATH=$PATH:"/data/courses/assembly-annotation-course/CDS_annotation/softwares/RepeatMasker"

mkdir -p $OUTPUT_DIR

cd $OUTPUT_DIR

module load OpenMPI/4.1.1-GCC-10.3.0
module load AUGUSTUS/3.4.0-foss-2021a

# maker settings
# apptainer exec --bind /data /data/courses/assembly-annotation-course/CDS_annotation/containers/MAKER_3.01.03.sif maker -CTL

# modifiy maker_opts.ctl adding
# genome path 
# mRNA seq 
# protein homology
# TE protein
# species model

mpiexec --oversubscribe -n 50 apptainer exec --bind $SCRATCH:/TMP --bind /data --bind $AUGUSTUS_CONFIG_PATH --bind $REPEATMASKER_DIR /data/courses/assembly-annotation-course/containers2/MAKER_3.01.03.sif maker -mpi --ignore_nfs_tmp -TMP /TMP maker_opts.ctl maker_bopts.ctl maker_evm.ctl maker_exe.ctl


# Merge the gff and fasta files
$COURSEDIR/softwares/Maker_v3.01.03/src/bin/gff3_merge -s -d $OUTPUT_DIR/assembly.maker.output/assembly_master_datastore_index.log > $OUTPUT_DIR/assembly.all.maker.gff
$COURSEDIR/softwares/Maker_v3.01.03/src/bin/gff3_merge -n -s -d $OUTPUT_DIR/assembly.maker.output/assembly_master_datastore_index.log > $OUTPUT_DIR/assembly.all.maker.noseq.gff
$COURSEDIR/softwares/Maker_v3.01.03/src/bin/fasta_merge -d $OUTPUT_DIR/assembly.maker.output/assembly_master_datastore_index.log -o $OUTPUT_DIR/assembly
