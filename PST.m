function PST
% Starts the GUI of the Philips and Siemens Parametric maps ans Spectroscopy Tool.

% Please refer to INSTRUCTIONS.m for instructions

%%  Globals
quantitative_files = {};
ref_file = '';
spec_file = '';
spec_file = '';
met_file = '';
water_file = '';
table_file = '';
sl_value = 1;
table_dir = '';
table_name = '';
sel_file = '';
sel_nr = 0;
lcm_nr = 0;
sel_x1_spec = 0;
sel_y1_spec = 0;
sel_x2_spec = 0;
sel_y2_spec = 0;
sel_z_spec = 0;
sel_z = 0;
cur_sel = [];
img_gr = [];
width_factor = 1;
magn_factor = 1;
is_sv = 0;
Manufacturer = '';
defdir = pwd;
curdir = defdir;
cur_sl = [];
out_sl = [];
idx = 1;
cur_sel_cell_array = [];
sel_z_cell_array = [];
last_pos_cell_array = [];
sel_x1_spec_prev = 0;
sel_y1_spec_prev = 0;
sel_x2_spec_prev = 0;
sel_y2_spec_prev = 0;
analyze_segm = false;
analyze_param = false;
analyze_param = false;
degzer = 164;
sddegz = 10;
degppm = 0;
sddegp = 1;
dkntmn = 0.15;
neach = 99;
nsimul = 13;
lcm_print = true;
% basis_list = {};
basis_idx = 1;
% basis_file = '';
lcm_spec = true;
ppmend = 0.5;
ppmst = 4.0;
spectra_pts = [];
bright_factor = 1;
bright_factor_str = '1';
lcm_def_file = [defdir filesep 'LCModel' filesep 'DONT_DELETE_ME_lcm_def.mat'];
lcm_data_file = [defdir filesep 'LCModel' filesep 'lcm_data.mat'];
data = struct;
spec_struct = [];
qMRI_names = {};
segmentation_is_there = false;
resliced_quantitative_files = {};
quantitative_slabs_only_VOI = {};
segmentation_analyzed = false;
parametric_analyzed = false;
do_PSF_blurring = true;
use_parfor = true;
current_ppmshift_idx = 0;
curr_ppmShift = 0;
lcmodel_processed = false;
image_name = [];
sel_names = {};
sel_names_struct = struct;
sel_file_is_old = true;

%% Initialize GUI
hf = figure('Position', [0 0 750 750], 'Name', 'PST', 'CloseRequestFcn', @my_close, 'MenuBar', 'none');
defaultBackground = get(0, 'defaultUicontrolBackgroundColor');
set(hf, 'Color', defaultBackground);

%% create Settings tab
hSet = uimenu('Label', '  Settings  ');
hSegmAna = uimenu('Parent', hSet, 'Callback', {@check_analyze_segm}, 'Label', 'Analyse segmented data', 'Checked', 'off');
hParamAna = uimenu('Parent', hSet, 'Callback', {@check_analyze_param}, 'Label', 'Analyse parameter data','Checked', 'off');
uimenu('Parent', hSet, 'Callback', {@switch_psf_blurring}, 'Label', 'Perform PSF blurring', 'Checked', 'on');
uimenu('Parent', hSet, 'Callback', {@switch_parfor}, 'Label', 'Use Parfor for LCModel', 'Checked', 'on');
uimenu('Parent', hSet, 'Callback', {@lcm_show_spectra}, 'Label', 'Show spectra', 'Checked', 'on');

%% create LCModel tab
hLCM = uimenu('Label', '  LCModel  ');
uimenu('Parent', hLCM, 'Callback', {@lcm_param}, 'Label', 'Parameters');
uimenu('Parent', hLCM, 'Callback', {@add_lcm_parameters}, 'Label', 'Add Parameters'); 
uimenu('Parent', hLCM, 'Callback', {@lcm_range}, 'Label', 'Define ppm range');
uimenu('Parent', hLCM, 'Callback', {@lcm_print_switch}, 'Label', 'Save print files');
uimenu('Parent', hLCM, 'Callback', {@lcm_basis}, 'Label', 'Use specific basis file');

%% CONSTRUCT GUI CONTENT

%% Input/Load data section
gr_sz = 60;
t_offs = 30;
e_offs = 15;
len = 200;
br_offs = 220;
col2 = 280;
row_start = 550;

% Title
hTitle = uicontrol(hf, 'Style', 'text', 'String', 'Parametric maps and Spectroscopy Tool', 'HorizontalAlignment', 'center', 'Position', [20 45+row_start+1.6*gr_sz len 50], 'FontSize', 12);

% Reference image
hRef_text = uicontrol(hf, 'Style', 'text', 'String', 'Reference image:', 'Position', [10 t_offs+row_start+1.6*gr_sz len 20]);
hRef_edit = uicontrol(hf, 'Style', 'edit', 'HorizontalAlignment', 'left', 'Position', [10 e_offs+row_start+1.6*gr_sz len 20], 'Callback', {@edit_text});
hRefbrowse_btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'Browse...', 'Position', [br_offs e_offs+row_start+1.6*gr_sz 45 25], 'Callback', {@ref_browse});

% MRS
hFilespec_text = uicontrol(hf, 'Style', 'text', 'String', 'MRS data:', 'Position',  [10 t_offs+row_start+1.0*gr_sz len 20]);
hFilespec_edit = uicontrol(hf, 'Style', 'edit', 'HorizontalAlignment', 'left', 'Position', [10 e_offs+row_start+1.0*gr_sz len 20], 'Callback', {@edit_text});
hFilespec_btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'Browse...', 'Position', [br_offs e_offs+row_start+1.0*gr_sz 45 25], 'Callback', {@spec_browse});

% Reference water
hFilewat_text = uicontrol(hf, 'Style', 'text', 'String', 'Water reference:', 'Position', [10 t_offs+row_start+0.4*gr_sz len 20]); 
hFilewat_edit = uicontrol(hf, 'Style', 'edit', 'HorizontalAlignment', 'left', 'Position', [10 e_offs+row_start+0.4*gr_sz len 20], 'Callback', {@edit_text});
hFilewat_btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'Browse...', 'Position', [br_offs e_offs+row_start+0.4*gr_sz 45 25], 'Callback', {@water_browse});

% Load Data button
hLoad_btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'Load Data', 'Position', [10+len/3 e_offs+row_start-0.2*gr_sz len/3 25], 'Callback', {@load_data});


%% Visual part 

% position for visual controls
col_vis = 80;
row_vis = 110;

% position the axes
posit = get(hf,'Position');
hAxes = axes('Units', 'pixels', 'Visible', 'off', 'Position', [col_vis+40 100 200 200]);
hf.UserData.LR_flipped = true;
hf.UserData.AP_flipped = true;
hf.UserData.initialAxesState.XDir = hAxes.XDir;
hf.UserData.initialAxesState.XDir = 'normal';
hf.UserData.initialAxesState.YDir = 'reverse';

% activate Show spectra
set([hAxes; get(hAxes,'Children')], 'ButtonDownFcn', @mouse_click);

% position the axes
posit = get(hf,'Position');
hAxes2 = axes('Units', 'pixels', 'Visible', 'off', 'Position', [3*(col_vis+40) 100 200 200]);
axis(hAxes2,'off')

% maximize
movegui(hf, 'center');
hf.WindowState = 'maximized';

% brightness
bright_step = 0.1;
bright_min  = 0.1;
bright_max  = 20;
hBrightText = uicontrol(hf, 'Style', 'text', 'String', 'Brightness:', 'HorizontalAlignment', 'left', 'Visible', 'off', 'Position', [col_vis e_offs+row_vis+2.20*gr_sz 60 20]);
hBrightEdit = uicontrol(hf, 'Style', 'edit', 'String', '1.0', 'Visible', 'off', 'Position', [col_vis+50 e_offs+row_vis+2.25*gr_sz 30 20], 'Callback', {@bright_edit});
hBrightUp = uicontrol(hf,'Style','pushbutton','String','▲', 'FontSize', 5, 'Visible', 'off',  'Position',[col_vis+80 e_offs+row_vis+2.42*gr_sz 15 10], 'Callback',@(src,evnt) bright_change(1));
hBrightDown = uicontrol(hf,'Style','pushbutton','String','▼', 'FontSize', 5, 'Visible', 'off',  'Position',[col_vis+80 e_offs+row_vis+2.25*gr_sz 15 10], 'Callback',@(src,evnt) bright_change(-1));

% change width
width_step = 0.1;
hWidthText = uicontrol(hf, 'Style', 'text', 'String', 'Change Width:', 'HorizontalAlignment', 'left', 'Visible', 'off', 'Position', [col_vis e_offs+row_vis+1.70*gr_sz 60 20]);
hWidthEdit = uicontrol(hf, 'Style', 'edit', 'String', '1.0', 'Visible', 'off', 'Position', [col_vis+50 e_offs+row_vis+1.75*gr_sz 30 20], 'Callback', {@width_edit});
hWidthUp = uicontrol(hf, 'Style', 'pushbutton', 'String', '▲', 'FontSize', 5, 'Visible', 'off', 'Position', [col_vis+80 e_offs+row_vis+1.92*gr_sz 15 10], 'Callback', @(~,~) width_arrow(1));
hWidthDown = uicontrol(hf, 'Style', 'pushbutton', 'String', '▼', 'FontSize', 5, 'Visible', 'off', 'Position', [col_vis+80 e_offs+row_vis+1.75*gr_sz 15 10], 'Callback', @(~,~) width_arrow(-1));

% magnify
magn_step = 0.1;
hMagnText = uicontrol(hf, 'Style', 'text', 'String', 'Magnify image:', 'HorizontalAlignment', 'left', 'Visible', 'off', 'Position', [col_vis e_offs+row_vis+1.20*gr_sz 60 20]);
hMagnEdit = uicontrol(hf, 'Style', 'edit', 'String', '1.0', 'Visible', 'off', 'Position', [col_vis+50 e_offs+row_vis+1.25*gr_sz 30 20], 'Callback', {@magn_edit});
hMagnUp = uicontrol(hf, 'Style', 'pushbutton', 'String', '▲', 'FontSize', 5, 'Visible', 'off', 'Position', [col_vis+80 e_offs+row_vis+1.42*gr_sz 15 10], 'Callback', @(~,~) magn_arrow(1));
hMagnDown = uicontrol(hf, 'Style', 'pushbutton', 'String', '▼', 'FontSize', 5, 'Visible', 'off', 'Position', [col_vis+80 e_offs+row_vis+1.25*gr_sz 15 10], 'Callback', @(~,~) magn_arrow(-1));

% show chemical shift displaced image
hShowCSText = uicontrol(hf, 'Style', 'text', 'String', 'Show ∆ChemShift:', 'HorizontalAlignment', 'left', 'Visible', 'off', 'Position', [col_vis e_offs+row_vis+0.70*gr_sz 60 20]);
hCSModifiedText = uicontrol(hf, 'Style', 'text', 'String', curr_ppmShift, 'Visible', 'off', 'Position', [col_vis+50 e_offs+row_vis+0.70*gr_sz 30 20]);
hIncreaseCS = uicontrol(hf,'Style','pushbutton','String','▲', 'FontSize', 5, 'Visible', 'off', 'Position', [col_vis+80 e_offs+row_vis+0.92*gr_sz 15 10], 'Callback',@(src,evnt) change_curr_ppmShift(1));
hDecreaseCS = uicontrol(hf,'Style','pushbutton','String','▼', 'FontSize', 5, 'Visible', 'off', 'Position', [col_vis+80 e_offs+row_vis+0.75*gr_sz 15 10], 'Callback',@(src,evnt) change_curr_ppmShift(-1));
% make them visible only when CSD was processed
hShowChemicallyShiftedImage.hShowCSText = hShowCSText;
hShowChemicallyShiftedImage.hShowCSModifiedText = hCSModifiedText;
hShowChemicallyShiftedImage.hIncreaseCS = hIncreaseCS;
hShowChemicallyShiftedImage.hDecreaseCS = hDecreaseCS;

% flip
hFlip_AP_btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'Flip AP', 'Visible', 'off', 'Position', [col_vis e_offs+row_vis+0.25*gr_sz 30 20], 'HorizontalAlignment', 'left', 'Callback', {@flip_AP});
hFlip_LR_btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'Flip LR', 'Visible', 'off', 'Position', [col_vis+35 e_offs+row_vis+0.25*gr_sz 30 20], 'HorizontalAlignment', 'left', 'Callback', {@flip_LR});

% Reset view
hResetView_btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'Reset', 'Visible', 'off', 'Position', [col_vis+70 e_offs+row_vis+0.25*gr_sz 30 20], 'HorizontalAlignment', 'left', 'Callback', {@reset_view});

% Slice slider
hSliceSlider = uicontrol(hf, 'Style', 'slider', 'Units', 'normalized', 'Visible', 'off', 'Position', [0.29 0.14 0.2 0.02], 'Callback', {@slice_slider});
hSliceSlider_text = uicontrol(hf, 'Style', 'text', 'Units', 'normalized', 'Position', [0.21 0.11 0.2 0.02]);

% Save image
hSaveImage_btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'Save image', 'Visible', 'off', 'Position', [col_vis e_offs+row_vis-0.2*gr_sz 48 20], 'HorizontalAlignment', 'left', 'Callback', @(~,~) save_image);
hImageName_edit = uicontrol(hf, 'Style', 'edit', 'String', '', 'Visible', 'off', 'Position', [col_vis+52 e_offs+row_vis-0.2*gr_sz 48 20], 'Callback', {@edit_text});

% group to modulate visibility
hVIS.hBrightText = hBrightText;
hVIS.hBrightEdit = hBrightEdit;
hVIS.hBrightUp = hBrightUp;
hVIS.hBrightDown = hBrightDown;
hVIS.hWidthText = hWidthText;
hVIS.hWidthEdit = hWidthEdit;
hVIS.hWidthUp = hWidthUp;
hVIS.hWidthDown = hWidthDown;
hVIS.hMagnText = hMagnText;
hVIS.hMagnEdit = hMagnEdit;
hVIS.hMagnUp = hMagnUp;
hVIS.hMagnDown = hMagnDown;
hVIS.hFlip_AP_btn = hFlip_AP_btn;
hVIS.hFlip_LR_btn = hFlip_LR_btn;
hVIS.hResetView_btn = hResetView_btn;
hVIS.hSlider = hSliceSlider;
hVIS.hSlider_text = hSliceSlider_text;
hVIS.hSaveImage_btn = hSaveImage_btn;
hVIS.hImageName_edit = hImageName_edit;

