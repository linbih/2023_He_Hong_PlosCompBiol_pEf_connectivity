clear all; clc; close all

% Set up FSL environment
setenv( 'FSLDIR', '/usr/local/fsl');
fsldir = getenv('FSLDIR');
fsldirmpath = sprintf('%s/etc/matlab',fsldir);
path(path, fsldirmpath);
clear fsldir fsldirmpath;

subjects = {'180607_Sub11','180621_Sub18','180724_Sub23','180828_Sub32' ...
,'180608_Sub12','180622_Sub19','180724_Sub24','180829_Sub33' ...
,'180612_Sub14','180623_Sub20','180725_Sub25','180830_Sub34' ...
,'180614_Sub15','180624_Sub21','180807_Sub29','180830_Sub35' ...
,'180618_Sub17','180626_Sub22','180808_Sub30'}; % All

datapath_ROI='/media/hhshare/LAB_2021/Hengda/FunctionalConnectivity/Subjects';
ROIs={'lSPL','rM1','rV2','rSPL','lS1','lIPL','lOFC','rOFC_rIFG','mPFC_SMA','lAuditory'};
outdir='/media/hhshare/LAB_2021/Hengda/FunctionalConnectivity/GroupLevel';

numofROIs = length(ROIs);

for i = 1:numofROIs
    disp(['ROIs - ',ROIs{i}])
    
    img_all = [];
    for sub = 1:length(subjects)
        D_fn=[datapath_ROI,'/',subjects{sub},'/ROIs_EEGSTV/SeedFC/SeedFC_',ROIs{i},'.nii.gz'];
        % Load
        [img,dims] = read_avw(D_fn);
        img = reshape(img,dims(1)*dims(2)*dims(3),1);
        img_all = cat(2,img_all,img);
    end
    
    p_group_mat = zeros(size(img_all,1),1);
    t_group_mat = zeros(size(img_all,1),1);
    
    [h,p,ci,stats] = ttest(img_all');
    p_group_mat = p;
    t_group_mat = stats.tstat;

    out = reshape(t_group_mat,dims(1),dims(2),dims(3),1);
    out_fn=[outdir,'/','SeedFC_GroupT_ROI',ROIs{i}];
    save_avw(out,out_fn,'f',[2 2 2 1])
    system(['/usr/local/fsl/bin/fslcpgeom /usr/local/fsl/data/standard/MNI152_T1_2mm.nii.gz ',out_fn,'.nii.gz']);
    
    out = reshape(p_group_mat,dims(1),dims(2),dims(3),1);
    out_fn=[outdir,'/','SeedFC_GroupP_ROI',ROIs{i}];
    save_avw(out,out_fn,'f',[2 2 2 1])
    system(['/usr/local/fsl/bin/fslcpgeom /usr/local/fsl/data/standard/MNI152_T1_2mm.nii.gz ',out_fn,'.nii.gz']);

end








