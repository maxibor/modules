#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { DAMAGEPROFILER } from '../../../software/damageprofiler/main.nf' addParams( options: [:] )

workflow test_damageprofiler {

    def bam = [ [ id:'test', single_end:false ],
              file("${launchDir}/tests/data/genomics/sarscov2/bam/test_paired_end_mdcalled.sorted.bam", checkIfExists: true)]

    DAMAGEPROFILER ( bam )
}
