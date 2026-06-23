function pst_lcm_param(lcm_def_file, lcm_data_file, degzer, sddegz, degppm, sddegp, dkntmn, neach, nsimul, VITRO)

%  Initialization tasks
% if ~exist('degzer_in', 'var') || isempty(degzer_in)
%     degzer = 164;
% else
%     degzer = degzer_in;
% end
% if ~exist('sddegz_in', 'var') || isempty(sddegz_in)
%     sddegz = 10;
% else
%     sddegz = sddegz_in;
% end
% if ~exist('degppm_in', 'var') || isempty(degppm_in)
%     degppm = 0;
% else
%     degppm = degppm_in;
% end
% if ~exist('sddegp_in', 'var') || isempty(sddegp_in)
%     sddegp = 1;
% else
%     sddegp = sddegp_in;
% end

% sddegp_in = sddegp;
% degppm_in = degppm;
% sddegz_in = sddegz;
% degzer_in = degzer;
degzer_str = num2str(degzer);
sddegz_str = num2str(sddegz);
degppm_str = num2str(degppm);
sddegp_str = num2str(sddegp);
dkntmn_str = num2str(dkntmn);
neach_str = num2str(neach);
nsimul_str = num2str(nsimul);
save_def = false;
% Initialize VITRO 
%  Initialize and hide the GUI as it is being constructed
hf = figure('Visible', 'off', 'Position', [500 480 280 320], 'Name', ...
    'LCModel Parameters', 'MenuBar', 'none', 'NumberTitle', 'off');
defaultBackground = get(0, 'defaultUicontrolBackgroundColor');
set(hf, 'Color', defaultBackground);

%  Construct the components
% TODO: Add 'Set as default'-button to save the default values in a
% permanant file in defdir (path as input) v

hneach_text = uicontrol(hf, 'Style', 'text', 'String', 'NEACH: ', ...
    'Position', [50 290 70 20], 'HorizontalAlignment', 'left');
hneach_edit = uicontrol(hf, 'Style', 'edit', 'HorizontalAlignment', 'right', ...
    'Position', [110 295 70 20], 'String', neach_str);
hdegzer_text = uicontrol(hf, 'Style', 'text', 'String', 'DEGZER:', ...
    'Position', [50 260 70 20], 'HorizontalAlignment', 'left');
hdegzer_edit = uicontrol(hf, 'Style', 'edit', 'HorizontalAlignment', 'right', ...
    'Position', [110 265 70 20], 'String', degzer_str);
hsddegz_text = uicontrol(hf, 'Style', 'text', 'String', 'SDDEGZ:', ...
    'Position', [50 230 70 20], 'HorizontalAlignment', 'left');
hsddegz_edit = uicontrol(hf, 'Style', 'edit', 'HorizontalAlignment', 'right', ...
    'Position', [110 235 70 20], 'String', sddegz_str);
hdegppm_text = uicontrol(hf, 'Style', 'text', 'String', 'DEGPPM:', ...
    'Position', [50 200 70 20], 'HorizontalAlignment', 'left');
hdegppm_edit = uicontrol(hf, 'Style', 'edit', 'HorizontalAlignment', 'right', ...
    'Position', [110 205 70 20], 'String', degppm_str);
hsddegp_text = uicontrol(hf, 'Style', 'text', 'String', 'SDDEGP:', ...
   'Position', [50 170 70 20], 'HorizontalAlignment', 'left');
hsddegp_edit = uicontrol(hf, 'Style', 'edit', 'HorizontalAlignment', 'right', ...
    'Position', [110 175 70 20], 'String', sddegp_str);
hdkntmn_text = uicontrol(hf, 'Style', 'text', 'String', 'DKNTMN: ', ...
   'Position', [50 140 70 20], 'HorizontalAlignment', 'left');
hdkntmn_edit = uicontrol(hf, 'Style', 'edit', 'HorizontalAlignment', 'right', ...
    'Position', [110 145 70 20], 'String', dkntmn_str);
