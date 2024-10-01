%% %Options: logical switches%
    showfig = true; % [true, false]
 exportprof = true; % triggers export_average & export_smooth, the profiles for practical use
  exportfig = true;
% Below: usually not needed
exportprof0 = false; % triggers the export of interface profile within anlz_photo, the noisy one

%% %Parameters%
epsilon = 6; % ratio between colour channels or 
    ROI = [145, 141, 145+530, 141+530]; % [x1, y1, x2, y2] (pix)
 center = [410, 406]; % [xc, yc] (pix)
     R2 = 1060; % pix
 windoww = 20; % argument passed to local_average (number of elements)
  R_min = 190; % used in monochrome mode
  R_max = 220; % used in monochrome mode

%% %More configuration%
 suffix = "*.jpg";
runmode = "monochrome"; % ["colour", "monochrome"]
% cl_pair = [3, 2]; % the first element is the dominant colour, the second -- the receding one: 1 - R, 2 - G, 3 - B

%% %Testing parameters%
do_circshift = false;
