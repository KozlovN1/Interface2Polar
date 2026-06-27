function analyse_photo_batch_par()
% Obtaining coordinates of a circular interface in polar coordinates 
% from a photograph. Batch processing.
% v.1.6 (2026-06-27)
% Nick Kozlov

%% Init
init_all;

%% Paths and files : declaration of variables
     rundir = fileparts(mfilename("fullpath"));
 configfile = "";
  configdir = "";
       path = "";
  exportdir = "";

% These variables are declared for the visibility inside parfor
      epsilonn = [];
       cl_pair = [];
           ROI = [];
        center = [];
            R2 = [];
    do_showfig = [];
  do_exportfig = [];
 do_exportprof = [];
do_exportprof0 = [];
  do_circshift = [];
 scandirection = [];
         R_min = [];
         R_max = [];
       windoww = [];

lastrunfile = "lastrun.txt";

% Misc
batch_mode = true;
skip_error = false;
file_count = 0;
error_count = 0;
resolution = 2048;

%% Welcome Wizard
welcome_wizard;

%% Prepare graphics
if do_exportfig==true
    scrsz = get(0,'ScreenSize');
end

%% Import data
suffix = strcat('.',suffix);
direc = dir([path,filesep,'*.*']);
filenames = {}; 
filenames1 = {};
[filenames1{1:length(direc),1}] = deal(direc.name);
cnt = 0;
for i=1:length(filenames1)
    if regexpi(filenames1{i},suffix)==1
        cnt = cnt + 1;
        filenames(cnt,1) = filenames1(i);
    end
end
clearvars cnt filenames1
filenames = sortrows(filenames); %sort all image files

%% Select the images range
[Nstart, Nfiles] = range_select(filenames, 'images');

tic % DEBUG
%% Main program
if runmode == "color"
    runmode = "colour";
end
f = fopen(strcat(exportdir,filesep,"batch_processing.log"),"w");
fprintf(f, "%s", "The program executed on ");
fprintf(f, "%s\n", string(datetime));
% prepare to parfor
parlog = [];

switch runmode
    case "colour"
        parfor i = Nstart:Nfiles
            try
                [phi, r, fig, fig1] = anlz_photo(path, filenames{i}, epsilonn, cl_pair, ...
                    ROI, center, R2, do_showfig, do_exportfig, do_exportprof0, do_circshift, ...
                    scandirection, R_min, R_max, exportdir);
            catch ME
                disp(ME)
                parlog = [parlog; [filenames{i}, "FAIL", ME.message]];
                % fprintf(f, "%s ;  %s\n", filenames{i}, "FAIL");
                error_count = error_count + 1;
                continue
                %# parfor version ignores skip_error
                % if ~skip_error
                %     handle_error;
                %     switch answer
                %         case 'Skip'
                %             continue
                %         case 'Skip all'
                %             skip_error = true;
                %             continue
                %         case 'Abort'
                %             msgbox('STOP: Operation aborted by user.')
                %             assert(false, 'STOP: Operation aborted by user.')
                %     end
                % else
                %     continue
                % end
            end
            parlog = [parlog; [filenames{i}, "Success!", " "]];
            % fprintf(f, "%s ;  %s\n", filenames{i}, "Success!");
            
            % postprocess & export here: %
            % TODO: function_batch;
            % -->
            if do_exportfig==true
                filename = filenames{i};
                print(fig,strcat(exportdir,filesep,filename,'.png'),'-dpng','-r300');
            end
            [phi_av,error1,r_av,error2] = local_average(phi',r',windoww,0);
            phi_ed = linspace(-pi,pi,resolution);
            r_ed = interp1(phi_av,r_av,phi_ed,'spline','extrap');
            if do_exportprof==true
                filename = filenames{i};
                % TODO?: export_averaged();
                % -->
                fid = fopen(strcat(exportdir,filesep,strcat(filename,'_av.csv') ),'w');
                fprintf( fid,'phi_av; +-; h_av; +-\n' );
                for j=1:1:length(phi_av)
                    fprintf(fid,'%e; ',phi_av(j) );
                    fprintf(fid,'%e; ',error1(j) );
                    fprintf(fid,'%e; ',1-r_av(j)/R2 );
                    fprintf(fid,'%e',error2(j)/R2 );
                    fprintf(fid,'%s\n',[]);
                end
                fclose(fid);
                % <--
            
                if do_showfig==false 
                    fig2 = figure('Position',[0 0 scrsz(3) scrsz(4)], ...
                        'Name', strcat('Azimuthal profiles: ',filename),'Visible','off');
                else
                    fig2 = figure('Position',[0 0 scrsz(3) scrsz(4)], ...
                        'Name', strcat('Azimuthal profiles: ',filename));
                end
                hold on;
                errorbar(phi_av./pi,1-r_av/R2,error2./R2,'.');
                plot(phi_ed./pi,1-r_ed/R2,'LineWidth',2);
                xlim([-1 1]);
                title('Azimuthal profile');
                xlabel('\phi/\pi'); 
                ylabel('{\it h}/{\it R}_2');
            
                % TODO?: export_smoothed();
                % -->
                fid = fopen(strcat(exportdir,filesep,strcat(filename,'.csv') ),'w');
                fprintf( fid,'phi; h\n' );
                for j=1:1:length(phi_ed)
                    fprintf(fid,'%e; ',phi_ed(j) );
                    fprintf(fid,'%e',1-r_ed(j)/R2 );
                    fprintf(fid,'%s\n',[]);
                end
                fclose(fid);
                try
                    print(fig2,strcat(exportdir,filesep,filename,'_profile.svg'),'-vector','-dsvg');
                catch
                    print(fig2,strcat(exportdir,filesep,filename,'_profile.svg'),'-painters','-dsvg');
                end
                % <--
            end
            % <--
            disp(['Processing files: ' ...
                int2str(round((i-Nstart+1)/(Nfiles-Nstart+1)*100,2)) ' %']);
            clc;
        end
    case "monochrome"
        for i = Nstart:1:Nfiles
            try
                [phi, r, fig, fig1] = anlz_photo_bw(path, filenames{i}, epsilonn, ROI, ...
                    center, R2, do_showfig, do_exportfig, do_exportprof0, R_min, R_max, exportdir);
            catch
                fprintf(f, "%s ;  %s\n", filenames{i}, "FAIL");
                error_count = error_count + 1;
                if ~skip_error
                    handle_error;
                    switch answer
                        case 'Skip'
                            continue
                        case 'Skip all'
                            skip_error = true;
                            continue
                        case 'Abort'
                            fclose(f);
                            msgbox('STOP: Operation aborted by user.')
                            assert(false, 'STOP: Operation aborted by user.')
                    end
                else
                    continue
                end
            end
            fprintf(f, "%s ;  %s\n", filenames{i}, "Success!");
            % postprocess & export here: %
            subroutine_batch;
        end
end
for i=1:size(parlog,1)
    fprintf(f, "%s ; %s ; %s\n", parlog(i,1), parlog(i,2), parlog(i,3));
end
fclose(f);
toc % DEBUG
disp('We are done!')
fprintf("%s\n", "Summary:")
fprintf("%g %s\n", Nfiles-Nstart+1-error_count, " of files sucessfully processed.")
fprintf("%g %s\n", error_count, " of files skipped due to errors.")
fprintf("%s\n", "For detail, see batch_processing.log in ", exportdir)
