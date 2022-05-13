%% Obtaining an interface coordinates from a colour photograph.
% v.0.5.1 (2022-05-10)
% Nick Kozlov

%% Init
prompt = strcat('Do you want to clean and restart over?');
dlgtitle = 'Restart over: y/n?';
definput = {'n'};
dims = [1 50];
answer = inputdlg(prompt,dlgtitle,dims,definput);
if answer{1,1} == 'y'
    clc; clear all; close all;
elseif answer{1,1} == 'n'
else
    disp('I did not understand the answer: y or n?');
end

%% %Options: logical switches%
   exportprof = true;
   showfig = false;

%% Parameters
epsilon = 3; % blue-to-green ratio
ROI = [1340,390,3930,2990];
center = [2630.5,1679.5];
R2 = 0.5 * 2764; % pix

% exportdir = '';
%      path = '';

%% More configuration
if exportprof == true
    %Check and selection of a directory for export%
    if  exist('exportdir','var')==1 && ischar(exportdir)
        exportdir=uigetdir(exportdir,'Where to save the resulting files?');
    else
        exportdir=uigetdir([],'Where to save the resulting files?');
    end
    %_%
end
%Import data%
suffix='*.jpg';
if  exist('path','var')==1 && ischar(path)
    path = uigetdir(path,'Select the directory');
else
    path = uigetdir([],'Select the directory');
end
direc = dir([path,filesep,suffix]); filenames={};
[filenames{1:length(direc),1}] = deal(direc.name);
filenames = sortrows(filenames); %sort all image files
%_%

%% Main program
for i = 1:1:length(filenames)
    [phi, r, fig, fig1] = ...
        anlz_photo(path, filenames{i}, epsilon, ROI, center, R2, showfig, exportprof, exportdir);
    clc;
    disp(['Processing files: ' int2str(round(i/length(filenames)*100,2)) ' %']);
end
