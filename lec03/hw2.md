# 1. Tell us a bit about the organism:
Drosophila melanogaster is a model organism whose genome is well characterized and studied in the field of genomics. It has a genome size of approximately 180Mb.

### Download GFF3 file:
    conda activate bioinfo 
    wget https://ftp.ensembl.org/pub/current_gff3/drosophila_melanogaster/Drosophila_melanogaster.BDGP6.46.112.gff3.gz
    gunzip Drosophila_melanogaster.BDGP6.46.112.gff3.gz


# 2. How many features does the file contain?
Count features in the file: Since feature lines are those that do not begin with #, I use this command to count them:
    
    grep -v '^#' Drosophila_melanogaster.BDGP6.46.112.gff3 | wc -l 

508218 features


# 3. How many sequence regions (chromosomes) does the file contain? 

    grep "##sequence-region" Drosophila_melanogaster.BDGP6.46.112.gff3 | wc -l 

1870 sequence regions


# 4. How many genes are listed for this organism?
    cat  Drosophila_melanogaster.BDGP6.46.112.gff3 | cut -f 3 | grep -w "gene" | wc -l

13986 genes

# 5. What are the top-ten most annotated feature types (column 3) across the genome?
    cut -f 3 Drosophila_melanogaster.BDGP6.46.112.gff3 | sort | uniq -c | sort -nr | head -10

196662 exon
163268 CDS
46782 five_prime_UTR
33738 three_prime_UTR
30799 mRNA
26148 ###
13986 gene
5898 transposable_element_gene
5898 transposable_element
4054 ncRNA_gene


# 6. Having analyzed this GFF file, does it seem like a complete and well-annotated organism?
Given that there are only 13986 genes annotated while there are 196662 exon 163268 CDS, and 30799 mRNA, this annotation version of Drosophila melanogaster seems mostly complete but potentially lacking gene annotations. Particularly, the fly genome contains approximately 16,000 genes that code for about 13,000 proteins (Adams et al. 2000; Dos Santos et al. 2014). Therefore, not all genes are fully annotated in this genome version.



My GitHub repo: https://github.com/hanhntran/bmmb852_24
