%%%% Author - Aamir Abbasi
%%%% Acute Neuromod Data Analysis Gulati Lab
%%%% SCRIPT TO READ CONTINOUS SPIKING DATA FROM TDT BLOCKS TO STORE IN A RAW BINARY FILE
%% Read TDT blocks and save each block to a mat file
clc; clear; close;
disp('running...');
root = 'Z:\TDTData\Acute_Neuromod_New-200929-144807\';
savepath = 'Z:\TDTData\Acute_Neuromod_New-200929-144807\';
cd(root);
blocks = {'I068-200929-154504','I069-200930-140540'};
totChannels = 32;
tic;
parfor j=1:length(blocks)
  
  blockpath = [root,blocks{j},'\'];
  for ch = 1:totChannels
    
    disp(['reading M1 channel ', num2str(ch)]);
    
    % Read channel by channel M1 spikedata
    output = TDTbin2mat(blockpath,'STORE','SU_1','CHANNEL',ch);
    
    % Extract M1 single units continous data
    su_M1 = output.streams.SU_1.data;
    
    % Make save directory if it dosen't exist
    currentpath = [savepath,blocks{j}(1:11),'_DAT_files\Channel_',num2str(ch),'\'];
    if ~exist(currentpath, 'dir')
      mkdir(currentpath);
    end
    
    % Save continous M1 data to a binary file
    su_M1 = su_M1(:)';
    fileID = fopen([currentpath,'SU_CONT.dat'],'w');
    fwrite(fileID,su_M1,'float32');
    fclose(fileID);
    
  end
end
runTime = toc;
disp(['done! time elapsed (hours) - ', num2str(runTime/3600)]);
