%%%% Author - Aamir Abbasi
%%%% BMI Data Analysis Gulati Lab
%%%% SCRIPT TO READ FILTER AND DOWNSAMPLE LFP DATA FROM RS4
%% Read TDT blocks and save each block to a mat file
clc; clear; close;
disp('running...');
root = 'Z:\TDTData\BMI_zBus_RS4_RV2-200629-135652\raw_data_RS4\';
savepath = 'Z:\Aamir\BMI\I064\Data\';
cd(root);
blocks = {'I064-200709-*','I064-200710-*'};

M1Chans = 1:32;
CbChans = 33:64; %make this 33:96 for Cambridge prob recordings
nSubsetChans = 4;
filterOrder1 = 2;
filterOrder2 = 4;
CutOff_freq_low = 0.1;
CutOff_freq_high = 300;
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
    
    LFPs1 = [];
    for h=1:nSubsetChans:size(data,1)
        % Take only a subset of channels for filtering (to avoid running
        % out of memory 
        d = data(h:h+3,:);
        
        % ---- Filtered LFP data ----
        % High pass filter
        Wn = CutOff_freq_low/fn;
        [b,a] = butter(filterOrder1,Wn,'high');
        lfp_M1 = filtfilt(b,a,double(d)');
        
        % Low pass filter
        Wn = CutOff_freq_high/fn;
        [b,a] = butter(filterOrder2,Wn,'low');
        lfp_M1 = filtfilt(b,a,lfp_M1);
        
        % Notch filter parameters to remove 60Hz line noise
        d = designfilt('bandstopiir','FilterOrder',2, ...
            'HalfPowerFrequency1',59.9,'HalfPowerFrequency2',60.1, ...
            'DesignMethod','butter','SampleRate',fs);
        lfp_M1 = filtfilt(d,lfp_M1);
        
        % Resample to 1kHz
        LFPs1 = [LFPs1; resample(lfp_M1,1,24)'];
    end
    
    % Downsampled freq
    Fs = fs/24;
    
    % Save M1 data as mat file
    save([savepath,blockNames(i).name,'\LFP_M1.mat'],...
      'LFPs1','Fs','-v7.3');
    
    disp('reading Cb channels...');
    
    % Read Cb raw data from RS4 .sev files (Cb channels are saved as ch 33-64 by RS4)
    raw_Cb = SEV2mat(blockpath,'CHANNEL',CbChans);
    
    % Extract Cb single units continous data
    data = raw_Cb.RSn1.data;

    LFPs2 = [];
    for h=1:nSubsetChans:size(data,1)
        % Take only a subset of channels for filtering (to avoid running
        % out of memory 
        d = data(h:h+3,:);
        
        % ---- Filtered LFP data ----
        % High pass filter
        Wn = CutOff_freq_low/fn;
        [b,a] = butter(filterOrder1,Wn,'high');
        lfp_Cb = filtfilt(b,a,double(d)');
        
        % Low pass filter
        Wn = CutOff_freq_high/fn;
        [b,a] = butter(filterOrder2,Wn,'low');
        lfp_Cb = filtfilt(b,a,lfp_Cb);
        
        % Notch filter parameters to remove 60Hz line noise
        d = designfilt('bandstopiir','FilterOrder',2, ...
            'HalfPowerFrequency1',59.9,'HalfPowerFrequency2',60.1, ...
            'DesignMethod','butter','SampleRate',fs);
        lfp_Cb = filtfilt(d,lfp_Cb);
        
        % Resample to 1kHz
        LFPs2 = [LFPs2,resample(lfp_Cb,1,24)'];
    end

    % Save Cb data as mat file
    save([savepath,blockNames(i).name,'\LFP_Cb.mat'],...
      'LFPs2','Fs','-v7.3');       
  end
end
runTime = toc;
disp(['done! time elapsed (minutes) - ', num2str(runTime/60)]);
%%