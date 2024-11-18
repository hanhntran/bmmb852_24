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

# print help message
help:
	@echo "# ACC=${ACC}"
	@echo "make info      # summary information on the genome"
	@echo "make download  # download the genome file"
	@echo "make simulate  # simulate the reads"
	@echo "make fastqc    # run fastqc"
	@echo "make trim      # run fastp to trim the reads"
	@echo "make align     # align the reads to the genome"
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
	datasets download genome accession ${ACC}
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
	fastp --cut_tail -i ${R1} -I ${R2} -o ${T1} -O ${T2}
	fastqc -q ${T1} -o reports

# index the genome
index:
	bwa index genome.fna

# align the reads to the genome
align: index
	bwa mem -t 4 genome.fna ${T1} ${T2} > trim_aligned.sam
	samtools view -b -o trim_aligned.bam trim_aligned.sam
	samtools sort -o trim_aligned.sorted.bam trim_aligned.bam	
	samtools index trim_aligned.sorted.bam
	bwa mem -t 4 genome.fna ${R1_sim} ${R2_sim} > sim_aligned.sam
	samtools view -b -o sim_aligned.bam sim_aligned.sam
	samtools sort -o sim_aligned.sorted.bam sim_aligned.bam
	samtools index sim_aligned.sorted.bam

# count the unaligned reads
unaligned_reads:
	samtools view -c -f 4 trim_aligned.sorted.bam

# count primary, secondary, supplementary, and unmapped reads
alignment_types:
	samtools view -c -F 256 trim_aligned.sorted.bam
	echo "Primary alignments:"
	samtools view -c -F 256 trim_aligned.sorted.bam
	
	echo "Secondary alignments:"
	samtools view -c -f 256 -F 2048 trim_aligned.sorted.bam

	echo "Supplementary alignments:"
	samtools view -c -f 2048 trim_aligned.sorted.bam

# Count properly paired alignments on reverse strand for first pair
properly_paired_reverse:
	samtools view -c -f 99 trim_aligned.sorted.bam

# Filter BAM file with properly paired primary alignments and mapping quality > 10
filter_bam:
	samtools view -h -f 2 -q 10 -o filtered.bam trim_aligned.sorted.bam
	samtools sort -o filtered.sorted.bam filtered.bam
	samtools index filtered.sorted.bam

# Compare flagstats between original and filtered BAM files
compare_flagstats:
	samtools flagstat trim_aligned.sorted.bam > trim_aligned.flagstat
	samtools flagstat filtered.sorted.bam > filtered.flagstat
	echo "Original BAM flagstats:"
	cat trim_aligned.flagstat
	echo "Filtered BAM flagstats:"
	cat filtered.flagstat

# generate alignment summary
#summary:
#	samtools flagstat trim_aligned.sorted.bam > trim_aligned.flagstat
#	samtools flagstat sim_aligned.sorted.bam > sim_aligned.flagstat

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

#variants:
#	# Make the vcf directory
#	mkdir -p vcf

#	# Call variants
#	bcftools mpileup -Ou -f ${REF} bam/trim_aligned.sorted.bam | bcftools call -mv -Oz -o vcf/trim_aligned.sorted.filtered.vcf.gz

#	# Index the vcf file
#	bcftools index vcf/trim_aligned.sorted.filtered.vcf.gz

#	# Count the number of variants
#	bcftools stats vcf/trim_aligned.sorted.filtered.vcf.gz > vcf/trim_aligned.sorted.filtered.vcf.stats

#	# Looking for false positives
#	bcftools filter -i 'QUAL>=30 && DP>=10 && MQ>=30' vcf/trim_aligned.sorted.filtered.vcf.gz > vcf/trim_aligned.sorted.filtered.false_positive_variants.vcf.gz

#	bcftools stats vcf/trim_aligned.sorted.filtered.false_positive_variants.vcf.gz > vcf/trim_aligned.sorted.filtered.false_positive_variants.vcf.stats

# VEP is installed in the environment called vep
vep: 
	# Sort and compress the GFF file
	# Needs the double $ to pass the $ from make to bash
	cat ${GFF} | sort -k1,1 -k4,4n -k5,5n -t$$'\t' | bgzip -c > ${GFF}.gz

	# Index the GFF file
	tabix -p gff ${GFF}.gz

	mkdir -p results
	
	micromamba run -n vep \
        ~/src/ensembl-vep/vep \
        -i vcf/${SAMPLE}.vcf.gz \
        -o results/vep.txt \
        --gff ${GFF}.gz \
        --fasta ${REF} \
        --force_overwrite 

	# Show the resulting files
	ls -lh results/*


all: bam vcf vep

# mark the target that do not create file
.PHONY: help info download genome fastqc trim align unaligned_reads alignment_types properly_paired_reverse filter_bam compare_flagstats
