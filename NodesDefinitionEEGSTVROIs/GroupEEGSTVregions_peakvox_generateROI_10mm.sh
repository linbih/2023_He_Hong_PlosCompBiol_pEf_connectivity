#!/bin/bash
# at peak vox location, generate spherical ROIs
# EEGSTV
# Hengda He, Feb 25 2021

ReD='\033[91m'
YelloW='\033[93m'
EndC='\033[0m'

scriptdir="/home/hengdahe/LAB_2021/ROIs/ROI_v3_EEGSTV/Scripts"
groupout_dir="/home/hengdahe/LAB_2021/ROIs/ROI_v3_EEGSTV/GroupLevel/Regions"

echo "group output directory: "${groupout_dir}
echo "Script directory: "${scriptdir}

coordinate_file=${groupout_dir}/ROIs_vox_coordinates_EEGSTV_regions.txt
networkoutdir=${groupout_dir}

input=${coordinate_file}
while IFS= read -r line
do

region=`echo $line | cut -d' ' -f1`
x=`echo $line | cut -d' ' -f2`
y=`echo $line | cut -d' ' -f3`
z_newline=`echo $line | cut -d' ' -f4` # REMOVE NEW LINE
z="${z_newline//[$'\t\r\n ']}"

echo 'TimeWindow:'${region}' x:'${x}' y:'${y}' z:'${z}
cmd='fslmaths '$FSLDIR'/data/standard/MNI152_T1_2mm.nii.gz -mul 0 -add 1 -roi '${x}' 1 '${y}' 1 '${z}' 1 0 1 '${groupout_dir}'/ROI_'${region}'_point.nii.gz -odt float'
$cmd

fslmaths ${networkoutdir}'/ROI_'${region}'_point.nii.gz' -kernel sphere 10 -fmean ${networkoutdir}'/ROI_'${region}'_sphere10mm.nii.gz' -odt float

fslmaths ${networkoutdir}'/ROI_'${region}'_sphere10mm.nii.gz' -bin ${networkoutdir}'/ROI_'${region}'_sphere10mm_bin.nii.gz'

done < "$input"

fslmerge -t ${networkoutdir}/ROI_all_sphere10mm_bin_all.nii.gz ${networkoutdir}/ROI_*_sphere10mm_bin.nii.gz
fslmaths ${networkoutdir}/ROI_all_sphere10mm_bin_all.nii.gz -Tmean -bin ${networkoutdir}/ROI_all_sphere10mm_bin_sum.nii.gz
cluster -i ${networkoutdir}/ROI_all_sphere10mm_bin_sum.nii.gz -t 0.1 -o ${networkoutdir}/ROI_all_sphere10mm_bin_cluster.nii.gz

#freeview ${networkoutdir}/ROI_all_sphere10mm_bin_cluster.nii.gz -f /home/hengdahe/LAB_2021/Results/Glassbrain/MNI152_FS/*pial



echo -e "${YelloW} done ${EndC}"

