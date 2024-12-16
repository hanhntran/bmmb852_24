#
# RNA-Seq from the Biostar Workflows
#
# http://www.biostarhandbook.com
#

# How many reads to download N=ALL for all.
N ?= ALL

# The number of CPUs to use.
NCPU ?= 4

# Apply Makefile customizations.
.DELETE_ON_ERROR:
SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables --no-print-directory

# The URL for the C elegans transcriptome.
URL ?= http://ftp.ensembl.org/pub/release-109/fasta/caenorhabditis_elegans/cdna/Caenorhabditis_elegans.WBcel235.cdna.all.fa.gz

# The name of the CDNA transcriptome file locally.
REF ?= ~/refs/c_elegans/Caenorhabditis_elegans.WBcel235.cdna.all.fa

# The name of the ensembl database to use for transcript to gene mapping.
ENSEMBL_DB ?= celegans_gene_ensembl

# The transcript to gene mapping file.
TX2GENE ?= ~/refs/tx2gene/${ENSEMBL_DB}.csv

# The resulting counts file.
COUNTS ?= res/c_elegans-counts.csv

# Final edger result
RESULT = res/edger.csv

# The design matrix.
DESIGN ?= c_elegans.csv

# Check that required executables exist.
EXE = salmon fastq-dump parallel micromamba
#OK := $(foreach exec,$(EXE),\
        $(if $(shell which $(exec)),ok,$(error "Program $(exec) not found")))

# Flags we pass to parallel in each invocation
FLAGS = -v --eta --colsep , --header : -j ${NCPU}

# Print help by default
usage:
	@echo "#"
	@echo "# C elegans RNA-Seq workflow in the Biostar Handbook"
	@echo "#"
	@echo "# See: https://www.biostarhandbook.com/books/workflows/workflows/airway-rnaseq/"
	@echo "#"
	@echo "# Parameters:"
	@echo "#"
	@echo "#    REF=${REF}"
	@echo "#    DESIGN=${DESIGN} "
	@echo "#"
	@echo "# Usage:"
	@echo "#"
	@echo "#    make design  # generates the design matrix"
	@echo "#    make genome  # download C elegans reference genome"
	@echo "#    make fastq   # downloads the fastq files"
	@echo "#    make align   # performs slamon quantification"
	@echo "#    make counts  # generates the salmon counts"
	@echo "#    make edger   # runs the edger differential expression analysis"
	@echo "#"
	@echo "#    make all     # runs all the steps above"
	@echo "#"
	@echo "# Setup:"
	@echo "#"
	@echo "#    bash src/setup/init-stats.sh"
	@echo "#"


# Download and unzip the reference genome.
${REF}:
	mkdir -p $(dir ${REF})
	curl ${URL} > ${REF}

# Trigger the reference indexing.
genome: ${REF}
	micromamba run -n salmon_env make -f src/run/salmon.mk index REF=${REF} NCPU=${NCPU}

# Create the design matrix.
design:
	@cat << EOF > ${DESIGN}
	run,group,type,sample
	SRR31712716,WT,WT,WT_1
	SRR31712715,WT,WT,WT_2
	SRR31712714,WT,WT,WT_3
	SRR31712713,mutant,mutant,mutant_1
	SRR31712712,mutant,mutant,mutant_2
	SRR31712711,mutant,mutant,mutant_3
	EOF
	@echo "# Created c elegans design: ${DESIGN}"

# Download the reads. Set N=ALL to get all
fastq: ${DESIGN}
	cat ${DESIGN} |  parallel ${FLAGS} \
	                 make -f src/run/sra.mk run \
	                 SRR={run} N=${N}

# Run alignments for all samples
align: ${DESIGN}
	# Run the alignment on each sample.
	cat ${DESIGN} | parallel ${FLAGS} \
	                micromamba run -n salmon_env make -f src/run/salmon.mk run \
	                REF=${REF} \
	                SAMPLE={sample} \
	                R1=reads/{run}_1.fastq \
	                R2=reads/{run}_2.fastq

# Create the ensemble transcript to gene mapping
${TX2GENE}:
	mkdir -p $(dir $@)
	micromamba run -n stats src/r/create_tx2gene.r -d ${ENSEMBL_DB} -o $@
	ls -lh $@

# Combine salmon outputs into the final counts.
${COUNTS}: ${DESIGN} ${TX2GENE}

	# Create the output folder for the counts.
	mkdir -p $(dir ${COUNTS})

	# Combine the counts
	micromamba run -n stats src/r/combine_salmon.r -d ${DESIGN} -G -t ${TX2GENE} -o ${COUNTS}

${RESULT}: ${DESIGN} ${COUNTS}
	# Generate the edger results
	micromamba run -n stats src/r/edger.r -d ${DESIGN} -c ${COUNTS} -o ${RESULT}

# Single command to generate the counts
counts: ${RESULT}
	# The results folder.
	mkdir -p res

	# The PCA plots are generated using grouping of the design file
	micromamba run -n stats src/r/plot_pca.r -d ${DESIGN} -c ${COUNTS} -f group -o res/pca_by_group.pdf
	# micromamba run -n stats src/r/plot_pca.r -d ${DESIGN} -c ${COUNTS} -f celltype -o res/pca_by_cells.pdf

# Run edger differential expression analysis.
edger: ${RESULT}
	# Make a directory
	mkdir -p res

	# Draw the heatmap
	micromamba run -n stats src/r/plot_heatmap.r -d ${DESIGN}  -c res/edger.csv -f group -o res/heatmap.pdf

	# List all the results
	@echo "# Results: "
	find res

# Get the data first
data: ${DESIGN} design genome fastq

# Trigger all steps at once.
all: ${DESIGN} genome fastq align counts edger

# Have a shortcut to all
run: all

.PHONY: usage data genome fastq align counts edger all