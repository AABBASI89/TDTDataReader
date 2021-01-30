%%%% Author - Aamir Abbasi
%%%% This script is used for splitting the video recorded using RV2 in to trials based on the WAVE channel 
%% Read video file and wave channels and then save every trial as a separate video file
clc; clear; close;
start = tic;
disp('running...');
root = 'E:\Aamir\BMI\';
savepath = 'E:\Aamir\BMI\';
cd(root);
blocks = { 'I076\Data\I076-201201-120931\'...
          ,'I076\Data\I076-201201-141645\'...
          ,'I076\Data\I076-201202-112106\'...
          ,'I076\Data\I076-201202-142652\'...
          ,'I076\Data\I076-201203-113433\'...
          ,'I076\Data\I076-201203-131642\'...
          ,'I076\Data\I076-201204-121406\'...
          ,'I076\Data\I076-201204-141944\'...
          ,'I076\Data\I076-201205-112030\'...
          ,'I076\Data\I076-201205-125511\'}; 
          
for j=1:length(blocks)
  
  % display current block
  disp(blocks{j});
  
  % Read Wave channel
  W = dir([blocks{j},'WAV*.mat']);
  load([root, blocks{j},W.name]);
  if exist('wav','var') 
    WAVE = wav;
    clear wav
  end
  if exist('fs','var') 
    Fs = fs;
    clear fs
  end 
  
  % Get trials start markers
  [~,trial_start, rtrials_start,~] = fn_getPerformanceTimestamps(WAVE,Fs,0,0);
  trial_start = trial_start./Fs;
  rtrials_start = rtrials_start/Fs;

  % Make save path
  savedir = [savepath,blocks{j},'Videos\'];
  if ~exist(savedir, 'dir')
    mkdir(savedir);
  end
  
  % Read trials from the video files and save them into separate .avi files
  VID = dir([blocks{j},'*.avi']);
  vidpath = [root,blocks{j},VID.name];
  vR = VideoReader(vidpath);
  for t=1:length(trial_start)
    frames = read(vR,[round((trial_start(t)-2)*vR.FrameRate),round((trial_start(t)+20)*vR.FrameRate)]);
    vW = VideoWriter([savedir,'Trial_',num2str(t),'.avi'],'Motion JPEG AVI');
    vW.FrameRate = vR.FrameRate;
    open(vW);
    writeVideo(vW,frames);
    close(vW);
  end
  
end
runTime = toc(start);
disp(['done! time elapsed (minutes) - ', num2str(runTime/60)]);

%%