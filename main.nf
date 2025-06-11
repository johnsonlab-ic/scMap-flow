nextflow.enable.dsl=2

// Default parameters
params.samplesheet = "${projectDir}/personal/samplesheet.csv"
params.outputDir = "output"
params.transcriptome = null
params.cellrangerPath = null

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
        --fastqs=${fastqPath} \\
        --sample=${sampleName} \\
        --transcriptome=${params.transcriptome} \\
    """
}

workflow {
    // Log the pipeline parameters
    log.info """
    ===================================
    scMap-flow pipeline
    ===================================
    Samplesheet: ${params.samplesheet}
    Output directory: ${params.outputDir}
    Transcriptome: ${params.transcriptome}
    Cell Ranger path: ${params.cellrangerPath}
    ===================================
    """
    
    // Read sample information from the CSV samplesheet
    Channel
        .fromPath(params.samplesheet)
        .splitCsv(header: true)
        .map { row -> tuple(row.sample_id, row.sample_name, row.fastq_path) }
        .set { sampleChannel }

    // Map samples
    mapSamples(sampleChannel)
}