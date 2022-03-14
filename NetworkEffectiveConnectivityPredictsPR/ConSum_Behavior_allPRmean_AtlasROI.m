clear all; clc; 
close all;

load('../m_var_B_m1_m2.mat')
load('../m_var_A.mat')

rois = {'PCC','Precuneus','dACC','lFEF','lAG','lAI','lSPL','mPFC','rFEF','rAG','rAI','rSPL'};

load('../../ELBO_89_AtlasROI.mat')
load('../sub_i_all.mat')
load('PR_oddstd.mat')

%{'180807_Sub29'}
%run index 45 failed during model fitting
failed = [45];
sub_i_all(failed) = [];
PR_oddmean_all(failed) = [];

%%
DMN = [1,8,2,5,10];
DAN = [4,9,7,12];
SN = [3,6,11];

%%

roi_sets = {DAN,DMN,SN};

brain_meas = squeeze(mean_B_m1_m2_all(:,:,1,:));

num_obs = size(brain_meas,3);
num_net = length(roi_sets);

brain_meas_pos_net = zeros(num_net,num_net,num_obs);
brain_meas_neg_net = zeros(num_net,num_net,num_obs);
for roi_i = 1:num_net
   for roi_j = 1:num_net
       select = brain_meas(roi_sets{roi_i},roi_sets{roi_j},:);
       brain_meas_pos_net(roi_i,roi_j,:) = squeeze(sum(sum((select>0).*select,1),2));
       brain_meas_neg_net(roi_i,roi_j,:) = squeeze(sum(sum((select<0).*select,1),2));
%        
   end
end

brain_meas_totest = brain_meas_pos_net;
% brain_meas_totest = brain_meas_neg_net;

%% Q1: what edges are reSNd to PR in the block

r_mat = zeros(num_net,num_net);
p_mat = zeros(num_net,num_net);

select = (ELBO_all_AtlasROI~=-Inf)&(imag(ELBO_all_AtlasROI)==0);

behavior_select = PR_oddmean_all;

for i = 1:num_net
    for j = 1:num_net

        [r,p] = corrcoef(brain_meas_totest(i,j,select),behavior_select(select));
        r_mat(i,j) = r(1,2);
        p_mat(i,j) = p(1,2);

    end
end

rois = {'DAN','DMN','SN'};

input = r_mat.*(p_mat<0.05/(num_net*num_net));

edgediffmax = max(max(input));
edgediff_min = min(min(input));
    
n_rois = num_net;
regions=rois;
behavior=rois;

