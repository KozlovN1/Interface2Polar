% Obtaining coordinates of a circular interface in polar coordinates 
% from a photograph. Batch processing.
% v.1.0 (2025-03-20)
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
batch_mode = true;
skip_error = false;
file_count = 0;
error_count = 0;
resolution = 2048;

%% Welcome Wizard
welcome_wizard;

%% Prepare graphics
if exportfig==true
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

%% Main program
if runmode == "color"
    runmode = "colour";
end
f = fopen(strcat(exportdir,filesep,"batch_processing.log"),"w");
fprintf(f, "%s", "The program executed on ");
fprintf(f, "%s\n", string(datetime));
switch runmode
    case "colour"
        for i = Nstart:1:Nfiles
            try
                [phi, r, fig, fig1] = anlz_photo(path, filenames{i}, epsilon, cl_pair, ...
                    ROI, center, R2, showfig, exportfig, exportprof0, do_circshift, exportdir);
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
    case "monochrome"
        for i = Nstart:1:Nfiles
            try
                [phi, r, fig, fig1] = anlz_photo_bw(path, filenames{i}, epsilon, ROI, ...
                    center, R2, showfig, exportfig, exportprof0, R_min, R_max, exportdir);
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
fclose(f);
disp('We are done!')
fprintf("%s\n", "Summary:")
fprintf("%g %s\n", Nfiles-Nstart+1-error_count, " of files sucessfully processed.")
fprintf("%g %s\n", error_count, " of files skipped due to errors.")
fprintf("%s\n", "For detail, see batch_processing.log in ", exportdir)
