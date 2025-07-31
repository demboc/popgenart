PopGenSimWrapper (Snakemake Workflow)

Dependencies:
1. fastsimcoal2 (https://cmpg.unibe.ch/software/fastsimcoal28/)
2. art_illumina (https://www.niehs.nih.gov/research/resources/software/biostatistics/art)
3. R (https://www.r-project.org/)
4. Snakemake  (https://snakemake.readthedocs./)

Getting Started:
To use this workflow, make sure to install Snakemake along with the other dependancies.
In your sample_input.csv file, scroll down to the <For Snakemake> section and set the following:

Prefix,default (change default to whatever you want to name the run)
fsc_loc,/path/to/fastsimcoal2 (change to the location of your working fastsimcoal2)
art_loc,/path/to/art_illumina (change to the location of your working art_illumina)


Running:
In your Snakemake environment, run the following command to start the pipeline:

$ snakemake --cores N

with N being the number of cores you want the wrapper to use.

After a successful run, two new directories named /results and /intermediate_files will be created.
This is where files are stored for each separate run. Output files (*.fq, *.sam, and *.aln files) will
automatically be moved to the /results directory.