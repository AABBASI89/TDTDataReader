%%%% Author - Aamir Abbasi
%%%% BMI Data Analysis Gulati Lab
%%%% SCRIPT TO READ CONTINOUS SPIKING DATA FROM TDT BLOCKS AND CONCATANATE DATA FROM THE SAME SESSION TO STORE IN A RAW BINARY FILE
%% Read TDT blocks and save each block to a mat file
clc; clear; close;
disp('running...');
root = 'Z:\TDTData\BMI_zBus-200310-092524\';
savepath = 'C:\Users\AbbasiM\Desktop\bmi-files-mat\I061\';
cd(root);
blocks = {'I061-200624*'};
for j=1:length(blocks)
  blockNames = dir(blocks{j});
  parfor i = 1:length(blockNames)
    blockpath = [root,blockNames(i).name,'\'];
    disp(blockpath);
    
    % Read stream data from a TDT block
    data = TDTbin2mat(blockpath,'STORE','SU_2');
    
    % Extract and save Cb single units continous data
    su_Cb = data.streams.SU_2.data;
    su_Cb = su_Cb(:)';
    
    % Save concatanated continous data to a binary file
    su_Cb = su_Cb(:)';
    if ~exist([savepath,blockpath(35:45),'-DAT-files\'], 'dir')
      mkdir([savepath,blockpath(35:45),'-DAT-files\']);
    end
    fileID = fopen([savepath,blockpath(35:45),'-DAT-files\','SU_CONT_Cb_',num2str(i-1),'.dat'],'w');
    fwrite(fileID,su_Cb,'float32');
    fclose(fileID);
  end
end
disp('done');
