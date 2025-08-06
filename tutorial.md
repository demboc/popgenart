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
|Transition rate|Trans_Rate|Fraction of the substitutions that are transitions (purine to purine or pyrimidine to pyrimidine)|Only applicable for DNA type mutation|


#### Parameters for ART_Illumina

**Required (for all sequencing mode)**

| Parameter | Parameter name in input file | Description | Additional notes |
|-----------------|-----------------|-----------------|-----------------|
|Read length|Read_Length|Length of fragments to be simulated from the reference fasta||
|Fold coverage|Fold_Coverage|Number of times a fragment is sequenced||
|Sequencing mode|Sequencing_Mode|Mode of sequencing|Can be:<br><br>**single** - Single-end sequencing <br><br>**paired** - Paired-end sequencing <br><br> **mate-pair** - Mate-pair sequencing|

**Required (for paired-end and mate-pair sequencing modes**

| Parameter | Parameter name in input file | Description | Additional notes |
|-----------------|-----------------|-----------------|-----------------|
|Mean fragment size|Mean_Frag_Size|Mean size of the insert (stretch of DNA sequence between the two reads)|For paired-end and mate-pair sequencing modes only<br><br>Note: If >2000 automatically changes the sequencing mode to mate-pair sequencing|
|Standard deviation of fragment sizes|Stdv_Frag_Size|Standard deviation of the insert sizes|For paired-end and mate-pair sequencing modes only|

**Not required (with default values**
| Parameter | Parameter name in input file | Description | Additional notes |
|-----------------|-----------------|-----------------|-----------------|
|Insertion rate|Insertion_Rate_FR<br><br>Insertion_Rate_SR|First read and second read (* for paired-end or mate-pair only) insertion rates during sequencing by synthesis|Default values:<br><br>Insertion_Rate_FR = 0.00009<br><br>Insertion_Rate_SR = 0.00015|
|Deletion rate|Deletion_Rate_FR<br><br>Deletion_Rate_SR<br><br>|First read and second read (* for paired-end or mate-pair only) deletion rates during sequencing by synthesisDefault values:<br><br>Deletion_Rate_FR = 0.00011<br><br>Deletion_Rate_SR = 0.00023|
|Quality score shift|QS_Shift_FR<br><br>QS_Shift_SR|The amount of quality shift for the base scores for the first read and second read (* for paired-end only).<br><br>Error rates are shifted based on this calculation $\frac{1}{10^{\frac{x}{10}}}$, <br><br>Where x is the QS assigned by the user.<br><br>Example:<br><br>A QS shift of 10 means the errors will be reduced to a tenth of the original.|Default values:<br><br>QS_Shift_FR = 0<br><br>QS_Shift_SR = 0 
|Masking cutoff |Masking_Cutoff|Cutoff ‘N’ frequency in a window size of a read length for masking regions|Default is “1” to mask all regions|
|Sequencing system|Sequencing_System|Illumina sequencing system with built-in (error) profiles to be used in simulation. |Can be:<br><br>**GA1** - Genome Analyzer I <br><br>**GA2** - Genome Analyzer II<br><br>**HS10** - HiSeq 1000<br><br>**HS20** - HiSeq 2000<br><br>HS25 - HiSeq 2500<br><br>**HSXn** - HiSeqX PCR free<br><br>**HSXt** - HiSeqX TruSeq<br><br>**MinS** - MiniSeq TruSeq<br><br>**MSv1** - MiSeq v1<br><br>**MSv3** - MiSeq v3<br><br>**NS50** - NextSeq500 v2 |
|SAM file|SAM_File|Indicate if SAM file would be generated|“Yes” or “No”|
|Alignment (Aln) file|Alignment_File|Indicate if alignment file would be generated|“Yes” or “No”|
|Error Free|Error_Free|Used to generate a SAM file with zero sequencing error along with the other files with the incorporated errors.|“Yes” or “No”|
|Separate quality score profile|Separate_QS|Separate QS profile for each nucleotide base|“Yes” or “No”|

#### Additional parameters
| Parameter | Parameter name in input file | Description | Additional notes |
|-----------------|-----------------|-----------------|-----------------|
|GC content|GC_Con|Proportion of GC in the genome to be simulated|Required in decimal notation (*e.g.*0.5)|


To further explore fastsimcoal2 and art_illumina, the user can also refer to the following documentations:
1. [ART_Illumina manual page](https://manpages.debian.org/testing/art-nextgen-simulation-tools/art_illumina.1.en.html)
2. [Fastsimcoal2 manual (PDF)](https://cmpg.unibe.ch/software/fastsimcoal2-25221/man/fastsimcoal25.pdf)

























