%% Chemical shift displacement

% column for visual elements
col_csde = 30;
row_csde = 360;

% Presets
hPresetPhilips_text = uicontrol(hf, 'Style', 'text', 'String', 'Preset:', 'HorizontalAlignment', 'left', 'Visible', 'off', 'Position', [col_csde e_offs+row_csde+1.65*gr_sz 80 20]);
hPresetPhilips_dropdown = uicontrol(hf, 'Style', 'popupmenu', 'String', {'Philips 2D sLASER', 'Philips 2D PRESS', 'Philips Rapid Biomed 31P 2D Pulse-Acq', 'Philips Rapid Biomed 1H 2D Pulse-Acq', 'Philips 1H 2D Pulse-Acq', 'Philips SV sLASER', 'Philips SV PRESS'}, 'Visible', 'off', 'Position', [col_csde+40 e_offs+row_csde+1.70*gr_sz 100 20], 'Callback', @(hObject, ~) apply_CSD_preset(hObject));

% Philips

% Pulse BWs
BW_ex = 3710; % Scanner uses BW99 = 3710 for nonadiabatic excitation 
hBW_ex_text = uicontrol(hf, 'Style', 'text', 'String', 'Excitation pulse BW99 (Hz):', 'HorizontalAlignment', 'left', 'Visible', 'off', 'Position', [col_csde e_offs+row_csde+1.15*gr_sz 80 20]);
hBW_ex_edit = uicontrol(hf, 'Style', 'edit', 'String', num2str(BW_ex), 'Visible', 'off', 'Position', [col_csde+85 e_offs+row_csde+1.20*gr_sz 40 20], 'Callback', @(hObject, ~) edit_value(hObject, 'BW_ex'));

BW_echo = 5614; % Scanner uses BW=5614 and not BW99=6597 for adiabatic refocusing in sLASER
hBW_echo_text = uicontrol(hf, 'Style', 'text', 'String', 'Echo pulse BW (Hz):', 'HorizontalAlignment', 'left', 'Visible', 'off', 'Position', [col_csde e_offs+row_csde+0.75*gr_sz 80 20]);
hBW_echo_edit = uicontrol(hf, 'Style', 'edit', 'String', num2str(BW_echo), 'Visible', 'off', 'Position', [col_csde+85 e_offs+row_csde+0.80*gr_sz 40 20], 'Callback', @(hObject, ~) edit_value(hObject, 'BW_echo'));

% Chemical shift direction inputs
shiftDirAP = 'A';
shiftDirLR = 'L';
shiftDirFH = 'F';
hShiftDir_text = uicontrol(hf, 'Style', 'text', 'String', 'Chem shift dir (A/P, L/R, F/H):', 'HorizontalAlignment', 'left', 'Visible', 'off', 'Position', [col_csde e_offs+row_csde+0.35*gr_sz 80 20]);
hAP_btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'A', 'Visible', 'off', 'Position', [col_csde+85 e_offs+row_csde+0.40*gr_sz 20 20], 'Callback', @(src,~) toggle_button(src,'A'));
hRL_btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'L', 'Visible', 'off', 'Position', [col_csde+110 e_offs+row_csde+0.40*gr_sz 20 20], 'Callback', @(src,~) toggle_button(src,'L'));
hFH_btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'F', 'Visible', 'off', 'Position', [col_csde+135 e_offs+row_csde+0.40*gr_sz 20 20], 'Callback', @(src,~) toggle_button(src,'F'));

RFOV_dir = 'AP';
hRFOV_dir_text = uicontrol(hf, 'Style', 'text', 'String', 'RFOV direction (AP/RL):', 'HorizontalAlignment', 'left', 'Visible', 'off', 'Position', [col_csde e_offs+row_csde-0.05*gr_sz 80 20]);
hRFOV_dir_btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'AP', 'Visible', 'off', 'Position', [col_csde+85 e_offs+row_csde+0.00*gr_sz 30 20], 'Callback', @(src,~) toggle_button(src,'AP'));

% Siemens

% warning
hWarningSiemensCSDE_text = uicontrol(hf, 'Style', 'text', 'String', {'WARNING! Work in progress!', 'Siemens CSDE is not verified!', 'Displacement may be wrong.'}, 'HorizontalAlignment', 'center', 'Visible', 'off', 'Position', [col_csde+30 e_offs+row_csde+0.5*gr_sz 100 80]);

% Some random starting values
GR_ex = -1.67; 
GR_echo1 = -4.38; 
GR_echo2 = -5.26;

% Gradient buttons and fields
hGR_text = uicontrol(hf, 'Style', 'text', 'String', 'G str (Ex / Echo1 / Echo2):', 'HorizontalAlignment', 'left', 'Visible', 'off', 'Position', [col_csde e_offs+row_csde+0.35*gr_sz 80 20]);
hGR_ex_edit = uicontrol(hf, 'Style', 'edit', 'String', num2str(GR_ex), 'Visible', 'off', 'Position', [col_csde+85 e_offs+row_csde+0.40*gr_sz 20 20], 'Callback', @(hObject, ~) edit_value(hObject, 'GR_ex'));
hGR_echo1_edit = uicontrol(hf, 'Style', 'edit', 'String', num2str(GR_echo1), 'Visible', 'off', 'Position', [col_csde+110 e_offs+row_csde+0.40*gr_sz 20 20], 'Callback', @(hObject, ~) edit_value(hObject, 'GR_echo1'));
hGR_echo2_edit = uicontrol(hf, 'Style', 'edit', 'String', num2str(GR_echo2), 'Visible', 'off', 'Position', [col_csde+135 e_offs+row_csde+0.40*gr_sz 20 20], 'Callback', @(hObject, ~) edit_value(hObject, 'GR_echo2'));

% ppmShifts
ppmShifts = [];
ppmShifts_with_0 = 0;
hPpmShiftText = uicontrol(hf, 'Style', 'text', 'String', '∆ppm from Planscan: -1, 0.2, ...:', 'HorizontalAlignment', 'left', 'Visible', 'off', 'Position', [col_csde e_offs+row_csde-0.45*gr_sz 90 20]);
hPpmShiftEdit = uicontrol(hf, 'Style', 'edit', 'String', '', 'HorizontalAlignment', 'left', 'Visible', 'off', 'Position', [col_csde+85 e_offs+row_csde-0.40*gr_sz 70 20], 'Callback', @(hObject, ~) edit_value(hObject, 'ppmShift'));
hPROC_CSDE_btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'Process CSDE', 'Visible', 'off', 'Position', [col_csde+30 e_offs+row_csde-1.0*gr_sz 100 25], 'HorizontalAlignment', 'left', 'Callback', {@(src,event) process_CSD()});

hCSDE_Philips.hPresetPhilips_text = hPresetPhilips_text;
hCSDE_Philips.hPresetPhilips_dropdown = hPresetPhilips_dropdown;
hCSDE_Philips.BW_ex_text = hBW_ex_text;
hCSDE_Philips.BW_ex_edit = hBW_ex_edit;
hCSDE_Philips.BW_echo_text = hBW_echo_text;
hCSDE_Philips.BW_echo_edit = hBW_echo_edit;
hCSDE_Philips.hShiftDir_text = hShiftDir_text;
hCSDE_Philips.shiftDirAP = hAP_btn;
hCSDE_Philips.shiftDirLR = hRL_btn;
hCSDE_Philips.shiftDirFH = hFH_btn;
hCSDE_Philips.RFOV_dir_text = hRFOV_dir_text;
hCSDE_Philips.RFOV_dir_btn = hRFOV_dir_btn;

hCSDE_Siemens.hWarningSiemensCSDE_text = hWarningSiemensCSDE_text;
hCSDE_Siemens.hGR_text = hGR_text;
hCSDE_Siemens.hGR_ex_edit = hGR_ex_edit;
hCSDE_Siemens.hGR_echo1_edit = hGR_echo1_edit;
hCSDE_Siemens.hGR_echo2_edit = hGR_echo2_edit;

hCSDE.ppmShiftText = hPpmShiftText;
hCSDE.ppmShiftEdit = hPpmShiftEdit;
hCSDE.hPROC_CSDE_btn = hPROC_CSDE_btn;

% CSDE visible 'On' button
hCSDE_Vis_btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'Show CSD parameters', 'Visible', 'off', 'Position', [col_csde+30 e_offs+row_csde+2.2*gr_sz 100 25], 'HorizontalAlignment', 'left', 'Callback', @(~,~) show_appropriate_CSDE_parameters);

%% Individual voxel processing
row_proc = 560;

hIndividual_text = uicontrol(hf, 'Style', 'text', 'String', 'Voxel processing', 'HorizontalAlignment', 'center', 'Visible', 'off', 'Position', [col2+43 row_proc+1.75*gr_sz 100 25]);
hSelect_btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'Select voxels', 'Visible', 'off', 'Position', [col2+20 row_proc+1.35*gr_sz 70 25], 'Callback', {@select_voxels});
hReuseSel_btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'Reuse selections', 'Visible', 'off', 'Position', [col2+95 row_proc+1.35*gr_sz 75 25], 'Callback', {@reuse_selections});
hDeleteSelection_btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'Delete last selection', 'Visible', 'off', 'Position', [col2+20 row_proc+0.8*gr_sz 70 25], 'Callback', {@del_last_selection});
hDeleteAll_btn = uicontrol(hf, 'Visible', 'off', 'Style', 'pushbutton', 'String', 'Delete all selections', 'Position',  [col2+95 row_proc+0.8*gr_sz 75 25], 'Callback', {@(~,~) del_all});
hLCM_btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'LCModel', 'Visible', 'off', 'Position', [col2+20 row_proc+0.25*gr_sz 70 25], 'Callback', {@process_lcmodel});
hProcSel_btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'Process composition', 'Visible', 'off', 'Position', [col2+95 row_proc+0.25*gr_sz 75 25],'Callback', {@process_composition});

hINDIVOX.hIndividual_text = hIndividual_text;
hINDIVOX.hSelect_btn = hSelect_btn;
hINDIVOX.hReuseSel_btn = hReuseSel_btn;
hINDIVOX.hDelete_btn = hDeleteSelection_btn;
hINDIVOX.hDeleteAll_btn = hDeleteAll_btn;
hINDIVOX.hLCM_btn = hLCM_btn;
hINDIVOX.hProcSel_btn = hProcSel_btn;

%% Table

col3 = 470;
row_res = 350;
hTablename_text = uicontrol(hf, 'Visible', 'off', 'Style', 'text', 'String', 'Results table filename:', 'Position', [col3 row_res+t_offs+4.7*gr_sz len 20], 'Callback', {@edit_text});
hTablename_edit = uicontrol(hf, 'Visible', 'off', 'Style', 'edit', 'String', '', 'HorizontalAlignment', 'left', 'Position', [col3 row_res+e_offs+4.7*gr_sz len 20], 'Callback', {@edit_text});
hTabledir_text = uicontrol(hf, 'Visible', 'off', 'Style', 'text', 'String', 'Results table directory:', 'Position', [col3 row_res+t_offs+4*gr_sz len 20]);
hTabledir_edit = uicontrol(hf, 'Visible', 'off', 'Style', 'edit', 'String', '', 'HorizontalAlignment', 'left', 'Position', [col3 row_res+e_offs+4*gr_sz len 20], 'Callback', {@edit_text});
hTable_btn = uicontrol(hf, 'Visible', 'off', 'Style', 'pushbutton', 'String', 'Browse...', 'Position', [col3 + br_offs row_res+e_offs+4*gr_sz 45 25], 'Callback', {@table_browse});
hMaketable_btn = uicontrol(hf, 'Visible', 'off', 'Style', 'pushbutton', 'String', 'Make table', 'Position',  [col3+len/3 row_res+e_offs+3.4*gr_sz len/3 25], 'Callback', {@make_table});

hTABLE.hTablename_text = hTablename_text;
hTABLE.hTablename_edit = hTablename_edit;
hTABLE.hTabledir_text = hTabledir_text;
hTABLE.hTabledir_edit = hTabledir_edit;
hTABLE.hTable_btn = hTable_btn;
hTABLE.hMaketable_btn = hMaketable_btn;

% Annotation
anno = annotation('textbox', [0.52 0.655 0.57 0.08], 'units', 'normalized', 'String', ('Click on a processed voxel to open the LCModel ps file.'), 'FitBoxToText', 'on', 'FontSize', 20, 'FontWeight','normal', 'HitTest','off', 'Visible', 'off');

% Enable
hEnableBtns_btn = uicontrol(hf, 'Visible', 'off', 'Style', 'pushbutton', 'String', 'Enable all buttons', 'Position',  [col_vis+40-len/5 e_offs+0.5*gr_sz len/2 25], 'Callback', {@(~,~) enable_buttons});

%% Resize GUI elements
set([hTitle hRef_text hRef_edit hFilespec_text hFilespec_edit hFilespec_btn hFilewat_text hFilewat_edit ...
    hPresetPhilips_text hPresetPhilips_dropdown ...
    hTabledir_text hTabledir_edit hTablename_text hTablename_edit hMaketable_btn hSelect_btn hRefbrowse_btn hFilewat_btn hTable_btn hDeleteAll_btn hLoad_btn ...
    hFlip_AP_btn hLCM_btn hDeleteSelection_btn hSliceSlider hSliceSlider_text ...
    hBrightText hBrightEdit hBrightUp hBrightDown ...
    hPpmShiftText hPpmShiftEdit hBW_ex_text hBW_ex_edit hBW_echo_text hBW_echo_edit hShiftDir_text hAP_btn hRL_btn hFH_btn hRFOV_dir_text hRFOV_dir_btn ...
    hWarningSiemensCSDE_text hGR_text hGR_ex_edit hGR_echo1_edit hGR_echo2_edit ...
    hWidthText hWidthEdit hWidthUp hWidthDown ...   
    hMagnText hMagnEdit hMagnUp hMagnDown ...
    hSaveImage_btn hImageName_edit ...
    hProcSel_btn hReuseSel_btn hCSDE_Vis_btn hFlip_LR_btn hIndividual_text hPROC_CSDE_btn hResetView_btn ...
    hShowCSText, hCSModifiedText, hIncreaseCS, hDecreaseCS, hEnableBtns_btn], ...
    'Units', 'normalized', 'FontUnits', 'normalized');

