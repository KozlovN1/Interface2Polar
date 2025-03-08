% Version 0.9.5 (2025-03-02)
% Nick Kozlov
%Options and Parameters%
if exist(lastrunfile, "file")==2
    lastrun = fopen(lastrunfile);
    fgets(lastrun);
    configfile = fgetl(lastrun);
    configdir = fgetl(lastrun);
    path = fgetl(lastrun);
end

if exist('path','var')==1 && ischar(path) % path ~= ""
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
    case 'Copy'
        prompt = strcat('Please give the new file name');
        dlgtitle = 'New file name';
        definput = {'config.m'};
        dims = [1 50];
        configfile = string(inputdlg(prompt,dlgtitle,dims,definput));
        configdir = uigetdir(configdir, ...
            "Directory to copy the configuration template to");
        status = copyfile('config_template.m', ...
            strcat(configdir, filesep, configfile));
        if status==1
            editfile = questdlg('Please edit the file. When done press NEXT.', ...
                'Waiting for the edit ...','NEXT','Abort','NEXT');
            if editfile=="Abort"
                msgbox('STOP: Operation aborted by user.')
                assert(false, 'STOP: Operation aborted by user.')
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
    % path = fgetl(lastrun);
    if exportprof==true || exportprof0==true || exportfig==true
        exportdir = fgetl(lastrun);
    end
    fclose(lastrun);
end

% if path ~= ""
%     path = uigetdir(path, "Directory containing images");
% else
%     path = uigetdir(configdir, "Directory containing images");
% end

if exportprof==true || exportprof0==true || exportfig==true
    if exist('exportdir','var')==1 && ischar(exportdir) % exportdir ~= ""
        exportdir = uigetdir(exportdir, "Directory to save results");
    else
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