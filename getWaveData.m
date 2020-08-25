%%%% Author - Aamir Abbasi
%%%% This script is used for reading WAVE channel from the TDT blocks
%% Read TDT blocks and save each block to a mat file
clc; clear; close;
disp('running...');
root = 'Z:\TDTData\BMI_zBus_RS4_RV2-200629-135652\';
savepath = 'Z:\Aamir\BMI\I064\';
cd(root);
blocks = {'I064-200709*','I064-200710*'};
for j=1:length(blocks)
  blockNames = dir(blocks{j});
  for i = 1:length(blockNames)
    blockpath = [root,blockNames(i).name,'\'];
    disp(blockpath);
    
    % Read stream data from a TDT block
    data = TDTbin2mat(blockpath,'STORE','Wav1');
    
    % Extract wave channel and sampling frequecy  
    WAVE = data.streams.Wav1.data;
    Fs   = data.streams.Wav1.fs;
    
    % Save 
    savedir = [savepath,blockNames(i).name,'\'];
    if ~exist(savedir, 'dir')
      mkdir(savedir);
    end
    save([savedir,'WAV.mat'],'WAVE','Fs');
  end
end
disp('done');

%%