%% Initialize GUI functions
function my_close(~, ~)

    cd(defdir);
    delete(gcf);
end

hf.ResizeFcn = @onFigureResize;
function onFigureResize(~, ~)

    set(hAxes, 'Units', 'normalized', 'Position', [0.26 0.17 0.25*magn_factor*width_factor 0.45*magn_factor]);
    set(hAxes2, 'Units', 'normalized', 'Position', [0.52 0.00 0.47 0.74]);
end

%% Settings tab functions

function check_analyze_segm(hObject, ~)

    if strcmp(get(hObject, 'Checked'), 'on')
        set(hObject, 'Checked', 'off');
        analyze_segm = false;
    else
        set(hObject, 'Checked', 'on');
        analyze_segm = true;
    end
end

function check_analyze_param(hObject, ~)

    if strcmp(get(hObject, 'Checked'), 'on')
        set(hObject, 'Checked', 'off');
        analyze_param = false;
    else 
        set(hObject, 'Checked', 'on');
        analyze_param = true;
    end
end

function switch_psf_blurring(hObject, ~)

    if strcmp(get(hObject, 'Checked'), 'on')
        set(hObject, 'Checked', 'off');
            do_PSF_blurring = false;
    else 
        set(hObject, 'Checked', 'on');
            do_PSF_blurring = true;
    end
end

function switch_parfor(hObject, ~)

    if strcmp(get(hObject, 'Checked'), 'on')
        set(hObject, 'Checked', 'off');
            use_parfor = false;
    else 
        set(hObject, 'Checked', 'on');
            use_parfor = true;
    end
end

function lcm_show_spectra(hObject, ~)

    if strcmp(get(hObject, 'Checked'), 'on')
        set(hObject, 'Checked', 'off');
        lcm_spec = false;
        set([hAxes; get(hAxes, 'Children')], 'ButtonDownFcn', '');
    else 
        set(hObject, 'Checked', 'on');
        lcm_spec = true;
        set([hAxes; get(hAxes, 'Children')], 'ButtonDownFcn', @mouse_click);
    end
end

%% LCModel tab functions

function lcm_param(~, ~)

    cd(defdir);
    if exist(lcm_data_file, 'file')
        data = load(lcm_data_file);
    end
    if isfield(data, 'degzer')
        degzer = data.degzer;
    end
    if isfield(data, 'sddegz')
        sddegz = data.sddegz;
    end
    if isfield(data, 'degppm')
        degppm = data.degppm;
    end
    if isfield(data, 'sddegp')
        sddegp = data.sddegp;
    end
    if isfield(data, 'dkntmn')
        dkntmn = data.dkntmn;
    end
    if isfield(data, 'neach')
        neach = data.neach;
    end    
    if isfield(data, 'nsimul')
        nsimul = data.nsimul;
    end     
    if isfield(data, 'nsimul')
        nsimul = data.nsimul;
    end
    if isfield(data, 'VITRO')
            VITRO = data.VITRO;
        else
            VITRO = 'F'; % Assign default if VITRO doesn't exist
    end
    pst_lcm_param(lcm_def_file, lcm_data_file, degzer, sddegz, degppm, sddegp, dkntmn, neach, nsimul, VITRO);
end

function add_lcm_parameters(~, ~)
    
    hParamFig = figure('Name', 'Add Parameters', 'Position', [500, 500, 320, 200], 'MenuBar', 'none', 'ToolBar', 'none', 'NumberTitle', 'off', 'Resize', 'off');
    uicontrol(hParamFig, 'Style', 'text', 'String', 'Please write each control parameter in a new line:', 'Position', [20, 70, 300, 120], 'HorizontalAlignment', 'left', 'FontSize', 10);
    hParamEdit = uicontrol(hParamFig, 'Style', 'edit', 'Max', 100, 'Min', 0, 'Position', [20, 50, 280, 120], 'HorizontalAlignment', 'left');
    uicontrol(hParamFig, 'Style', 'pushbutton', 'String', 'Save', 'Position', [20, 10, 80, 30], 'Callback', {@save_lcm_parameters, hParamEdit});
    uicontrol(hParamFig, 'Style', 'pushbutton', 'String', 'Close', 'Position', [220, 10, 80, 30], 'Callback', @(~, ~) close(hParamFig));
end

function save_lcm_parameters(~, ~, hParamEdit)
    
    new_params = get(hParamEdit, 'String');
    if ischar(new_params)
        new_params = cellstr(new_params);
    end
    % Load existing data in lcm_data_file 
    if exist(lcm_data_file, 'file') == 2
        [path, name,ext] = fileparts(lcm_data_file);
        if contains(name,'_temp')
            temp_lcm_data_file = fullfile(path,[name,ext]);
        else
            newname = [name , '_temp',ext];
            temp_lcm_data_file = fullfile(path,newname);
            copyfile(lcm_data_file,temp_lcm_data_file);
        end
        data = load(temp_lcm_data_file);
    else
        data = struct;
    end
    % Store the new parameters in lcm_data_file
    data.new_params = new_params;
    save(temp_lcm_data_file, '-struct', 'data');
    lcm_data_file = temp_lcm_data_file;
    msgbox('Parameters saved successfully!', 'Success');
end

function lcm_range(~, ~)

    cd(defdir);
    if exist(lcm_data_file, 'file') == 2
        data = load(lcm_data_file);
    end
    if isfield(data, 'ppmend')
        ppmend = data.ppmend;
    end
    if isfield(data, 'ppmst')
        ppmst = data.ppmst;
    end
    pst_lcm_range(lcm_def_file, lcm_data_file, ppmend, ppmst);
end

function lcm_print_switch(hObject, ~)
    if strcmp(get(hObject, 'Checked'), 'on')
        set(hObject, 'Checked', 'off');
        lcm_print = false;
    else 
        set(hObject, 'Checked', 'on');
        lcm_print = true;
    end
end

function lcm_basis(~, ~)

    % Read the text file containing the numbered list of basis files with 
    % descriptions and let an user select a proper basis file
    cd(defdir);

    if exist(lcm_data_file, 'file') == 2
        data = load(lcm_data_file);
    end
    pst_lcm_basis(lcm_def_file, lcm_data_file);
end

%% Input/Load data functions 

function edit_text(hObject, ~)
    switch hObject
        case hRef_edit
            ref_file = get(hObject, 'String');
        case hFilespec_edit
            spec_file = get(hObject, 'String');
        case hFilewat_edit
            water_file = get(hObject, 'String');            
        case hTabledir_edit
            table_dir = get(hObject, 'String');
        case hTablename_edit
            table_name = get(hObject, 'String');
        case hImageName_edit
            image_name = get(hObject, 'String');
    end
end

function ref_browse(~, ~)
    
    cd(curdir);
    [FileName, PathName] = uigetfile({'*.nii;*.nii.gz', 'NIfTI Files (*.nii, *.nii.gz)'; '*.*', 'All Files (*.*)'}, 'Select MRS file');
    file = [PathName FileName];

    if isequal(FileName(end-2:end),'.gz')
        gunzip(file); % the filename from the above is already .nii
        file = [PathName FileName(1:end-3)];
    end

    if ~isequal(FileName, 0) && ~isequal(PathName, 0)
        set(hRef_edit, 'String', file);
        ref_file = file;
        curdir = PathName;
        set([hFilespec_edit hFilewat_edit hTabledir_edit hTablename_edit], 'String', '');
        img_gr = [];
        spec_file = '';
        water_file = '';
        met_file = '';
        table_dir = '';
        table_name = '';
        cur_sel_cell_array = [];
        sel_z_cell_array = [];
        last_pos_cell_array = [];
    end
end

function spec_browse(~, ~)
   
    cd(curdir);
    cd('..')
    [FileName, PathName] = uigetfile({'*.SDAT;*.RDA', 'MRS Files (*.SDAT, *.RDA)'; '*.*', 'All Files (*.*)'}, 'Select MRS file');
    if ~isequal(FileName, 0) && ~isequal(PathName, 0)
        fullname = [PathName FileName];
        set(hFilespec_edit, 'String', fullname);
        spec_file = fullname;
        curdir = PathName;
    end

    cd(defdir);
    if ~isempty(spec_file)
        [is_sv, Manufacturer] = pst_get_is_sv_and_vendor(spec_file);
        spec_struct.Manufacturer = Manufacturer;
    else
        warning("MRS file is empty")
    end
end

function water_browse(~, ~)

    cd(curdir);
    [FileName, PathName] = uigetfile({'*.SDAT;*.RDA', 'MRS Files (*.SDAT, *.RDA)'; '*.*', 'All Files (*.*)'}, 'Select reference water file');

    if ~isequal(FileName, 0) && ~isequal(PathName, 0)
        fullname = [PathName FileName];
        set(hFilewat_edit, 'String', fullname);
        water_file = fullname;
        curdir = PathName;
    end
    cd(defdir);
    if isempty(water_file)
        warning("unsuppressed water file empty")
    end
end

function load_data(~, ~)

    disp(' ')
    disp('Loading and coregistering data...');
    disp(' ')

    % activate reactivation button
    set(hEnableBtns_btn, 'Visible', 'on');

    % deactivate the Load button
    set(hLoad_btn, 'String', 'Loading...', 'Enable', 'off');
    pause(0.01);

    % check if there are segmentation and parameter files. Tick the
    % settings if they are there and reslice these images into the ref space

    [segmentation_is_there, segmentation_files] = pst_check_cfiles(ref_file);
    [q, qMRI_files, qMRI_names] = pst_check_qfiles(ref_file);

    if ~analyze_segm && (segmentation_is_there>-2)
            answer = questdlg('T1 segmentation exists! Would you like to use the segmented data?', 'Use segmented data?', 'Yes', 'No', 'No');
        switch answer
            case 'Yes'
                analyze_segm = true;
                set(hSegmAna, 'Checked', 'On', 'Enable', 'on')
            case 'No'
                analyze_segm = false;
                set(hSegmAna, 'Checked', 'Off', 'Enable', 'off')
        end
    end

    if ~analyze_param && q == 1
            answer = questdlg('qMRI maps found! Would you like to use these data?', 'Use qMRI data?', 'Yes', 'No', 'No'); 
        switch answer
            case 'Yes'
                analyze_param = true;
                set(hParamAna, 'Checked', 'On', 'Enable', 'on')
            case 'No'
                analyze_param = false;
                set(hParamAna, 'Checked', 'Off', 'Enable', 'off')
        end
    end
    quantitative_files = [];
    if analyze_segm
        quantitative_files = [quantitative_files, segmentation_files];
    end
    if analyze_param
        quantitative_files = [quantitative_files, qMRI_files];
    end
    
    if (~analyze_segm && ~analyze_param) && ~isempty(quantitative_files)
        disp('Quantitative maps do not participate in processing!')
    end

    resliced_quantitative_files = pst_reslice_quantitative_files(quantitative_files, ref_file);
    
    spec_struct = pst_load_spec(spec_file, water_file, ref_file, is_sv, Manufacturer);
    if ~isempty(water_file)
                
        % spec_struct = pst_check_water_dim(spec_struct); % water should be
        % of the same size as metabolites. for Philips it's always the case
        % if the water is acquired in the same sequence with metabolites.
        % For Siemens might not be the case

        % Function correctness is not yet checked.
        % Commented for now
        
    end

    % First, we need the rotation matrix which is the same as in the ppmShift = 0.
    % we may get it from coreg, a special case is waiting there:
    spec_struct.case = 'Get_rotation_matrix';
    spec_struct = pst_coreg(spec_struct, is_sv, ref_file, 0); % ppmShift = 0
    fprintf('%s\n', 'Processing Planscan geometry...');
    process_CSD(0, 'silent'); % here only the default ppmShift = 0 is processed

    % selections
    cur_sel_cell_array = [];
    sel_z_cell_array = [];
    last_pos_cell_array = [];
    cur_sel = zeros([spec_struct.nYvoxels spec_struct.nXvoxels spec_struct.nZvoxels]);
    
    % visual
    prepare_visual(0);
    visual_out(0);

    % enable buttons
    set(hCSDE_Vis_btn, 'Visible', 'on')
    setGroupVisibility(hVIS, 'on');
    setGroupVisibility(hINDIVOX, 'on');

    if isempty(resliced_quantitative_files)
        set(hProcSel_btn, 'Enable', 'off');
    else
        set(hProcSel_btn, 'Enable', 'on');
    end

    % reasign the array of delta ppmshifts if it was already input once
    if isequal(get(hPpmShiftEdit, 'Visible'), 'on')
        edit_value(hPpmShiftEdit, 'ppmShift');
    end

    if ~is_sv
        set(hSelect_btn, 'Enable', 'on');
        set(hDeleteSelection_btn, 'Enable', 'on');
    else
        set(hSelect_btn, 'Enable', 'off');
        set(hDeleteSelection_btn, 'Enable', 'off');
    end
    
    % reactivate the button
    set(hLoad_btn, 'Enable', 'on');
    set(hLoad_btn, 'String', 'Load Data');

    fclose('all');
    disp(' ')
    disp('Data loaded!')

    
end

%% Visual part functions

function bright_edit(~, ~)

    bright_factor_str = get(hBrightEdit, 'String');
    num = str2double(bright_factor_str);

    if num < 0.1
        num = 0.1;
    elseif num > 20
        num = 20;
    end

    set(hBrightEdit, 'String', sprintf('%1.1f', num));

    bright_factor = num;
    cur_sl = img_gr(:,:,idx);
    scaling_factor = max(max(cur_sl))/256;
    out_sl = cur_sl./scaling_factor;
    out_sl = out_sl .* bright_factor;
    image(hAxes, out_sl);
    hAxes.XColor = 'none';
    hAxes.YColor = 'none';
    hAxes.XTick  = [];
    hAxes.YTick  = [];
    
    if ~is_sv
        draw_FOV(spec_struct.geometry);
        draw_VOI(curr_ppmShift);
        draw_selection(spec_struct.geometry);
    else
        draw_VOI(curr_ppmShift);
    end

    apply_flip_AP(hAxes, hf.UserData.AP_flipped);
    apply_flip_LR(hAxes, hf.UserData.LR_flipped);
end

