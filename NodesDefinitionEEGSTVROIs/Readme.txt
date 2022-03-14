The scripts were used to generate salience processing nodes/ROIs/masks from the group-level EEG-informed fMRI analysis results. 
The scripts were also used to map the nodes onto each subject's cortical surface, warped into fsaverage standard space to be compared with HCP atlas for naming the nodes location/function.
The results from the scripts were used for Figure 1 in the mansuscript.

FSL (FMRIB Software Library v6.0) will be needed for the scripts.
FSL: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki
The FreeSurfer segmentation results of gray matter will be needed.
FreeSurfer: https://surfer.nmr.mgh.harvard.edu

1) GroupEEGSTVregions_peakvox_generateROI_10mm.sh
This script takes the coordinate of peak voxel in each statistically significant cluster from the group level EEG single trial variability (STV) informed fMRI analysis. 
At each peak location, we generated a spherical ROI with radius of 10 mm. 

2) TransformEEGSTVRegions2native_projvol2surf.sh
This script warped the nodes generated in the MNI space back to each subjects structural space. The nodes were then mapped to each subject's reconstructed cortical surface. Then the surface ROIS were warped to fsaverage standard space based on surface registration of the sulcal depth and folding curvature.

3) surfgroupmean.sh
Each subject's surface ROIs were summarized, and a majority voting was performed to obtain the group level surface ROIs, and the results were compared with the HCP atlas in freeview visualization toolbox (FreeSurfer).

4) ROIs_inMNI2Sub_10mm.sh
This script warped each node from the MNI152 standard space to each subject's structural space. The node/ROI in each subject's structural space will be used for the further analyses (functional and effective connectivity analyses).






