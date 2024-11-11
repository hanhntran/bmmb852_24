# Set the trace
set -uex

SRA=SRR066627
N=10000 # number of reads to download

# The output read names
R1=reads/${SRA}_1.fastq
R2=reads/${SRA}_2.fastq

# Trimmed read names
T1=reads/${SRA}_1.trimmed.fastq
T2=reads/${SRA}_2.trimmed.fastq

################################################################################

# Download 1000 read pairs with fastq-dump into the reads directory
fastq-dump -X ${N} -F --outdir reads --split-files ${SRA}

# Run FastQC to inspect the quality of the raw sequencing data
mkdir -p reports
fastqc -q -o ./reports ${R1}

# Run fastp to trim the low quality reads and remove the Illumina adapters
fastp --cut_tail \
    -i ${R1} -o ${T1} \
    -I ${R2} -O ${T2} 

# Run FastQC to inspect the quality of the trimmed sequencing data
fastqc -q -o ./reports ${T1}
