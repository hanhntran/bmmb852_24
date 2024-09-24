# Set the trace to show the commands as executed
#set -uex

# the URL to the annotation file (gff3) and the file name
ANNOTATION_URL="https://ftp.ensembl.org/pub/current_gff3/drosophila_melanogaster/Drosophila_melanogaster.BDGP6.46.112.gff3.gz"
GFF3_FILE="Drosophila_melanogaster.BDGP6.46.112.gff3"

# file name for the gene annotation
GENE_FILE="Drosophila_melanogaster.BDGP6.46.112.gene.gff3"



# ---------- NOTHING NEEDS TO BE CHANGED BELOW THIS LINE ---------- #
# set directory to be the directory of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# make a directory to store the data
mkdir -p $DIR/data

# download the gff3 file if it doesn't already exist in the data directory
if [ ! -f $DIR/data/${GFF3_FILE}.gz ]; then
    wget ${ANNOTATION_URL} -O $DIR/data/${GFF3_FILE}.gz
fi

# unzip the gff3 file but keep the original file
gunzip -k $DIR/data/${GFF3_FILE}.gz

# Make a new GFF file with only the features of type gene
cat $DIR/data/${GFF3_FILE} | awk '$3 == "gene"' > $DIR/data/${GENE_FILE}


# ----------Inspect the gene annotation file ---------- #
# How many sequence regions (chromosomes) does the file contain?
echo -e "\n============================================================================"
echo "- How many sequence regions (chromosomes) does the file contain?"
grep -v "^#" $DIR/data/${GENE_FILE} | cut -f 1 | sort | uniq | wc -l | \
echo "Answer: The file contains $(cat -) sequence regions"

echo -e "\n==========================================================================="
# How many genes does the file contain?
echo "- How many genes does the file contain?"
grep -v "^#" $DIR/data/${GENE_FILE} | grep -w "gene" | wc -l | \
echo "Answer: The file contains $(cat -) genes"

echo -e "\n==========================================================================="
#What are the top-ten most annotated feature types (column 3) across the genome?
echo "- What are the top-ten most annotated feature types (column 3) across the genome?"
cut -f 3 $DIR/data/${GFF3_FILE} | sort | uniq -c | sort -nr | head -10 | \
echo "Answer: The top-ten most annotated feature types are:
$(cat -)"