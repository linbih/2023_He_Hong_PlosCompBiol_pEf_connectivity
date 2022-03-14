#!/bin/bash
# for each ROI in EEGSTV analysis
# extract time series from ROI
# Hengda He, May 25 2021

ReD='\033[91m'
YelloW='\033[93m'
EndC='\033[0m'

codepath='/media/hhshare/LAB_2021/Hengda/FunctionalConnectivity/Scripts'
ROIsubdir='/home/hengdahe/LAB_2020/Subjects'
FSdir='/media/hhshare/LAB_2020/Linbi/Subjects'
outsubdir='/media/hhshare/LAB_2021/Hengda/FunctionalConnectivity/Subjects'
fmripreprosubdir='/media/hhshare/LAB_2021/Hengda/Subjects'

#SUBJECTS=(180828_Sub32) # test
SUBJECTS=(180607_Sub11 180618_Sub17 180624_Sub21 180725_Sub25 180829_Sub33 180608_Sub12 180621_Sub18 180626_Sub22 180807_Sub29 180830_Sub34 180612_Sub14 180622_Sub19 180724_Sub23 180808_Sub30 180830_Sub35 180614_Sub15 180623_Sub20 180724_Sub24 180828_Sub32) # all

roilist=(lAuditory mPFC_SMA lIPL rM1 lOFC rOFC_rIFG lS1 rSPL lSPL rV2)

for SUB in ${SUBJECTS[*]};    
do
	echo ${SUB}

	ROIdir=${ROIsubdir}/${SUB}/ROIs_EEGSTVBased/final_HCP
	outdir=${outsubdir}/${SUB}/ROIs_EEGSTV
	mkdir ${outdir}
	mkdir ${outdir}/timeseries

	for roi in ${roilist[*]};    
	do
		echo ${roi}
		ROIinStr=${ROIdir}/ROI_${roi}_sphere10mm_bin.nii.gz
		regoutdir=${ROIsubdir}/${SUB}/registrations/Stru2EPI_co_reg
		mridir=${ROIsubdir}/${SUB}/MRIs
		ribbondir=`ls ${FSdir}/${SUB}/FreeSurfer/mri/ribbon.mgz`
		structT1=`ls ${mridir}/${SUB}_STRUCT_bias_removed.nii.gz`
		mri_convert ${ribbondir} ${FSdir}/${SUB}/FreeSurfer/mri/ribbon.nii.gz
		fslmaths ${FSdir}/${SUB}/FreeSurfer/mri/ribbon.nii.gz -thr 3 -uthr 3 -bin ${outdir}/ribbon_lh.nii.gz
		fslmaths ${FSdir}/${SUB}/FreeSurfer/mri/ribbon.nii.gz -thr 42 -uthr 42 -bin ${outdir}/ribbon_rh.nii.gz
		fslmaths ${outdir}/ribbon_lh.nii.gz -add ${outdir}/ribbon_rh.nii.gz -bin ${outdir}/ribbon_gmmask.nii.gz
		mri_vol2vol --targ ${structT1} --mov ${outdir}/ribbon_gmmask.nii.gz --regheader --o ${outdir}/ribbon_gmmask_inT1.nii.gz --nearest
		
		fslmaths ${ROIinStr} -mul ${outdir}/ribbon_gmmask_inT1.nii.gz ${outdir}/ROI_${roi}_sphere10mm_bin_inGM.nii.gz

		for runpath in `ls ${mridir}/${SUB}_Run*_FUNC_bias_removed.nii.gz`;
		do 
			runnum=${runpath##*${SUB}_}
			runnum=${runnum%%_FUNC_bias_removed.nii.gz*}
			echo "fMRI run #: "${runnum}
		
			epiimg=`ls ${ROIsubdir}/${SUB}/registrations/Stru2EPI_co_reg/${runnum}/${runnum}_FUNC_bias_removed_midvol.nii.gz`
			preprocessedfMRI=`ls ${fmripreprosubdir}/${SUB}/fsl_preprocessing/${runnum}.feat/filtered_func_data_nuisance_regress_residual.nii.gz`
			
			flirt -in ${outdir}/ROI_${roi}_sphere10mm_bin_inGM.nii.gz -ref ${epiimg} -applyxfm -init ${ROIsubdir}/${SUB}/registrations/Stru2EPI_co_reg/${runnum}/struc2epi.mat -out ${outdir}/ROI_${roi}_sphere10mm_bin_inFunc${runnum}.nii.gz -interp nearestneighbour

			fslmeants -i ${preprocessedfMRI} -o ${outdir}/timeseries/ROI_${roi}_sphere10mm_bin_inFunc${runnum}.txt -m ${outdir}/ROI_${roi}_sphere10mm_bin_inFunc${runnum}.nii.gz

		done
	done
done


echo -e "${YelloW} done ${EndC}"






