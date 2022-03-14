clear all; clc; 
close all

subjects = {'180607_Sub11','180621_Sub18','180724_Sub23','180828_Sub32' ...
,'180608_Sub12','180622_Sub19','180724_Sub24','180829_Sub33' ...
,'180612_Sub14','180623_Sub20','180725_Sub25','180830_Sub34' ...
,'180614_Sub15','180624_Sub21','180807_Sub29','180830_Sub35' ...
,'180618_Sub17','180626_Sub22','180808_Sub30'}; % All

pathtxt_regressors='/media/hhshare/LAB_2021/Linbi/Results/time_regressors_noorth_pupil';
datapath_ROI='/media/hhshare/LAB_2021/Hengda/FunctionalConnectivity/Subjects';
mri_dir='/home/hengdahe/LAB_2020/Subjects';

ROIs={'lSPL','rM1','rV2','rSPL','lS1','lIPL','lOFC','rOFC_rIFG','mPFC_SMA','lAuditory'};

numofROIs = length(ROIs);

R_mat = zeros(numofROIs,numofROIs,length(subjects));
P_mat = zeros(numofROIs,numofROIs,length(subjects));
z_mat = zeros(numofROIs,numofROIs,length(subjects));

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
    for i = 1:numofROIs
        for j = 1:numofROIs
            [R,P] = corrcoef(ROI_ts_all_remove(:,i),ROI_ts_all_remove(:,j));
            R_mat(i,j,sub)=R(1,2);
            P_mat(i,j,sub)=P(1,2);
        end
    end

    z_mat(:,:,sub) = 0.5 * log((1 + R_mat(:,:,sub)) ./ (1 - R_mat(:,:,sub)));

end
    
p_group_mat = zeros(numofROIs,numofROIs);
t_group_mat = zeros(numofROIs,numofROIs);

    for i = 1:numofROIs
        for j = 1:numofROIs
            
            if i == j
                
            else
                [h,p,ci,stats] = ttest(squeeze(z_mat(i,j,:)));
                p_group_mat(i,j) = p;
                t_group_mat(i,j) = stats.tstat;
            end
            
        end
    end
    
    %%
    
z_mat_mean = mean(z_mat,3);
for i = 1:numofROIs
    z_mat_mean(i,i) = 1;
end

input = z_mat_mean.*(p_group_mat<0.05);

edgediffmax = max(max(input));
edgediff_min = min(min(input));
    
n_rois = length(ROIs);
regions=ROIs;
behavior=ROIs;

mymap = [[linspace(0.5,1,-edgediff_min*50),linspace(1,0.8,edgediffmax*50+1)]',...
    [linspace(0.65,1,-edgediff_min*50),linspace(1,0.4,edgediffmax*50+1)]',... %ones(edgediff_min+edgediffmax+1,1)'
    [linspace(0.6,1,-edgediff_min*50),linspace(1,0.1,edgediffmax*50+1)]'];

figure,
imagesc(input)
colormap(mymap), colorbar 
% axis off
for i=1:n_rois % region
    for j=1:n_rois %behavior
       
          regionsk = strrep(regions{i},'_','-');
          behaviorsm = strrep(behavior{j},'_','-');
          if length(regionsk)<=10
              text(-0.5,i,regionsk,'FontWeight','bold','FontSize',15);    
          else
              text(-0.5,i-0.1,regionsk(1:round((1+end)/2-1)),'FontWeight','bold','FontSize',20);
              text(-0.5,i+0.1,regionsk(1+round((1+end)/2-1):end),'FontWeight','bold','FontSize',20);
          end

          if length(behaviorsm)<=12
             text(j-0.15*(length(behaviorsm))/3,n_rois-0.2+1,behaviorsm,'FontWeight','bold','FontSize',15);    
          else
             text(j-0.3*(length(behaviorsm))/12,n_rois-0.2+0.9,behaviorsm(1:round((1+end)/2)),'FontWeight','bold','FontSize',20); 
             text(j-0.3*(length(behaviorsm))/12,n_rois-0.2+1.1,behaviorsm(1+round((1+end)/2):end),'FontWeight','bold','FontSize',20); 
          end

   end
end
set(gca,'xtick', linspace(0.5,n_rois+0.5,n_rois+1), 'ytick', linspace(0.5,n_rois+.5,n_rois+1));
set(gca,'xgrid', 'on', 'ygrid', 'on', 'gridlinestyle', '-', 'xcolor', 'k', 'ycolor', 'k');
set(gca, 'xticklabel', []);set(gca, 'yticklabel', []);
title([' FC: Fisher Z value'])
set(gca,'FontSize',20)

    
    
    
    
    
    

