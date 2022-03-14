#!/bin/bash
# EEGSTV regions transformed to native space, then project to surface
# 1. EEGSTV regions in MNI152 space warped back into native space
# 2. project EEGSTV regions to surface
# Hengda He, Feb 2021

ReD='\033[91m'
YelloW='\033[93m'
EndC='\033[0m'

SUBJECTS=(180607_Sub11 180618_Sub17 180624_Sub21 180725_Sub25 180829_Sub33 180608_Sub12 180621_Sub18 180626_Sub22 180807_Sub29 180830_Sub34 180612_Sub14 180622_Sub19 180724_Sub23 180808_Sub30 180830_Sub35 180614_Sub15 180623_Sub20 180724_Sub24 180828_Sub32) # all

#SUBJECTS=$1
scriptdir="/home/hengdahe/LAB_2021/ROIs/ROI_v3_EEGSTV/Scripts"
output_subdir="/home/hengdahe/LAB_2020/Subjects"
FSdir="/home/hengdahe/LAB_2020/FS_workspace"
eegstvregiondir="/home/hengdahe/LAB_2021/ROIs/ROI_v3_EEGSTV/GroupLevel/Regions"

echo "Subject output directory: "${output_subdir}
echo "Script directory: "${scriptdir}

SUBJECTS_DIR=${FSdir}

for SUB in ${SUBJECTS[*]};    
do echo ${SUB}

    suboutdir=${output_subdir}/${SUB}/registrations/spatialnormalization
    eegstvregiondir_sub=${output_subdir}/${SUB}/ROIs_EEGSTVBased
    mkdir ${eegstvregiondir_sub}

    T1head=`ls ${output_subdir}/${SUB}/MRIs/${SUB}_STRUCT_bias_removed.nii.gz`
    T1brain=`ls ${output_subdir}/${SUB}/MRIs/${SUB}_STRUCT_bias_removed_brain.nii.gz`
    standardhead="${FSLDIR}/data/standard/MNI152_T1_2mm.nii.gz"
    standardbrain="${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz"
    standard_mask="${FSLDIR}/data/standard/MNI152_T1_2mm_brain_mask_dil.nii.gz"

    # inverse the spatial normalization warp
    #invwarpresult=`ls -ld ${suboutdir}/T1brain2standardbrain_warp_inv.nii.gz | wc -l`
    #if [ $invwarpresult = "1" ]; then
    #    echo -e "${YelloW} Existed: inv warp ${EndC}"
    #else
    #    echo -e "${YelloW} inverse warp ${EndC}"
    #    invwarp --ref=${T1brain} --warp=${suboutdir}/T1brain2standardbrain_warp.nii.gz --out=${suboutdir}/T1brain2standardbrain_warp_inv
    #fi

    # get the mask
    EEGSTV_regionsmap=`ls ${eegstvregiondir}/ROI_all_sphere10mm_bin_sum.nii.gz`

    # warp back to native space
    applywarp --ref=${T1brain} --in=${EEGSTV_regionsmap} --warp=${suboutdir}/T1brain2standardbrain_warp_inv.nii.gz --out=${eegstvregiondir_sub}/ROI_all_sphere10mm_bin_sum_${SUB}_T1Space.nii.gz --interp=nn
    cp ${T1head} ${eegstvregiondir_sub}/
    mri_convert ${FSdir}/${SUB}/mri/orig.mgz ${eegstvregiondir_sub}/orig_FSspace.nii.gz

	for hm in {lh,rh}; do
	    echo "hemisphere: "${hm}
	    mri_vol2surf --mov ${eegstvregiondir_sub}/ROI_all_sphere10mm_bin_sum_${SUB}_T1Space.nii.gz --out ${eegstvregiondir_sub}/${hm}.${SUB}_FSSpace.mgh --projfrac 0.5 --hemi ${hm} --regheader ${SUB}

	    mri_surf2surf --srcsubject ${SUB} --srchemi ${hm} --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi ${hm} --trgsurfreg sphere.reg --tval ${eegstvregiondir_sub}/${hm}.fsaverage.${SUB}.mgh --sval ${eegstvregiondir_sub}/${hm}.${SUB}_FSSpace.mgh --noreshape --cortex
	done


done

echo -e "${YelloW} done ${EndC}"





