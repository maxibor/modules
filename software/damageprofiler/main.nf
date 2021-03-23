include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

unset display

process DAMAGEPROFILER {
    tag "$meta.id"
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    conda (params.enable_conda ? "bioconda::damageprofiler=1.1" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/damageprofiler:1.1--0"
    } else {
        container "quay.io/biocontainers/damageprofiler:1.1--0"
    }

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*/*.txt")             , optional:true, emit: txt
    tuple val(meta), path("*/DamageProfiler.log"), emit: log
    tuple val(meta), path("*/*.pdf")             , optional:true, emit: pdf
    tuple val(meta), path("*/dmgprof.json")      , optional:true, emit: json
    path "*.version.txt"                                 , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    def avail_mem = 2
    if (!task.memory) {
        log.info '[DamageProfiler] Available memory not known - defaulting to 3GB. Specify process memory requirements to change this.'
    } else {
        avail_mem = task.memory.giga
    }
    """
    damageprofiler -Xmx${avail_mem}g \\
        -i $bam \\
        -o $prefix
        $options.args \\

    damageprofiler --version 2>&1 | sed -e "s/DamageProfiler v//g" > ${software}.version.txt
    """
}
