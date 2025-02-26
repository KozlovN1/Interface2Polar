% Version 0.9.4.2 (2025-02-26)
% Nick Kozlov

prompt = strcat('Do you want to CLEAN and restart over?');
dlgtitle = 'Restart over: y/n?';
defbtn = 'No';
answer = questdlg(prompt,dlgtitle, ...
    'Yes', 'No', 'Abort', defbtn);

switch answer
    case 'Yes'
        clc; clear all; close all;
    case 'No'
    case 'Abort'
        msgbox('STOP: Operation aborted by user.')
        assert(false, 'STOP: Operation aborted by user.')
end