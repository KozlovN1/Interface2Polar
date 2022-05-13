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
   exportprof = false;
   showfig = true;

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
if exist('path','var')==1 && ischar(path) && exist('filename','var') && ischar(filename)
    [filename,path]=uigetfile(strcat(path,filesep,filename),'Select the file');
elseif exist('path','var')==1 && ischar(path)
    [filename,path]=uigetfile(strcat(path,suffix),'Select the file');
else
    [filename,path]=uigetfile(suffix,'Select the file');
end
%_%

%% Main program
if exportprof == true
    [phi, r, fig, fig1] = ...
        anlz_photo(path, filename, epsilon, ROI, center, R2, showfig, exportprof, exportdir);
else
    [phi, r, fig, fig1] = ...
        anlz_photo(path, filename, epsilon, ROI, center, R2, showfig, exportprof);
end
