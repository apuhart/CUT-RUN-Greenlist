# CUT&RUN Analysis Repository

This GitHub repository is dedicated to performing **CUT&RUN (Cleavage Under Targets & Release Using Nuclease)** analysis using the **Greenlist normalization** approach. This method is based on the work described in the paper:

**Fabio N de Mello, Ana C Tahira, Maria Gabriela Berzoti-Coelho, Sergio Verjovski-Almeida**  
_The CUT&RUN greenlist: genomic regions of consistent noise are effective normalizing factors for quantitative epigenome mapping_  
**Briefings in Bioinformatics, Volume 25, Issue 2, March 2024**, bbad538  
[DOI: 10.1093/bib/bbad538](https://doi.org/10.1093/bib/bbad538)

## Overview

The repository contains the code, scripts, and methods for processing and analyzing CUT&RUN sequencing data using a novel **Greenlist normalization** strategy. This approach leverages specific genomic regions identified as consistent sources of noise across various CUT&RUN experiments, providing an effective and reproducible method for normalization. The Greenlist approach allows for more accurate quantification of chromatin features by reducing experimental biases.

### Key Features:
- Scripts for data processing and normalization of CUT&RUN data
- Implementation of the Greenlist method for normalization
- Tools to handle CUT&RUN sequencing outputs and statistical analysis

## How to Use

1. **Clone the Repository**:
   To get started, clone this repository to your local machine:

   ```bash
   git clone https://github.com/apuhart/CUT-RUN.git

2. **Scripts**:
    The repository contains various scripts (.sh files) to process CUT&RUN data, perform Greenlist normalization, and analyze results. Modify the scripts as necessary for your specific dataset.

4. **Running the Analysis**:
    Ensure that your CUT&RUN sequencing data is prepared according to the formats supported by the scripts. The input typically consists of processed alignment files (e.g., BAM files).

5. **Output**:
    After preparing the data, you can execute the provided shell scripts for analysis. The Greenlist normalization is integrated into the analysis pipeline, ensuring that noise is accounted for during the quantitative epigenome mapping process.

## Citation

If you use this repository or the Greenlist normalization method in your research, please cite the following paper:

**Fabio N de Mello, Ana C Tahira, Maria Gabriela Berzoti-Coelho, Sergio Verjovski-Almeida**  
_The CUT&RUN greenlist: genomic regions of consistent noise are effective normalizing factors for quantitative epigenome mapping_  
**Briefings in Bioinformatics, Volume 25, Issue 2, March 2024**, bbad538  
[DOI: 10.1093/bib/bbad538](https://doi.org/10.1093/bib/bbad538)

## License

This repository is licensed under the MIT License. See the LICENSE file for more details.
