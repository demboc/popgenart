## Installation 

Installation of popgenART can be done in three ways as will be outlined below. Upon installation of the dependencies, the user can opt to use a wrapper script run using bash or implemented in Snakemake. The user may also opt to forgo the installation of the dependencies by pulling a docker image containing the scripts and required programs. 

### Bash
To run the pipeline fully in Bash, install the following dependencies:
1. [FastSimCoal2](https://cmpg.unibe.ch/software/fastsimcoal28/)
2. [ART_Illumina](https://www.niehs.nih.gov/research/resources/software/biostatistics/art)

In your working directory, run this code to clone the GitHub repository containing the scripts:
```
git clone -b main https://github.com/demboc/popgensimwrapper popgenART_bash
```
Add execution permission to the wrapper script by running these lines of code:
```
cd popgenART_bash
chmod +x popgenART.sh
```

### Snakemake

To set up Snakemake, follow the following instructions:

Install Dependencies:
1. [FastSimCoal2](https://cmpg.unibe.ch/software/fastsimcoal28/)
2. [ART_illumina](https://www.niehs.nih.gov/research/resources/software/biostatistics/art)
3. [Miniforge](https://github.com/conda-forge/miniforge)

Clone the Snakemake repository and change the current working directory by running the following lines of code:
```
git clone -b snakemake-workflow https://github.com/demboc/popgensimwrapper popgenART_snakemake
cd popgenART_snakemake
```

Setup a Conda environment
1. Assuming you have all the dependencies installed, create a custom environment for this wrapper via:
```
conda create -n popgenART snakemake -c bioconda -c conda-forge
```
2. Activate the environment.
```
conda activate popgenART
```
3. You can now safely run this wrapper in this isolated snakemake environment.



