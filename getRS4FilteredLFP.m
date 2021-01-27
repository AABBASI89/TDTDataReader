%%%% Author - Aamir Abbasi
%%%% BMI Data Analysis Gulati Lab
%%%% SCRIPT TO READ FILTER AND DOWNSAMPLE LFP DATA FROM RS4
%% Read TDT blocks and save each block to a mat file
clc; clear; close;
disp('running...');
root = 'Z:\TDTData\BMI_zBus_RS4-200629-101443\raw_data_RS4\';
savepath = 'Z:\Aamir\BMI\I064\Data\';
cd(root);
blocks = {'I064-200701-*','I064-200706-*','I064-200702-*','I064-200707-*','I064-200708-*'};

M1Chans = 1:32;
CbChans = 33:64; %make this 33:96 for Cambridge prob recordings
tic;
for j=1:length(blocks)
  blockNames = dir([root,blocks{j}]);
  for i = 1:length(blockNames)
    blockpath = [root,blockNames(i).name,'\'];
    disp(blockpath);
    
    disp('reading M1 channels...');
    
    % Read M1 raw data from RS4 .sev files
    raw_M1 = SEV2mat(blockpath,'CHANNEL',M1Chans);
    
    % Extract M1 single units continous data
    data = raw_M1.RSn1.data;
    
    % Get sampling frequency
    fs = raw_M1.RSn1.fs;
    
    % Get Nyquist frequency
    fn = fs/2;
    
    % ---- Filtered LFP data ----
    % High pass filter
    CutOff_freqs = 0.1;
    Wn = CutOff_freqs./fn;
    filterOrder = 2;
    [b,a] = butter(filterOrder,Wn,'high');
    lfp_M1 = filtfilt(b,a,double(data)');
    
    % Low pass filter
    CutOff_freqs = 300;
    Wn = CutOff_freqs./fn;
    filterOrder = 4;
    [b,a] = butter(filterOrder,Wn,'low');
    lfp_M1 = filtfilt(b,a,lfp_M1);
    
    % Notch filter parameters to remove 60Hz line noise
    d = designfilt('bandstopiir','FilterOrder',2, ...
      'HalfPowerFrequency1',59.9,'HalfPowerFrequency2',60.1, ...
      'DesignMethod','butter','SampleRate',fs);
    lfp_M1 = filtfilt(b,a,lfp_M1);
    
    % Resample to 1kHz
    LFPs1 = resample(lfp_M1,1,24)';
    Fs = fs/24;
    
    % Save M1 data as mat file
    save([savepath,blockNames(i).name,'\LFP_M1.mat'],...
      'LFPs1','Fs','-v7.3');
    
    disp('reading Cb channels...');
    
    % Read Cb raw data from RS4 .sev files (Cb channels are saved as ch 33-64 by RS4)
    raw_Cb = SEV2mat(blockpath,'CHANNEL',CbChans);
    
    % Extract Cb single units continous data
    data = raw_Cb.RSn1.data;
       
    % ---- Filtered LFP data -------------------------
    % High pass filter
    CutOff_freqs = 0.1;
    Wn = CutOff_freqs./fn;
    filterOrder = 3;
    [b,a] = butter(filterOrder,Wn,'high');
    lfp_Cb = filtfilt(b,a,double(data)');
    
    % Low pass filter
    CutOff_freqs = 300;
    Wn = CutOff_freqs./fn;
    filterOrder = 3;
    [b,a] = butter(filterOrder,Wn,'low');
    lfp_Cb = filtfilt(b,a,lfp_Cb);
    
    % Notch filter parameters to remove 60Hz line noise
    d = designfilt('bandstopiir','FilterOrder',2, ...
      'HalfPowerFrequency1',59.9,'HalfPowerFrequency2',60.1, ...
      'DesignMethod','butter','SampleRate',fs);
    lfp_Cb = filtfilt(b,a,lfp_Cb)';
    
    % Resample to 1kHz
    LFPs2 = resample(lfp_Cb',1,24)';

    % Save Cb data as mat file
    save([savepath,blockNames(i).name,'\LFP_Cb.mat'],...
      'LFPs2','Fs','-v7.3');       
  end
end
runTime = toc;
disp(['done! time elapsed (minutes) - ', num2str(runTime/60)]);
%%