%Options and Parameters%
if exist(lastrunfile, "file")==2
    lastrun = fopen(lastrunfile);
    fgets(lastrun);
    configfile = fgetl(lastrun);
end
[configfile, configdir] = uigetfile(strcat(configdir, filesep, configfile),...
    "File with parameters of configuration");

run(strcat(configdir, filesep, configfile));

%More configuration%
if exist(lastrunfile, "file")==2
    path = fgetl(lastrun);
    if exportprof==true || exportprof0==true || exportfig==true
        exportdir = fgetl(lastrun);
    end
    fclose(lastrunfile);
end

if path ~= ""
    path = uigetdir(path, "Directory containing images");
else
    path = uigetdir(configdir, "Directory containing images");
end

if exportprof==true || exportprof0==true || exportfig==true
    if exportdir ~= ""
        exportdir = uigetdir(exportdir, "Directory to save results");
    else
        exportdir = uigetdir(configdir, "Directory to save results");
    end
end