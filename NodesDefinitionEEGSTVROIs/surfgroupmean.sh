#!/bin/bash
# Surface based group GLM statistical analysis
# 1. concatenate all subjects
# 2. run glm a simple t test across subjects
# 3. correct for multiple comparision using permutation
# Hengda He, Sept 13 2020

ReD='\033[91m'
YelloW='\033[93m'
EndC='\033[0m'

#codepath="/home/hh2699/Lab/Linbi/Scripts"
#subdir="/home/hh2699/Lab/Linbi/Subjects"

scriptdir="/home/hengdahe/LAB_2021/ROIs/ROI_v3_EEGSTV/Scripts"
output_subdir="/home/hengdahe/LAB_2020/Subjects"
FSdir="/home/hengdahe/LAB_2020/FS_workspace"
eegstvregiondir="/home/hengdahe/LAB_2021/ROIs/ROI_v3_EEGSTV/GroupLevel/Regions"
eegstvsurfacedir="/home/hengdahe/LAB_2021/ROIs/ROI_v3_EEGSTV/GroupLevel/surface"

echo "Subject output directory: "${output_subdir}
echo "Script directory: "${scriptdir}

#eegstvregiondir_sub=${output_subdir}/${SUB}/ROIs_EEGSTVBased

    for hm in {lh,rh}; do
        echo "hemisphere: "${hm}


mri_concat ${output_subdir}/*/ROIs_EEGSTVBased/${hm}.fsaverage.*.mgh --o ${eegstvsurfacedir}/${hm}.fsaverage.concate.mgh

mri_concat ${output_subdir}/*/ROIs_EEGSTVBased/${hm}.fsaverage.*.mgh --o ${eegstvsurfacedir}/${hm}.fsaverage.mean.mgh --mean

    done


echo -e "${YelloW} done ${EndC}"
