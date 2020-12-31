function [performance,start_trials,start_rwdtrials,start_rwd]  = fn_getPerformanceTimestamps(wave,fs,plotFlag2,plotFlag1)
%----------------------------------------------------------------------------------------------------------------
% fn_getPerformanceTimestamps computes the learning curve. 
% @ Aamir Abbasi. Based on the function written by Tanuj Gulati.
% ----------- INPUTS
% wav      = A struct containing ttl signal and sampling frequency. Obtained from TDTbin2mat function.
% fs       = Sampling frequency.
% plotFlag1 = A boolean variable used to display plot for pulse detection.
% plotFlag2 = A boolean variable used to display performance plot.
%
% ----------- OUTPUTS
% performance     = learning curve ignoring the unsuccessful trials.
% start_trials    = timestamps of all trial onset.
% start_rwdtrials = timestamps of rewarded trial onset.
% start_rwd       = timestamps of reward onset.
%----------------------------------------------------------------------------------------------------------------

% initialize
if nargin < 3 %default value of t1 is always 1 and plotFlat is 0
  plotFlag1 = 0;
  plotFlag2 = 0;
elseif nargin<4
  plotFlag1 = 0;
end

% convert wave channel in to a logical vector 
wave = wave>1;

% detect the rising edge of all the pulses
pulses = find((diff(wave)>0.5)==1);
pulses_diff = diff(pulses);

% detect pulses for the onset of trials
% in pulses_ind 1s indicates trial start and 0s indicated reward delivery two pulse 
pulses_ind = [1 pulses_diff>16*fs]; 
start_trials = pulses(pulses_ind==1);

% detect pulses for rewarded trials and reward trial onset
start_rwdtrials = [];
start_rwd = [];
for n = 1:length(pulses_ind)-1
    if pulses_ind(n)-pulses_ind(n+1) == 1
      start_rwdtrials = [start_rwdtrials pulses(n)];
    end
    if pulses_ind(n)==1 && pulses_ind(n+1)==1 
      start_rwdtrials = [start_rwdtrials 0];
      start_rwd = [start_rwd 0];
    end
    if pulses_ind(n)==0 && pulses_ind(n+1)==0
      start_rwd = [start_rwd pulses(n)];
    end
end

% plot pulses and event detection!
if plotFlag1 == 1
  figure; plot((1:length(wave))/fs,wave);hold on;
  plot(pulses/fs,1,'g*');
  plot(start_trials/fs,0.99,'ko');
  plot(start_rwdtrials/fs,0.98,'yx');
  plot(start_rwd/fs,0.97,'r+');
end

% get the performance curve and plot it!!!
performance = (start_rwd - start_rwdtrials(1:length(start_rwd)))/fs;
for i=1:length(performance)
  if performance(i)==0
    performance(i)=15;
  end
end
if plotFlag2 == 1
  figure; plot(performance);
end

