# CUT&RUN Analysis Repository


"""
This GitHub repository is dedicated to performing CUT&RUN (Cleavage Under Targets & Release Using Nuclease) analysis using the Greenlist normalization approach. This method is based on the work described in the paper:


Fabio N de Mello, Ana C Tahira, Maria Gabriela Berzoti-Coelho, Sergio Verjovski-Almeida
The CUT&RUN greenlist: genomic regions of consistent noise are effective normalizing factors for quantitative epigenome mapping
Briefings in Bioinformatics, Volume 25, Issue 2, March 2024, bbad538
DOI: 10.1093/bib/bbad538
"""


README = """
## Overview


This repository contains the code, scripts, and methods for processing and analyzing CUT&RUN sequencing data using a Greenlist normalization strategy. The approach leverages genomic regions identified as consistent sources of noise across various CUT&RUN experiments, providing a reproducible method for normalization and more accurate quantification of chromatin features.


## Key Features


- Scripts for processing and normalizing CUT&RUN data
- Implementation of the Greenlist normalization method
- Handling of CUT&RUN sequencing outputs and statistical analysis


## How to Use


### Clone the Repository


git clone https://github.com/apuhart/CUT-RUN-Greenlist.git


### Running the Pipeline


The main pipeline is executed via the run_pipeline.sh script. Run it as follows:


bash run_pipeline.sh \
-i "data" \
-o "output" \
-g "Homo_sapiens.GRCh38.dna.primary_assembly.fa"


Where:
- -i "data" specifies the folder containing your input CUT&RUN sequencing data
- -o "output" specifies the folder where results will be written
- -g specifies the reference genome


Note: Ensure the data folder and reference genome are prepared as required. The output folder will be created if it does not exist.


## Citation


Fabio N de Mello, Ana C Tahira, Maria Gabriela Berzoti-Coelho, Sergio Verjovski-Almeida
The CUT&RUN greenlist: genomic regions of consistent noise are effective normalizing factors for quantitative epigenome mapping
Briefings in Bioinformatics, Volume 25, Issue 2, March 2024, bbad538
DOI: 10.1093/bib/bbad538


## License


This repository is licensed under the MIT License. See the LICENSE file for details.
"""