function bright_change(dir)

    bright_factor = str2double(get(hBrightEdit,'String'));
    bright_factor = max(bright_min, min(bright_max, bright_factor + dir*bright_step));
    set(hBrightEdit,'String',sprintf('%1.1f',bright_factor));
    cur_sl = img_gr(:,:,idx);
    scaling_factor = max(max(cur_sl))/256;
    out_sl = (cur_sl ./ scaling_factor) * bright_factor;
    image(hAxes, out_sl);
    hAxes.XColor = 'none';
    hAxes.YColor = 'none';
    hAxes.XTick  = [];
    hAxes.YTick  = [];

    if ~is_sv
        draw_FOV(spec_struct.geometry);
        draw_VOI(curr_ppmShift);
        draw_selection(spec_struct.geometry);
    else
        draw_VOI(curr_ppmShift);
    end

    apply_flip_AP(hAxes, hf.UserData.AP_flipped);
    apply_flip_LR(hAxes, hf.UserData.LR_flipped);
end

function width_edit(hObject, ~)

    str = get(hObject, 'String');
    num = str2double(str);
    if num>0
        width_factor = num;
        posit = get(hf,'Position');
        set(hAxes, 'Units', 'normalized', 'Position', [0.26 0.17 0.25*magn_factor*width_factor 0.45*magn_factor]);
    else
        errordlg('The magnification factor must be positive!');
    end

    if ~is_sv
        draw_FOV(spec_struct.geometry);
        draw_selection(spec_struct.geometry);
    end
end

function width_arrow(direction)

    width_factor = str2double(get(hWidthEdit, 'String'));
    if isnan(width_factor)
        width_factor = 1;
    end
    width_factor = width_factor + direction*width_step;
    width_factor = max(0.1, min(7, width_factor));
    set(hWidthEdit, 'String', sprintf('%1.1f', width_factor));
    posit = get(hf,'Position');
    set(hAxes, 'Units', 'normalized', 'Position', [0.26 0.17 0.25*magn_factor*width_factor 0.45*magn_factor]);
    if ~is_sv
        draw_FOV(spec_struct.geometry);
        draw_VOI(curr_ppmShift);
        draw_selection(spec_struct.geometry);
    end
end

function magn_edit(hObject, ~)

    str = get(hObject, 'String');
    num = str2double(str);
    if num>0
        magn_factor = num;
        posit = get(hf,'Position');
        set(hAxes, 'Units', 'normalized', 'Position', [0.26 0.17 0.25*magn_factor*width_factor 0.45*magn_factor]);
    else
        errordlg('The magnification factor must be positive!');
    end

    if ~is_sv
        draw_FOV(spec_struct.geometry);
        draw_selection(spec_struct.geometry);
    end
end

function magn_arrow(direction)

    magn_factor = str2double(get(hMagnEdit, 'String'));
    if isnan(magn_factor)
        magn_factor = 1;
    end
    magn_factor = magn_factor + direction*magn_step;
    magn_factor = max(0.1, min(7, magn_factor));
    set(hMagnEdit, 'String', sprintf('%1.1f', magn_factor));
    posit = get(hf,'Position');
    set(hAxes, 'Units', 'normalized', 'Position', [0.26 0.17 0.25*magn_factor*width_factor 0.45*magn_factor]);
    if ~is_sv
        draw_FOV(spec_struct.geometry);
        draw_VOI(curr_ppmShift);
        draw_selection(spec_struct.geometry);
    end
end

function change_curr_ppmShift(step)

    current_ppmshift_idx = current_ppmshift_idx + step;
    if current_ppmshift_idx > numel(ppmShifts_with_0)
        current_ppmshift_idx = 1;
    elseif current_ppmshift_idx < 1
        current_ppmshift_idx = numel(ppmShifts_with_0);
    end
    curr_ppmShift = ppmShifts_with_0(current_ppmshift_idx);
    set(hCSModifiedText, 'String', num2str(curr_ppmShift));
    visual_out(curr_ppmShift);
    
    apply_flip_AP(hAxes, hf.UserData.AP_flipped);
    apply_flip_LR(hAxes, hf.UserData.LR_flipped);
end


function flip_AP(~,~)
    
    hf = ancestor(hAxes,'figure');
    apply_flip_AP(hAxes, ~hf.UserData.AP_flipped);
    hf.UserData.AP_flipped = ~hf.UserData.AP_flipped;
end

function apply_flip_AP(axes_to_AP_flip, AP_flipped)

    if AP_flipped
        axes_to_AP_flip.YDir = 'reverse';
    else 
        axes_to_AP_flip.YDir = 'normal';
    end
end

function flip_LR(~,~)
    
    hf = ancestor(hAxes,'figure');
    apply_flip_LR(hAxes, ~hf.UserData.LR_flipped);
    hf.UserData.LR_flipped = ~hf.UserData.LR_flipped;
end

function apply_flip_LR(axes_to_LR_flip, LR_flipped)

    if LR_flipped
        axes_to_LR_flip.XDir = 'normal';
    else 
        axes_to_LR_flip.XDir = 'reverse';
    end
end

function reset_view(~,~)
    
    % reset orientation
    hf = ancestor(hAxes, 'figure');
    hAxes.XDir = hf.UserData.initialAxesState.XDir;
    hAxes.YDir = hf.UserData.initialAxesState.YDir;
    hf.UserData.LR_flipped = false;
    hf.UserData.AP_flipped = false;

    % reset brightness
    bright_factor = 1;
    set(hBrightEdit, 'String', sprintf('%1.1f', bright_factor));
    cur_sl = img_gr(:,:,idx);
    scaling_factor = max(max(cur_sl))/256;
    out_sl = (cur_sl ./ scaling_factor) * bright_factor;
    image(hAxes, out_sl);
    hAxes.XColor = 'none';
    hAxes.YColor = 'none';
    hAxes.XTick  = [];
    hAxes.YTick  = [];

    % reset magnification
    magn_factor = 1;
    set(hMagnEdit, 'String', sprintf('%1.1f', magn_factor));
    
    % reset width
    width_factor = 1;
    set(hWidthEdit, 'String', sprintf('%1.1f', width_factor));

    % reset demonstration of the chemical shift
    set(hCSModifiedText, 'string', 0);

    set(hAxes, 'Units', 'normalized', 'Position', [0.26 0.17 0.25*magn_factor*width_factor 0.45*magn_factor]);

    if ~is_sv
        draw_FOV(spec_struct.geometry);
        draw_VOI(0);
        draw_selection(spec_struct.geometry);
    else
        draw_VOI(0);
    end
end

function slice_slider(hObject, ~)
    
    sl_value = get(hObject, 'Value');
    idx = round(sl_value);
    cur_sl = img_gr(:,:,idx);
    scaling_factor = max(max(cur_sl))/256;
    out_sl = cur_sl./scaling_factor;
    out_sl = out_sl .* bright_factor;
    image(hAxes, out_sl);
    hAxes.XColor = 'none';
    hAxes.YColor = 'none';
    hAxes.XTick  = [];
    hAxes.YTick  = [];
    if ~is_sv
        draw_FOV(spec_struct.geometry);
        draw_VOI(curr_ppmShift);
        draw_selection(spec_struct.geometry);
    else
        draw_VOI(curr_ppmShift);
    end
    
    apply_flip_AP(hAxes, hf.UserData.AP_flipped);
    apply_flip_LR(hAxes, hf.UserData.LR_flipped);

    if ~isempty(spectra_pts)
        hold on
        for i = 1:size(spectra_pts, 1)
            cur_x = spectra_pts(i,1);
            cur_y = spectra_pts(i,2);
            plot(cur_x, cur_y, 'xr', 'LineWidth', 2);
        end
        hold off
    end
    set(hSliceSlider_text, 'String', ['slice' num2str(idx)]);
    set(hImageName_edit, 'String', ['slice' num2str(idx)]);
    image_name = ['slice' num2str(idx)];
end

%% Chemical Shift displacement functions

function edit_value(hObject, paramName)
    str = get(hObject, 'String');
    switch paramName
        case 'BW_ex'
            BW_ex = str2double(str);
        case 'BW_echo'
            BW_echo = str2double(str);
        case 'GR_ex'
            GR_ex = str2double(str);
        case 'GR_echo1'
            GR_echo1 = str2double(str);
        case 'GR_echo2'
            GR_echo2 = str2double(str);              
        case 'ppmShift'
            parts = regexp(str, '[, ]+', 'split');
            parts = parts(~cellfun('isempty', parts));
            vals = str2double(strtrim(parts));
            ppmShifts = vals;
            set(hObject, 'String', strjoin(arrayfun(@num2str, ppmShifts, 'UniformOutput', false), ', '));
            ppmShifts = sort(ppmShifts);
            if ~any(ppmShifts == 0)
                ppmShifts_with_0 = sort([ppmShifts 0]);
            else
                ppmShifts_with_0 = ppmShifts;
            end
    end
end

function toggle_button(src, dir)

    % Flip label
    switch src.String
        case 'A', newVal = 'P';
        case 'P', newVal = 'A';
        case 'L', newVal = 'R';
        case 'R', newVal = 'L';
        case 'F', newVal = 'H';
        case 'H', newVal = 'F';
        case 'AP', newVal = 'RL';
        case 'RL', newVal = 'AP';            
    end

    % Compute +1 or -1
    src.String = newVal;

    % Assign to correct global
    switch dir
        case 'A'
            shiftDirAP = newVal;
        case 'L'
            shiftDirLR = newVal;
        case 'F'
            shiftDirFH = newVal;
        case 'AP'
            RFOV_dir = newVal;
        case 'LR'
            RFOV_dir = newVal;            
    end
end

function load_csd_parameters

    % load/derive chemical shift parameters

    if isequal(Manufacturer, 'Philips')

        if ~is_sv
            spec_struct.geometry.RFOV_dir = RFOV_dir;
        else
            spec_struct.geometry.RFOV_dir = 'none';
        end
    
        spec_struct.BW_ex = BW_ex;
        spec_struct.BW_echo = BW_echo;
    
        if shiftDirAP == 'A' 
            spec_struct.geometry.signShiftAP = -1;
        else 
            spec_struct.geometry.signShiftAP = 1;
        end
    
        if shiftDirLR == 'R' 
            spec_struct.geometry.signShiftLR = -1;
        else 
            spec_struct.geometry.signShiftLR = 1;
        end
    
        if shiftDirFH == 'F' 
            spec_struct.geometry.signShiftFH = 1;
        else 
            spec_struct.geometry.signShiftFH = -1;
        end
    
        % In Philips 2D MRSI there is a "RFOV direction" parameter.
        % If RFOV direction == AP it means that the 180-pulse spacially selects
        % in the AP direction, while the 90-pulse works in the LR direction.
        % This tells us to introduce BW_lr and BW_ap instead of BW_ex and BW_echo.
        % The last 180 (or the last pair of AFP in sLASER) is always used for slice selection, that's why it's BW_echo
    
        if isequal(spec_struct.geometry.RFOV_dir, 'AP') || isequal(spec_struct.geometry.RFOV_dir, 'none') % none is for single voxel
            spec_struct.BW_lr = BW_ex;
            spec_struct.BW_ap = BW_echo;
            spec_struct.BW_cc = BW_echo; % cc is always measured with echo
        elseif isequal(spec_struct.geometry.RFOV_dir, 'RL')
            spec_struct.BW_lr = BW_echo;
            spec_struct.BW_ap = BW_ex;
            spec_struct.BW_cc = BW_echo; 
        end

    elseif isequal(Manufacturer, 'Siemens')

        if ~is_sv
            spec_struct.geometry.RFOV_dir = RFOV_dir;
        else
            spec_struct.geometry.RFOV_dir = 'none';
        end

        spec_struct.GR_ex = GR_ex;
        spec_struct.GR_echo1 = GR_echo1;
        spec_struct.GR_echo2 = GR_echo2;

        if isequal(spec_struct.geometry.RFOV_dir, 'AP') || isequal(spec_struct.geometry.RFOV_dir, 'none') % none is for single voxel
            spec_struct.GR_lr = GR_ex;
            spec_struct.GR_ap = GR_echo1;
            spec_struct.GR_cc = GR_echo2; % cc is always measured with echo
        elseif isequal(spec_struct.geometry.RFOV_dir, 'RL')
            spec_struct.GR_lr = GR_echo1;
            spec_struct.GR_ap = GR_ex;
            spec_struct.GR_cc = GR_echo2; 
        end
    end
end

