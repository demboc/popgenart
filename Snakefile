# Snakefile


# Define variables
prefix = config.get("prefix", "defaultprefix")
input_csv = "sample_input.csv"
fsc_loc = "/home/dembs/.local/bin/fsc28"
art_loc = "/usr/local/bin/art_illumina"

# Rule to define final outputs (must exist after a successful run)
rule all:
    input:
        "scripts_ready.flag",
        f"{prefix}.par",
        f"{prefix}.arp",
        f"{prefix}_tempseq.fa",
        f"{prefix}_indices.txt",
        f"{prefix}_SNPseq.csv",
        f"{prefix}.fasta",
        f"{prefix}1.fq",
        f"{prefix}2.fq"

# Rule to ensure all scripts are executable with permissions
rule chmod_scripts:
    input:
        scripts=[
            "parser_script.sh",
            "dummygen_script.sh",
            "generatefasta_script.sh",
            "art_illum.sh",
            "parse_arp.sh"
        ]
    output:
        touch("scripts_ready.flag")
    shell:
        """
        chmod +x {input}
        touch {output}
        """

# Rule to generate .par file from input CSV
rule generate_par_file:
    input:
        csv=input_csv
    output:
        par=f"{prefix}.par"
    params:
        prefix=prefix
    shell:
        """
        ./parser_script.sh {input} {params.prefix}
        """


# Rule to run fastsimcoal to generate .arp file
rule run_fsc:
    input:
        par=f"{prefix}.par"
    output:
        arp=f"{prefix}.arp"
    params:
        fsc_loc=fsc_loc,
        prefix=prefix
    shell:
        """
        {params.fsc_loc} -i {input} -n1
        mv {params.prefix}/*.arp {output}
        """

# Rule to generate dummy reference sequence
rule generate_dummy_sequence:
    input:
        csv=input_csv
    output:
        fasta=f"{prefix}_tempseq.fa"
    params:
        prefix=prefix
    shell:
        """
        ./dummygen_script.sh {input} {params.prefix}
        """

# Rule to parse .arp file from run_fsc to get indices and SNP data
rule parse_arp:
    input:
        arp=f"{prefix}.arp"
    output:
        indices="{prefix}_indices.txt",
        snps="{prefix}_SNPseq.csv"
    params:
        prefix=prefix
    shell:
        """
        ./parse_arp.sh {params.prefix} {input}
        """


# Rule to generate final simulated population data in .fasta
rule generate_fasta:
    input:
        f"{prefix}_indices.txt",
        f"{prefix}_tempseq.fa",
        f"{prefix}_SNPseq.csv"
    output:
        f"{prefix}.fasta"
    params:
        prefix=prefix
    shell:
        """
        ./generatefasta_script.sh {params.prefix} {input}
        """


# Rule to simulate sequencing reads with ART
rule simulate_reads_with_art:
    input:
        fasta="{prefix}.fasta",
        csv=input_csv
    output:
        fq1="{prefix}1.fq",
        fq2="{prefix}2.fq"
    params:
        prefix="{prefix}",
        artloc=art_loc
    shell:
        """
        ./art_illum.sh {params.prefix} {input.csv} {params.artloc}
        """

