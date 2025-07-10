# scMap-flow

A simple Nextflow pipeline for processing single-cell RNA-seq data using Cell Ranger and Cell Ranger ARC.

## Requirements

- [Nextflow](https://www.nextflow.io/) (v22.04.0 or later)
- Cell Ranger (for standard scRNA-seq)
- Cell Ranger ARC (for multiome data)
- Reference transcriptomes (GRCh38 or mm10)

## Quick Start

### Standard scRNA-seq

```bash
nextflow run johnsonlab-ic/scMap-flow \
  --samplesheet path/to/samplesheet.csv \
  --outputDir path/to/output \
  --transcriptome path/to/cellranger/transcriptome_reference \
  --cellrangerPath path/to/cellranger \
  -profile imperial
```

### Multiome (ARC) Analysis

```bash
nextflow run johnsonlab-ic/scMap-flow \
  --arc true \
  --samplesheet_multiome path/to/multiome_samplesheet.csv \
  --outputDir path/to/output \
  --cellranger_arc_path path/to/cellranger-arc \
  --cellranger_arc_ref_path path/to/cellranger_arc/reference \
  -profile imperial
```

## Samplesheet Formats

### Standard scRNA-seq Samplesheet

Format:
```
sample_id,sample_name,fastq_path
```

Example:
```
sample_id,sample_name,fastq_path
sample1,1,/path/to/fastq_directory
sample2,2,/path/to/fastq_directory
```

- `sample_id`: Used for output directory naming
- `sample_name`: Matches the prefix of your FASTQ files
- `fastq_path`: Path to directory containing FASTQ files

### Multiome (ARC) Samplesheet

Format:
```
sample_id_unique,fastqs,sample,library_type
```

Example:
```
sample_id_unique,fastqs,sample,library_type
sample1,/path/to/gex_directory,311234_1-sample1_G,Gene Expression
sample1,/path/to/atac_directory,311235_1-sample1_A,Chromatin Accessibility
sample2,/path/to/gex_directory,311236_2-sample2_G,Gene Expression
sample2,/path/to/atac_directory,311237_2-sample2_A,Chromatin Accessibility
```

- `sample_id_unique`: Unique sample identifier (used for grouping GEX and ATAC data)
- `fastqs`: Path to directory containing FASTQ files
- `sample`: Folder name that exactly matches the FASTQ folder name (including _G or _A suffix)
- `library_type`: Either "Gene Expression" or "Chromatin Accessibility"
