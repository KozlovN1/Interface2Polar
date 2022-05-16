%% Obtaining an interface coordinates from a colour photograph.
% v.0.6 (2022-05-13)
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
   showfig = false; % Keep it false with large series to avoid memory drainage

%% Parameters
epsilon = 6; % ratio between colour channels
cl_pair = [2, 3]; % the first element is the dominant colour, the second -- the submissive one: 1 - R, 2 - G, 3 - B
ROI = [351,372,351+1164,372+1194];
center = [975,975];
R2 = 0.5 * 1490; % pix

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
suffix='\w*.jpg';
if  exist('path','var')==1 && ischar(path)
    path = uigetdir(path,'Select the directory');
else
    path = uigetdir([],'Select the directory');
end
direc = dir([path,filesep,'*.*']);
filenames={}; filenames1={};
[filenames1{1:length(direc),1}] = deal(direc.name);
cnt = 0;
for i=1:length(filenames1)
    if regexpi(filenames1{i},suffix) == 1
        cnt = cnt + 1;
        filenames(cnt,1) = filenames1(i);
    end
end
clearvars cnt filenames1
filenames = sortrows(filenames); %sort all image files
%_%

%% Main program
for i = 1:1:length(filenames)
    [phi, r, fig, fig1] = ...
        anlz_photo(path, filenames{i}, epsilon, cl_pair, ROI, center, R2, showfig, exportprof, exportdir);
    clc;
    disp(['Processing files: ' int2str(round(i/length(filenames)*100,2)) ' %']);
end
