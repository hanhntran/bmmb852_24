
# BAM File Analysis Report

## Commands Used

### Generate BAM File from SRA Reads
The BAM file was generated using the following command in the Makefile:

```make
make align
```

### Count Unaligned Reads
To count the number of reads that did not align to the reference genome:

```make
make unaligned_reads
```

### Count Primary, Secondary, and Supplementary Alignments
To identify the number of primary, secondary, and supplementary alignments:

```make
make alignment_types
```

### Count Properly Paired Alignments on the Reverse Strand in the First Pair
To determine the number of properly paired alignments on the reverse strand contained in the first pair:

```make
make properly_paired_reverse
```

### Filter BAM File by Mapping Quality
To create a new BAM file that contains only properly paired primary alignments with a mapping quality of over 10:

```make
make filter_bam
```

### Compare Flagstats Between Original and Filtered BAM Files
To generate and compare flagstat outputs for the original and filtered BAM files:

```make
make compare_flagstats
```

## Results and Answers to Questions

### How many reads did not align with the reference genome?
The number of unaligned reads was determined with the `make unaligned_reads` command.

**Answer:** 
```
samtools view -c -f 4 trim_aligned.sorted.bam
587
```

### How many primary, secondary, and supplementary alignments are in the BAM file?
Using `make alignment_types`, the following counts were obtained:

```
samtools view -c -F 256 trim_aligned.sorted.bam
17794
echo "Primary alignments:"
Primary alignments:
samtools view -c -F 256 trim_aligned.sorted.bam
17794
echo "Secondary alignments:"
Secondary alignments:
samtools view -c -f 256 -F 2048 trim_aligned.sorted.bam
0
echo "Supplementary alignments:"
Supplementary alignments:
samtools view -c -f 2048 trim_aligned.sorted.bam
8

```

### How many properly paired alignments on the reverse strand are formed by reads contained in the first pair?
The count was determined using `make properly_paired_reverse`.

**Answer:** 
```
samtools view -c -f 256 -F 2048 trim_aligned.sorted.bam
0
```

### Filtered BAM File with Properly Paired Primary Alignments (Mapping Quality > 10)
A new BAM file, `filtered.sorted.bam`, was created using `make filter_bam` to include only properly paired primary alignments with a mapping quality over 10.

### Flagstat Comparison
The flagstat statistics for the original and filtered BAM files were generated and compared using `make compare_flagstats`.

- **Original BAM flagstats:** 
```
echo "Original BAM flagstats:"
Original BAM flagstats:
cat trim_aligned.flagstat
17794 + 0 in total (QC-passed reads + QC-failed reads)
17786 + 0 primary
0 + 0 secondary
8 + 0 supplementary
0 + 0 duplicates
0 + 0 primary duplicates
17207 + 0 mapped (96.70% : N/A)
17199 + 0 primary mapped (96.70% : N/A)
17786 + 0 paired in sequencing
8893 + 0 read1
8893 + 0 read2
16914 + 0 properly paired (95.10% : N/A)
16974 + 0 with itself and mate mapped
225 + 0 singletons (1.27% : N/A)
34 + 0 with mate mapped to a different chr
23 + 0 with mate mapped to a different chr (mapQ>=5)
```
- **Filtered BAM flagstats:** 
```
echo "Filtered BAM flagstats:"
Filtered BAM flagstats:
cat filtered.flagstat
15418 + 0 in total (QC-passed reads + QC-failed reads)
15415 + 0 primary
0 + 0 secondary
3 + 0 supplementary
0 + 0 duplicates
0 + 0 primary duplicates
15418 + 0 mapped (100.00% : N/A)
15415 + 0 primary mapped (100.00% : N/A)
15415 + 0 paired in sequencing
7706 + 0 read1
7709 + 0 read2
15415 + 0 properly paired (100.00% : N/A)
15415 + 0 with itself and mate mapped
0 + 0 singletons (0.00% : N/A)
0 + 0 with mate mapped to a different chr
0 + 0 with mate mapped to a different chr (mapQ>=5)

```