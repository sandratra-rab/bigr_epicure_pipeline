# bigr_epicure_pipeline
Snakemake pipeline for Epicure analyses: Chip-Seq, Atac-Seq, Cut&Tag, Cut&Run, MeDIP-Seq, 8-OxoG-Seq


# Pipeline description

_note: The following steps may not be perform in that exact order._

## Pre-pocessing

| Step                        | Tool             | Documentation                                                                                                                             | Reason                                                                                         |
| --------------------------- | ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| Download genome sequence    | curl             | [Snakemake-Wrapper: download-sequence](https://snakemake-wrappers.readthedocs.io/en/v1.31.1/wrappers/reference/ensembl-sequence.html)     | Ensure genome sequence are consistent in Epicure analyses                                      |
| Download genome annotation  | curl             | [Snakemake-Wrapper: download-annotation](https://snakemake-wrappers.readthedocs.io/en/v1.31.1/wrappers/reference/ensembl-annotation.html) | Ensure genome annotation are consistent in Epicure analyses                                    |
| Download blacklised regions | manual shell FTP |                                                                                                                                           | Ensure blacklist regions are consistent in Epicure analyses                                    |
| Trimming + QC               | Fastp            | [Snakemake-Wrapper: fastp](https://snakemake-wrappers.readthedocs.io/en/v1.31.1/wrappers/fastp.html)                                      | Perform read quality check and corrections, UMI, adapter removal, QC before and after trimming |
| Quality Control             | FastqScreen      | [Snakemake-Wrapper: fastq-screen](https://snakemake-wrappers.readthedocs.io/en/v1.31.1/wrappers/fastq_screen.html)                               | Perform library quality check |


## Read mapping

| Step            | Tool      | Documentation                                                                                                                                          | Reason                                                                                                                                                                                                                             |
| --------------- | --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Indexation      | Bowtie2   | [Snakemake-Wrapper: bowtie2-build](https://snakemake-wrappers.readthedocs.io/en/v1.31.1/wrappers/bowtie2/build.html)                                   | Index genome for up-coming read mapping                                                                                                                                                                                            |
| Mapping         | Bowtie2   | [Snakemake-Wrapper: bowtie2-align](https://snakemake-wrappers.readthedocs.io/en/v1.31.1/wrappers/bowtie2/align.html)                                   | Align sequenced reads on the genome                                                                                                                                                                                                |
| Filtering       | Sambamba  | [Snakemake-Wrapper: sambamba-sort](https://snakemake-wrappers.readthedocs.io/en/v1.31.1/wrappers/sambamba/sort.html)                                   | Sort alignment over chromosome position, this reduce up-coming required computing resources, and reduce alignment-file size.                                                                                                       |
| Filtering       | Sambamba  | [Snakemake-Wrapper: sambamba-view](https://snakemake-wrappers.readthedocs.io/en/v1.31.1/wrappers/sambamba/view.html)                                   | Remove non-canonical chromosomes and mapping belonging to mitochondrial chromosome.                                                                                                                                                |
| Filtering       | Sambamba  | [Snakemake-Wrapper: sambamba-markdup](https://snakemake-wrappers.readthedocs.io/en/v1.31.1/wrappers/sambamba/markdup.html)                             | Remove sequencing duplicates.                                                                                                                                                                                                      |
| Filtering       | DeepTools | [Snakemake-Wrapper: sambamba-sort](https://snakemake-wrappers.readthedocs.io/en/v1.31.1/wrappers/deeptools/alignmentsieve.html)                        | For Atac-seq only. Reads on the positive strand should be shifted 4 bp to the right and reads on the negative strand should be shifted 5 bp to the left as in [Buenrostro et al. 2013](https://pubmed.ncbi.nlm.nih.gov/24097267/). |
| Archive         | Sambamba  | [Snakemake-Wrapper: sambamba-view](https://snakemake-wrappers.readthedocs.io/en/v1.31.1/wrappers/sambamba/view.html)                                   | Compress alignment fil in CRAM format in order to reduce archive size.                                                                                                                                                             |
| Quality Control | Picard    | [Snakemake-Wrapper: picard-collect-multiple-metrics](https://snakemake-wrappers.readthedocs.io/en/v1.31.1/wrappers/picard/collectmultiplemetrics.html) | Summarize alignments, GC bias, insert size metrics, and quality score distribution.                                                                                                                                                |
| Quality Control | Samtools  | [Snakemake-Wrapper: samtools-stats](https://snakemake-wrappers.readthedocs.io/en/v1.31.1/wrappers/samtools/stats.html)                                 | Summarize alignment metrics. Performed before and after mapping-post-processing in order to highlight possible bias.                                                                                                               |
| Quality Control | DeepTools | [Snakemake-Wrapper: deeptools-fingerprint](https://snakemake-wrappers.readthedocs.io/en/v1.31.1/wrappers/deeptools/plotfingerprint.html)               | Control imuno precipitation signal specificity. |


## Coverage


| Step            | Tool      | Documentation                                                                                                                            | Reason                                                                              |
| --------------- | --------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| Coverage        | DeepTools | [Snakemake-Wrapper: deeptools-bamcoverage](https://snakemake-wrappers.readthedocs.io/en/v1.31.1/wrappers/deeptools/bamcoverage.html)     | Compute genome coverage, normalized to 1M reads                                     |
| Coverage        | MEDIPS    | Incoming                                                                                                                                 | Compute genome coverage with CpG density correction using MEDIPS (MeDIP-Seq only)   |
| Scaled-Coverage | DeepTools | [Snakemake-Wrapper: deeptools-computematrix](https://snakemake-wrappers.readthedocs.io/en/v1.31.1/wrappers/deeptools/computematrix.html) | Calculate scores per genomic regions. Used for heatmaps and profile coverage plots. |
| Heatmap         | DeepTools | [Snakemake-Wrapper: deeptools-plotheatmap](https://snakemake-wrappers.readthedocs.io/en/v1.31.1/wrappers/deeptools/plotheatmap.html)     | Plot heatmap and peak coverage among samples                                        |
| Depth        | DeepTools | [Snakemake-Wrapper: deeptools-plotheatmap](https://snakemake-wrappers.readthedocs.io/en/v1.31.1/wrappers/deeptools/plotcoverage.html)    | Assess the sequencing depth of given samples |


## Peak-Calling

| Step         | Tool | Documentation                                                                                                          | Reason |
| ------------ | ---- | ---------------------------------------------------------------------------------------------------------------------- | ------ |
| Peak-Calling | Mac2 | [Snakemake-Wrapper: macs2-callpeak](https://snakemake-wrappers.readthedocs.io/en/v1.31.1/wrappers/macs2/callpeak.html) | Search for significant peaks |


## Differential Peak Calling

| Step         | Tool | Documentation                                                                                                          | Reason |
| ------------ | ---- | ---------------------------------------------------------------------------------------------------------------------- | ------ |
| Peak-Calling | MEDIPS | Incoming | Search for significant variation in peak coverage with EdgeR (MeDIP-Seq only) |

# Roadmap

* Coverage: Fingerprint, PCA, PBC
* Peak-calling: Seacr, FRiP, FDR
* Peak-annotation: Homer, CentriMo
* Differential Peak Calling: DiffBind, EdgeR, csaw
* IGV: screen-shot, igv-reports
* Big freaking multiqc at the end!

Based on Snakemake-Wrappers version 1.31.1