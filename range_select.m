function [Nstart, Nfiles]=range_select(filenames, objects)
% v.0.9.7.1 (2025-03-08)
% Nick Kozlov

if isempty(objects)
    objects = 'files';
end

element1 = 1;
element2 = length(filenames);
prompt = {'Start number','End number'};
dlgtitle = strcat('How many ', objects, ' to process?');
dims = [1 50];
definput = {num2str(element1),num2str(element2)};
answer = inputdlg(prompt,dlgtitle,dims,definput);
if str2double(answer{1}) >= element1
    Nstart = str2double(answer{1});
else
    disp(strcat('Invalid value; setting it to the default: ',...
        num2str(element1)));
    Nstart = element1;
end
if str2double(answer{2}) <= element2
    Nfiles = str2double(answer{2});
else
    disp(strcat('Invalid value; setting it to the maximum amount of files: ',...
        num2str(element2)));
    Nfiles = element2;
end

end