ACC=GCA_000002985.3
GFF=ncbi_dataset/data/${ACC}/genomic.gff
GENOME=genome.fna
N=10000
R1_sim=sim_reads/wgsim_read1.fq
R2_sim=sim_reads/wgsim_read2.fq	
L=100 # length of the reads
SRA=SRR5828462

#
# Variant calling workflow.
#

# Accession number of c elegans genome.
ACC=GCA_000002985.3

# The reference file.
REF=ncbi_dataset/data/${ACC}/genomic.fna

# The GFF file.
GFF=ncbi_dataset/data/${ACC}/genomic.gff

# The sequencing read accession number.
SRR=SRR5828462

# The number of reads to get
N=500000

# The name of the sample (see: bio search SRR5828462)
SAMPLE=VC50184

# The path to read 1
R1=reads/${SAMPLE}_1.fastq

# The path to read 2
R2=reads/${SAMPLE}_2.fastq

# The resulting BAM file.
BAM=bam/${SAMPLE}.bam

# The resulting variant VCF file (compressed!).
VCF=vcf/${SAMPLE}.vcf.gz

# Custom makefile settings.
SHELL = bash
.ONESHELL:
.SHELLFLAGS = -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# Print the usage of the makefile.
usage:
    @echo "#"
    @echo "# SNP call demonstration"
    @echo "#"
    @echo "# ACC=${ACC}"
    @echo "# SRR=${SRR}"
    @echo "# SAMPLE=${SAMPLE}"
    @echo "# BAM=${BAM}"
    @echo "# VCF=${VCF}"
    @echo "#"
    @echo "# make bam|vcf|all"
    @echo "#"

# Check that the bio toolbox is installed.
CHECK_FILE = src/run/genbank.mk
${CHECK_FILE}:
    @echo "#"
    @echo "# Please install toolbox with: bio code"
    @echo "#"
    @exit 1

# Create the BAM alignment file.
bam: ${CHECK_FILE}
    # Get the reference genome and the annotations.
    make -f src/run/genbank.mk ACC=${ACC} REF=${REF} GFF=${GFF} fasta gff

    # Index the reference genome.
    make -f src/run/bwa.mk REF=${REF} index

    # Download the sequence data.
    make -f src/run/sra.mk SRR=${SRR} R1=${R1} R2=${R2} N=${N} run

    # Align the reads to the reference genome. 
    # Use a sample name in the readgroup.
    make -f src/run/bwa.mk SM=${SAMPLE} REF=${REF} R1=${R1} R2=${R2} BAM=${BAM} run stats

# Call the SNPs in the resulting BAM file.
vcf:
    make -f src/run/bcftools.mk REF=${REF} BAM=${BAM} VCF=${VCF} run

# Run all the steps.
all: bam vcf

# Remove all the generated files.
#clean:
#    rm -rf ${REF} ${GFF} ${R1} ${R2} ${BAM} ${VCF}

# These targets do not correspond to files.
.PHONY: bam vcf all usage #clean
