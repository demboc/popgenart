# popgenART Snakemake Workflow
### If you prefer to run the wrapper with Snakemake, you may follow the instructions below:

--- 

### Install Dependencies:
1. FastSimCoal2 (https://cmpg.unibe.ch/software/fastsimcoal28/)
2. art_illumina (https://www.niehs.nih.gov/research/resources/software/biostatistics/art)
3. Miniforge  (https://github.com/conda-forge/miniforge)

--- 

### Set up a Conda Environment:
Assuming you have all the dependencies installed, create a custom environment for this wrapper via:

	conda create -n popgenART snakemake -c bioconda -c conda-forge

Activate it with:

	conda activate popgenART

You can now safely run this wrapper in this isolated snakemake environment.

---

### Prepare Your Input File:
Open empty_input.csv in a text editor. This csv file holds both simulation parameters and the tool paths. You may change the name of this file into something you can easily remember. Make sure to scroll down to the <For Snakemake> section and set:

Field,Parameter  
Prefix,default *(change to desired name for your run)*  
fsc_loc,/path/to/fastsimcoal2 *(change to full path to your working fastsimcoal2 executable)*  
art_loc,/path/to/art_illumina *(change to full path to your working art_illumina executable)*  
input_file,/path/to/empty_input.csv *(change to full path to your input .csv file)*

Example:
Prefix,test_run  
fsc_loc,/home/user/.local/bin/fsc28  
art_loc,/home/user/.local/bin/art_illumina  
input_file,/home/user/popgenart_snakemake/sample_input.csv  

A sample input file has been provided to you in the repository for you to try running the tool with.

---

### Running the Workflow:
Once your input file and environment is ready, run:

	snakemake --cores N

Replace N with the number of CPU cores you want to allocate to the pipeline.

---

### Output:
After a successful run, Snakemake will create:

1. {prefix}/results/ - contains simulated Illumina sequencing files (*.fq, *.sam, *.aln)
2. {prefix}/intermediate_files/ - contains intermediate data used in the run (e.g., .fasta, .arp, .par, etc.)
3. logs for each rule, stored in .snakemake/log
