nextflow.enable.dsl=2

// Default parameters
params.samplesheet = "${projectDir}/personal/samplesheet.csv"
params.outputDir = '/rds/general/user/ah3918/projects/puklandmarkproject/ephemeral/alex/mapping_outs'
params.transcriptome = '/rds/general/user/ah3918/projects/puklandmarkproject/live/Users/tools/reference_data/cellranger/refdata-gex-GRCh38-2024-A'
params.cellrangerPath = '/rds/general/user/ah3918/projects/puklandmarkproject/live/Users/tools/cellranger-9.0.1/cellranger'
params.localCores = 20
params.localMem = 400

process mapSamples {
    label "process_higher_memory"
    tag { sampleId }
    publishDir "${params.outputDir}", mode: 'copy', overwrite: true
    input:
    tuple val(sampleId), val(fastqPath), val(sampleName)

    output:
    path "${sampleId}_mapped"

    script:
    """
    echo "Processing sample ${sampleId} from ${fastqPath} with sample name ${sampleName}"
    ${params.cellrangerPath} count --id="${sampleId}_mapped" \\
        --fastqs=${fastqPath} \\
        --sample=${sampleName} \\
        --transcriptome=${params.transcriptome} \\
        --localcores=${params.localCores} \\
        --localmem=${params.localMem} \\
        --create-bam=true
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
        .map { row -> tuple(row.sample_id, row.fastq_path, row.sample_name) }
        .set { sampleChannel }

    // Map samples
    mapSamples(sampleChannel)
}