%%%% Author - Aamir Abbasi
%%%% BMI Data Analysis Gulati Lab
%%%% SCRIPT TO READ CONTINOUS SPIKING DATA FROM RS4 AND CONCATANATE DATA FROM THE SAME SESSION TO STORE IN A RAW BINARY FILE
%% Read TDT blocks and save each block to a mat file
%  32 channels TDT array in M1 [Chans 1-32]
%  64 channels Cambridge polytrodes in Cb [Chans 33-96]
clc; clear; close;
disp('running...');
addpath(genpath('C:\Users\FleischerP\Documents\MATLAB\TDTDataReader-master\'));
% Change root and save paths along with blocks as needed!
root = 'Z:\M1_Cb_Reach\I086\RS4_Data\'; 
savepath = 'Z:\M1_Cb_Reach\I086\RS4_Data\';
cd(root);
blocks = {'I086-210517-*','I086-210518-*','I086-210519-*','I086-210520-*','I086-210521-*'};
totChannels_m1 = 32;  
start = tic;
for j=4%1:length(blocks)
  blockNames = dir([root,blocks{j}]);
  for i = 1:length(blockNames)
    blockpath = [root,blockNames(i).name,'\'];
    disp(blockpath);
    
    parfor ch = 1:totChannels_m1      
      disp(['reading M1 channel ', num2str(ch-1)]);      
      % Read M1 raw data for a single channel from RS4 .sev files
      raw_M1 = SEV2mat(blockpath,'CHANNEL',ch);      
      % Extract M1 single units continous data
      su_M1(ch,:) = raw_M1.RSn1.data;         
    end
    
    % Reject common mean reference
    su_M1 = su_M1 - mean(su_M1);
    
    % Save channel by channel data in .DAT files
    for ch = 1:size(su_M1,1)
        % Make save directory if it dosen't exist
        currentpath = [savepath,blockNames(i).name(1:11),'_DAT_files\M1\Channel_',num2str(ch-1),'\'];
        if ~exist(currentpath,'dir')
            mkdir(currentpath);
        end        
        % Save continous M1 data to a binary file
        M1_DAT = su_M1(ch,:);
        fileID = fopen([currentpath,'SU_CONT_M1_Ch_',num2str(ch-1),'_',num2str(i-1),'.dat'],'w');
        fwrite(fileID,M1_DAT,'float32');
        fclose(fileID);
    end
    clear su_M1 
  end
end
runTime = toc(start);
disp(['done! time elapsed (minutes) - ', num2str(runTime/60)]);
%%