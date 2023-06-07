rule chipseeker_plot_distance_to_tss_single_sample:
    input:
        ranges="chipseeker/annotation/{sample}.{peaktype}.RDS",
    output:
        png="data_output/Peak_Calling/{peaktype}/Distance_to_TSS/{sample}.png",
    threads: 1
    resources:
        mem_mb=lambda wildcards, attempt: attempt * 1024 * 4,
        runtime=lambda wildcards, attempt: attempt * 20,
        tmpdir=tmp,
    log:
        "logs/chipseeker/distanceplot/{sample}.{peaktype}.log",
    params:
        extra="",
    conda:
        "../../envs/chipseeker.yaml"
    script:
        "../../scripts/chipseeker/chipseeker_plot_distance_tss.R"


rule chipseeker_plot_distance_to_tss_differential_binding:
    input:
        ranges="chipseeker/annotation/{model_name}.RDS",
    output:
        png="data_output/Differential_Binding/{model_name}/Distance_to_TSS.png",
    threads: 1
    resources:
        mem_mb=lambda wildcards, attempt: attempt * 1024 * 4,
        runtime=lambda wildcards, attempt: attempt * 20,
        tmpdir=tmp,
    log:
        "logs/chipseeker/distanceplot/{model_name}.log",
    params:
        extra="",
    conda:
        "../../envs/chipseeker.yaml"
    script:
        "../../scripts/chipseeker/chipseeker_plot_distance_tss.R"