steps = 5000;
mymap = [[linspace(0.5,1,-(edgediff_min)*steps),linspace(1,0.8,edgediffmax*steps+1)]',...
    [linspace(0.65,1,-(edgediff_min)*steps),linspace(1,0.4,edgediffmax*steps+1)]',... %ones(edgediff_min+edgediffmax+1,1)'
    [linspace(0.6,1,-(edgediff_min)*steps),linspace(1,0.1,edgediffmax*steps+1)]'];

figure,
imagesc(input)
colormap(mymap), colorbar 
% axis off
for i=1:n_rois % region
    for j=1:n_rois %behavior
       
          regionsk = strrep(regions{i},'_','-');
          behaviorsm = strrep(behavior{j},'_','-');
          if length(regionsk)<=10
              text(0.05,i,regionsk,'FontWeight','bold','FontSize',20);    
          else
              text(0.05,i-0.1,regionsk(1:round((1+end)/2-1)),'FontWeight','bold','FontSize',20);
              text(0.05,i+0.1,regionsk(1+round((1+end)/2-1):end),'FontWeight','bold','FontSize',20);
          end

          if length(behaviorsm)<=12
             text(j-0.15*(length(behaviorsm))/3,n_rois-0.3+1,behaviorsm,'FontWeight','bold','FontSize',20);    
          else
             text(j-0.3*(length(behaviorsm))/12,n_rois-0.3+0.9,behaviorsm(1:round((1+end)/2)),'FontWeight','bold','FontSize',20); 
             text(j-0.3*(length(behaviorsm))/12,n_rois-0.3+1.1,behaviorsm(1+round((1+end)/2):end),'FontWeight','bold','FontSize',20); 
          end

   end
end
set(gca,'xtick', linspace(0.5,n_rois+0.5,n_rois+1), 'ytick', linspace(0.5,n_rois+.5,n_rois+1));
set(gca,'xgrid', 'on', 'ygrid', 'on', 'gridlinestyle', '-', 'xcolor', 'k', 'ycolor', 'k');
set(gca, 'xticklabel', []);set(gca, 'yticklabel', []);
title(['Corr Coef r (p<.05) Odd-B & PR-odd mean Matrix'])
set(gca,'FontSize',20)
%% % %     
i = 1; % to DAN
j = 3; % from SN

load('../colors.mat')

brain_mea = squeeze(brain_meas_totest(i,j,:));

[r,p] = corrcoef(brain_mea(select),behavior_select(select));

    figure; plot(brain_mea(select),behavior_select(select),'k.','LineWidth',2); lsline
    str = {['r = ',num2str(r(1,2))],['p = ',num2str(p(1,2))]};
    a = annotation('textbox', [0.65, 0.35, 0.1, 0.1], 'String', str,'LineStyle','none');
    a.FontSize = 18;
%     ylabel('mean odd PR')
%     xlabel('connectivity parameter')
    ylabel('Mean TEPR of oddball trials')
    xlabel('SN-to-DAN oddball-modulated positive network strength')
    
    hold on 
    label = [];
    for lp = 1:length(ELBO_all_AtlasROI);
    if((ELBO_all_AtlasROI(lp)==-Inf)|(imag(ELBO_all_AtlasROI)~=0))
    else
        scatter(brain_mea(lp),behavior_select(lp),200,colors(sub_i_all(lp),:),'filled')
%         text(brain_mea(lp)*1.01,behavior_select(lp)*1.01,num2str(sub_i_all(lp)),'FontWeight','bold','FontSize',10);    
        label = [label sub_i_all(lp)];
    end
    hold on
    end
    grid on
    
    set(gca,'FontSize',20)
      %%
      
    load('PR_oddmean_sub_allblocks.mat')
    
    label = sub_i_all(select);
    A = brain_mea(select);

    brain_mea_sub = zeros(1,19);

    behavior_sub = PR_oddmean_sub;
    
    for sub = 1:19
        brain_mea_sub(sub) = mean(A(find(label==sub)));
    end
    
    [r,p] = corrcoef(brain_mea_sub,behavior_sub);

    figure; plot(brain_mea_sub,behavior_sub,'k.','LineWidth',2); lsline
    hold on;
    for lp = 1:19
%         scatter(brain_mea_sub(lp),behavior_sub(lp),500,colors(lp,:),'filled')
        scatter(brain_mea_sub(lp),behavior_sub(lp),500,[0.4 0.4 0.4],'filled')
%         text(brain_mea_sub(lp)*1.01,behavior_sub(lp)*1.01,num2str(lp),'FontWeight','bold','FontSize',15);
    end
    str = {['r = ',num2str(r(1,2),4)],['p = ',num2str(p(1,2),2)]};
    ylabel('Mean TEPR of oddball trials')
    xlabel('SN-to-DAN oddball-modulated positive network strength')
    set(gcf, 'Units', 'Inches', 'Position', [0, 0, 10,6])
    
    
    a = annotation('textbox', [0.65, 0.2, 0.1, 0.1], 'String', str,'LineStyle','none');
    a.FontSize = 18;
    grid on
    set(gca,'FontSize',20)
  
%% sub level for all connections

brain_meas_totest = brain_meas_pos_net;
% brain_meas_totest = brain_meas_neg_net;

network_r = zeros(3,3);
network_p = zeros(3,3);

for i = 1:3
    for j = 1:3
        
        brain_mea = squeeze(brain_meas_totest(i,j,:));
        A = brain_mea(select);
        for sub = 1:19
            brain_mea_sub(sub) = mean(A(find(label==sub)));
        end
        [r,p] = corrcoef(brain_mea_sub,behavior_sub);
        network_r(i,j) = r(1,2);
        network_p(i,j) = p(1,2);
    end
end

figure,imagesc(network_r)

figure,imagesc(network_p)
