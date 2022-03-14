clear all; 
clc; 
close all;

dataPath ='/media/hhshare/LAB_2021/Hengda/Results/NewELBO/Results_v3_Linbi_EEGSTVROI';

% all
 subjects = {'180607_Sub11','180618_Sub17','180624_Sub21','180725_Sub25',...
     '180829_Sub33','180608_Sub12','180621_Sub18','180626_Sub22','180807_Sub29',...
     '180830_Sub34','180612_Sub14','180622_Sub19','180724_Sub23','180808_Sub30',...
     '180830_Sub35','180614_Sub15','180623_Sub20','180724_Sub24','180828_Sub32'};

rois = {'lAuditory','lIPL','lOFC','lS1','lSPL','mPFC_SMA','rM1','rOFC_rIFG','rSPL','rV2'}; 
timeroder = [5,7,10,9,4,2,3,8,6,1];

rois = rois(timeroder);

mean_B_m1_m2_all = [];
variance_B_m1_m2_all = [];

for sub_i = 1:length(subjects)
    
    subject = subjects{sub_i};
    disp(subject)
    file = dir ([dataPath,'/',[subject '*']]);
    filenames = {file.name};
    findblk = ~cellfun(@isempty, strfind(filenames, '.mat'));
    numblocks = sum( findblk );
    Blknames = filenames(find(findblk));

    for Blk_id = 1:numblocks

        result_blk = load([dataPath,'/',Blknames{Blk_id}]);
        disp([dataPath,'/',Blknames{Blk_id}])

        APst = result_blk.BDS.APst;
        AVariancePst = result_blk.BDS.AVariancePst;
        BPst = result_blk.BDS.BPst;
        BVariancePst = result_blk.BDS.BVariancePst;
     
        %% collect
        mean_B_m1_m2_all = cat(4,mean_B_m1_m2_all,BPst); % 4-dim -> sessions
        variance_B_m1_m2_all = cat(4,variance_B_m1_m2_all,BVariancePst);
        
    end
    
end

% load('m_var_B_m1_m2.mat')
save('m_var_B_m1_m2.mat','mean_B_m1_m2_all','variance_B_m1_m2_all')

load('../ELBO_88_EEGSTVROI.mat')
 select = (ELBO_all_EEGSTVROI==-Inf)|(imag(ELBO_all_EEGSTVROI)~=0);
 mean_B_m1_m2_all(:,:,:,select) = [];
  variance_B_m1_m2_all(:,:,:,select) = [];
  
%% B_m1 and [Oddball]

roi_num = size(variance_B_m1_m2_all,1);
B_odd_mean = zeros(roi_num,roi_num);
B_odd_var = zeros(roi_num,roi_num);
for i = 1:size(mean_B_m1_m2_all,1)
   for j = 1:size(mean_B_m1_m2_all,2)
       % for each element
       mean_top = 0;
       mean_bot = 0;
       var_bot = 0;
       for k = 1:size(mean_B_m1_m2_all,4)
           % for each session
            sigma_k_2 = diag(squeeze(variance_B_m1_m2_all(i,j,1,k)));
            mean_k = squeeze(mean_B_m1_m2_all(i,j,1,k));
            mean_top = mean_top + 1/(sigma_k_2)*mean_k;
            mean_bot = mean_bot + 1/(sigma_k_2);
            var_bot = var_bot + 1/(sigma_k_2);
       end
       B_odd_mean(i,j) = mean_top/mean_bot;
       B_odd_var(i,j) = 1/var_bot;
   end
end

