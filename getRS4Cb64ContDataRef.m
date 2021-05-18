%%%% Author - Aamir Abbasi
%%%% BMI Data Analysis Gulati Lab
%%%% SCRIPT TO READ CONTINOUS SPIKING DATA FROM RS4 AND CONCATANATE DATA FROM THE SAME SESSION TO STORE IN A RAW BINARY FILE
%% Read TDT blocks and save each block to a mat file
%  32 channels TDT array in M1 [Chans 1-32]
%  64 channels Cambridge polytrodes in Cb [Chans 33-96]
clc; clear; close;
disp('running...');
% Change root and save paths along with blocks as needed!
root = 'Z:\TDTData\BMI_zBus_RS4_RV2_Cb64-201130-100839\raw_data_RS4\'; 
savepath = 'Z:\TDTData\BMI_zBus_RS4_RV2_Cb64-201130-100839\raw_data_RS4\';
cd(root);
blocks = {'I076-201201-*','I076-201202-*','I076-201203-*'};
totChannels_m1 = 32;  
totPolytrodes  = 4;
polytrode_grps = [[21 17 53 18 57 22 23 30 55 61 32 63 59 19 20 28];
                 [27 26 52 49 48 25 50 58 54 62 56 29 60 24 51 64];
                 [5 8 44 47 1 7 31 40 42 36 46 3 38 10 45 34];
                 [11 15 43 16 39 12 9 4 41 35 2 33 37 13 14 6]];
start = tic;
for j=1:length(blocks)
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
        M1_DAT = su_M1(ch);
        fileID = fopen([currentpath,'SU_CONT_M1_Ch_',num2str(ch-1),'_',num2str(i-1),'.dat'],'w');
        fwrite(fileID,M1_DAT,'float32');
        fclose(fileID);
    end
    
    parfor ch = 1:length(polytrode_grps(:))
      
      disp(['reading Cb channel ', num2str(ch-1)]);
      
      % Read Cb raw data from RS4 .sev files (Cb channels are saved as ch 33-96 by RS4)
      raw_Cb = SEV2mat(blockpath,'CHANNEL', ch+32);
      
      % Extract Cb single units continous data
      su_Cb(ch,:) = raw_Cb.RSn1.data;
     
    end
    
    % Reject common mean reference
    su_Cb = su_Cb - mean(su_Cb);
    
    % Save channel by channel data in .DAT files
    for ch = 1:totPolytrodes
      
      % Get channels for a single polytrode
      cb_DAT = su_Cb(polytrode_grps(ch),:);
        
      % Make save directory if it dosen't exist 
      currentpath = [savepath,blockNames(i).name(1:11),'_DAT_files\Cb\Polytrode_',num2str(ch-1),'\'];
      if ~exist(currentpath, 'dir')
        mkdir(currentpath);
      end

      % Save continous Cb data to a binary file
      cb_DAT = cb_DAT(:)';
      fileID = fopen([currentpath,'SU_CONT_Cb_poly_',num2str(ch-1),'_',num2str(i-1),'.dat'],'w');
      fwrite(fileID,cb_DAT,'float32');
      fclose(fileID);
    end    
    
  end
end
runTime = toc(start);
disp(['done! time elapsed (minutes) - ', num2str(runTime/60)]);
%%