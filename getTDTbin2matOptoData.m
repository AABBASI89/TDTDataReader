%%%% Author - Aamir Abbasi
%%%% BMI Data Analysis Gulati Lab
%% Read TDT blocks and save each block to a mat file
clc; clear; close;
disp('running...');
addpath(genpath('C:\Users\AbbasiM\Documents\MATLAB\TDTSDK\TDTbin2mat'));
root = 'Z:\TDTData\BMI_zBus_RS4_RV2_CbOpto-210301-104205\';
savepath = 'Z:\Aamir\BMI\I091\Data\';
cd(root);
% sessions = {'I088-210809-*','I088-210810-*','I088-210811-*','I088-210812-*'...
%     ,'I088-210813-*','I088-210816-*','I088-210817-*'};
sessions = {'I091-210908-*','I091-210909-*','I091-210910-*','I091-210913-*','I091-210917-*'};
for j = 1:length(sessions)
    blockNames = dir([root,sessions{j}]);
    for i = 1:length(blockNames)
        blockpath = strcat(blockNames(i).name);
        disp(blockpath);
        
        % Read stream data from a TDT block
        data = TDTbin2mat(blockpath,'TYPE',4);
        
        % Create save dir
        currentsavepath = [savepath,blockNames(i).name];
        if ~exist(currentsavepath, 'dir')
            mkdir(currentsavepath);
        end
        
        % Extract and save wave channel
        wav = data.streams.Wav2.data;
        fs1 = data.streams.Wav1.fs;
        fs2 = data.streams.Wav2.fs;
        if fs2 ~= fs1
            wav = resample(double(wav),1,24);
            fs = fs1;
        else
            fs = fs2;
        end
%         wav = wav(round(0.1*fs):end);
%         wav = [wav zeros(1,round(0.1*fs)-1)];
        save(strcat(currentsavepath,'\WAV.mat'),'wav','fs');
        
        % Extract and save opto TTL
        optotrig = data.streams.Pul1.data;
        fs = data.streams.Pul1.fs;
        save(strcat(currentsavepath,'\TTL.mat'),'optotrig','fs');
        
        % Extract and save M1 LFP
        lfp_M1 = data.streams.LFP1.data;
        fs = data.streams.LFP1.fs;
%         lfp_M1([1:16 18],:) = []; %Only for I088
        lfp_M1([3 11 13 15:32],:) = []; %Only for I091
        save(strcat(currentsavepath,'\LFP_M1.mat'),'lfp_M1','fs');

    end
end
disp('done');
