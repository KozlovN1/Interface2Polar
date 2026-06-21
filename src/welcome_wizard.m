% Version 1.4.2 (2026-02-10)
% Nick Kozlov
%Options and Parameters%
if exist(lastrunfile, "file")==2
    lastrun = fopen(lastrunfile);
    fgets(lastrun);
    configfile = fgetl(lastrun);
    configdir = fgetl(lastrun);
    path = fgetl(lastrun);
else
    % TODO: Check if this is always pertinent
    configdir = rundir;
end

if exist('path','var')==1 && length(path)>1 % ischar(path) % string(path)~=""
    path = uigetdir(path, "Directory containing images");
else
    path = uigetdir(configdir, "Directory containing images");
end

%_%
prompt = strcat(['Indicate the configuration file [Indicate], ' ...
    'or you may copy the template [Copy]']);
dlgtitle = 'Retrieving the config file';
defbtn = 'Indicate';
answer = questdlg(prompt,dlgtitle, ...
    'Indicate', 'Copy', 'Abort', defbtn);

switch answer
    case 'Indicate'
        [configfile, configdir] = uigetfile(strcat( ...
            configdir, filesep, configfile), ...
            "File with parameters of configuration");
        try
            if ispc
                % command = ['notepad.exe ', strcat(configdir, filesep, configfile)];
                command = strcat('notepad.exe "', configdir, filesep, configfile, '"');
                sysmes = dos(command);
            elseif isunix
                if ~unix('which gedit')
                    % command = ['gedit "' strcat(configdir, filesep, configfile) '"'];
                    command = strcat('gedit "', configdir, filesep, configfile, '"');
                % elseif ~unix('which kate')
                %     command = ['kate "' strcat(configdir, filesep, configfile) '"'];
                elseif ~unix('which mousepad')
                    % command = ['mousepad "' strcat(configdir, filesep, configfile) '"']
                    % command = 'mousepad "' + strcat(configdir, filesep, configfile) + '"'
                    command = strcat('mousepad "', configdir, filesep, configfile, '"');
                else
                    command = strcat('xterm -fa monaco -fs 13 -bg black -fg gray -e ''editor "', configdir, filesep, configfile, '" '' ');
                end
                sysmes = unix(command);
            end
        catch
            fprintf("Please edit the config file manually\n")
        end
    case 'Copy'
        prompt = strcat('Please give the new file name');
        dlgtitle = 'New file name';
        definput = {'config.m'};
        dims = [1 50];
        configfile = string(inputdlg(prompt,dlgtitle,dims,definput));
        configdir = uigetdir(configdir, ...
            "Directory to copy the configuration template to");
        status = copyfile(strcat(rundir,filesep,'config_template.m'), ...
            strcat(configdir, filesep, configfile));
        if status==1
            try
                if ispc
                    % command = ['notepad.exe ', strcat(configdir, filesep, configfile)];
                    command = strcat('notepad.exe "', configdir, filesep, configfile, '"');
                    sysmes = dos(command);
                elseif isunix
                    if ~unix('which gedit')
                        command = strcat('gedit "', configdir, filesep, configfile, '"');
                    % elseif ~unix('which kate')
                    %     command = 'kate "' + strcat(configdir, filesep, configfile) + '"';
                    elseif ~unix('which mousepad')
                        % command = 'mousepad "' + strcat(configdir, filesep, configfile) + '"'
                        command = strcat('mousepad "', configdir, filesep, configfile, '"');
                    %     command = ['mousepad "', strcat(configdir, filesep, configfile), '"'] % ХЗ, чё такое
                    else
                        % command = ['xterm -fa monaco -fs 13 -bg black -fg gray -e ''editor "' strcat(configdir, filesep, configfile) '" '' '];
                        command = strcat('xterm -fa monaco -fs 13 -bg black -fg gray -e ''editor "', configdir, filesep, configfile, '" '' ');
                    end
                    sysmes = unix(command);
                end
            catch
                fprintf("Something went wrong: %s\n", sysmes) % DEBUG
                editfile = questdlg('Please edit the file. When done press NEXT.', ...
                    'Waiting for the edit ...','NEXT','Abort','NEXT');
                if editfile=="Abort"
                    msgbox('STOP: Operation aborted by user.')
                    assert(false, 'STOP: Operation aborted by user.')
                end
            end
        else
            msgbox('The file was not copied. Please copy manually.', ...
                'Error','error');
            assert(status,'Error copying file');
        end
    case 'Abort'
        msgbox('STOP: Operation aborted by user.')
        assert(false, 'STOP: Operation aborted by user.')
end
%_%

run(strcat(configdir, filesep, configfile));

%More configuration%
if exist(lastrunfile, "file")==2
    if do_exportprof==true || do_exportprof0==true || do_exportfig==true
        exportdir = fgetl(lastrun);
    end
    fclose(lastrun);
end

if do_exportprof==true || do_exportprof0==true || do_exportfig==true
    if exist('exportdir','var')==1 && length(exportdir)>1 % exportdir~=0 % string(exportdir)~="" % ischar(exportdir)
        % fprintf("exportdir: %s\n", exportdir) % DEBUG
        exportdir = uigetdir(exportdir, "Directory to save results");
    else
        % fprintf("configdir: %s\n", configdir) % DEBUG
        exportdir = uigetdir(configdir, "Directory to save results");
    end
end

%Save the last paths%
f = fopen(lastrunfile, "w");
fprintf(f, "%s", "The parameters registered on ");
fprintf(f, "%s\n", string(datetime));
fprintf(f, "%s\n", configfile);
fprintf(f, "%s\n", configdir);
fprintf(f, "%s\n", path);
fprintf(f, "%s\n", exportdir);
fclose(f);