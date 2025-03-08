% v.0.9.8 (2025-03-08)
% Nick Kozlov

%% %Options: logical switches%
    showfig = true; % [true, false]
 exportprof = true; % triggers export_average & export_smooth, the profiles for practical use
  exportfig = true;

%% %Basic configuration%
 suffix = "*.tif";
runmode = "monochrome"; % ["colour", "monochrome"]

%% %Parameters%
epsilon = 6; % ratio between colour channels or conrast criterion for monochrome signal
    ROI = [145, 141, 145+530, 141+530]; % [x1, y1, x2, y2] (pix)
 center = [410, 406]; % [xc, yc] (pix)
     R2 = 1060; % Radius of the studied domain (e.g. of a container or cell) (pix)
windoww = 20; % argument passed to local_average (number of elements)
  R_min = 190; % used in monochrome mode
  R_max = 220; % used in monochrome mode
% cl_pair = [3, 2]; % the first element is the dominant colour, the second -- the receding one: 1 - R, 2 - G, 3 - B

%% %Batch processing parameters%
if batch_mode
    skip_error = false;
end

%% %Testing parameters%
do_circshift = false;
% Below: usually not needed
exportprof0 = false; % triggers the export of interface profile within anlz_photo, the noisy one