hnsimul_text = uicontrol(hf, 'Style', 'text', 'String', 'NSIMUL: ', ...
   'Position', [50 110 70 20], 'HorizontalAlignment', 'left');
hnsimul_edit = uicontrol(hf, 'Style', 'edit', 'HorizontalAlignment', 'right', ...
    'Position', [110 115 70 20], 'String', nsimul_str);
%VITRO
hvitro_text = uicontrol(hf, 'Style', 'text', 'String', 'VITRO:', ...
    'Position', [50 80 70 20], 'HorizontalAlignment', 'left');
hvitro_popup = uicontrol(hf, 'Style', 'popupmenu', 'String', {'F', 'T'}, ...
    'Position', [110 85 70 20], 'Value', 1, ...  % Default 'F' selected
    'Callback', @vitro_popup_callback);

hradio_btn = uicontrol(hf, 'Style', 'radiobutton', 'String', ...
    'Save as default', 'Value', 0, 'Position', [10 50 200 20]);
hDef_btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'Load default', ...
    'Position', [10 10 120 30]);
hOK_btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'OK', ...
    'Position', [140 10 60 30]);
hCancel_btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'Cancel', ...
   'Position', [210 10 60 30]);

%  Initialization tasks
% Change units to normalized so components resize automatically
set([hDef_btn hOK_btn hCancel_btn hsddegp_text hsddegp_edit hdegppm_text ...
    hdegppm_edit hsddegz_text hsddegz_edit hdkntmn_text hdkntmn_edit hneach_text hneach_edit hdegzer_text ...
    hdegzer_edit hradio_btn hnsimul_text hnsimul_edit], 'Units', 'normalized' ...
    );

% Set the callbacks
set([hdkntmn_edit hsddegp_edit hdegppm_edit hsddegz_edit hdegzer_edit hnsimul_edit], 'Callback', ...
    {@edittext_callback});
set(hradio_btn, 'Callback', {@radio_btn_callback});
set(hDef_btn, 'Callback', {@def_callback});
set(hOK_btn, 'Callback', {@OK_callback});
set(hCancel_btn, 'Callback', {@cancel_callback});
set([hf hdkntmn_edit hneach_edit hsddegp_edit hdegppm_edit hsddegz_edit hdegzer_edit hnsimul_edit hradio_btn ...
    hDef_btn hOK_btn hCancel_btn], 'KeyPressFcn', {@key_press});
set(hvitro_popup, 'Callback', @vitro_popup_callback);
% Move the GUI to the center of the screen
movegui(hf, 'center');
% Make the GUI visible
set(hf, 'Visible', 'on');
uicontrol(hdegzer_edit);

%  Callbacks for LCM_PHASING
function edittext_callback(hObject, ~)
    switch hObject
        case hnsimul_edit
            nsimul_str = get(hObject, 'String');
            nsimul = str2num(nsimul_str);          
        case hdkntmn_edit
            dkntmn_str = get(hObject, 'String');
            dkntmn = str2num(dkntmn_str);                     
        case hneach_edit
            neach_str = get(hObject, 'String');
            neach = str2num(neach_str);              
        case hsddegp_edit
            sddegp_str = get(hObject, 'String');
            sddegp = str2num(sddegp_str);
        case hdegppm_edit
            degppm_str = get(hObject, 'String');
            degppm = str2num(degppm_str);
        case hsddegz_edit
            sddegz_str = get(hObject, 'String');
            sddegz = str2num(sddegz_str);
        case hdegzer_edit
            degzer_str = get(hObject, 'String');
            degzer = str2num(degzer_str);
    end
end

function vitro_popup_callback(hObject, ~)
    contents = cellstr(get(hObject, 'String'));
    VITRO = contents{get(hObject, 'Value')};
end

function radio_btn_callback(hObject, ~)
    if (get(hObject, 'Value') == get(hObject, 'Max'))
        % Radio button is selected - save the values as default
        save_def = true;
    else
        save_def = false;
    end
