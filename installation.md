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
   
### Docker 

1. Create an account in [Docker cloud](https://hub.docker.com/) or install [Docker-Desktop](https://www.docker.com/products/docker-desktop/) for Windows. Ensure that your machine uses Linux or a subsystem equivalent to it.  
2. Other dependencies (i.e., Fastsimcoal2 and ART_illumina) required for running the program are already packaged in the Dockerfile. **You no longer need to install these**.

**Creating a Docker image and container from scratch**
1. Download scripts in https://github.com/demboc/popgensimwrapper.git >docker-image-to-container.
```
git clone -b docker-image-to-container https://github.com/demboc/popgensimwrapper
```

2. If you have downloaded the source files in your machine, open the terminal directly. Through the terminal, open or set the working directory to the source folder containing the scripts. Open the sample_input.csv file and edit the necessary parameters for running the program. **Do not modify the file name**.
3. Create the Docker image:
```
docker build -t <my-image>
```
4. To check if the image was successfully built, run this command and ensure that the set name of your image is in the list:
```
docker images
```
5. You may now use the image to build the container. The real-time execution of the scripts will be displayed in the terminal.
   *If the sample_input.csv file is inside the present working directory, run this command:*
   ```
   docker run -v “&(pwd)”:/popgen <my-image>
   ```

   *If the sample_input.csv file is in a different path, use this command:*
   ```
   docker run \
   -v /path/sample_input.csv:/popgen/sample_input.csv \
   -v “$(pwd)”:/popgen \
   <my-image>
   
   ```