function apply_CSD_preset(hObject)

    index = hObject.Value;
    items = hObject.String;
    selection = items{index};

    switch selection
        case 'Philips 2D sLASER'
            disp('Philips 2D sLASER preset selected');

            set(hBW_ex_text, 'Visible', 'on');
            set(hBW_ex_edit, 'Visible', 'on');
            set(hShiftDir_text, 'Enable', 'on');
            set(hAP_btn, 'Enable', 'on');
            set(hRL_btn, 'Enable', 'on');
            set(hFH_btn, 'Enable', 'off');
            set(hRFOV_dir_text, 'Enable', 'on');
            set(hRFOV_dir_btn, 'Enable', 'on');
            
            BW_ex = 3710;
            set(hBW_ex_edit, 'String', num2str(BW_ex));
            BW_echo = 5614;
            set(hBW_echo_edit, 'String', num2str(BW_echo));
            set(hBW_echo_text, 'String', 'Echo pulse BW (Hz):');

        case 'Philips 2D PRESS'

            set(hBW_ex_text, 'Visible', 'on');
            set(hBW_ex_edit, 'Visible', 'on');
            set(hShiftDir_text, 'Enable', 'on');
            set(hAP_btn, 'Enable', 'on');
            set(hRL_btn, 'Enable', 'on');
            set(hFH_btn, 'Enable', 'off');
            set(hRFOV_dir_text, 'Enable', 'on');
            set(hRFOV_dir_btn, 'Enable', 'on');
            
            disp('Philips 2D PRESS preset selected');
            BW_ex = 2277;
            set(hBW_ex_edit, 'String', num2str(BW_ex));
            set(hBW_ex_edit, 'String', num2str(BW_ex));
            BW_echo = 1357;
            set(hBW_echo_edit, 'String', num2str(BW_echo));
            set(hBW_echo_text, 'String', 'Echo pulse BW99 (Hz):');

        case 'Philips Rapid Biomed 31P 2D Pulse-Acq'

            disp('Philips Rapid 31P 2D Pulse-Acq preset selected');
            set(hBW_ex_text, 'Visible', 'off');
            set(hBW_ex_edit, 'Visible', 'off');
            set(hShiftDir_text, 'Enable', 'off');
            set(hAP_btn, 'Enable', 'off');
            set(hRL_btn, 'Enable', 'off');
            set(hFH_btn, 'Enable', 'off');
            set(hRFOV_dir_text, 'Enable', 'off');
            set(hRFOV_dir_btn, 'Enable', 'off');
            
            % in current implementation, the slice is selected by the
            % BW_echo. So in this case we will just rename the echo pulse into excitation pulse
            set(hBW_echo_text, 'String', 'Excitation pulse BW99 (Hz):');
            BW_echo = 6468;
            set(hBW_echo_edit, 'String', num2str(BW_echo));

        case 'Philips Rapid Biomed 1H 2D Pulse-Acq'

            disp('Philips Rapid 1H 2D Pulse-Acq preset selected');
            set(hBW_ex_text, 'Visible', 'off');
            set(hBW_ex_edit, 'Visible', 'off');
            set(hShiftDir_text, 'Enable', 'off');
            set(hAP_btn, 'Enable', 'off');
            set(hRL_btn, 'Enable', 'off');
            set(hFH_btn, 'Enable', 'off');
            set(hRFOV_dir_text, 'Enable', 'off');
            set(hRFOV_dir_btn, 'Enable', 'off');
            
            % in current implementation, the slice is selected by the
            % BW_echo. So in this case we will just rename the echo pulse into excitation pulse
            set(hBW_echo_text, 'String', 'Excitation pulse BW99 (Hz):');
            BW_echo = 3374;
            set(hBW_echo_edit, 'String', num2str(BW_echo));

        case 'Philips 1H 2D Pulse-Acq'

            disp('Philips 1H 2D Pulse-Acq preset selected');
            set(hBW_ex_text, 'Visible', 'off');
            set(hBW_ex_edit, 'Visible', 'off');
            set(hShiftDir_text, 'Enable', 'off');
            set(hAP_btn, 'Enable', 'off');
            set(hRL_btn, 'Enable', 'off');
            set(hFH_btn, 'Enable', 'off');
            set(hRFOV_dir_text, 'Enable', 'off');
            set(hRFOV_dir_btn, 'Enable', 'off');
            
            % in current implementation, the slice is selected by the
            % BW_echo. So in this case we will just rename the echo pulse into excitation pulse
            set(hBW_echo_text, 'String', 'Excitation pulse BW99 (Hz):');
            BW_echo = 2277;
            set(hBW_echo_edit, 'String', num2str(BW_echo));

        case 'Philips SV sLASER'
            disp('Philips SV sLASER preset selected');

            set(hBW_ex_text, 'Visible', 'on');
            set(hBW_ex_edit, 'Visible', 'on');
            set(hShiftDir_text, 'Enable', 'on');
            set(hAP_btn, 'Enable', 'on');
            set(hRL_btn, 'Enable', 'on');
            set(hFH_btn, 'Enable', 'on');
            set(hRFOV_dir_text, 'Enable', 'on');
            set(hRFOV_dir_btn, 'Enable', 'on');
            
            BW_ex = 3710;
            set(hBW_ex_edit, 'String', num2str(BW_ex));
            BW_echo = 5614;
            set(hBW_echo_edit, 'String', num2str(BW_echo));
            set(hBW_echo_text, 'String', 'Echo pulse BW (Hz):');

        case 'Philips SV PRESS'
            disp('Philips SV sLASER preset selected');

            set(hBW_ex_text, 'Visible', 'on');
            set(hBW_ex_edit, 'Visible', 'on');
            set(hShiftDir_text, 'Enable', 'on');
            set(hAP_btn, 'Enable', 'on');
            set(hRL_btn, 'Enable', 'on');
            set(hFH_btn, 'Enable', 'on');
            set(hRFOV_dir_text, 'Enable', 'off');
            set(hRFOV_dir_btn, 'Enable', 'off');
            
            BW_ex = 2277;
            set(hBW_ex_edit, 'String', num2str(BW_ex));
            BW_echo = 1357;
            set(hBW_echo_edit, 'String', num2str(BW_echo));
            set(hBW_echo_text, 'String', 'Echo pulse BW99 (Hz):');
    end
end

function process_CSD(varargin)
    
    % This function processes the chemically shift displaced geometry
    % starting with the shift = 0
    % First, the FOV/VOI/SV masks for a given shift are found.
    % Then, if not SV, the image slabs for the anatomical reference and
    % quantitative files for the given shift are calculated.

    if nargin > 0
        ppmShifts = 0;
    end
    
    if isequal(ppmShifts, 0)
        if ~is_sv
            % find the VOI mask in coreg 
            spec_struct.voxID = 'VOI';
            spec_struct = pst_coreg(spec_struct, is_sv, ref_file, 0);

            % find the FOV mask in coreg as if it was a voxel
            spec_struct.voxID = 'FOV';
            spec_struct = pst_coreg(spec_struct, is_sv, ref_file, 0);
    
            % find the image slab
            spec_struct = pst_get_slab(spec_struct, {ref_file}, 0, do_PSF_blurring);

            [spec_struct, shift0_quantitative_slabs_only_VOI] = pst_get_slab(spec_struct, resliced_quantitative_files, 0, do_PSF_blurring);
            quantitative_slabs_only_VOI{1} = shift0_quantitative_slabs_only_VOI;
            spec_struct.('shifted_0').slab_VOI_mask_filepath = fileparts(spec_struct.('shifted_0').slab_VOI_mask_filename);
            spec_struct.('shifted_0').mask = spm_read_vols(spm_vol(spec_struct.('shifted_0').slab_VOI_mask_filename));

        else
            spec_struct.voxID = 'SV';
            spec_struct = pst_coreg(spec_struct, is_sv, ref_file, 0);
            spec_struct.('shifted_0').VOI_mask_filename = spec_struct.VOI_mask_filename;
            spec_struct.('shifted_0').mask = spm_read_vols(spm_vol(spec_struct.('shifted_0').VOI_mask_filename));

        end
        
        % returning from here because this is the case when the function is called by the Load Data button
        return 
    else
        % now the function is called by the Process CSDE button

        set(hPROC_CSDE_btn, 'String', 'Processing CSDE...', 'Enable', 'off')
        pause(0.01);
    
        load_csd_parameters;
    
        for i=1:length(ppmShifts)
            shifted_structs(i) = spec_struct;
        end
        for i = 1:length(ppmShifts) 
        
            fprintf('\n%s%s%s\n', 'Processing shifted geometry, delta = ', num2str(ppmShifts(i)), '...');

            if ~is_sv
                
                if spec_struct.geometry.exist_VOI 
                    % find shifted VOI mask in coreg
                    shifted_structs(i).voxID = 'VOI';
                    tmp = pst_coreg(shifted_structs(i), is_sv, ref_file, ppmShifts(i));
                    fields = fieldnames(tmp);
                    for f = 1:numel(fields)
                        shifted_structs(i).(fields{f}) = tmp.(fields{f});
                    end
                end
    
                % find shifted FOV mask in coreg as if it was a voxel
                shifted_structs(i).voxID = 'FOV';
                shifted_structs(i) = pst_coreg(shifted_structs(i), is_sv, ref_file, ppmShifts(i));
        
                % find the image slab
                [tmp2, ~] = pst_get_slab(shifted_structs(i), {ref_file}, ppmShifts(i), do_PSF_blurring);
                fields2 = fieldnames(tmp2);
                for f2 = 1:numel(fields2)
                    shifted_structs(i).(fields2{f2}) = tmp2.(fields2{f2});
                end

            else
                % find shifted SV mask in coreg
                shifted_structs(i).voxID = 'SV';
                result = pst_coreg(shifted_structs(i), is_sv, ref_file, ppmShifts(i));
                result = orderfields(result, shifted_structs(i)); 
                shifted_structs(i) = result;
            end
        
            % get the VOI piece from quantitative images
            if ~is_sv
                [shifted_structs(i), curr_shift_quantitative_slabs_only_VOI] = pst_get_slab(shifted_structs(i), resliced_quantitative_files, ppmShifts(i), do_PSF_blurring);
                quantitative_slabs_only_VOI{i+1} = curr_shift_quantitative_slabs_only_VOI; % i = 1 is already filled with the results for delta CSD = 0
            end
        end
    end

    for i=1:length(ppmShifts)

        shift_val_str = pst_get_shift_value_string(ppmShifts(i));

        if ~is_sv

            spec_struct.(['shifted_' shift_val_str]).image_slab_filename = shifted_structs(i).(['shifted_' shift_val_str]).image_slab_filename;
            spec_struct.(['shifted_' shift_val_str]).image_slab_filepath = fileparts(shifted_structs(i).(['shifted_' shift_val_str]).image_slab_filename);
            
            if spec_struct.geometry.exist_VOI

                spec_struct.(['shifted_' shift_val_str]).slab_VOI_mask_filename = shifted_structs(i).(['shifted_' shift_val_str]).slab_VOI_mask_filename;
                spec_struct.(['shifted_' shift_val_str]).slab_VOI_mask_filepath = fileparts(spec_struct.(['shifted_' shift_val_str]).slab_VOI_mask_filename);
    
                % load the VOI mask and save in this struct, shall be used in draw_VOI
                spec_struct.(['shifted_' shift_val_str]).mask = spm_read_vols(spm_vol(spec_struct.(['shifted_' shift_val_str]).slab_VOI_mask_filename));
            end
        else
            spec_struct.(['shifted_' shift_val_str]).VOI_mask_filename = shifted_structs(i).VOI_mask_filename;
            spec_struct.(['shifted_' shift_val_str]).mask = spm_read_vols(spm_vol(spec_struct.(['shifted_' shift_val_str]).VOI_mask_filename));
        end
        prepare_visual(ppmShifts(i));
    end

    setGroupVisibility(hShowChemicallyShiftedImage, 'on');
    curr_ppmShift = ppmShifts(1);
    set(hCSModifiedText, 'String', num2str(curr_ppmShift));
    visual_out(curr_ppmShift);

    set(hPROC_CSDE_btn, 'Enable', 'on', 'String', 'Process CSDE')
    disp(' ')
    disp('Chemical Shift Displacement processed!')
end

%% Individual voxel processing functions

function select_voxels(~,~)
    
    if exist(sel_file, 'file') && sel_file_is_old % in this case refresh the file (the flag by default is True)
        delete(sel_file)
    end
    sel_file_is_old = false;

    if isempty(cur_sel)
        cur_sel = zeros([spec_struct.nYvoxels spec_struct.nXvoxels spec_struct.nZvoxels]);
    end

    %add names to selections
    default_name = sprintf('selec%d', sel_nr);

    choice = questdlg('Enter selection name:', 'Selection Name', 'Input Name', 'Use Default', 'Use Default');
    if strcmp(choice, 'Input Name')
        answer = inputdlg('Input selection name:', 'Selection Name', [1 35], {default_name});
        if ~isempty(answer)
            selection_name = answer{1};
        else
            selection_name = default_name;
        end
    else
        selection_name = default_name;
    end

    sel_z = idx * spec_struct.geometry.ref_vox_sz(3)/spec_struct.geometry.vox_sz(3);
    sel_z_spec = 1;
    
    [~, rect] = imcrop(hAxes);
    if ~isempty(rect)
        sel_nr = sel_nr + 1;
        sel_x1_spec_prev = sel_x1_spec;
        sel_y1_spec_prev = sel_y1_spec;
        sel_x2_spec_prev = sel_x2_spec;
        sel_y2_spec_prev = sel_y2_spec;
        sel_x1_spec = ceil(rect(1)*spec_struct.geometry.ref_vox_sz(1)/spec_struct.geometry.vox_sz(1)) ;
        sel_y1_spec = ceil(rect(2)*spec_struct.geometry.ref_vox_sz(2)/spec_struct.geometry.vox_sz(2)) ;
        sel_x2_spec = ceil((rect(1)+rect(3))*spec_struct.geometry.ref_vox_sz(1)/spec_struct.geometry.vox_sz(1)) ; 
        sel_y2_spec = ceil((rect(2)+rect(4))*spec_struct.geometry.ref_vox_sz(2)/spec_struct.geometry.vox_sz(2)) ;
            
        fprintf('%s\n\n', 'The following matrix indicates your current voxel selection(s):'); 
        cur_sel(sel_y1_spec:sel_y2_spec, sel_x1_spec:sel_x2_spec, sel_z_spec) = sel_nr;

        % Ensure the indices are within the bounds of the selection matrix
        sel_x1_spec = max(1, sel_x1_spec);
        sel_y1_spec = max(1, sel_y1_spec);
        sel_x2_spec = min(size(cur_sel, 2), sel_x2_spec);
        sel_y2_spec = min(size(cur_sel, 1), sel_y2_spec);
        
        cur_sel_cell_array = [cur_sel_cell_array {cur_sel}];

        for i = 1:size(cur_sel, 1)
            fprintf('\t');
            fprintf('%d ', cur_sel(i,:,sel_z_spec));
            fprintf('\n');
        end
        fprintf('\n');
        sel_z_cell_array = [sel_z_cell_array {sel_z}];

        if ~isempty(spec_file)
            [path, name] = fileparts(spec_file);
            sel_file = fullfile(path, [name '.csv']);
        end

        fid = fopen(sel_file, 'a');
        if ftell(fid) == 0
            fprintf(fid, '%s\n', 'i j Region');
        end
        for i = sel_x1_spec:sel_x2_spec
            for j = sel_y1_spec:sel_y2_spec
                fprintf(fid, '%d\t%d\t%s\n', spec_struct.nXvoxels - i + 1, j, selection_name); 
            end
        end
        fclose(fid);
       
        draw_FOV(spec_struct.geometry);
        draw_VOI(curr_ppmShift);
        draw_selection(spec_struct.geometry);
    else
        fprintf('No selection was made!\n');
    end
end

