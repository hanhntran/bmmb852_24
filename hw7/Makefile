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
	@echo "make clean     # remove the downloaded files"
	@echo "make simulate  # simulate the reads"
	@echo "make fastqc    # run fastqc"
	@echo "make trim      # run fastp to trim the reads"

# print the summary information of the genome
info:
	@datasets summary genome accession ${ACC} | jq

# download the genome file and unzip
${GFF}:
	datasets download genome accession ${ACC}
	# never overwrite file when unzipping
	unzip -n ncbi_dataset.zip

# create genome symlink
genome:
	cp ./ncbi_dataset/data/${ACC}/*.fna ./genome.fna

# clean up downloaded files
clean:
	rm -rf ncbi_dataset/data/${ACC}
	rm -f md5sum.txt ncbi_dataset.zip

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

# mark the target that do not create file
.PHONY: help info download clean genome simulate fastqc trim
