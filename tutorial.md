## Tutorial

popgenART comes with two sample csv files to be used as sample inputs. One csv file (sample_input.csv) contains parameters with pre-assigned values and, thus, can be used to run the line of code below.

```
./popgenART.sh -i sample_input.csv -p <prefix> -f <location of fastsimcoal2 binary> -a <location of art_illumina binary>
```
*Note: ./popgenART.sh can be replaced with the location of the wrapper script. All flags are required. 

Three folders will be created containing the temporary files, intermediate input files, and the final output file (generated sample genomes (.fasta) and short reads (.sam, .aln, and .fq files)). 

The second input file is an editable csv file listing all possible parameters (names formatted correctly) with no preset values. Users can thus customize as needed, keeping in mind the necessary parameters for the evolutionary scenario being modeled and the type of sequencing method to be used. Simplified instructions for fastsimcoal2 and art_illumina are provided below. Unnecessary rows can be deleted if not relevant. 

#### Parameters for fastsimcoal2 

| Parameter | Parameter name in input file | Description | Additional notes |
|-----------------|-----------------|-----------------|-----------------|
| Number of population samples | Demes | Number of populations to be simulated; Natural number (1,2,3,...) |Basis for the number of values required for other parameters with label (*)|
|Population effective size*|Pop_Size|Number of genes present in a population ||



