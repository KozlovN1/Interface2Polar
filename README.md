The program reconstructs an azimuthal profile of a circular or close-ended interface from photographic images into polar coordinates. It can run in single or batch mode.

In order to run the analysis of a photograph you will need to set the processing parameters via a configuration file.


- Obligatory parameters (user must give appropriate values):

a) The most important parameter is epsilon that characterizes ratio between colour channels or conrast criterion for monochrome images. It is to be obtained by trial and error, otherwise you may use some other image processing software (like ImageJ, for intance) to suggest/determine the appropriate value.

b) R2 is the characteristic size of the image in pixels.

c) In coulour mode, parameter cl_pair lets one select two colour channels that are going to be compared for the interface criterion: epsilon is compared to cl_pair(,,1)/cl_pair(,,2).

d) Parameter windoww permits to tune the averaging of the obtained azimuthal profile.

e) suffix, runmode.


- Parameters with default values:

a) Logical parameters "showfig", "exportprof", "exportfig" stand for showing the obtained profile in figures, exporting those figures, and exporting the profile into two *.csv files. Generally, one sets showfig=false in batch mode. Through combinations of these parameters you may take measuremets from Matlab figures, explore, or export data for postprocessing, or do everything at the same time.

b) do_circshift, exportprof0 are technical.


- Optional parameters (may be left empty, i.e. = []):

a) You will also need the coordinates of the origin (usually the center of the experimental cell) and region of interest, unless your image is preliminary centered and trimmed. In the latter case these parameters may be measured from an image automatically.

b) In monochrome mode, optional parameters R_min and R_max allow the user narrowing the region of seeking the interface. They may be empty.


Examples of all of the parameters are given in config_template.m. Upon the first run of the program, a wizard provides you with an option to copy this template or to select a pre-configured file.



The program was applied for processing images in experimental work [Kozlov V. G., Zimasova A. R., Kozlov N. V. Stability of liquid-liquid interface in unevenly rotating horizontal cylinder // Interfacial Phenomena and Heat Transfer. 2024. Vol. 12. Iss. 1. P. 63–74. DOI: 10.1615/InterfacPhenomHeatTransfer.2023050051].
