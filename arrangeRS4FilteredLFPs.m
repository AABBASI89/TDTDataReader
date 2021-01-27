%%%% Author - Aamir Abbasi
%%%% BMI Data Analysis Gulati Lab
%%%% SCRIPT TO ARRANGE LFP DATA ACQUIRED USING RS4 INTO channels_X_samples matrix
%% --------------------------------------------------------------------------------
tic;
clc; clear; close;
disp('running...');
root = 'Z:\TDTData\BMI_zBus_RS4-200629-101443\raw_data_RS4\';
savepath = 'Z:\TDTData\BMI_zBus_RS4-200629-101443\';
cd(root);
blocks = {'I064-*_M*'};
nChans = 32;
for j=1:length(blocks)
  blockNames = dir([root,blocks{j}]);
  for i = 1:length(blockNames)
    blockpath = [root,blockNames(i).name,'\'];
    m1_path = [blockpath,'M1\'];
    disp(m1_path);
    for ch=1:nChans
      LFP_files = dir([m1_path,'Channel_',num2str(ch-1),'\LFP_DSAMP*.mat']);
      
    end
    blockNames = dir([root,blocks{j}]);
  end
  
  
  for tet = 1:size(tetrode_grps,1)
    
    disp(['reading Cb tetrode ', num2str(tet-1)]);
    
    
    
  end
end
runTime = toc;
disp(['done! time elapsed (minutes) - ', num2str(runTime/60)]);
%%