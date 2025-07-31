# Snakefile

import csv

# Load CSV config into dictionary
config_data = {}
with open("sample_input.csv", newline="") as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
        if row and len(row) == 2:
            key, value = row
            config_data[key.strip()] = value.strip()

# Extract values
prefix = config_data.get("Prefix", "defaultprefix")
sequencing_mode = config_data.get("Sequencing_Mode", "paired").strip().lower()
is_paired = sequencing_mode in ("paired", "matepair")
fsc_loc = config_data.get("fsc_loc")
art_loc = config_data.get("art_loc")

# Rule to define final outputs (must exist after a successful run)
rule all:
    input:
        "scripts_ready.flag",
        f"results/{prefix}/.organized",
        f"intermediate_files/{prefix}/.organized"


# Rule to ensure all scripts are executable with permissions
rule chmod_scripts:
    input:
        scripts=[
            "scripts/parser_script.sh",
            "scripts/dummygen_script.sh",
            "scripts/generatefasta_script.sh",
            "scripts/art_illum.sh",
            "scripts/parse_arp.sh"
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
        csv="sample_input.csv"
    output:
        par=f"{prefix}.par"
    params:
        prefix=prefix
    shell:
        """
        scripts/parser_script.sh {input} {params.prefix}
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
        csv="sample_input.csv"
    output:
        fasta=f"{prefix}_tempseq.fa"
    params:
        prefix=prefix
    shell:
        """
        scripts/dummygen_script.sh {input} {params.prefix}
        """

# Rule to parse .arp file from run_fsc to get indices and SNP data
rule parse_arp:
    input:
        arp=f"{prefix}.arp"
    output:
        indices=f"{prefix}_indices.txt",
        snps=f"{prefix}_SNPseq.csv"
    params:
        prefix=prefix
    shell:
        """
        scripts/parse_arp.sh {params.prefix} {input}
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
        scripts/generatefasta_script.sh {params.prefix} {input}
        """

# Rule to simulate paired-end reads or single-end reads in art_illumina
if is_paired:
    rule simulate_reads:
        input:
            fasta=f"{prefix}.fasta",
            csv="sample_input.csv"
        output:
            fq1=f"{prefix}1.fq",
            fq2=f"{prefix}2.fq",
            aln1=f"{prefix}1.aln",
            aln2=f"{prefix}2.aln",
            sam=f"{prefix}.sam"
        params:
            prefix=prefix,
            artloc=art_loc
        shell:
            r"""
            scripts/art_illum.sh {params.prefix} {input.csv} {params.artloc}
            """
else:
    rule simulate_reads:
        input:
            fasta=f"{prefix}.fasta",
            csv="sample_input.csv"
        output:
            fq1=f"{prefix}.fq",
            aln1=f"{prefix}.aln",
            sam=f"{prefix}.sam"
        params:
            prefix=prefix,
            artloc=art_loc
        shell:
            r"""
            scripts/art_illum.sh {params.prefix} {input.csv} {params.artloc}
            """

# Rule to move outputs and intermediate files in their respective directories after everything
rule organize_files:
    input:
        flag=f"{prefix}.sam"
    output:
        results_flag=f"results/{prefix}/.organized",
        intermediate_flag=f"intermediate_files/{prefix}/.organized"
    shell:
        """
        mkdir -p results/{prefix}
        mkdir -p intermediate_files/{prefix}
        shopt -s nullglob
        mv *.fq results/{prefix}/
        mv *.aln results/{prefix}/
        mv *.sam results/{prefix}/
        mv *.arp intermediate_files/{prefix}/
        mv *.fasta intermediate_files/{prefix}/
        mv *.par intermediate_files/{prefix}/
        mv *.fa intermediate_files/{prefix}/
        mv *indices.txt intermediate_files/{prefix}/
        mv *seed.txt intermediate_files/{prefix}/
        mv *SNPseq.csv intermediate_files/{prefix}/
        rm {prefix}/*.arb {prefix}/*.simparam
        rmdir {prefix}
        touch {output.results_flag} {output.intermediate_flag}
        """
