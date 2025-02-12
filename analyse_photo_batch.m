%% Obtaining an interface coordinates from a colour photograph.
% v.0.6.4 (2023-05-18)
% Nick Kozlov

%% Init
init_all;

%% %Options: logical switches%
   exportprof0 = false;
   exportprof = true;
   showfig = false; % Keep it "false" with large series to avoid memory drainage
   exportfig = true;

%% Parameters
% epsilon = 3; % ratio between colour channels
% cl_pair = [3, 2]; % the first element is the dominant colour, the second -- the submissive one: 1 - R, 2 - G, 3 - B
% ROI = [1340,390,3930,2960];
% center = [2630.5,1679.5];
% R2 = 0.5 * 2764; % pix
% windoww=24;

exportdir = '';
     path = '';

run(strcat(path,filesep,'../config.m'));

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
suffix='\w*.tif';
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
        anlz_photo(path, filenames{i}, epsilon, cl_pair, ROI, center, R2, showfig, exportfig, exportprof0, exportdir);
    % postprocess + export here
    if exportfig==true
        filename=filenames{i};
%         if showfig==true
        figure(fig);
        if showfig==false 
            set(fig,'Visible','off')
        end
        print(strcat(exportdir,filesep,filename,'.png'),'-dpng','-r300');
    end
    [phi_av,error1,r_av,error2]=local_average(phi',r',windoww,0);
    phi_ed=linspace(-pi,pi,2000);
    r_ed=interp1(phi_av,r_av,phi_ed,'spline','extrap');
    if exportprof == true
        filename=filenames{i};
        export_averaged;
        export_smoothed;
    end
    clc;
    disp(['Processing files: ' int2str(round(i/length(filenames)*100,2)) ' %']);
end
disp('We are done!');