function reuse_selections(~,~)

    [sel_path, sel_name] = fileparts(spec_file);
    sel_file = [sel_path filesep sel_name '.csv'];
    if ~isempty(sel_file) && exist(sel_file, 'file') == 2 && ~isempty(spec_file) && isempty(met_file)
        quest = sprintf('%s%s\n%s', 'The program has found MRS selection. ', 'Do you want to reuse it?', 'Be sure the image is flipped the same way as it was during initial selection.');
        answer = questdlg(quest, 'Previous region selection');

        switch answer
            case 'Yes'
                [ij, region] = read_sel_file(sel_file);
                if ~isempty(ij) && ~isempty(region)
                    sel_z = 1;
                    sel_z_cell_array = [sel_z_cell_array {sel_z}];
                    for ind = 1:size(ij, 1)
                        sel_str = regexp(region{ind}, '\d+', 'match');
                        sel_nr = str2double(sel_str{1});
                        i = ij(ind, 1);
                        j = ij(ind, 2);
                        plot_i = i;
                        plot_j = spec_struct.nYvoxels - j + 1;
                        cur_sel(plot_j, plot_i, sel_z) = sel_nr;
                    end
                    cur_sel_cell_array = [cur_sel_cell_array {cur_sel}];
                    draw_selection(spec_struct.geometry);
                else
                    warning("The selection couldn't be taken over!");
                end
            case 'No'
                a2 = questdlg('Delete MRS region selection file?', 'Previous region selection', 'Yes', 'No', 'No');
                if strcmp(a2, 'Yes')
                    delete(sel_file);
                end
            case 'Cancel'
                return
        end
    else
        errordlg('No previous selection found!');
    end
end

function del_last_selection(~, ~)

    if ~is_sv
        if sel_nr > 0
            sel_nr = sel_nr - 1;
            if sel_nr == 0
                try
                    delete(sel_file);
                catch
                end
            end
        end
    
        if ~isempty(cur_sel_cell_array)
            cur_sel_cell_array = cur_sel_cell_array(1:end-1);
            if ~isempty(cur_sel_cell_array)
                cur_sel = cur_sel_cell_array{end};
            else
                cur_sel = zeros([spec_struct.nYvoxels spec_struct.nXvoxels spec_struct.nZvoxels]);
            end
        end
    
        sel_x1_spec = sel_x1_spec_prev;
        sel_y1_spec = sel_y1_spec_prev;
        sel_x2_spec = sel_x2_spec_prev;
        sel_y2_spec = sel_y2_spec_prev;
        
        if idx > 0
            cur_sl = img_gr(:,:,idx);
            scaling_factor = max(max(cur_sl))/256;
            out_sl = cur_sl./scaling_factor;
            out_sl = out_sl.*bright_factor;
            image(hAxes, out_sl);
            hAxes.XColor = 'none';
            hAxes.YColor = 'none';
            hAxes.XTick  = [];
            hAxes.YTick  = [];
            set(hAxes, 'Units', 'normalized', 'Position', [0.26 0.17 0.25*magn_factor*width_factor 0.45*magn_factor], 'Visible', 'on');

            draw_FOV(spec_struct.geometry);
            draw_VOI(curr_ppmShift);
            draw_selection(spec_struct.geometry);
            
            apply_flip_AP(hAxes, hf.UserData.AP_flipped);
            apply_flip_LR(hAxes, hf.UserData.LR_flipped);
        end

        if exist(sel_file, 'file') == 2 && ~isempty(last_pos_cell_array)
            last_pos = last_pos_cell_array{end};
            if last_pos == 0
                delete(sel_file);
                return
            else
                fid = fopen(sel_file);
                data = fread(fid, last_pos);
                fclose(fid);
                fid = fopen(sel_file, 'w');
                fwrite(fid, data);
                fclose(fid);
            end
        end

        % fprintf('%s\n\n', 'The following matrix indicates your current voxel selection(s):');
        % for i = 1:size(cur_sel, 1)
        %     fprintf('\t');
        %     fprintf('%d ', cur_sel(i,:,sel_z_spec));
        %     fprintf('\n');
        % end
        % fprintf('\n');
        fprintf('%s\n', 'Selection deleted!');
    end
end

function del_all

    answer = questdlg('Delete all selections?', 'Question:', 'Yes', 'No', 'Yes');
    if strcmp(answer, 'Yes')
        for i = 1:sel_nr
            del_last_selection;
        end
    else 
        return
    end
end

function process_lcmodel(~, ~)

    set(hLCM_btn, 'Enable', 'off')
    set(hLCM_btn, 'String', 'Processing...')
    pause(0.01);

    if ~isempty(cur_sel_cell_array) || is_sv
        if is_sv
            fprintf('%s\n', '_______________________________________________');
            fprintf('%s\n\n', 'Performing LCModel analysis of the single voxel');
        else
            fprintf('%s\n', '__________________________________________________' );
            fprintf('%s\n\n', 'Performing LCModel analysis of the selected voxels' );
        end
        if ~is_sv
            sel_z_spec = ceil(sel_z);
        end

        cd(defdir);

        if ~exist(lcm_data_file, 'file')

            data.neach = neach;
            data.degzer = degzer;
            data.sddegz = sddegz;
            data.degppm = degppm;
            data.sddegp = sddegp;
            data.dkntmn = dkntmn;  
            data.nsimul = nsimul;  
            data.ppmend = ppmend;
            data.ppmst = ppmst;
            data.lcm_print = lcm_print;
            data.basis_idx = basis_idx;
        else
            data = load(lcm_data_file);
            if isfield(data, 'sptype')
                data = rmfield(data, 'sptype');
            end
            if isfield(data, 'basis_idx')
                basis_idx = data.basis_idx;
            else
                data.basis_idx = basis_idx;
            end
            if ~isfield(data, 'degzer')
                data.degzer = degzer;
            end
            if ~isfield(data, 'sddegz')
                data.sddegz = sddegz;
            end
            if ~isfield(data, 'dkntmn')
                data.dkntmn = dkntmn;
            end
            if ~isfield(data, 'nsimul')
                data.nsimul = nsimul;
            end
            if ~isfield(data, 'degppm')
                data.degppm = degppm;
            end
            if ~isfield(data, 'sddegp')
                data.sddegp = sddegp;
            end
            if ~isfield(data, 'ppmend')
                data.ppmend = ppmend;
            end
            if ~isfield(data, 'ppmst')
                data.ppmst = ppmst;
            end
            data.lcm_print = lcm_print;
        end
        save(lcm_data_file, '-struct', 'data');
        if exist([spec_struct.spec_path filesep 'lcm'], 'dir')
            answer = questdlg('LCModel processing was already done. Would you like to run it again?', 'Question:', 'Yes', 'No', 'No');
            switch answer
                case 'Yes'
                    lcmDir = fullfile(spec_struct.spec_path, 'lcm');
                    pdfDir = fullfile(spec_struct.spec_path, ['lcm' filesep 'lcm_pdf']);
                    pngDir = fullfile(spec_struct.spec_path, ['lcm' filesep 'lcm_png']);
                    
                    fclose all;
                    if exist(pdfDir, 'dir')
                        rmdir(pdfDir, 's');
                    end
                    if exist(pngDir, 'dir')
                        rmdir(pngDir, 's');
                    end
                    if exist(lcmDir, 'dir')
                        rmdir(lcmDir, 's');
                    end
                case 'No'
                    return
            end
        end
        if ~isempty(spec_file)
            raw_name = pst_make_raw_file(spec_struct, false);
        end
        if ~isempty(water_file)
            raw_name_water = pst_make_raw_file(spec_struct, true);
        else
            raw_name_water = '';
        end
        sel_names = {};
        sel_names_struct = struct;
        if ~is_sv
            [ij, sel_names] = read_sel_file(sel_file);
            if isempty(ij)
                errordlg('Please select voxels for LCModel analysis first!');
                fprintf('%s\n\n', 'Analysis cancelled!');
                return
            end
            for ind = 1:size(ij, 1)
                i = ij(ind, 1);
                j = ij(ind, 2);
                lcm_i = i;
                lcm_j = spec_struct.nYvoxels - j + 1;
                sel_names_struct.(['vox' num2str(lcm_i) '_' num2str(lcm_j)]) = sel_names{ind}; 
            end
        else
            ij = [1 1];
            sel_names{1} = 'SV';
            sel_names_struct.('vox1_1') = 'SV';
        end

        basis_set = data.basis_set;

        if ispc
            % Windows part starts here
    
            if ~exist('LCModel\LCModel.exe', 'file')
                disp('LCModel executable "LCModel\LCModel.exe" not found!')
                disp('Extracting it from the LCModel\LCModel_executable.zip...')
                try
                    unzip("LCModel\LCModel_executable.zip","LCModel\");
                catch e
                    disp("A problem occured when extracting the LCModel_executable.zip archive!")
                    disp("Please put the LCModel.exe file in the LCModel folder!")
                    return
                end
                disp('LCModel.exe extracted!')
            end
            
            fprintf('%s', 'Creating control files and running LCModel analysis...');
            tic
            indices = 1:size(ij,1);
            if use_parfor && ~is_sv
                parfor ind = indices
                    pst_process_lcm_voxel(ij, ind, spec_struct, basis_set, sel_names{ind}, raw_name, raw_name_water, lcm_data_file);
                end
            else
                for ind = indices
                    pst_process_lcm_voxel(ij, ind, spec_struct, basis_set, sel_names{ind}, raw_name, raw_name_water, lcm_data_file);
                end
            end
            lcm_time = toc;
            fprintf('%s%.0f%s\n', 'finished in ', lcm_time, ' seconds!');
            cd(defdir)
            if ~is_sv
                lcm_nr = lcm_nr + 1;
            end
            if lcm_time < 2
                fprintf('%s\n', 'LCModel analysis complete!');
                fprintf('%s\n', 'WARNING! Low elapsed time! Please check the lcm folder.');
            else
                fprintf('%s\n', 'LCModel analysis complete!');
            end

            % Windows part ends here

        elseif isunix
         
             % to be added
        % 
        %     % Linux part starts here
        %     for ind = 1:size(ij, 1)
        %         i = ij(ind, 1);
        %         j = ij(ind, 2);
        %         lcm_i = i;
        %         lcm_j = spec_struct.nYvoxels - j + 1;
        %         ctrl_name = pst_make_ctrl_file(defdir, spec_file, basis_file, lcm_i, lcm_j, sel_names{ind}, raw_name, raw_name_water, lcm_data_file);
        %         ctrl_cell{ind} = ctrl_name;
        %         if ~isempty(ctrl_name)
        %             lcm_cmd = sprintf('%s %s', '$HOME/.lcmodel/bin/lcmodel <', ctrl_cell{ind});
        %             cmd_cell{ind} = lcm_cmd;
        %         else
        %             errordlg('LCModel analysis cancelled!');
        %             return
        %         end
        %     end
        %     cd(curdir)
        %     if exist('cmd_file.txt', 'file')
        %         delete('cmd_file.txt');
        %     end
        %     fid_cmd_file = fopen('cmd_file.txt','w');
        %     fprintf(fid_cmd_file,'%s\n', cmd_cell{:});
        %     fclose(fid_cmd_file);
        %     cmd = sprintf('%s%s%s', './lcm_run.sh ', curdir, 'cmd_file.txt');
        %     cd(defdir)
        %     fprintf('%s\n', 'Running analysis, parallel computing is ON...');
        %     system(cmd);
        %     cd(defdir);
        %     if ~is_sv
        %         lcm_nr = lcm_nr + 1;
        %     end
        %     fprintf('%s\n', '______________________________________________________');
        % 
        %     % Linux part ends here
        % 
        end
        lcmodel_processed = true;
    else
        errordlg('Please select voxels to be analysed with LCModel!');
    end
    fclose('all');

    % convert ps files to pdf
    % 1) copy ps2pdf converter to the lcm folder
    % 2) copy all ps files to the files folder of the ps2pdf converter
    % 3) run converter
    % 4) copy pdf to lcm_pdf

    disp('Converting PS to PDF...')
    copyfile([defdir filesep 'third_party' filesep 'ps2pdf'], [curdir 'lcm' filesep 'ps2pdf'])
    copyfile(fullfile([curdir 'lcm'], '*.ps'), [curdir 'lcm' filesep 'ps2pdf' filesep 'files']);
    cd([curdir 'lcm' filesep 'ps2pdf']);
    [status, cmdout] = system('convert.bat > NUL 2>&1');
    if status ~= 0
        disp('Conversion to PDF failed:')
        disp(cmdout)
        cd(defdir)
        return
    end

    copyfile([curdir 'lcm' filesep 'ps2pdf' filesep 'files'], [curdir 'lcm_pdf']);
    cd('..'); %go to lcm
    rmdir('ps2pdf', 's');
    cd(defdir)

    fprintf('%s\n', 'PS files converted to PDF (lcm_pdf folder)');
    fprintf('%s\n', '_________________________________________________');

    set(hLCM_btn, 'Enable', 'on');
    set(hLCM_btn, 'String', 'LCModel');
    setGroupVisibility(hTABLE, 'On')
    
    set(anno, 'Visible', 'on'); 

end

