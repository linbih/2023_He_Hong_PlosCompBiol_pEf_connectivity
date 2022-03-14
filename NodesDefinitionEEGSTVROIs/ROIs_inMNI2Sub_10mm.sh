#!/bin/bash
# transform ROIs in MNI space to subject space, EEGSTV based ROIs
# Hengda He, Mar 16th 2021

ReD='\033[91m'
YelloW='\033[93m'
EndC='\033[0m'

#SUBJECTS=$1
SUBJECTS=(180607_Sub11 180618_Sub17 180624_Sub21 180725_Sub25 180829_Sub33 180608_Sub12 180621_Sub18 180626_Sub22 180807_Sub29 180830_Sub34 180612_Sub14 180622_Sub19 180724_Sub23 180808_Sub30 180830_Sub35 180614_Sub15 180623_Sub20 180724_Sub24 180828_Sub32) # all

scriptdir="/home/hengdahe/LAB_2021/ROIs/ROI_v3_EEGSTV/Scripts"
output_subdir="/home/hengdahe/LAB_2020/Subjects"
groupica_dir="/home/hengdahe/LAB_2021/ROIs/ROI_v3_EEGSTV/GroupLevel/Regions"
data_subdir="/home/hengdahe/LAB_2020/Subjects"

echo "output directory: "${output_subdir}
echo "Script directory: "${scriptdir}
echo "group ica directory: "${groupica_dir}

