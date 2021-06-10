%%%% Author - Aamir Abbasi
%%%% BMI Data Analysis Gulati Lab
%%%% SCRIPT TO READ CONTINOUS SPIKING DATA FROM RS4 AND CONCATANATE DATA FROM THE SAME SESSION TO STORE IN A RAW BINARY FILE
%% Read TDT blocks and save each block to a mat file
%  32 channels TDT array in M1 [Chans 1-32]
%  64 channels Cambridge polytrodes in Cb [Chans 33-96]
clc; clear; close;
disp('running...');
addpath(genpath('C:\Users\AbbasiM\Documents\MATLAB\TDTDataReader-master\'));
% Change root and save paths along with blocks as needed!
root = 'Z:\TDTData\BMI_zBus_RS4_RV2_Cb64-201130-100839\raw_data_RS4\'; 
savepath = 'Z:\TDTData\BMI_zBus_RS4_RV2_Cb64-201130-100839\raw_data_RS4\';
cd(root);
blocks = {'I086-210506-*','I086-210507-*','I086-210511-*','I086-210512-*','I086-210513-*','I086-210514-*'};  
totPolytrodes  = 4;
polytrode_grps = [[21 17 53 18 57 22 23 30 55 61 32 63 59 19 20 28];
                 [27 26 52 49 48 25 50 58 54 62 56 29 60 24 51 64];
                 [5 8 44 47 1 7 31 40 42 36 46 3 38 10 45 34];
                 [11 15 43 16 39 12 9 4 41 35 2 33 37 13 14 6]];
start = tic;
for j=1:length(blocks)
  blockNames = dir([root,blocks{j}]);
  parfor i = 1:length(blockNames)
    blockpath = [root,blockNames(i).name,'\'];
    disp(blockpath);
    
    for ch = 1:totPolytrodes
      
      % disp(['reading Cb tetrode ', num2str(tet-1)]);
      
      % Read Cb raw data from RS4 .sev files (Cb channels are saved as ch 33-96 by RS4)
      raw_Cb = SEV2mat(blockpath,'CHANNEL', polytrode_grps(ch)+32);
      
      % Extract Cb single units continous data
      su_Cb = raw_Cb.RSn1.data;
      
      % Make save directory if it dosen't exist 
      currentpath = [savepath,blockNames(i).name(1:11),'_DAT_files\Cb\Polytrode_',num2str(ch-1),'\'];
      if ~exist(currentpath, 'dir')
        mkdir(currentpath);
      end

      % Save continous Cb data to a binary file
      su_Cb = su_Cb(:)';
      fileID = fopen([currentpath,'SU_CONT_Cb_poly_',num2str(ch-1),'_',num2str(i-1),'.dat'],'w');
      fwrite(fileID,su_Cb,'float32');
      fclose(fileID);
    
    end
  end
end
runTime = toc(start);
disp(['done! time elapsed (minutes) - ', num2str(runTime/60)]);
%%