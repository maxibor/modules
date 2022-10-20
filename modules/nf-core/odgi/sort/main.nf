process ODGI_SORT {
    tag "$meta.id"
    label 'process_high'

    conda (params.enable_conda ? "bioconda::odgi=0.8.0" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/odgi:0.8.0--py310hc8f18ef_0':
        'quay.io/biocontainers/odgi:0.8.0--py310hc8f18ef_0' }"

    input:
    tuple val(meta), path(graph)

    output:
    tuple val(meta), path("*.og"), emit: sorted_graph
    path "versions.yml"          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    odgi \\
        sort \\
        --threads $task.cpus \\
        --idx ${graph} \\
        --out ${prefix}.og \\
        $args
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        odgi: \$(echo \$(odgi version 2>&1) | cut -f 1 -d '-' | cut -f 2 -d 'v')
    END_VERSIONS
    """
}
