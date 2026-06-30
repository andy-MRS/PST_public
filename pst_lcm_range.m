function pst_lcm_range(lcm_def_file, lcm_data_file, ppmend, ppmst)

save_def = false;
ppmend_str = sprintf('%.1f', ppmend);
ppmst_str = sprintf('%.1f', ppmst);

%  Initialize and hide the GUI as it is being constructed
hf = figure('Visible', 'off', 'Position', [500 450 300 170], 'Name', 'LCModel Range', 'MenuBar', 'none', 'NumberTitle', 'off');
defaultBackground = get(0, 'defaultUicontrolBackgroundColor');
set(hf, 'Color', defaultBackground);

%  Construct the components
hprompt_text = uicontrol(hf, 'Style', 'text', 'Position', [10 140 290 20], 'String', 'Please enter LCModel ppm range parameters:', 'HorizontalAlignment', 'left');
hppmend_text = uicontrol(hf, 'Style', 'text', 'String', 'ppmend:', 'Position', [60 110 70 20], 'HorizontalAlignment', 'left');
hppmend_edit = uicontrol(hf, 'Style', 'edit', 'HorizontalAlignment', 'right', 'Position', [120 115 70 20], 'String', ppmend_str);
hppmst_text = uicontrol(hf, 'Style', 'text', 'String', 'ppmst:', 'Position', [60 80 70 20], 'HorizontalAlignment', 'left');
hppmst_edit = uicontrol(hf, 'Style', 'edit', 'HorizontalAlignment', 'right', 'Position', [120 85 70 20], 'String', ppmst_str);
hradio_btn = uicontrol(hf, 'Style', 'radiobutton', 'String', 'Save as default', 'Value', 0, 'Position', [10 50 200 20]);
hDef_btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'Load default', 'Position', [10 10 120 30]);
hOK_btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'OK', 'Position', [150 10 60 30]);
hCancel_btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'Cancel', 'Position', [230 10 60 30]);

%  Initialization tasks
% Change units to normalized so components resize automatically
set([hDef_btn hOK_btn hCancel_btn hppmst_text hppmst_edit hppmend_text hppmend_edit hprompt_text hradio_btn], 'Units', 'normalized');

% Set the callbacks
set([hppmst_edit hppmend_edit], 'Callback', {@edittext_callback});
set(hradio_btn, 'Callback', {@radio_btn_callback});
set(hDef_btn, 'Callback', {@def_callback});
set(hOK_btn, 'Callback', {@OK_callback});
set(hCancel_btn, 'Callback', {@cancel_callback});
set([hf hppmst_edit hppmend_edit hradio_btn hDef_btn hOK_btn hCancel_btn], 'KeyPressFcn', {@key_press});

% Move the GUI to the center of the screen
movegui(hf, 'center');
% Make the GUI visible
set(hf, 'Visible', 'on');
uicontrol(hppmend_edit);

%  Callbacks for LCM_RANGE
function edittext_callback(hObject, ~)
    switch hObject
        case hppmst_edit
            ppmst_str = get(hObject, 'String');
            ppmst = str2num(ppmst_str);
        case hppmend_edit
            ppmend_str = get(hObject, 'String');
            ppmend = str2num(ppmend_str);
    end
end

function radio_btn_callback(hObject, ~)
    if (get(hObject, 'Value') == get(hObject, 'Max'))
        save_def = true;
    else
        save_def = false;
    end
end

function def_callback(~, ~)
    % load default values
    warn = zeros(2, 1);
    if exist(lcm_def_file, 'file') == 2
        def_data = load(lcm_def_file);
        if isfield(def_data, 'ppmend')
            ppmend = def_data.ppmend;
            ppmend_str = sprintf('%.1f', ppmend);
            set(hppmend_edit, 'String', ppmend_str);
            warn(1) = 1;
        end
        if isfield(def_data, 'ppmst')
            ppmst = def_data.ppmst;
            ppmst_str = sprintf('%.1f', ppmst);
            set(hppmst_edit, 'String', ppmst_str);
            warn(2) = 1;
        end
    end
    if ~prod(warn)
        warndlg('The default values are missing!');
    end
end

function OK_callback(~, ~)
    data.ppmend = ppmend;
    data.ppmst = ppmst;
    if exist(lcm_data_file, 'file') ~= 2
        save(lcm_data_file, '-struct', 'data');
    else
        save(lcm_data_file, '-struct', 'data', '-append');
    end
    if save_def
        def_data.ppmend = ppmend;
        def_data.ppmst = ppmst;
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