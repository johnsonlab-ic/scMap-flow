# scMap-flow

A simple Nextflow pipeline for processing single-cell RNA-seq data using Cell Ranger.

## Requirements

- [Nextflow](https://www.nextflow.io/)
- [Cell Ranger](https://support.10xgenomics.com/single-cell-gene-expression/software/overview/welcome)
- Reference transcriptome (e.g., GRCh38)

## Quick Start

1. Prepare a samplesheet CSV with the following format:
   ```csv
   sample_id,fastq_path,sample_name
   sample1,/path/to/fastq/directory,1
   sample2,/path/to/fastq/directory,2
   ```

2. Run the pipeline:
   ```bash
   nextflow run main.nf \\
     --samplesheet path/to/samplesheet.csv \\
     --outputDir path/to/output \\
     --transcriptome path/to/transcriptome \\
     --cellrangerPath path/to/cellranger \\
     -profile imperial
   ```

## Parameters

| Parameter | Description |
|-----------|-------------|
| `--samplesheet` | Path to input CSV samplesheet |
| `--outputDir` | Directory for output files |
| `--transcriptome` | **REQUIRED**: Path to reference transcriptome |
| `--cellrangerPath` | **REQUIRED**: Path to Cell Ranger executable |
| `--localCores` | Number of cores for Cell Ranger (default: 20) |
| `--localMem` | Memory in GB for Cell Ranger (default: 400) |

## Notes

- The `sample_id` is used to name output directories
- The `sample_name` should match the prefix in your FASTQ filenames
- Ensure your Cell Ranger installation is compatible with your reference transcriptome