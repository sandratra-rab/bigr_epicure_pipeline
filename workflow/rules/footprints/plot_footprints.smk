rule plot_footprints_sample:
    input:
        unpack(get_plot_footprints_input),
    output:
        png="data_output/Motifs/Fingerprints/{sample}/{sample}.{motif}.png",
        bam=temp("fingerprints/{sample}.{motif}.bam"),
        bai=temp("fingerprints/{sample}.{motif}.bam.bai"),
        rda=temp("fingerprints/{sample}.{motif}.RData"),
    threads: 1
    resources:
        mem_mb=lambda wildcards, attempt: attempt * 1024 * 30,
        runtime=lambda wildcards, attempt: attempt * 60 * 2,
        tmpdir=tmp,
    log:
        "logs/plot_footprints/{sample}.log"
    params:
        name="{sample}",
        motif="{motif}",
    conda:
        "../../envs/factorfootprints.yaml"
    script:
        "../../scripts/factorfootprints/factor_footprints.R"


rule plot_footprints_condition:
    input:
        unpack(get_plot_footprints_input),
    output:
        png="data_output/Motifs/Fingerprints/{model_name}/{model_name}.{motif}.png",
        bam=temp("fingerprints/{model_name}.{motif}.bam"),
        bai=temp("fingerprints/{model_name}.{motif}.bam.bai"),
        rda=temp("fingerprints/{model_name}.{motif}.RData"),
    threads: 1
    resources:
        mem_mb=lambda wildcards, attempt: attempt * 1024 * 30,
        runtime=lambda wildcards, attempt: attempt * 60 * 2,
        tmpdir=tmp,
    log:
        "logs/plot_footprints/{model_name}.log"
    params:
        name="{model_name}",
        motif="{motif}",
    conda:
        "../../envs/factorfootprints.yaml"
    script:
        "../../scripts/factorfootprints/factor_footprints.R"