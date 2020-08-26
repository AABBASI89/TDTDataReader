%%%% Author - Aamir Abbasi
%%%% BMI Data Analysis Gulati Lab
%%%% SCRIPT TO READ CONTINOUS SPIKING DATA FROM RS4 AND CONCATANATE DATA FROM THE SAME SESSION TO STORE IN A RAW BINARY FILE
%% Read TDT blocks and save each block to a mat file
%  A4x1 tet channel groups animal I061
%  [[8 6 4 7];[5 3 24 22];[20 23 21 19];[17 18 1 2];[16 15 32 31];[29 27 25 30];[28 26 13 11];[9 14 12 10]];
%  A4x2 tet channel groups animal I064							
%  [[8 4 3 22];[20 21 18 2];[16 32 27 30];[28 13 14 10];[6 7 5 24];[23 19 17 1];[15 31 29 25];[26 11 9 12];
clc; clear; close;
disp('running...');
root = 'Z:\TDTData\BMI_zBus_RS4-200629-101443\raw_data_RS4\'; 
savepath = 'Z:\TDTData\BMI_zBus_RS4-200629-101443\raw_data_RS4\';
cd(root);
blocks = {'I064-200701-*'};
tetrode_grps = [[8 4 3 22];
                [20 21 18 2];
                [16 32 27 30];
                [28 13 14 10];
                [6 7 5 24];
                [23 19 17 1];
                [15 31 29 25];
                [26 11 9 12]];
totChannels = 32;              
tic;
for j=1:length(blocks)
  blockNames = dir([root,blocks{j}]);
  parfor i = 1:length(blockNames)
    blockpath = [root,blockNames(i).name,'\'];
    disp(blockpath);
    
    for ch = 1:totChannels
      
      % disp(['reading M1 channel ', num2str(ch-1)]);
      
      % Read M1 raw data for a single channel from RS4 .sev files
      raw_M1_1 = SEV2mat(blockpath,'CHANNEL',ch);
      
      % Extract M1 single units continous data
      su_M1 = raw_M1_1.RSn1.data;
      
      % Make save directory if it dosen't exist
      currentpath = [savepath,blockNames(i).name(1:11),'_DAT_files\M1\Channel_',num2str(ch-1),'\'];
      if ~exist(currentpath,'dir')
        mkdir(currentpath);
      end

      % Save continous M1 data to a binary file
      su_M1 = su_M1(:)';
      fileID = fopen([currentpath,'SU_CONT_M1_Ch_',num2str(ch-1),'_',num2str(i-1),'.dat'],'w');
      fwrite(fileID,su_M1,'float32');
      fclose(fileID);
      
    end
    
    for tet = 1:size(tetrode_grps,1)
      
      % disp(['reading Cb tetrode ', num2str(tet-1)]);
      
      % Read Cb raw data from RS4 .sev files (Cb channels are saved as ch 33-64 by RS4)
      raw_Cb = SEV2mat(blockpath,'CHANNEL',tetrode_grps(tet,:)+32);
      
      % Extract Cb single units continous data
      su_Cb = raw_Cb.RSn1.data;
      
      % Make save directory if it dosen't exist 
      currentpath = [savepath,blockNames(i).name(1:11),'_DAT_files\Cb\Tetrode_',num2str(tet-1),'\'];
      if ~exist(currentpath, 'dir')
        mkdir(currentpath);
      end

      % Save continous Cb data to a binary file
      su_Cb = su_Cb(:)';
      fileID = fopen([currentpath,'SU_CONT_Cb_tet_',num2str(tet-1),'_',num2str(i-1),'.dat'],'w');
      fwrite(fileID,su_Cb,'float32');
      fclose(fileID);
    
    end
    
  end
end
runTime = toc;
disp(['done! time elapsed (minutes) - ', num2str(runTime/60)]);
%%