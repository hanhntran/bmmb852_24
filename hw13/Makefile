#
# Variant calling workflow with mapping and read counting.
#

# Accession number of c elegans genome.
ACC=GCA_000002985.3

# The reference file.
REF=ncbi_dataset/data/${ACC}/genomic.fna

# The GFF file.
GFF=ncbi_dataset/data/${ACC}/genomic.gff

# The sequencing read accession number.

# The number of reads to get
N=500000

# The name of the sample (see: bio search SRR5828462)
#SAMPLE=VC50184

# The path to read 1
R1=reads/${SRR}_1.fastq

# The path to read 2
R2=reads/${SRR}_2.fastq

# The resulting BAM file.
BAM=bam/${SAMPLE}.bam

# The resulting variant VCF file (compressed!).
VCF=vcf/${SAMPLE}.vcf.gz

# Count matrix file
COUNT_MATRIX=count_matrix.txt

# print help message
help:
	@echo "# ACC=${ACC}"
	@echo "make info      # summary information on the genome"
	@echo "make download  # download the genome file"
	@echo "make simulate  # simulate the reads"
	@echo "make fastqc    # run fastqc"
	@echo "make trim      # run fastp to trim the reads"
	@echo "make align     # align the reads to the genome"
	@echo "make count     # count reads using featureCounts"
	@echo "make all       # run all the steps"
	@echo "make unaligned_reads # count the unaligned reads"
	@echo "make alignment_types # count the alignment types"
	@echo "make properly_paired_reverse # count the properly paired reverse alignments"
	@echo "make filter_bam # filter the BAM file"
	@echo "make compare_flagstats # compare the flagstats between original and filtered BAM files"
	@echo "make vcf # call the variants"
	@echo "make vep # run VEP"

# print the summary information of the genome
info:
	@datasets summary genome accession ${ACC} | jq

# download the genome file and unzip
${GFF}:
	datasets download genome accession ${ACC} --include gff3
	# never overwrite file when unzipping
	unzip -n ncbi_dataset.zip

# create genome symlink
genome: ${GFF}
	cp ./ncbi_dataset/data/${ACC}/*.fna ./genome.fna

# simulate the reads
simulate:
	mkdir -p sim_reads
	wgsim -N ${N} -1 ${L} -2 ${L} -r 0 -R 0 -X 0 ${GENOME} ${R1_sim} ${R2_sim}

# download the reads
download:
	mkdir -p reads
	fastq-dump -X ${N} -F --outdir reads --split-files ${SRR}

# run fastqc
fastqc:
	mkdir -p reports
	fastqc -q ${R1} -o reports

# run fastp to trim the reads
trim:
	mkdir -p trim
	fastp --cut_tail -i ${R1} -I ${R2} -o trim/${SAMPLE}_1.trimmed.fastq -O trim/${SAMPLE}_2.trimmed.fastq
	fastqc -q trim/${SAMPLE}_1.trimmed.fastq -o reports

# index the genome
index:
	bwa index genome.fna

# align the reads to the genome
align: index
	mkdir -p bam
	bwa mem -t 4 genome.fna trim/${SAMPLE}_1.trimmed.fastq trim/${SAMPLE}_2.trimmed.fastq > bam/${SAMPLE}.sam
	samtools view -b -o bam/${SAMPLE}.bam bam/${SAMPLE}.sam
	samtools sort -o bam/${SAMPLE}.sorted.bam bam/${SAMPLE}.bam
	samtools index bam/${SAMPLE}.sorted.bam

# count reads using featureCounts
count:
	mkdir -p counts
	featureCounts -a ${GFF} -o counts/${SAMPLE}_count.txt -t gene -g ID bam/*.sorted.bam

# Define a target to run all steps for a single sample
run: genome download trim align count

# Call the SNPs in the resulting BAM file.
vcf:
	make -f src/run/bcftools.mk REF=${REF} BAM=${BAM} VCF=${VCF} run

all: genome download trim align count vcf

# mark the target that do not create file
.PHONY: help info download genome fastqc trim align count vcf run
