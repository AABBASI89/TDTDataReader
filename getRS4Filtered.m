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
blocks = {'I064-200630-*'};
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
  for i = 1:length(blockNames)
    blockpath = [root,blockNames(i).name,'\'];
    disp(blockpath);
    
    for ch = 1:totChannels
      
      disp(['reading M1 channel ', num2str(ch-1)]);
      
      % Read M1 raw data for a single channel from RS4 .sev files
      raw_M1 = SEV2mat(blockpath,'CHANNEL',ch);
      
      % Extract M1 single units continous data
      data = raw_M1.RSn1.data;
      
      % Get sampling frequency
      Fs = raw_M1.RSn1.fs;
      
      % Get Nyquist frequency
      Fn = Fs/2;
      
      % --- Filtered single unit data -----------------
      % Bandpass filter parameters
      CutOff_freqs = [300 5000];
      Wn = CutOff_freqs./Fn;
      filterOrder = 3;
      [b,a] = butter(filterOrder,Wn);
      su_M1 = filtfilt(b,a,double(data));
      
      % ---- Filtered LFP data -------------------------
      % High pass filter 
      CutOff_freqs = 0.1;
      Wn = CutOff_freqs./Fn;
      filterOrder = 3;
      [b,a] = butter(filterOrder,Wn,'high');
      lfp_M1 = filtfilt(b,a,double(data));
      
      % Low pass filter 
      CutOff_freqs = 300;
      Wn = CutOff_freqs./Fn;
      filterOrder = 3;
      [b,a] = butter(filterOrder,Wn,'low');
      lfp_M1 = filtfilt(b,a,lfp_M1);      
      
      % Notch filter parameters to remove 60Hz line noise
      d = designfilt('bandstopiir','FilterOrder',2, ...
        'HalfPowerFrequency1',59.9,'HalfPowerFrequency2',60.1, ...
        'DesignMethod','butter','SampleRate',Fs);
      lfp_M1 = filtfilt(b,a,lfp_M1);
      
      % Resample to 1kHz
      lfp_M1_dSamp = resample(lfp_M1,1,24);
      Fds = Fs/24;
      
      % Make save directory if it dosen't exist
      currentpath = [savepath,blockNames(i).name,'_MAT_files\M1\Channel_',num2str(ch-1),'\'];
      if ~exist(currentpath,'dir')
        mkdir(currentpath);
      end
      
      % Save M1 data as mat file
      save([currentpath,'SU_CONT_M1_Ch_',num2str(ch-1),'_',num2str(i-1),'.mat'],...
            'su_M1','Fs','-v7.3');  
      save([currentpath,'LFP_CONT_M1_Ch_',num2str(ch-1),'_',num2str(i-1),'.mat'],...
            'lfp_M1','Fs','-v7.3');  
      save([currentpath,'LFP_CONT_M1_Ch_',num2str(ch-1),'_',num2str(i-1),'.mat'],...
            'lfp_M1_dSamp','Fds','-v7.3');           
    end
    
    for tet = 1:size(tetrode_grps,1)
      
      disp(['reading Cb tetrode ', num2str(tet-1)]);
      
      % Read Cb raw data from RS4 .sev files (Cb channels are saved as ch 33-64 by RS4)
      raw_Cb = SEV2mat(blockpath,'CHANNEL',tetrode_grps(tet,:)+32);
      
      % Extract Cb single units continous data
      data = raw_Cb.RSn1.data;
      
      % Get sampling frequency
      Fs = raw_Cb.RSn1.fs;
      
      % Get Nyquist frequency
      Fn = Fs/2;
      
      % --- Filtered single unit data -----------------
      % Bandpass filter parameters
      CutOff_freqs = [300 5000];
      Wn = CutOff_freqs./Fn;
      filterOrder = 3;
      [b,a] = butter(filterOrder,Wn);
      su_Cb = filtfilt(b,a,double(data)')';
      
      % ---- Filtered LFP data -------------------------
      % High pass filter 
      CutOff_freqs = 0.1;
      Wn = CutOff_freqs./Fn;
      filterOrder = 3;
      [b,a] = butter(filterOrder,Wn,'high');
      lfp_Cb = filtfilt(b,a,double(data)');
      
      % Low pass filter 
      CutOff_freqs = 300;
      Wn = CutOff_freqs./Fn;
      filterOrder = 3;
      [b,a] = butter(filterOrder,Wn,'low');
      lfp_Cb = filtfilt(b,a,lfp_Cb);      
      
      % Notch filter parameters to remove 60Hz line noise
      d = designfilt('bandstopiir','FilterOrder',2, ...
        'HalfPowerFrequency1',59.9,'HalfPowerFrequency2',60.1, ...
        'DesignMethod','butter','SampleRate',Fs);
      lfp_Cb = filtfilt(b,a,lfp_Cb)';
      
      % Resample to 1kHz
      lfp_Cb_dSamp = resample(lfp_Cb',1,24)';
      Fds = Fs/24;
      
      % Make save directory if it dosen't exist
      currentpath = [savepath,blockNames(i).name,'_MAT_files\Cb\Channel_',num2str(tet-1),'\'];
      if ~exist(currentpath,'dir')
        mkdir(currentpath);
      end
      
      % Save Cb data as mat file
      save([currentpath,'SU_CONT_Cb_Ch_',num2str(tet-1),'_',num2str(i-1),'.mat'],...
            'su_Cb','Fs','-v7.3'); 
      save([currentpath,'LFP_CONT_Cb_Ch_',num2str(tet-1),'_',num2str(i-1),'.mat'],...
            'lfp_Cb','Fs','-v7.3');
      save([currentpath,'LFP_DSAMP_Cb_Ch_',num2str(tet-1),'_',num2str(i-1),'.mat'],...
            'lfp_Cb_dSamp','Fds','-v7.3');
    end
  end
end
runTime = toc;
disp(['done! time elapsed (minutes) - ', num2str(runTime/60)]);
%%