function process_composition(~, ~)

    % this function processes the T1-segmentation and qMRI values in the selected voxels. 
    % It creates the masks and applies them to the maps
    
    set(hProcSel_btn, 'Enable', 'off', 'String', 'Processing...');
    pause(0.01);

    if ~is_sv
        fprintf('\n%s', 'Processing the tissue composition of the selected voxels')
    else
        fprintf('\n%s', 'Processing the tissue composition of the single voxel')
    end

    if ~is_sv
        % make a loop over selection, save selection names if not saved at LCModel step
        sel_names = {}; %refresh if the new selection was done after processing
        sel_names_struct = struct;
        [ij, sel_names] = read_sel_file(sel_file);
        for ind = 1:size(ij, 1)
            i = ij(ind, 1);
            j = ij(ind, 2);
            lcm_i = i;
            lcm_j = spec_struct.nYvoxels - j + 1;
            sel_names_struct.(['vox' num2str(lcm_i) '_' num2str(lcm_j)]) = sel_names{ind};
        end
    else
        sel_names_struct.('vox1_1') = 'SV';
    end

    for i=1:length(ppmShifts_with_0)
        
        shift_val_str = pst_get_shift_value_string(ppmShifts_with_0(i));

        % prepare the folder for individual results
        voxel_results_folders.(['folder_' shift_val_str]) = [spec_struct.spec_path, filesep 'voxel_results' filesep 'voxel_results_' num2str(ppmShifts_with_0(i))];
        if ~exist(voxel_results_folders.(['folder_' shift_val_str]), 'dir')
            mkdir(voxel_results_folders.(['folder_' shift_val_str]));
        end

        if ~is_sv

            curr_shift_image_slab_filename = spec_struct.(['shifted_' shift_val_str]).image_slab_filename;
            outdir = fileparts(curr_shift_image_slab_filename);

            vol_curr_shift_image_slab = spm_vol(curr_shift_image_slab_filename);
            img = spm_read_vols(vol_curr_shift_image_slab);
            
            N_sel_vox = size(ij, 1);
            seg_tmp = false(N_sel_vox,1); % tmps were made for parfor over ppmShifts. But they were buggy, and hence, deprecated.
            param_tmp = false(N_sel_vox,1);
            vox_ids{i} = cell(N_sel_vox,1);
            
            fprintf('\nDelta chemical shift = %.2f ppm:\n', ppmShifts_with_0(i))
            reverseStr = '';
            for k = 1:N_sel_vox
                msg = sprintf('Processing voxel %d/%d', k, size(ij, 1));
                fprintf([reverseStr msg]);
                reverseStr = repmat(sprintf('\b'), 1, numel(msg));
                
                % find ranges where the current MRSI voxel belongs
                sel_lr_edge1 = spec_struct.nXvoxels - ij(k, 1);
                sel_lr_edge2 = spec_struct.nXvoxels - ij(k, 1) + 1;
                sel_ap_edge1 = ij(k, 2) - 1;
                sel_ap_edge2 = ij(k, 2);

                local_ap_edge1 = round(sel_ap_edge1 * spec_struct.geometry.vox_sz(2) / spec_struct.geometry.ref_vox_sz(2));
                local_ap_edge2 = round(sel_ap_edge2 * spec_struct.geometry.vox_sz(2) / spec_struct.geometry.ref_vox_sz(2));
                local_lr_edge1 = round(sel_lr_edge1 * spec_struct.geometry.vox_sz(1) / spec_struct.geometry.ref_vox_sz(1));
                local_lr_edge2 = round(sel_lr_edge2 * spec_struct.geometry.vox_sz(1) / spec_struct.geometry.ref_vox_sz(1));       

                % create the mask of the individual MRSI voxel
                mask = zeros(size(img));
                mask(local_lr_edge1:local_lr_edge2, local_ap_edge1:local_ap_edge2, :) = 1;
                curr_mask = vol_curr_shift_image_slab;
                
                % unify the voxel mask name with LCModel name. 
                % Remember that in LCModel we have row-col and not col-row:
                % e.g. LCModel 17-27 voxel is 27-17.
                % BUT at the make_table stage LCModel 17-27 will also turn into 27-17.
                vox_ids{i}{k} = [spec_struct.nXvoxels-sel_lr_edge1 spec_struct.nYvoxels-sel_ap_edge1];

                curr_mask.fname = fullfile(outdir, sprintf('%d_%d.nii', vox_ids{i}{k}(1), vox_ids{i}{k}(2)));
                spm_write_vol(curr_mask, mask);

                % apply the mask to get segmentation and qMRI values
                [segmentation_analyzed_tmp, parametric_analyzed_tmp] = pst_segm(curr_mask.fname, voxel_results_folders, quantitative_slabs_only_VOI{i}, analyze_segm, qMRI_names, ppmShifts_with_0(i));
                seg_tmp(k) = segmentation_analyzed_tmp;
                param_tmp(k) = parametric_analyzed_tmp;
            end

            segmentation_analyzed = any(seg_tmp);
            parametric_analyzed = any(param_tmp);

            % Read the results into selected voxel substructs
            spec_struct = pst_combine_voxel_jsons(spec_struct, voxel_results_folders, shift_val_str, vox_ids{i});
    
        else
            one_spec = spec_struct;
            curr_mask.fname = one_spec.(['shifted_' shift_val_str]).VOI_mask_filename;
            [segmentation_analyzed, parametric_analyzed] = pst_segm(curr_mask.fname, voxel_results_folders, resliced_quantitative_files, analyze_segm, qMRI_names, ppmShifts_with_0(i));
            spec_struct = pst_combine_voxel_jsons(spec_struct, voxel_results_folders, shift_val_str, 'SV');
            parametric_json_name = strcat(voxel_results_folders.(['folder_' shift_val_str]), filesep, one_spec.voxID, '.json');
            spec_struct.voxel_results.(['voxresults_' shift_val_str]).('vox1_1') = readstruct(parametric_json_name);
        end
    end
    fprintf('\nVoxel composition analysis finished!\n');
    
    set(hProcSel_btn, 'Enable', 'on', 'String', 'Process composition');

    setGroupVisibility(hTABLE, 'On')
end

%% Make Table functions 
function table_browse(~, ~)

    cd(curdir);
    dir_name = uigetdir('', 'Select directory for saving the results table');
    if ~isequal(dir_name, 0)
        set(hTabledir_edit, 'String', dir_name);
        table_dir = dir_name;
        if isempty(get(hTablename_edit, 'String'))
            table_name = 'table';
            set(hTablename_edit, 'String', 'table');
        end
    end
end

function make_table(~, ~)
    
    if isempty(table_dir) && (~isempty(spec_file) || ~isempty(met_file))
        table_browse;
        if isempty(table_dir)
            return
        end
    end
    table_file = fullfile(table_dir, table_name);

    cd(defdir)
    lcmodel_new_fields = [];
    if lcmodel_processed % todo: send inside make table function
        
        % combine .table files from LCModel to spec_struct.voxel_results.lcmodel
        if ~is_sv
            [ij, ~] = read_sel_file(sel_file);
            spec_struct = pst_combine_lcm_tables(spec_struct, spec_file, ij);
        else
            try 
                lcm_sv_dir = dir(fullfile(fileparts(spec_file), 'lcm', 'SV_*.table'));
                lcm_sv_table_file = [lcm_sv_dir.folder filesep lcm_sv_dir.name];
                dataStruct = pst_io_readlcmtab(lcm_sv_table_file);
                spec_struct.voxel_results.lcmodel.('vox1_1') = dataStruct; % save the file content to spec_struct
            catch
                fprintf('%s %s%s\n', 'ERROR: Could not read the LCModel result .table file', lcm_sv_dir.name, '!')
                spec_struct.voxel_results.lcmodel.('vox1_1') = [];
            end
        end
        tmp = fieldnames(spec_struct.voxel_results.lcmodel);
        lcmodel_all_fields = fieldnames(spec_struct.voxel_results.lcmodel.(tmp{1}));
        lcmodel_all_fields = strrep(lcmodel_all_fields,'0x2B','+');
        lcmodel_all_fields = strrep(lcmodel_all_fields,'0x25',' %');
        lcmodel_all_fields = strrep(lcmodel_all_fields,'x0x2D','-');   
        lcmodel_all_fields = strrep(lcmodel_all_fields,'0x2F','/');  
    
        lcmodel_new_fields = choose_lcmodel_results(lcmodel_all_fields);
    
        lcmodel_new_fields = strrep(lcmodel_new_fields,'+','0x2B');
        lcmodel_new_fields = strrep(lcmodel_new_fields,' %','0x25');
        lcmodel_new_fields = strrep(lcmodel_new_fields,'-','x0x2D');   
        lcmodel_new_fields = strrep(lcmodel_new_fields,'/','0x2F');  
    end

    cd(defdir)
    if ~isempty(spec_file)
        pst_make_table(spec_struct, table_file, lcmodel_processed, segmentation_analyzed, ppmShifts_with_0, parametric_analyzed, qMRI_names, lcmodel_new_fields, sel_names_struct);
    end
    fprintf('%s\n', ' ');
    fprintf('%s\n', '___________________________');
    fprintf('%s\n\n', 'The final table is created!');
    fclose('all');
end

%% functions

function prepare_visual(delta_ppm)
    
    shift_val_str = pst_get_shift_value_string(delta_ppm);
    current_structure = spec_struct.(['shifted_' shift_val_str]);
    planscan_structure = spec_struct.('shifted_0');
      
    if ~is_sv
        image_vol = spm_vol(current_structure.image_slab_filename);
        if spec_struct.geometry.exist_VOI 
            mask_vol = spm_vol(current_structure.slab_VOI_mask_filename);
            mask_vol_0 = spm_vol(planscan_structure.slab_VOI_mask_filename);
        end
    else
        image_vol = spm_vol(ref_file);
        mask_vol = spm_vol(current_structure.VOI_mask_filename);
        mask_vol_0 = spm_vol(planscan_structure.VOI_mask_filename);
    end
    
    current_structure.image = spm_read_vols(image_vol);
    
    if spec_struct.geometry.exist_VOI 

        current_structure.mask = spm_read_vols(mask_vol);
        planscan_structure.mask = spm_read_vols(mask_vol_0);

        % find the intersection of the Planscan mask and the current_image, save it as Orange so that it's used later in draw_VOI:
        current_orange_filename = [ref_file(1:end-4) '_orange.nii'];
        imcalc_input_images = [ mask_vol_0 image_vol ];
        spm_imcalc_cmd = "spm_imcalc( imcalc_input_images, current_orange_filename, '(i1 .* i2 > 0)', struct('dtype', 16))";
        evalc(spm_imcalc_cmd);
        current_orange_vol = spm_vol(current_orange_filename);
        current_orange = spm_read_vols(current_orange_vol);
        current_structure.orange = permute(current_orange, [2 1 3]);
        delete(current_orange_filename);
    
        % find the intersection of the shifted mask and the planscan image, save it as White 
        current_white_filename = [ref_file(1:end-4) '_white.nii'];
        imcalc_input_images = [ mask_vol image_vol ];
        spm_imcalc_cmd = "spm_imcalc( imcalc_input_images, current_white_filename, '(i1 .* i2 > 0)', struct('dtype', 16))";
        evalc(spm_imcalc_cmd);
        current_white_vol = spm_vol(current_white_filename);
        current_white = spm_read_vols(current_white_vol);
        current_structure.white = permute(current_white, [2 1 3]);
        delete(current_white_filename);
    end

    slices_idx = 1;
    for i = 1:size(current_structure.image, 3)
        imgi = current_structure.image(:,:,i);
        imgi = imgi';
        current_structure.img_gr(:,:,slices_idx) = imgi;
        slices_idx = slices_idx + 1;
    end
 
    spec_struct.(['shifted_' shift_val_str]) = current_structure;

    [~,~,d3] = size(current_structure.img_gr);
    max_val = d3;
    
    if ~is_sv
        idx = floor(d3/2) + 1;
    else
        nonzero_coords = find(squeeze(any(any(planscan_structure.mask,1),2)));
        idx = floor((nonzero_coords(end) + nonzero_coords(1))/2) + 1;
    end

    sl_value = idx;

    if max_val > 1
        set(hSliceSlider, 'Min', 1, 'Max', max_val, 'SliderStep', [1/(max_val-1) 1/(max_val-1)], 'Value', sl_value, 'Visible', 'on');
    else
        set(hSliceSlider, 'Visible', 'off');
    end
end

function visual_out(delta_ppm)
    
    shift_val_str = pst_get_shift_value_string(delta_ppm);
    current_structure = spec_struct.(['shifted_' shift_val_str]);
    img_gr = current_structure.img_gr;

    cur_sl = img_gr(:,:,idx);
    scaling_factor = max(max(cur_sl))/256;
    out_sl = cur_sl./scaling_factor;
    out_sl = out_sl * bright_factor;
    colormap(gray);
    image(hAxes, out_sl);

    hAxes.XColor = 'none';
    hAxes.YColor = 'none';
    hAxes.XTick  = [];
    hAxes.YTick  = [];
    posit = get(hf,'Position');
    set(hAxes, 'Units', 'normalized', 'Position', [0.26 0.17 0.25*magn_factor*width_factor 0.45*magn_factor], 'Visible', 'on');

    if ~is_sv 
        draw_FOV(spec_struct.geometry);
        draw_VOI(delta_ppm);
        draw_selection(spec_struct.geometry);
    else
        draw_VOI(delta_ppm);
    end

    lcm_nr = 1;
    set(hSliceSlider_text, 'String', ['slice' num2str(idx)]);
    set(hImageName_edit, 'String', ['slice' num2str(idx)]);
    image_name = ['slice' num2str(idx)];
end

