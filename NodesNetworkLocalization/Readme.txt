The scripts here were used for seed based functional connectivity and nodes network localization.
The scripts were used to obtain results in Figure 2 of the manuscript.

FSL (FMRIB Software Library v6.0) will be needed for the scripts.
FSL: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki
The FreeSurfer segmentation results of gray matter will be needed.
FreeSurfer: https://surfer.nmr.mgh.harvard.edu

1) extract_EEGSTVROI_timeseries_FSGMmask.sh

This script will extract preprocessed BOLD time series from each salience processing node.
The node shperical ROI binary mask will be intersected with the gray matter ribbon mask.
And the intersection will be used to extract the averaged (across voxels in the mask) preprocessed BOLD time series within the mask.
The preprocessed BOLD time series of each salience processing nodes will be saved.

Inputs: salience processing node spherical ROI mask, graymatter ribbon masks (from FreeSurfer)
Outputs: preprocessed BOLD signal of salience processing nodes

2) seedbasedFCanalysis.m

This script will run seed based functional connectivity analysis. 
The preprocessed BOLD time sereies of each salience processing node will be extracted.
Pearson's correlation coefficient (PCC) will be computed between the node's BOLD time sereies and preprocessed BOLD signal of each fMRI voxel.
The PCC will be converted into Fisher-z score, and the z score map will be saved.

Inputs: preprocessed BOLD signal of salience processing nodes, preprocessed fMRI data
Outputs: seed-based functional connectivity z score map for each subject and each node

3) seedbasedFCanalysis_groupTtest.m

This script will run the random effect (t test) group level statistical analysis on the seed-based functional connectivity z score map across subjects for each node/ROI.
The group level p value and t value maps will be saved.

Inputs: seed-based functional connectivity z score map for each subject and each node
Outputs: group level p value and t value maps for each node



