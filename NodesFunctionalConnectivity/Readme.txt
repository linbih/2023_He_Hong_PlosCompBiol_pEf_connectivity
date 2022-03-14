
fMRI_functionalconnectivity_mixedeffect.m
This script was used for node to node functional connectivity analysis.
This script was used to obtain regulst in Figure 3 of the manuscript.

Preprocessed BOLD time series from each salience processing node was extracted, 
then we removed task related variability from the BOLD time sereies.
Pearson's correlation coefficient (PCC) was computed between the time series of the nodes.
The PCC was converted into Fisher-z score,
The significant z score functional connectivity matrix was visualized (p<0.05 uncorrected).

Inputs: preprocessed BOLD signal of salience processing nodes
Outputs: visualization of significant z score functional connectivity matrix

