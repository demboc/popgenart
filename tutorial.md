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
|Sample size*|Sample_Size| Number of individuals within a specific population||
|Growth rate*|Growth_Rate|Initial growth rates for population samples (e.g. 0 no growth). Given the current sample size of No , the final population size is calculated based on the growth rate of r in t generations is: $N_t = N_0 e^{rt}$ | 
|Number of migration matrices|No_Migration||Number should correspond to the number of matrices in the succeeding lines; Can be used only when the number of demes is greater than 1. |
|Migration Matrix|Migration_Matrix|Details the direction of the migrant from one deme to another. |Example usage:<br><br>With two demes (deme 0 and 1), the input for the migration matrix<br><br>Migration_Matrix,0.0,0.0005, 0.0001,0.0<br><br>Means that deme 0 is sending a migrant backwards in time to deme 1 at a rate of 0.0005. This is given by the first two numbers. Deme 1 is sending migrants to deme 0 at a rate of 0.0001.|
|Number of historical event| Hist_Event||Number corresponds to the number of historical events; Basis for the number of values required for other parameters with label(**)|
|Number of generations**|Time|Number of generations prior to the occurrence of the historical event ||
|Source deme**|Source|Deme that is the source of the migrants|Note that the first deme corresponds to deme 0|
|Sink deme**|Sink|Deme to which the individuals will migrate|Note that the first deme corresponds to deme 0|
|Number of migrants**|Migrants|Expected number of migrants moving from source to sink deme||
|New size of the sink deme**|New_Size|New size of the sink deme relative to its size at (Time)||
|New growth rate of the sink deme**|New_Growth|New growth rate of the sink deme ||
|New migration matrix**|H_Migration_M|New migration matrix to be used further back in time  ||
|Number of independent chromosomes|Num_Chrom|Indicates prokaryotic (1) or eukaryotic (>1) individuals|Basis for the number of values required for other parameters with label (***)|
|Chromosome structure|Chrom_Structure|If individuals have >1 chromosomes, these chromosomes can either have different (1) or similar (0) structures.||
|Number of chromosome segments ***|Num_Blocks|Number of chromosome segments that may differ by the type of markers, recombination rates, etc. |Basis for the number of values required for other parameters with label (****)|
|Data type ****|Data_Type|Type of genetic marker to be simulated|Current implementation only supports DNA type|
|Number of markers **** |Num_Loci|Number of marker with the specific data type |For the DNA type, Num_Loci corresponds to the sequence length|
|Recombination rate ****|Recomb_Rate|Recombination rate between adjacent markers||
|Mutation rate ****|Mut_Rate||In the case of the DNA type, mutation rate per base pair|
|Transition rate|Trans_RateFraction of the substitutions that are transitions (purine to purine or pyrimidine to pyrimidine)|Only applicable for DNA type mutation|



