% B_m2 and [std]
roi_num = size(variance_B_m1_m2_all,1);
B_std_mean = zeros(roi_num,roi_num);
B_std_var = zeros(roi_num,roi_num);
for i = 1:size(mean_B_m1_m2_all,1)
   for j = 1:size(mean_B_m1_m2_all,2)
       % for each element
       mean_top = 0;
       mean_bot = 0;
       var_bot = 0;
       for k = 1:size(mean_B_m1_m2_all,4)
           % for each session
            sigma_k_2 = diag(squeeze(variance_B_m1_m2_all(i,j,2,k)));
            mean_k = squeeze(mean_B_m1_m2_all(i,j,2,k));
            mean_top = mean_top + 1/(sigma_k_2)*mean_k;
            mean_bot = mean_bot + 1/(sigma_k_2);
            var_bot = var_bot + 1/(sigma_k_2);
       end
       B_std_mean(i,j) = mean_top/mean_bot;
       B_std_var(i,j) = 1/var_bot;
   end
end

%% plot significant connectivity from icdf
B_odd_mean_significant = zeros(roi_num,roi_num);
[x_low minidx]= min(B_odd_mean(:));
[x_high maxidx] = max(B_odd_mean(:));
x = linspace(x_low-3*sqrt(B_odd_var(minidx)),x_high+3*sqrt(B_odd_var(maxidx)),2000);
p_level = 0.05/(roi_num*roi_num);
p = [p_level,1-p_level];
for i = 1:size(mean_B_m1_m2_all,1)
   for j = 1:size(mean_B_m1_m2_all,2)
       normal_cdf = cdf('Normal',x,B_odd_mean(i,j),sqrt(B_odd_var(i,j))); % mu, sigma(std)
       normal_pdf = pdf('Normal',x,B_odd_mean(i,j),sqrt(B_odd_var(i,j))); % mu, sigma(std)
       normal_icdf = icdf('Normal',p,B_odd_mean(i,j),sqrt(B_odd_var(i,j))); % mu, sigma(std)
       disp(num2str(normal_icdf))
%        figure,plot(x,normal_cdf,'LineWidth',2)
%        figure,plot(x,normal_pdf,'LineWidth',2)
       grid on
       set(gca,'FontSize',18)
       if (normal_icdf(1)>0)||(normal_icdf(2)<0)
           disp(['p<0.05 (',num2str(i),',',num2str(j),')'])
           B_odd_mean_significant(i,j) = B_odd_mean(i,j);
       end
   end
end

B_odd_mean_significant = B_odd_mean_significant(timeroder,timeroder,:);


% std
B_std_mean_significant = zeros(roi_num,roi_num);
[x_low minidx]= min(B_std_mean(:));
[x_high maxidx] = max(B_std_mean(:));
x = linspace(x_low-3*sqrt(B_std_var(minidx)),x_high+3*sqrt(B_std_var(maxidx)),2000);
p_level = 0.05/(roi_num*roi_num);
p = [p_level,1-p_level];
for i = 1:size(mean_B_m1_m2_all,1)
   for j = 1:size(mean_B_m1_m2_all,2)
       normal_cdf = cdf('Normal',x,B_std_mean(i,j),sqrt(B_std_var(i,j))); % mu, sigma(std)
       normal_pdf = pdf('Normal',x,B_std_mean(i,j),sqrt(B_std_var(i,j))); % mu, sigma(std)
       normal_icdf = icdf('Normal',p,B_std_mean(i,j),sqrt(B_std_var(i,j))); % mu, sigma(std)
       disp(num2str(normal_icdf))
%        figure,plot(x,normal_cdf,'LineWidth',2)
%        figure,plot(x,normal_pdf,'LineWidth',2)
       grid on
       set(gca,'FontSize',18)
       if (normal_icdf(1)>0)||(normal_icdf(2)<0)
           disp(['p<0.05 (',num2str(i),',',num2str(j),')'])
           B_std_mean_significant(i,j) = B_std_mean(i,j);
       end
   end
end

B_std_mean_significant = B_std_mean_significant(timeroder,timeroder,:);




%% B_odd_mean_significant

input = B_odd_mean_significant;
edgediffmax = max(max(input));
edgediff_min = min(min(input));
    
