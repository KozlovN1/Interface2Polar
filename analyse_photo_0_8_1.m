%% Obtaining an interface coordinates from a colour photograph.
% v.0.8.1 (2023-07-13)
% Nick Kozlov

%% Init
init_all;

%% %Options: logical switches%
   showfig = true;
   exportprof = false;
   exportfig = false;
   exportprof0 = false;

%% Parameters
exportdir = '/home/nk/Images-expmnts/Алсу/3 об в с/4 Гц/frot=3,flib=4,e=0.69/interface';
     path = '/home/nk/Images-expmnts/Алсу/3 об в с/4 Гц/frot=3,flib=4,e=0.69/';
     
run(strcat(path,filesep,'../config_bw.m'));

%% More configuration
%Import data%
suffix='*.jpg';
if exist('path','var')==1 && ischar(path) && exist('filename','var') && ischar(filename)
    [filename,path]=uigetfile(strcat(path,filesep,filename),'Select the file');
elseif exist('path','var')==1 && ischar(path)
    [filename,path]=uigetfile(strcat(path,filesep,suffix),'Select the file');
else
    [filename,path]=uigetfile(suffix,'Select the file');
end
%_%
if exportprof==true || exportprof0==true || exportfig==true
    %Check and selection of a directory for export%
    if  exist('exportdir','var')==1 && ischar(exportdir)
        exportdir=uigetdir(exportdir,'Where to save the resulting files?');
    else
        exportdir=uigetdir([],'Where to save the resulting files?');
    end
    %_%
end

%% Main program
if exportprof0 == true
    [phi, r, fig, fig1] = ...
        anlz_photo_bw(path, filename, epsilon, ROI, center, R2, showfig, ...
        exportfig, exportprof0, R_min, R_max, exportdir);
else
    [phi, r, fig, fig1] = ...
        anlz_photo_bw(path, filename, epsilon, ROI, center, R2, showfig, ...
        exportfig, exportprof0, R_min, R_max);
end

% Post processing the profile %
[phi_av,error1,r_av,error2]=local_average(phi',r',window,0);
phi_ed=linspace(-pi,pi,2000);
r_ed=interp1(phi_av,r_av,phi_ed,'spline','extrap');

% Visualization %
if showfig == true
    figure(fig1);
    subplot(2,1,2);
    hold on;
    % plot(phi_av./pi,1-r_av/R2);
    errorbar(phi_av./pi,1-r_av/R2,error2./R2,'.');
    plot(phi_ed./pi,1-r_ed/R2,'LineWidth',2);
end

% Export the post-processed data %
if exportprof == true
    export_averaged;
    export_smoothed;
end

% Export the photo with the profile %
if exportfig==true
%     if showfig==true
    figure(fig);
    if showfig==false 
        set(fig,'Visible','off')
    end
    print(strcat(exportdir,filesep,filename,'.png'),'-dpng','-r300');
end

msgbox('We are done!');