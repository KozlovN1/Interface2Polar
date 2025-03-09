%% Obtaining an interface coordinates from a colour photograph.
% v.0.9.9.1 (2025-03-09)
% Nick Kozlov

%% Init
init_all;

%% Paths and files : declaration of variables
 configfile = "";
  configdir = "";
       path = "";
  exportdir = "";

lastrunfile = "lastrun.txt";

% Misc
batch_mode = false;
resolution = 2048;

%% Welcome Wizard
welcome_wizard;

%% Import data
if exist('path','var')==1 && ischar(path) && exist('filename','var') && ischar(filename)
    [filename,path] = uigetfile(strcat(path,filesep,filename),'Select the file');
elseif exist('path','var')==1 && ischar(path)
    [filename,path] = uigetfile(strcat(path,filesep,suffix),'Select the file');
else
    [filename,path] = uigetfile(suffix,'Select the file');
end

%% Main program
% Do the evaluation %
if runmode == "color"
    runmode = "colour";
end
switch runmode
    case "colour"
        if ~exportprof0
            [phi, r, fig, fig1] = anlz_photo(path, filename, epsilon, cl_pair, ...
                ROI, center, R2, showfig, exportfig, exportprof0, ...
                do_circshift);
        else
            [phi, r, fig, fig1] = anlz_photo(path, filename, epsilon, cl_pair, ...
                ROI, center, R2, showfig, exportfig, exportprof0, ...
                do_circshift, exportdir);
        end
    case "monochrome"
        if ~exportprof0
            [phi, r, fig, fig1] = anlz_photo_bw(path, filename, epsilon, ROI, ...
                center, R2, showfig, exportfig, exportprof0, R_min, R_max);
        else
            [phi, r, fig, fig1] = anlz_photo_bw(path, filename, epsilon, ROI, ...
                center, R2, showfig, exportfig, exportprof0, R_min, R_max, exportdir);
        end
end

% Not sure this will ever be usewful
if isempty(r) || isempty(phi)
    msgbox('Interface could not be found.','Error','error')
    assert(false, 'STOP: Interface not found.')
end

% Post processing the profile %
[phi_av,error1,r_av,error2] = local_average(phi',r',windoww,0);
phi_ed = linspace(-pi,pi,resolution);
r_ed = interp1(phi_av,r_av,phi_ed,'spline','extrap');
% pp = csape(phi_av,r_av,'periodic'); % Curve Fitting Toolbox
% r_ed = ppval(pp,phi_ed);            % Curve Fitting Toolbox

% Visualization %
if showfig == true
    figure(fig1);
    subplot(2,1,2);
    hold on;
    % plot(phi_av./pi,1-r_av/R2);
    errorbar(phi_av./pi,1-r_av/R2,error2./R2,'.');
    plot(phi_ed./pi,1-r_ed/R2,'LineWidth',2);

    scrsz = get(0,'ScreenSize');
    fig2=figure('Name', strcat('Azimuthal profiles: ',filename) ,'Position',...
            [0 0 scrsz(3) scrsz(4)]); % ,'Visible','off');
    % set(fig2,'Visible','off');
    hold on;
    errorbar(phi_av./pi,1-r_av/R2,error2./R2,'.');
    plot(phi_ed./pi,1-r_ed/R2,'LineWidth',2);
    xlim([-1 1]);
    title('Azimuthal profile');
    xlabel('\phi/\pi'); 
    ylabel('{\it h}/{\it R}_2');
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