n_rois = length(rois);
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
              text(-0.5,i,regionsk,'FontWeight','bold','FontSize',15);    
          else
              text(-0.5,i-0.1,regionsk(1:round((1+end)/2-1)),'FontWeight','bold','FontSize',15);
              text(-0.5,i+0.1,regionsk(1+round((1+end)/2-1):end),'FontWeight','bold','FontSize',15);
          end

          if length(behaviorsm)<=8
             text(j-0.14*(length(behaviorsm))/3,n_rois-0.2+1,behaviorsm,'FontWeight','bold','FontSize',15);    
          else
              text(j-0.12*(length(behaviorsm))/3,n_rois-0.2+1,behaviorsm,'FontWeight','bold','FontSize',15);    
%              text(j-0.3*(length(behaviorsm))/10,n_rois-0.2+0.9,behaviorsm(1:round((1+end)/2)),'FontWeight','bold','FontSize',15); 
%              text(j-0.3*(length(behaviorsm))/10,n_rois-0.2+1.1,behaviorsm(1+round((1+end)/2):end),'FontWeight','bold','FontSize',15); 
          end

   end
end
set(gca,'xtick', linspace(0.5,n_rois+0.5,n_rois+1), 'ytick', linspace(0.5,n_rois+.5,n_rois+1));
set(gca,'xgrid', 'on', 'ygrid', 'on', 'gridlinestyle', '-', 'xcolor', 'k', 'ycolor', 'k');
set(gca, 'xticklabel', []);set(gca, 'yticklabel', []);
title(['B odd Matrix'])
set(gca,'FontSize',20)


   %% B_std_mean_significant

input = B_std_mean_significant;
edgediffmax = max(max(input));
edgediff_min = min(min(input));
    
n_rois = length(rois);
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
              text(-0.5,i,regionsk,'FontWeight','bold','FontSize',20);    
          else
              text(-0.5,i-0.1,regionsk(1:round((1+end)/2-1)),'FontWeight','bold','FontSize',20);
              text(-0.5,i+0.1,regionsk(1+round((1+end)/2-1):end),'FontWeight','bold','FontSize',20);
          end

          if length(behaviorsm)<=12
             text(j-0.15*(length(behaviorsm))/3,n_rois-0.2+1,behaviorsm,'FontWeight','bold','FontSize',20);    
          else
             text(j-0.3*(length(behaviorsm))/12,n_rois-0.2+0.9,behaviorsm(1:round((1+end)/2)),'FontWeight','bold','FontSize',20); 
             text(j-0.3*(length(behaviorsm))/12,n_rois-0.2+1.1,behaviorsm(1+round((1+end)/2):end),'FontWeight','bold','FontSize',20); 
          end

   end
end
set(gca,'xtick', linspace(0.5,n_rois+0.5,n_rois+1), 'ytick', linspace(0.5,n_rois+.5,n_rois+1));
set(gca,'xgrid', 'on', 'ygrid', 'on', 'gridlinestyle', '-', 'xcolor', 'k', 'ycolor', 'k');
set(gca, 'xticklabel', []);set(gca, 'yticklabel', []);
title(['B std Matrix'])
set(gca,'FontSize',20) 

%% nodes in the processing - all

input = B_odd_mean_significant;

self_conmat = eye(10).*input;
input_noself = (~eye(10)).*input;

self_con = abs(diag(self_conmat));
afferent = sum(abs(input_noself),2); % in
efferent = sum(abs(input_noself),1); % out
all_con = self_con + afferent + efferent';

% hierarchy_strength = efferent - afferent';

figure,plot(afferent,'--x','LineWidth',3)
hold on 
plot(efferent,'--x','LineWidth',3)
hold on
plot(self_con,'--x','LineWidth',3)
hold on 
plot(all_con,'--x','LineWidth',3)

legend('Afferent (in)','Efferent (out)','Self-connections','All-connections')

% legend('afferent (in)','efferent (out)','hierarchy strength')
roissm = strrep(rois,'_','-');
xticklabels(roissm)
grid on
set(gca,'FontSize',20)
ylim([0 1.5])
% title('B odd')




















