% v.1.2 (2025-12-01)
% Nick Kozlov

%% %Options: logical switches%
    showfig = true; % [true, false]
 exportprof = true; % triggers export_average & export_smooth, the profiles for practical use
  exportfig = true;

%% %Basic configuration%
 suffix = "*.tif";
runmode = "colour"; % ["colour", "monochrome"]
scandirection = "inwards"; % ["inwards", "outwards"]

%% %Parameters%
epsilon = 2; % ratio between colour channels or conrast criterion for monochrome signal
    ROI = [145, 141, 145+530, 141+530]; % [x1, y1, x2, y2] (pix)
 center = [410, 406]; % [xc, yc] (pix)
     R2 = 1060; % Radius of the studied domain (e.g. of a container or cell) (pix)
windoww = 20; % argument passed to local_average (number of elements)
  R_min = 190; % strengthen the ROI condition
  R_max = []; % strengthen the ROI condition
cl_pair = [3, 2]; % the first element is the dominant colour, the second -- the receding one: 1 - R, 2 - G, 3 - B
resolution = 2048; % Resolution of the interpolated profile exported

%% %Batch processing parameters%
if batch_mode
    skip_error = false;
end

%% %Testing parameters%
do_circshift = false;
% Below: usually not needed
exportprof0 = false; % triggers the export of interface profile within anlz_photo, the noisy one
