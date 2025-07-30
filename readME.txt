PopGenSimWrapper (Snakemake Workflow)

Make sure you have Snakemake installed in your system (see https://snakemake.readthedocs.io/en/stable/)

In your Snakemake environment, run the following command:

snakemake --config prefix=defaultprefix --cores N

where:
- defaultprefix is your run name (you can change this to whatever you want)
- N is the number of CPU cores that will be used for the run (just set it to 1 or all)

Make sure that you have the following:
1. fastsimcoal2 (https://cmpg.unibe.ch/software/fastsimcoal28/)
2. art_illumina (https://www.niehs.nih.gov/research/resources/software/biostatistics/art)
3. rbase (for this, edit the script if you are not running in the pgc hpc server -> change to whatever can run an r script)
