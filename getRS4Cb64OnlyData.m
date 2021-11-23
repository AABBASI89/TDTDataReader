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
blocks = {'I086-210505-*','I086-210506-*','I086-210507-*','I086-210511-*','I086-210512-*','I086-210513-*','I086-210514-*'};  
totPolytrodes  = 4;
polytrode_grps = [[49 52 43 53 51 41 38 46 48 59 33 64 56 54 61 44]; % Polytrode 0
                  [60 57 39 35 31 62 34 50 42 58 47 37 55 36 40 63]; % Polytrode 1
                  [22 17 23 32 8 21 45 15 18 7 26 12 10 14 27 3];      % Polytrode 2
                  [28 29 24 20 16 1 13 5 19 9 4 2 11 30 25 6]];    % Polytrode 3
start = tic;
for j=1:length(blocks)
  blockNames = dir([root,blocks{j}]);
  for i = 1:length(blockNames)
    blockpath = [root,blockNames(i).name,'\'];
    disp(blockpath);
    
    parfor ch = 1:totPolytrodes
          
      % Read Cb raw data from RS4 .sev files (Cb channels are saved as ch 33-96 by RS4)
      raw_Cb = SEV2mat(blockpath,'CHANNEL', polytrode_grps(ch,:)+32);
      
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