function mouse_click(~, ~)

    % get the clicked point
    cur_pt = get(hAxes, 'CurrentPoint');
    cur_x = cur_pt(1,1);
    cur_y = cur_pt(1,2);
    if ~is_sv
        if cur_x < 0 || cur_x > size(cur_sl, 2) || cur_y < 0 || cur_y > size(cur_sl, 1)
            return
        end
    end
    
    % find the corresponding ps-file
    if ~is_sv

        % calculate the corresponding spectroscopic voxel
        ylimit = ylim(hAxes);
        totalY = ylimit(2) - ylimit(1);

        xlimit = xlim(hAxes);
        totalX = xlimit(2) - xlimit(1);
        cur_x_spec = ceil((totalX - cur_x)*spec_struct.geometry.ref_vox_sz(1)/spec_struct.geometry.vox_sz(1));
        cur_y_spec = ceil((totalY - cur_y)*spec_struct.geometry.ref_vox_sz(2)/spec_struct.geometry.vox_sz(2));
        file_ptrn = sprintf('%s%d%s%d%s', '*_', cur_y_spec, '-', cur_x_spec, '.pdf');
    else
        file_ptrn = sprintf('%s%s%s', 'SV_', '*', '.pdf');
    end

    spec_path = fileparts(spec_file);
    pdf_files = dir(fullfile(spec_path, 'lcm_pdf', file_ptrn));
    delete(anno);
    if ~isempty(pdf_files)
        pdf_file = pdf_files(1).name;
        if ispc
            cd(defdir)
            input_pdf = fullfile(spec_path, 'lcm_pdf', pdf_file);
            [~, pdf_name] = fileparts(pdf_file);
            if ~isfolder([spec_path filesep 'lcm_png'])
                mkdir([spec_path filesep 'lcm_png']);
            end
            output_pattern = fullfile(spec_path, 'lcm_png', sprintf('%d_%d', cur_y_spec, cur_x_spec), [pdf_name '_page%02d.png']);
            if ~isfolder([spec_path filesep 'lcm_png' filesep sprintf('%d_%d', cur_y_spec, cur_x_spec)])
                mkdir([spec_path filesep 'lcm_png' filesep sprintf('%d_%d', cur_y_spec, cur_x_spec)]);
            end
            convert_PDF_PNG_cmd = sprintf('"third_party\\mupdf-1.27.0-windows\\mutool.exe" draw -r 150 -A 8 -o "%s" "%s"', output_pattern, input_pdf);
            [code, message] = system(convert_PDF_PNG_cmd);
            if code ~= 0
                disp(message);
                return
            end
            folder = fullfile(spec_path, 'lcm_png', sprintf('%d_%d', cur_y_spec, cur_x_spec));
            fig = ancestor(hAxes2, 'figure');
            set(hAxes2, 'Clipping', 'on')
            setupViewer(fig, hAxes2, folder);
    
            if exist('anno',"var")
                delete(anno);
            end
            anno = annotation('textbox', [0.52 0.655 0.57 0.08], 'units', 'normalized', 'String', ('Scroll PS file with mousewheel | Zoom with Ctrl + mousewheel | Pan with LMB'), 'FitBoxToText', 'on', 'FontSize', 16, 'FontWeight','normal', 'HitTest','off');

        elseif isunix
            open_cmd = sprintf('%s %s', 'evince', fullfile(spec_path, 'lcm', ps_file));
            pst_system_LD_clean(open_cmd);
        end
        
        if ~exist('hMarker','var') || isempty(hMarker) || ~isgraphics(hMarker)
            hold(hAxes,'on')
            hMarker = line(hAxes, cur_x, cur_y,'Marker','x', 'Color','r', 'LineStyle','none', 'LineWidth',1, 'MarkerSize',10);
            hold(hAxes,'off')
        else
            set(hMarker, 'XData', cur_x, 'YData', cur_y);
        end

        spectra_pts = [spectra_pts; cur_x cur_y];
    else

        anno = annotation('textbox', [0.52 0.655 0.70 0.08], 'units', 'normalized', 'String', ('This voxel was not processed in LCModel'), 'FitBoxToText', 'on', 'FontSize', 20, 'FontWeight','normal', 'HitTest','off');
    end
    
    
    function setupViewer(fig, ax, folder)
    
        files = dir(fullfile(folder,'*.png'));
        [~, index] = sort({files.name});
        files = files(index);
        
        viewer.files = files;
        viewer.folder = folder;
        viewer.page = 1;
        viewer.zoom = 1;
        viewer.xOffset = 0;
        viewer.yOffset = 0;
        viewer.dragging = false;
        viewer.dragStart = [];
        viewer.hAxes = ax;
        guidata(fig, viewer);
        viewer.idx = 1;
        set(ax, 'Units', 'normalized', 'Position', [0.52 0.00 0.47 0.74]);
        guidata(fig, viewer);
        showPage(fig);
        drawnow;
    
        % callbacks
        fig.WindowScrollWheelFcn  = @(src,evt) wheelCallback(src,evt);
        fig.WindowButtonDownFcn   = @(src,evt) mouseDown(src);
        fig.WindowButtonUpFcn     = @(src,evt) mouseUp(src);
        fig.WindowButtonMotionFcn = @(src,evt) mouseMove(src);
        
        render(fig);
    end
    
    function factor = get_resolution_rescaling_factor(hFig) % without this function, the resolution of the image is not optimized to the resolution of the display. I found the factor empirically. 
    
        figSize = get(hFig,'Position');
        W = figSize(3);
        
        factor = W/1920*0.6;
    
    end

    function render(fig)
    
        viewer = guidata(fig);
        img = imread(fullfile(viewer.folder, viewer.files(viewer.page).name));
        [h,w,~] = size(img);
        img = img( round(0.10*h):round(0.96*h), round(0.04*w):round(0.97*w), :);
        resolution_rescaling_factor = get_resolution_rescaling_factor(hf);
        img = imresize(img, resolution_rescaling_factor);       
        ax = viewer.hAxes;
        cla(ax,'reset')
        imshow(img, 'Parent', ax, 'InitialMagnification','fit')
        axis(ax,'image')
        axis(ax,'off')
        set(ax,'YDir','reverse')
        [viewer.h, viewer.w, ~] = size(img);
        viewer.xOffset = 0;
        viewer.yOffset = 0;
        viewer.zoom = max(viewer.zoom, 1);
        guidata(fig, viewer);
        applyView(fig);
        drawnow;
    end
    
    function applyView(fig)
    
        viewer = guidata(fig);
        ax = viewer.hAxes;
        w = viewer.w;
        h = viewer.h;
        cx = w/2;
        cy = h/2;
        halfW = w/(2*viewer.zoom);
        halfH = h/(2*viewer.zoom);
        xlim(ax, [cx-halfW cx+halfW] + viewer.xOffset)
        ylim(ax, [cy-halfH cy+halfH] + viewer.yOffset)
        set(ax,'YDir','reverse')
    end
    
    function mouseDown(fig)
    
        viewer = guidata(fig);
        cp = get(viewer.hAxes,'CurrentPoint');
        viewer.dragging = true;
        viewer.dragStart = cp(1,1:2);
        guidata(fig, viewer);
    end
    
    function mouseMove(fig)
    
        viewer = guidata(fig);
        if ~viewer.dragging
            return
        end
        cp = get(viewer.hAxes,'CurrentPoint');
        cp = cp(1,1:2);
        delta = viewer.dragStart - cp;
        viewer.xOffset = viewer.xOffset + delta(1);
        viewer.yOffset = viewer.yOffset + delta(2);
        viewer.dragStart = cp;
        guidata(fig, viewer);
        applyView(fig);   
    end
    
    
    function mouseUp(fig)
    
        viewer = guidata(fig);
        viewer.dragging = false;
        guidata(fig, viewer);
    end
    
    function wheelCallback(fig, evt)
    
        viewer = guidata(fig);
        ctrl = ismember('control', get(fig,'CurrentModifier'));
        if ctrl
            factor = 1.1;
            if evt.VerticalScrollCount > 0
                viewer.zoom = viewer.zoom / factor;
            else
                viewer.zoom = viewer.zoom * factor;
            end
            viewer.zoom = max(0.5, min(10, viewer.zoom));
        else
            viewer.page = viewer.page + evt.VerticalScrollCount;
            viewer.page = max(1, min(numel(viewer.files), viewer.page));
            viewer.zoom = 1;
            viewer.xOffset = 0;
            viewer.yOffset = 0;
        end
        guidata(fig, viewer);
        render(fig);
    end
    
    
    function showPage(fig)
    
        viewer = guidata(fig);
        file = fullfile(viewer.folder, viewer.files(viewer.idx).name);
        img = imread(file);
        cla(viewer.hAxes,'reset')

        imshow(img, 'Parent', viewer.hAxes, 'InitialMagnification', 'fit');
    
        axis(viewer.hAxes,'image')
        axis(viewer.hAxes,'off')
    
        xlim(viewer.hAxes, [1 size(img,2)])
        ylim(viewer.hAxes, [1 size(img,1)])
    
        set(viewer.hAxes, 'YDir', 'reverse')
    
        drawnow
    end
    
end

function show_appropriate_CSDE_parameters(~,~)

    setGroupVisibility(hCSDE, 'on')
    if isequal(Manufacturer, 'Philips')
        setGroupVisibility(hCSDE_Philips, 'on')
    elseif isequal(Manufacturer, 'Siemens')
        setGroupVisibility(hCSDE_Siemens, 'on')
    end
end

function setGroupVisibility(hGroup, visibleFlag)

    fields = fieldnames(hGroup);
    for k = 1:length(fields)
        if isgraphics(hGroup.(fields{k}))
            set(hGroup.(fields{k}), 'Visible', visibleFlag);
        end
    end

    if isfield(hGroup, 'shiftDirFH')
        if ~is_sv
            set(hFH_btn, 'Enable', 'off');
        else
            set(hFH_btn, 'Enable', 'on');
        end
    end

    if isfield(hGroup, 'RFOV_dir_btn')
        if ~is_sv
            set(hRFOV_dir_btn, 'Enable', 'on');
        else
            set(hRFOV_dir_btn, 'Enable', 'off');
        end
    end

end

function [ij, region] = read_sel_file(sel_file)

    ij = [];
    region = {};
    fid = fopen(sel_file);
    if fid == -1
        return
    end
    sel_data = textscan(fid, '%d%d%s', 'delimiter', '\t', 'CollectOutput', 1, 'HeaderLines', 1);
    ij = sel_data{1};
    region = sel_data{2};
    fclose(fid);
end

function draw_FOV(geometry)
    
    hr2 = rectangle('Parent', hAxes, 'Position', [0.5 0.5 floor(geometry.FOV_size(1)/geometry.ref_vox_sz(1))+0.5 floor(geometry.FOV_size(2)/geometry.ref_vox_sz(2))+0.5], 'LineWidth', 0.5, 'EdgeColor', 'y');
    
    if lcm_spec
        set(hr2, 'ButtonDownFcn', @mouse_click);
    end
    for j = 1:spec_struct.nXvoxels-1
        x = (0.5+geometry.vox_sz(1)*j)/geometry.ref_vox_sz(1);
        line(hAxes, [x x], [0 (geometry.FOV_size(2))/geometry.ref_vox_sz(2)], 'Color', [0.3059 0.5804 0.2941]);
    end
    for i = 1:spec_struct.nYvoxels-1
        y = (0.5+geometry.vox_sz(2)*i)/geometry.ref_vox_sz(2);
        line(hAxes, [0 geometry.FOV_size(1)/geometry.ref_vox_sz(1)], [y y], 'Color', [0.3059 0.5804 0.2941]);
    end
    
    if lcm_spec
       set([hAxes; get(hAxes, 'Children')], 'ButtonDownFcn', @mouse_click);
    end

end

function draw_VOI(ppmShift)

    shift_val_str = pst_get_shift_value_string(ppmShift);
    current_structure = spec_struct.(['shifted_' shift_val_str]);

    % plot VOI contour
    if spec_struct.geometry.exist_VOI
        warning off
        hold (hAxes, 'on')
        contour('Parent', hAxes, current_structure.orange(:,:,idx) > 0, [0.5 0.5], 'color', '#FF8C00', 'LineWidth', 2);
            if ~ppmShift == 0
                contour('Parent', hAxes, current_structure.white(:,:,idx) > 0, [0.5 0.5], 'color', 'w', 'LineWidth', 2);
            end
        hold (hAxes, 'off')
        warning on
    else
        return
    end
end

function draw_selection(geometry)

    colors = [
        0.0, 1.0, 1.0;    % Bright Cyan
        1.0, 0.5, 0.0;    % Bright Orange
        1.0, 1.0, 0.0;    % Bright Yellow
        0.5, 1.0, 0.0;    % Bright Chartreuse
        0.0, 1.0, 0.0;    % Bright Lime
        0.75, 0.0, 1.0;   % Bright Violet
        0.0, 1.0, 0.5;    % Bright Spring Green
        0.0, 0.5, 1.0;    % Bright Dodger Blue
        0.0, 0.0, 1.0;    % Bright Blue
        0.5, 0.0, 1.0;    % Bright Purple
        1.0, 0.0, 1.0;    % Bright Magenta
        1.0, 0.0, 0.5;    % Bright Rose
        1.0, 0.75, 0.0;   % Bright Amber
        1.0, 0.0, 0.75;   % Bright Pink
        0.0, 0.75, 1.0;   % Bright Sky Blue
        1.0, 0.5, 0.5;    % Bright Light Coral
        0.75, 1.0, 0.0;   % Bright Lemon Lime
        0.0, 0.75, 0.75;  % Bright Teal
        ];
    
    if ~isempty(cur_sel)
        for i = 1:spec_struct.nXvoxels
            for j = 1:spec_struct.nYvoxels
                if cur_sel(j,i) > 0
                    color = colors(cur_sel(j,i), :);
                    x_start = (i-1) * geometry.vox_sz(1)/geometry.ref_vox_sz(1);
                    y_start = (j-1) * geometry.vox_sz(2)/geometry.ref_vox_sz(2);
                    rectangle('Parent', hAxes, 'Position', [x_start+0.5 y_start+0.5 geometry.vox_sz(1)/geometry.ref_vox_sz(1) geometry.vox_sz(2)/geometry.ref_vox_sz(2)], 'LineWidth', 0.1, 'EdgeColor', color);
                end
            end
        end
    end
end

function save_image

    F = getframe(hAxes);
    image_folder = [curdir 'images' filesep ['delta_ppmShift_' num2str(curr_ppmShift)]];
    if ~exist(image_folder, "dir")
        mkdir(image_folder)
    end
    image_ext = '.bmp';
    imwrite(F.cdata, fullfile(image_folder, [image_name image_ext]));
    disp('Image saved')
end

function new_fields = choose_lcmodel_results(all_fields)

    fields_to_choose_from = all_fields(7:2:end);

    dlg = dialog('Position',[500 200 200 800], 'Name','Select processed metabolites');
    listbox = uicontrol('Parent', dlg, 'Style', 'listbox', 'Units', 'normalized', 'Position', [0.1 0.2 0.8 0.75], 'String', fields_to_choose_from, 'Max', 2, 'Min', 0);
    uicontrol('Parent', dlg, 'Units', 'normalized', 'Position', [0.25 0.05 0.1 0.1], 'String', 'OK', 'Callback', @ok_callback);
    uicontrol('Parent', dlg, 'Units', 'normalized', 'Position', [0.55 0.05 0.1 0.1], 'String', 'Cancel', 'Callback', 'delete(gcf)');
    uiwait(dlg);

    function ok_callback(~, ~)
        selected_idx = 2 * listbox.Value;
        selected_idx_with_SD = [6 + selected_idx - 1; 6 + selected_idx]; % in addition to the metabolite select its SD
        selected_idx_with_SD = [3:6, selected_idx_with_SD(:).']; % force select SNR, FWHM and Ph_shift 
        new_fields = all_fields(selected_idx_with_SD);
        delete(dlg);
    end
end

function enable_buttons
    
    set(hLoad_btn, 'String', 'Load Data', 'Enable', 'on');
    if isequal(get(hPROC_CSDE_btn, 'Visible'), 'on')
        set(hPROC_CSDE_btn, 'String', 'Process CSDE', 'Enable', 'on')
    end
    
    if isequal(get(hLCM_btn, 'Visible'), 'on')
        set(hLCM_btn, 'String', 'LCModel', 'Enable', 'on')
    end
    
    if isequal(get(hProcSel_btn, 'Visible'), 'on') && ~isempty(resliced_quantitative_files)
        set(hProcSel_btn, 'String', 'Process composition', 'Enable', 'on')
    end

end

end
