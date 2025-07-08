nextflow.enable.dsl=2

// Default parameters
params.samplesheet = "${projectDir}/personal/samplesheet.csv"
params.outputDir = "output"
params.transcriptome = null
params.cellrangerPath = null
params.arc = false  // Parameter to control whether to use the multiome (ARC) process

process mapSamples {
    label "process_higher_memory"
    tag { sampleId }
    publishDir "${params.outputDir}", mode: 'copy', overwrite: true
    input:
    tuple val(sampleId), val(sampleName), val(fastqPath)

    output:
    path "${sampleId}_mapped"

    script:
    """
    echo "Processing sample ${sampleId} from ${fastqPath} with sample name ${sampleName}"
    ${params.cellrangerPath} count --id="${sampleId}_mapped" \\
        --create-bam true \\
        --fastqs=${fastqPath} \\
        --sample=${sampleName} \\
        --transcriptome=${params.transcriptome} \\
    """
}

process mapSamples_multiome {
    label "process_higher_memory"
    tag { sampleId }
    publishDir "${params.outputDir}", mode: 'copy', overwrite: true
    input:
    tuple val(sampleId), val(sampleName), val(fastqPath)

    output:
    path "${sampleId}_mapped_arc"

    script:
    """
    echo "Processing multiome sample ${sampleId} from ${fastqPath} with sample name ${sampleName}"
    ${params.cellranger_arc_path} count --id="${sampleId}_mapped_arc" \\
        --fastqs=${fastqPath} \\
        --sample=${sampleName} \\
        --reference=${params.cellranger_arc_ref_path}
    """
}

// Parameters for multiome workflow
params.samplesheet_multiome = null
params.cellranger_arc_path = null
params.cellranger_arc_ref_path = null

// Define the RNA workflow
workflow rna {
    // Log the pipeline parameters
    log.info """
    ===================================
    scMap-flow 10x RNA pipeline
    ===================================
    Samplesheet: ${params.samplesheet}
    Output directory: ${params.outputDir}
    Transcriptome: ${params.transcriptome}
    Cell Ranger path: ${params.cellrangerPath}
    ===================================
    """
    
    if (!params.samplesheet) {
        error "Samplesheet not provided. Please specify --samplesheet"
    }
    
    if (!params.transcriptome) {
        error "Transcriptome not provided. Please specify --transcriptome"
    }
    
    if (!params.cellrangerPath) {
        error "Cell Ranger path not provided. Please specify --cellrangerPath"
    }
    
    // Read sample information from the CSV samplesheet
    Channel
        .fromPath(params.samplesheet)
        .splitCsv(header: true)
        .map { row -> tuple(row.sample_id, row.sample_name, row.fastq_path) }
        .set { sampleChannel }

    // Process RNA samples
    mapSamples(sampleChannel)
}

// Define the multiome workflow
workflow multiome {
    // Log the pipeline parameters for multiome workflow
    log.info """
    ===================================
    scMap-flow 10x Multiome pipeline
    ===================================
    Multiome Samplesheet: ${params.samplesheet_multiome ?: 'Not provided'}
    Output directory: ${params.outputDir}
    Multiome Reference: ${params.cellranger_arc_ref_path ?: 'Not provided'}
    Cell Ranger ARC path: ${params.cellranger_arc_path ?: 'Not provided'}
    ===================================
    """
    
    if (!params.samplesheet_multiome) {
        error "Multiome samplesheet not provided. Please specify --samplesheet_multiome"
    }
    
    if (!params.cellranger_arc_ref_path) {
        error "Multiome reference not provided. Please specify --cellranger_arc_ref_path"
    }
    
    if (!params.cellranger_arc_path) {
        error "Cell Ranger ARC path not provided. Please specify --cellranger_arc_path"
    }
    
    // Read sample information from the multiome CSV samplesheet
    Channel
        .fromPath(params.samplesheet_multiome)
        .splitCsv(header: true)
        .map { row -> tuple(row.sample_id, row.sample_name, row.fastq_path) }
        .set { multiomeSampleChannel }

    // Process multiome samples
    mapSamples_multiome(multiomeSampleChannel)
}

// Main entry workflow - selects which workflow to run based on params
workflow {
    if (params.arc) {
        multiome()
    } else {
        rna()
    }
}