end

function def_callback(~, ~)
    % load default values
    warn = zeros(6, 1);
    if exist(lcm_def_file, 'file') == 2
        def_data = load(lcm_def_file);
        if isfield(def_data, 'degzer')
            degzer = def_data.degzer;
            degzer_str = num2str(degzer);
            set(hdegzer_edit, 'String', degzer_str);
            warn(1) = 1;
        end
        if isfield(def_data, 'sddegz')
            sddegz = def_data.sddegz;
            sddegz_str = num2str(sddegz);
            set(hsddegz_edit, 'String', sddegz_str);
            warn(2) = 1;
        end
        if isfield(def_data, 'degppm')
            degppm = def_data.degppm;
            degppm_str = num2str(degppm);
            set(hdegppm_edit, 'String', degppm_str);
            warn(3) = 1;
        end
        if isfield(def_data, 'sddegp')
            sddegp = def_data.sddegp;
            sddegp_str = num2str(sddegp);
            set(hsddegp_edit, 'String', sddegp_str);
            warn(4) = 1;
        end
        if isfield(def_data, 'dkntmn')
            dkntmn = def_data.dkntmn;
            dkntmn_str = num2str(dkntmn);
            set(hdkntmn_edit, 'String', dkntmn_str);
            warn(5) = 1;
        end
        if isfield(def_data, 'neach')
            neach = def_data.neach;
            neach_str = num2str(neach);
            set(hneach_edit, 'String', neach_str);
            warn(5) = 1;
        end         
        if isfield(def_data, 'nsimul')
            nsimul = def_data.nsimul;
            nsimul_str = num2str(nsimul);
            set(hnsimul_edit, 'String', nsimul_str);
            warn(6) = 1;
        end     
        if isfield(def_data, 'VITRO')
            VITRO = def_data.VITRO;
            set(hvitro_popup, 'Value', find(strcmp({'F', 'T'}, VITRO)));
        else
            VITRO = 'F';  % Default value
            set(hvitro_popup, 'Value', 1);
        end
    end
    if ~prod(warn)
        warndlg('The default values are missing!');
    end
end

function OK_callback(~, ~)
    data.degzer = degzer;
    data.sddegz = sddegz;
    data.degppm = degppm;
    data.sddegp = sddegp;
    data.dkntmn = dkntmn;
    data.neach = neach;
    data.nsimul = nsimul;
    data.VITRO = VITRO;
    if exist(lcm_data_file, 'file') ~= 2
        % make temprorary directory to save a temporary file with phasing
        % parameters
%         if exist('temp', 'dir') ~= 7
%             mkdir('temp');
%         end
        save(lcm_data_file, '-struct', 'data');
    else
        save(lcm_data_file, '-struct', 'data', '-append');
    end
    if save_def
        def_data.degzer = degzer;
        def_data.sddegz = sddegz;
        def_data.degppm = degppm;
        def_data.sddegp = sddegp;
        def_data.dkntmn = dkntmn;
        def_data.neach = neach;
        def_data.nsimul = nsimul;
        def_data.VITRO = VITRO;
        if exist(lcm_def_file, 'file') ~= 2
            save(lcm_def_file, '-struct', 'def_data');
        else
            save(lcm_def_file, '-struct', 'def_data', '-append');
        end
    end
    close;
end

function cancel_callback(~, ~)
    close;
end

function key_press(hObject, eventdata)
    key = eventdata.Key;
    if strcmpi(key, 'return')
        switch hObject
%             case hradio_btn
%                 val = get(hObject, 'Value');
%                 max = get(hObject, 'Max');
%                 min = get(hObject, 'Min');
%                 if (val == max)
%                     set(hObject, 'Value', min);
%                     save_def = false;
%                 else
%                     set(hObject, 'Value', max);
%                     save_def = true;
%                 end
            case hDef_btn
                def_callback;
            case hCancel_btn
                cancel_callback;
            otherwise
                OK_callback;
        end
    end
end
end