%%%% Author - Aamir Abbasi
%%%% BMI Data Analysis Gulati Lab
%% Read TDT blocks and save each block to a mat file
clc; clear; close;
disp('running...');
root = 'Z:\TDTData\BMI_zBus_RS4_RV2_Cb64-201130-100839\';
cd(root);

blockNames = dir('I086-210514-*');
for i = 1:length(blockNames)
  blockpath = strcat(blockNames(i).name);
  disp(blockpath);
  
  % Read stream data from a TDT block
  data = TDTbin2mat(blockpath,'TYPE',4);
  
  if ~exist(strcat(blockpath,'\LFP_M1.mat'),'file') || ~exist(strcat(blockpath,'\WAV.mat'),'file')...
      || ~exist(strcat(blockpath,'\LFP_Cb.mat'),'file')
    
    if strcmp(blockNames(i).name(1:4),'I050') == 1
      
      % Extract and save wave channel
      wav = data.streams.Wav1.data;
      fs = data.streams.Wav1.fs;
      save(strcat(blockpath,'\WAV.mat'),'wav','fs');
      
      % Extract and save M1 LFP
      lfp_M1 = data.streams.LFP1.data(17:32,:);
      fs = data.streams.LFP1.fs;
      save(strcat(blockpath,'\LFP_M1.mat'),'lfp_M1','fs');
      
      % Extract and save Cb LFP
      lfp_Cb = data.streams.LFP1.data(1:16,:);
      fs = data.streams.LFP1.fs;
      save(strcat(blockpath,'\LFP_Cb.mat'),'lfp_Cb','fs');
      
    else
      
      % Extract and save wave channel
      wav = data.streams.Wav1.data;
      fs = data.streams.Wav1.fs;
      save(strcat(blockpath,'\WAV.mat'),'wav','fs');
      
      % Extract and save M1 LFP
      lfp_M1 = data.streams.LFP1.data;
      fs = data.streams.LFP1.fs;
      save(strcat(blockpath,'\LFP_M1.mat'),'lfp_M1','fs');
      
      % Extract and save Cb LFP
      lfp_Cb = data.streams.LFP2.data;
      fs = data.streams.LFP2.fs;
      save(strcat(blockpath,'\LFP_Cb.mat'),'lfp_Cb','fs');
      
    end
  end
%   if ~exist(strcat(blockpath,'\SU_CONT_Cb_Fs.mat'),'file') || ~exist(strcat(blockpath,'\SU_CONT_Cb.dat'),'file')
%     
%     % Extract and save Cb single units continous data
%     su_Cb = data.streams.SU_2.data;
%     fs = data.streams.SU_2.fs;
%     
%     % Scale su_Cb to microVolts and typecast to int16
%     for ch=1:size(su_Cb,1)
%       su_Cb_uV(ch,:) = int16(su_Cb(ch,:).*1e6);
%     end
%     
%     % Save data to files
%     save([blockpath,'\SU_CONT_Cb_Fs.mat'],'fs');
%     fileID = fopen([blockpath,'\SU_CONT_Cb.dat'],'w');
%     fwrite(fileID,su_Cb_uV,'int16');
%     fclose(fileID);
%     
%   end
  
  % snips = data.snips.eNe1;
  % if ~exist(strcat(blockpath,'\SNIPS.mat'),'file')
  %   save(strcat(blockpath,'\SNIPS.mat'),'snips');
  % end
  clear data lfp_Cb lfp_M1 wav fs su_Cb
  
end
disp('done');

