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

pathtxt_regressors='/media/hhshare/LAB_2021/Linbi/Results/time_regressors_noorth_pupil';
datapath_ROI='/media/hhshare/LAB_2021/Hengda/FunctionalConnectivity/Subjects';
subdir='/media/hhshare/LAB_2021/Hengda/Subjects';
mri_dir='/home/hengdahe/LAB_2020/Subjects';
ROIs={'lSPL','rM1','rV2','rSPL','lS1','lIPL','lOFC','rOFC_rIFG','mPFC_SMA','lAuditory'};

numofROIs = length(ROIs);

for sub = 1:length(subjects)
    disp(['Subject - ',subjects{sub}])

    datapath_regressors=[pathtxt_regressors,'/',subjects{sub},'/ROIanalysis_newglm_noorth'];   
    measurements=importdata([datapath_regressors,'/',subjects{sub},'_measurements.txt']);
    std_trad=measurements(:,1);
    odd_trad=measurements(:,2);
    
    file = dir ([mri_dir,['/' subjects{sub} '/MRIs/' subjects{sub} '_Run*_FUNC_bias_removed_brain.nii.gz']]);
    filenames = {file.name};
    numblocks = length(filenames);
    
    ROI_ts_all = [];
    for Blk_id = 1:numblocks
        ROI_ts = zeros(size(measurements,1)/numblocks,numofROIs);
        for i = 1:numofROIs
            ROI_ts(:,i)=importdata([datapath_ROI,'/',subjects{sub},'/ROIs_EEGSTV/timeseries/ROI_',ROIs{i},'_sphere10mm_bin_inFuncRun',num2str(Blk_id),'.txt']);
        end
        ROI_ts_all = [ROI_ts_all;ROI_ts];
    end
        
    ROI_ts_all_remove = ROI_ts_all;
    task = [std_trad odd_trad];
    for i = 1:numofROIs
        [b,dev,stats] = glmfit(task,ROI_ts_all(:,i));
        ROI_ts_all_remove(:,i) = ROI_ts_all_remove(:,i) - b(2).*task(:,1) - b(3).*task(:,2);
    end

    % correlation
    D = [subdir '/' subjects{sub} '/fsl_preprocessing/ConcateFUNC_inMNISpace.nii.gz'];
    % Load BOLD dataset:
    [img,dims] = read_avw(D);
    img = reshape(img,dims(1)*dims(2)*dims(3),dims(4));
    
    for i = 1:numofROIs
        T = ROI_ts_all_remove(:,i);
        % Perform correlation:
%         out = corr(T,img');
        [out pva] = corr(T,img');
        out = reshape(out',dims(1),dims(2),dims(3),1);
        pva = reshape(pva',dims(1),dims(2),dims(3),1);
        out(isnan(out)==1) = 0;
        out(pva>=0.01) = 0;

        % Perform r to z transform:
        out = 0.5*log((1+out)./(1-out));

        % Save output image:
        out_folder=[datapath_ROI,'/',subjects{sub},'/ROIs_EEGSTV/SeedFC'];
        if ~exist(out_folder, 'dir')
           mkdir(out_folder)
        end
        out_fn=[datapath_ROI,'/',subjects{sub},'/ROIs_EEGSTV/SeedFC/SeedFC_',ROIs{i}];
        save_avw(out,out_fn,'f',[2 2 2 1])
        system(['/usr/local/fsl/bin/fslcpgeom /usr/local/fsl/data/standard/MNI152_T1_2mm.nii.gz ',out_fn,'.nii.gz']);
    end
    
end
    