for SUB in ${SUBJECTS[*]};
do echo ${SUB}

    suboutdir=${output_subdir}/${SUB}/registrations/spatialnormalization
    roidir_sub=${output_subdir}/${SUB}/ROIs_EEGSTVBased/final
    mkdir ${roidir_sub}
    roidir_sub_HCP=${output_subdir}/${SUB}/ROIs_EEGSTVBased/final_HCP
    mkdir ${roidir_sub_HCP}

    T1brain=`ls ${data_subdir}/${SUB}/MRIs/${SUB}_STRUCT_bias_removed_brain.nii.gz`

    # get the MNI space ROIs
    mask_left_Postcentral=${groupica_dir}/ROI_left_Postcentral_sphere10mm_bin.nii.gz
    mask_left_SPL=${groupica_dir}/ROI_left_SPL_sphere10mm_bin.nii.gz
    mask_left_SuperiorLateralOccipital=${groupica_dir}/ROI_left_SuperiorLateralOccipital_sphere10mm_bin.nii.gz
    mask_left_TemporalPole=${groupica_dir}/ROI_left_TemporalPole_sphere10mm_bin.nii.gz
    mask_left_FrontalPole=${groupica_dir}/ROI_left_FrontalPole_sphere10mm_bin.nii.gz
    mask_SFG_SMA=${groupica_dir}/ROI_SFG_SMA_sphere10mm_bin.nii.gz
    mask_right_SPL=${groupica_dir}/ROI_right_SPL_sphere10mm_bin.nii.gz
    mask_right_Precentral=${groupica_dir}/ROI_right_Precentral_sphere10mm_bin.nii.gz
    mask_right_OccipitalPole=${groupica_dir}/ROI_right_OccipitalPole_sphere10mm_bin.nii.gz
    mask_right_FrontalPole=${groupica_dir}/ROI_right_FrontalPole_sphere10mm_bin.nii.gz
    #mask_right_SuperiorLateralOccipital=${groupica_dir}/ROI_right_SuperiorLateralOccipital_sphere10mm_bin.nii.gz # mostly outside the brain


    # warp IC back to native space
    applywarp -r ${T1brain} -i ${mask_left_Postcentral} -w ${suboutdir}/T1brain2standardbrain_warp_inv.nii.gz -o ${roidir_sub}/ROI_left_Postcentral_sphere10mm_bin.nii.gz --interp=nn
    applywarp -r ${T1brain} -i ${mask_left_SPL} -w ${suboutdir}/T1brain2standardbrain_warp_inv.nii.gz -o ${roidir_sub}/ROI_left_SPL_sphere10mm_bin.nii.gz --interp=nn
    applywarp -r ${T1brain} -i ${mask_left_SuperiorLateralOccipital} -w ${suboutdir}/T1brain2standardbrain_warp_inv.nii.gz -o ${roidir_sub}/ROI_left_SuperiorLateralOccipital_sphere10mm_bin.nii.gz --interp=nn
    applywarp -r ${T1brain} -i ${mask_left_TemporalPole} -w ${suboutdir}/T1brain2standardbrain_warp_inv.nii.gz -o ${roidir_sub}/ROI_left_TemporalPole_sphere10mm_bin.nii.gz --interp=nn
    applywarp -r ${T1brain} -i ${mask_left_FrontalPole} -w ${suboutdir}/T1brain2standardbrain_warp_inv.nii.gz -o ${roidir_sub}/ROI_left_FrontalPole_sphere10mm_bin.nii.gz --interp=nn
    applywarp -r ${T1brain} -i ${mask_SFG_SMA} -w ${suboutdir}/T1brain2standardbrain_warp_inv.nii.gz -o ${roidir_sub}/ROI_SFG_SMA_sphere10mm_bin.nii.gz --interp=nn
    applywarp -r ${T1brain} -i ${mask_right_SPL} -w ${suboutdir}/T1brain2standardbrain_warp_inv.nii.gz -o ${roidir_sub}/ROI_right_SPL_sphere10mm_bin.nii.gz --interp=nn
    applywarp -r ${T1brain} -i ${mask_right_Precentral} -w ${suboutdir}/T1brain2standardbrain_warp_inv.nii.gz -o ${roidir_sub}/ROI_right_Precentral_sphere10mm_bin.nii.gz --interp=nn
    applywarp -r ${T1brain} -i ${mask_right_OccipitalPole} -w ${suboutdir}/T1brain2standardbrain_warp_inv.nii.gz -o ${roidir_sub}/ROI_right_OccipitalPole_sphere10mm_bin.nii.gz --interp=nn
    applywarp -r ${T1brain} -i ${mask_right_FrontalPole} -w ${suboutdir}/T1brain2standardbrain_warp_inv.nii.gz -o ${roidir_sub}/ROI_right_FrontalPole_sphere10mm_bin.nii.gz --interp=nn
    #applywarp -r ${T1brain} -i ${mask_right_SuperiorLateralOccipital} -w ${suboutdir}/T1brain2standardbrain_warp_inv.nii.gz -o ${roidir_sub}/ROI_right_SuperiorLateralOccipital_sphere10mm_bin.nii.gz --interp=nn

	# make a HCP naming copy
	cp ${roidir_sub}/ROI_left_Postcentral_sphere10mm_bin.nii.gz ${roidir_sub_HCP}/ROI_lS1_sphere10mm_bin.nii.gz
	cp ${roidir_sub}/ROI_left_SPL_sphere10mm_bin.nii.gz ${roidir_sub_HCP}/ROI_lSPL_sphere10mm_bin.nii.gz
	cp ${roidir_sub}/ROI_left_SuperiorLateralOccipital_sphere10mm_bin.nii.gz ${roidir_sub_HCP}/ROI_lIPL_sphere10mm_bin.nii.gz
	cp ${roidir_sub}/ROI_left_TemporalPole_sphere10mm_bin.nii.gz ${roidir_sub_HCP}/ROI_lAuditory_sphere10mm_bin.nii.gz
	cp ${roidir_sub}/ROI_left_FrontalPole_sphere10mm_bin.nii.gz ${roidir_sub_HCP}/ROI_lOFC_sphere10mm_bin.nii.gz
	cp ${roidir_sub}/ROI_SFG_SMA_sphere10mm_bin.nii.gz ${roidir_sub_HCP}/ROI_mPFC_SMA_sphere10mm_bin.nii.gz
	cp ${roidir_sub}/ROI_right_SPL_sphere10mm_bin.nii.gz ${roidir_sub_HCP}/ROI_rSPL_sphere10mm_bin.nii.gz
	cp ${roidir_sub}/ROI_right_Precentral_sphere10mm_bin.nii.gz ${roidir_sub_HCP}/ROI_rM1_sphere10mm_bin.nii.gz
	cp ${roidir_sub}/ROI_right_OccipitalPole_sphere10mm_bin.nii.gz ${roidir_sub_HCP}/ROI_rV2_sphere10mm_bin.nii.gz
	cp ${roidir_sub}/ROI_right_FrontalPole_sphere10mm_bin.nii.gz ${roidir_sub_HCP}/ROI_rOFC_rIFG_sphere10mm_bin.nii.gz

done

echo -e "${YelloW} done ${EndC}"

