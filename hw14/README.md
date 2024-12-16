# Gene Expression Analysis

This pipeline automates the process of gene expression analysis using RNA-seq data. 

## Prerequisites
Ensure 'stats' environment is installed using the following command:
```
# Get the code.
bio code

# Run the script to create the stats environment.
bash src/setup/init-stats.sh 
```

## Files
- `rnaseq.mk`: The workflow definition.
- `c_elegans.csv`: A file containing a list of SRA accession numbers (one per line).

## Running the Pipeline
1. **Prepare the SRA List**:
```
 make -f rnaseq.mk design
```
2. Run the Makefile with GNU Parallel
```
 make -f rnaseq.mk all
```

3. Visualize PCA by group:
The PCA plot shows the first two principal components (PC1 and PC2) of the data, colored by group. The groups are generally clustered together, indicating that the samples are similar to each other. 
![IGV screenshot](./res/pca_by_group.pdf)

4. Count the number of reads mapped to each gene
First few lines of gene expression information from the two groups:
```
name	gene	length	baseMean	baseMeanA	baseMeanB	foldChange	log2FoldChange	PValue	PAdj	FDR	falsePos	WT_1	WT_2	WT_3	mutant_1	mutant_2	mutant_3
WBGene00015687	chdp-1	1367.2	819	819	0	0	-12.7	2.1E-05	1E-03	0.001	0	915	749	793	0	0	0
WBGene00012239	W04A8.4	756.2	54	15	39	2.55	1.4	3.2E-02	9.9E-01	0.8001	2	12	17	16	55	29	33
WBGene00004029	pik-1	1301.2	66.3	18.7	47.7	2.626	1.4	6.3E-02	9.9E-01	0.981	3	21	9	26	33	67	43
WBGene00014307	WBGene00014307	520.9	6528	4305	2223	0.516	-1	1.2E-01	9.9E-01	0.981	4	2407	7605	2903	2187	1649	2833
WBGene00003704	nhr-114	1173.3	2276.3	1441.3	835	0.579	-0.8	1.4E-01	9.9E-01	0.981	5	663	1721	1940	620	807	1078
WBGene00013014	Y48E1C.1	4156.2	75	48.7	26.3	0.542	-0.9	1.7E-01	9.9E-01	0.981	6	30	49	67	33	16	30
WBGene00014309	WBGene00014309	1264.6	13905	8076	5829	0.722	-0.5	1.8E-01	9.9E-01	0.981	7	6554	11065	6609	5673	4996	6818
WBGene00004412	rpl-1	245.6	86.3	54.7	31.7	0.58	-0.8	2E-01	9.9E-01	0.981	8	84	48	32	30	32	33
WBGene00019946	chat-1	945.2	80	52.3	27.7	0.518	-0.9	2.2E-01	9.9E-01	0.981	9	27	101	29	33	26	24
```

## Observations:
### Consistent Expression Levels:

- `chdp-1`: is the only gene that is significantly expressed in the WT samples and not expressed in the mutant samples FDR < 0.005. This gene involved in the actin cytoskeleton assembly in dendrites and in assembly of microtubule cytoskeleton, intracellular organelle transport and neuropeptide secretion in the high-ordered dendritic branches.

### Considerations:
- Since all the mutant samples have 0 reads mapped to them, it is possible that the samples are not sequenced properly or not as reliable. Thus, I would trust the results with a grain of salt.
