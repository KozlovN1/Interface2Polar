% function init_all%(defaultanswer)
prompt = strcat('Do you want to CLEAN and restart over?');
dlgtitle = 'Restart over: y/n?';
definput = {'n'};
dims = [1 50];
answer = inputdlg(prompt,dlgtitle,dims,definput);
if answer{1,1} == 'y'
    clc; clear all; close all;
elseif answer{1,1} == 'n'
else
    disp('I did not understand the answer: y or n?');
end
% end