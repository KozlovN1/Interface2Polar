function [Nstart, Nfiles]=range_select(filenames, objects)
% Creates a dialog to select a range within a list of objects.
% VibTechLib collection.
% Version 1.0.1 (2025-03-20)
% Nick Kozlov

if isempty(objects)
    objects = 'files';
end

element1 = 1;
element2 = length(filenames);
prompt = {'Start number','End number'};
dlgtitle = strcat('Range of _', objects, ':');
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
    disp(strcat('Invalid value; setting it to the maximum amount of _', ...
        objects, ': ', num2str(element2)));
    Nfiles = element2;
end

end