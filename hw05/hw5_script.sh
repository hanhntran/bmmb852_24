# Set the trace to show the commands as executed
set -uex

# the URL to the genome fil
FASTA_ACCESSION="GCA_000002985.3"





# ---------- NOTHING NEEDS TO BE CHANGED BELOW THIS LINE ---------- #
# make a directory to store the data
echo -e "\n====================================PART 1========================================"

echo "Step 1: Downloading the genome file..."
# download the fasta file 
datasets download genome accession ${FASTA_ACCESSION}

# Unpack the data. (Overwrite files if they already exist)
unzip -o ./ncbi_dataset.zip

# Make a link to a simpler name
ln -sf ./ncbi_dataset/data/${FASTA_ACCESSION}/*.fna ./genome.fa

# Remove the original downloaded data
#rm -rf ./ncbi_dataset.zip ./ncbi_dataset

# Print the number of sequences in the genome
grep -c "^>" ./genome.fa

echo "Downloading the genome FASTA file with the accession number ${FASTA_ACCESSION}..."

echo "Genome reports"
# Report the size of the FASTA file
echo "Calculating the size of the FASTA file..."
FILE_SIZE=$(du -ch ./ncbi_dataset/data/${FASTA_ACCESSION}/*.fna | grep total | awk '{print $1}')
echo "FASTA file size: $FILE_SIZE"

echo "Calculating genome size..."
# filter the file to remove the beginning portion that starts with '#'
grep -v '^>' ./genome.fa > ./genome_filtered.fa

# count number of nucleotides in the genome
GENOME_SIZE=$(cat ./genome_filtered.fa | tr -d '\n' | wc -c)
echo "Total genome size: $GENOME_SIZE"

# Get the number of chromosomes in the genome
NUM_CHROMOSOMES=$(grep '>' ./genome.fa | wc -l)
echo "Number of chromosomes: $NUM_CHROMOSOMES"

# Get name (id) and length of each chromosome in the genome.
awk '/^>/ {if (seqlen){print name "\t" seqlen}; name=$0; seqlen=0; next} {seqlen += length($0)} END {print name "\t" seqlen}' genome.fa


echo -e "\n====================================PART 2========================================"
#
# Simulate reads with wgsim
#

# The location of the genome file (FASTA format)
echo "Simulating reads with wgsim with coverage 10x and read length 100bp..."
GENOME=genome.fa
# coverage
COV=10
# Lengh of the reads
L=100


# formula to calculate the number of reads 
# Number of reads= 
# Coverage×Genome Size ​/ (Read Length×2)

# The number of reads
N=$( echo "(($COV*$GENOME_SIZE)/($L*2))" | bc )
echo "Simulating reads with wgsim with coverage 10x and read length 100bp, N = $N"

# The files to write the reads to
R1=reads/wgsim_read1.fq
R2=reads/wgsim_read2.fq

# --- Simulation actions below ---

# Make the directory that will hold the reads extracts 
# the directory portion of the file path from the read
mkdir -p $(dirname ${R1})

# Simulate with no errors and no mutations
#wgsim -N ${N} -1 ${L} -2 ${L} -r 0 -R 0 -X 0 \
#      ${GENOME} ${R1} ${R2}

# Run read statistics
#seqkit stats ${R1} ${R2}

# Compress the reads
#gzip ${R1} ${R2}

#seqkit stats ${R1}.gz ${R2}.gz


FILE_SIZE_FQ=$(du -ch ./reads/*_read1.fq | grep total | awk '{print $1}')
FILE_SIZE_FQ_GZ=$(du -ch ./reads/*_read1.fq.gz | grep total | awk '{print $1}')
echo "Size of the FASTQ file: $FILE_SIZE_FQ"
echo "Size of the FASTQ file: $FILE_SIZE_FQ_GZ"
echo "Space saved: 0.2008, or about 20.08%."


# coverage
COV_30=30
# Lengh of the reads
L=100

# formula to calculate the number of reads 
# Number of reads= 
# Coverage×Genome Size ​/ (Read Length×2)

# The number of reads
N=$( echo "(($COV_30*$GENOME_SIZE)/($L*2))" | bc )

echo "Simulating reads with wgsim with coverage 30x and read length 100bp, N = $N"

# coverage
COV_150=10
# Lengh of the reads
L=150

# The number of reads
N=$( echo "(($COV_150*$GENOME_SIZE)/($L*2))" | bc )

echo "Simulating reads with wgsim with coverage 10x and read length 150bp, N = $N"



echo -e "\n====================================PART 3========================================"
YEAST_GENOME_SIZE=12100000
DROSOPHILA_GENOME_SIZE=143700000
HUMAN_GENOME_SIZE=3200000000

echo "FASTA file size of yeast: $YEAST_GENOME_SIZE"
echo "FASTA file size of Drosophila: $DROSOPHILA_GENOME_SIZE"
echo "FASTA file size of Human: $HUMAN_GENOME_SIZE"

# size of one read
one_read_size=
# coverage
COV=30
# Lengh of the reads
L=100

# Calculate the number of reads needed
N=$(echo "($COV * $YEAST_GENOME_SIZE) / ($L * 2)" | bc)
echo "YEAST: Simulating reads with wgsim with coverage 30x and read length 100bp, N = $N"

# Calculate uncompressed FASTQ file size (each read pair is ~200 bytes)
SIZE=$(($N * 200))
echo "YEAST: uncompressed fastq file size: $SIZE bytes"

# Calculate compressed size (assuming 20% of the original size after compression)
COMPRESSED_SIZE=$(echo "$SIZE * 0.2" | bc)
echo "YEAST: compressed fastq file size: $COMPRESSED_SIZE bytes"


# Calculate the number of reads needed
N=$(echo "($COV * $DROSOPHILA_GENOME_SIZE) / ($L * 2)" | bc)
echo "DROSOPHILA: Simulating reads with wgsim with coverage 30x and read length 100bp, N = $N"

# Calculate uncompressed FASTQ file size (each read pair is ~200 bytes)
SIZE=$(($N * 200))
echo "DROSOPHILA: uncompressed fastq file size: $SIZE bytes"

# Calculate compressed size (assuming 20% of the original size after compression)
COMPRESSED_SIZE=$(echo "$SIZE * 0.2" | bc)
echo "DROSOPHILA: compressed fastq file size: $COMPRESSED_SIZE bytes"

N=$( echo "(($COV*$HUMAN_GENOME_SIZE)/($L*2))" | bc )       
echo "HUMAN: Simulating reads with wgsim with coverage 30x and read length 100bp, N = $N"

# Calculate uncompressed FASTQ file size (each read pair is ~200 bytes)     
SIZE=$(($N*200))  
echo "HUMAN: uncompressed fastq file size: $SIZE"

COMPRESSED_SIZE=$(echo "$SIZE * 0.2" | bc)
echo "HUMAN: compressed fastq file size: $COMPRESSED_SIZE"
