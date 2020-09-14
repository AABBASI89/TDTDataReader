%%%% Author - Aamir Abbasi
%%%% BMI Data Analysis Gulati Lab
%%%% SCRIPT TO READ CONTINOUS SPIKING DATA FROM TDT BLOCKS AND CONCATANATE DATA FROM THE SAME SESSION TO STORE IN A RAW BINARY FILE
%% Read TDT blocks and save each block to a mat file
clc; clear; close;
disp('running...');
root = 'Z:\TDTData\BMI_zBus-200310-092524\';
savepath = 'Z:\TDTData\BMI_zBus-200310-092524\';
cd(root);
blocks = {'I061-200504-*'};

tetrode_grps = [[ 8  6  4  7];
                [ 5  3 24 22];
                [20 23 21 19];
                [17 18  1  2];
                [16 15 32 31];
                [29 27 25 30];
                [28 26 13 11];
                [ 9 14 12 10]];
tic;              
for j=1:length(blocks)
  blockNames = dir(blocks{j});
  parfor i = 1:length(blockNames)
    blockpath = [root,blockNames(i).name,'\'];
    disp(blockpath);
    
    for tet = 1:size(tetrode_grps,1)
      
      % disp(['reading Cb tetrode ', num2str(tet-1)]);
      
      % Read Cb raw data from tdt SingleUnits2 gizmo
      raw_Cb = TDTbin2mat(blockpath,'STORE','SU_2','CHANNEL',tetrode_grps(tet,:));
      
      % Extract Cb single units continous data
      su_Cb = raw_Cb.streams.SU_2.data;
      
      % Make save directory if it dosen't exist 
      currentpath = [savepath,blockNames(i).name(1:11),'_DAT_files\Cb\Tetrode_',num2str(tet-1),'\'];
      if ~exist(currentpath, 'dir')
        mkdir(currentpath);
      end

      % Save continous Cb data to a binary file
      su_Cb = su_Cb(:)';
      fileID = fopen([currentpath,'SU_CONT_Cb_tet_',num2str(tet-1),'_',num2str(i-1),'.dat'],'w');
      fwrite(fileID,su_Cb,'float32');
      fclose(fileID);
    
    end    
  end
end
runTime = toc;
disp(['done! time elapsed (hours) - ', num2str(runTime/3600)]);
