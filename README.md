# scMap-flow

A simple Nextflow pipeline for processing single-cell RNA-seq data using Cell Ranger.

## Requirements

- Nextflow
- Cell Ranger (standard or ARC version for multiome data)
- Reference transcriptome

## Quick Start

### Standard scRNA-seq

```bash
nextflow run johnsonlab-ic/scMap-flow \
  --samplesheet path/to/samplesheet.csv \
  --outputDir path/to/output \
  --transcriptome path/to/transcriptome \
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
  --cellranger_arc_ref_path path/to/arc_reference \
  -profile imperial
```

## Samplesheet Format

Both workflows use a CSV format with the following columns:
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