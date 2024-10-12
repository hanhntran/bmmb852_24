## Assignment 5 Genome Report for *Caenorhabditis elegans*

### 1. Select a genome, then download the corresponding FASTA file.

The size of the file is 97M bytes.

The total size of the genome is 100272607 or ~100MB.    

The number of chromosomes in the genome is 6.

The name (id) and length of each chromosome in the genome:
```
BX284601.5 Caenorhabditis elegans chromosome I	15072434
BX284602.5 Caenorhabditis elegans chromosome II	15279421
BX284603.4 Caenorhabditis elegans chromosome III	13783801
BX284604.4 Caenorhabditis elegans chromosome IV	17493829
BX284605.5 Caenorhabditis elegans chromosome V	20924180
BX284606.5 Caenorhabditis elegans chromosome X	17718942
```

### 2. Generate a simulated FASTQ output for a sequencing instrument of your choice.  Set the parameters so that your target coverage is 10x.
- How many reads have you generated?
5013630 

- What is the average read length?
100

- How big are the FASTQ files? 234M


- Compress the files and report how much space that saves: 143M --> Space saved: 0.2008, or about 20.08%. 

- Discuss whether you could get the same coverage with different parameter settings (read length vs. read number).

        To simulate reads with coverage 30x and read length 100bp, we need N = 15040890 reads. 

        To simulate reads with coverage 10x and read length 150bp, we need N = 3342420 reads. 

### 3. How much data would be generated when covering the Yeast,  the Drosophila or the Human genome at 30x?

| Genome | Genome Size (FASTA)	 | Reads for 30x Coverage	 | FASTQ Size (Uncompressed)	 | FASTQ Size (compressed)
|--------|----------|-------------|-------------|-------------|
| Yeast  | 12.5 MB	      | 2.5 million	       | 1.75 GB	       | 0.44 GB
| Drosophila | 139 MB	      | 27.8 million	       | 19.46 GB	       | 3.89 GB	       | 4.87 GB
| Human    | 3.2 GB	      | 640 million	       | 448 GB	       | 89.6 GB	       | 112 GB

