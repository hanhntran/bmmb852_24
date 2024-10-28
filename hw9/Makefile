ACC=GCA_000002985.3
GFF=ncbi_dataset/data/${ACC}/genomic.gff
GENOME=genome.fna
N=10000
R1_sim=sim_reads/wgsim_read1.fq
R2_sim=sim_reads/wgsim_read2.fq	
L=100 # length of the reads
SRA=SRR066627
R1=reads/${SRA}_1.fastq
R2=reads/${SRA}_2.fastq
T1=reads/${SRA}_1.trim.fastq
T2=reads/${SRA}_2.trim.fastq

# print help message
help:
	@echo "# ACC=${ACC}"
	@echo "make info      # summary information on the genome"
	@echo "make download  # download the genome file"
	@echo "make simulate  # simulate the reads"
	@echo "make fastqc    # run fastqc"
	@echo "make trim      # run fastp to trim the reads"
	@echo "make align     # align the reads to the genome"
	@echo "make clean_align # clean up the aligned files"
	@echo "make all       # run all the steps"
	@echo "make unaligned_reads # count the unaligned reads"
	@echo "make alignment_types # count the alignment types"
	@echo "make properly_paired_reverse # count the properly paired reverse alignments"
	@echo "make filter_bam # filter the BAM file"
	@echo "make compare_flagstats # compare the flagstats between original and filtered BAM files"
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
	fastq-dump -X ${N} -F --outdir reads --split-files ${SRA}

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


all: info download genome simulate fastqc trim align unaligned_reads alignment_types properly_paired_reverse filter_bam compare_flagstats summary

# mark the target that do not create file
.PHONY: help info download genome simulate fastqc trim align unaligned_reads alignment_types properly_paired_reverse filter_bam compare_flagstats summary
