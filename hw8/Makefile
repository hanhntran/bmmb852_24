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

# clean up the aligned files
clean_align:
	rm trim_aligned.sam sim_aligned.sam trim_aligned.bam sim_aligned.bam

all: info download genome simulate fastqc trim align clean_align

# mark the target that do not create file
.PHONY: help info download genome simulate fastqc trim align clean_align
