% v.0.9.8 (2025-03-08)
% Nick Kozlov

prompt = strcat('Unable to process the current image. Choose action:');
dlgtitle = 'Error processing image!';
defbtn = 'Skip';
answer = questdlg(prompt,dlgtitle, 'Skip', 'Skip all', 'Abort', defbtn);
