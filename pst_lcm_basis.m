function pst_lcm_basis(lcm_def_file, lcm_data_file, basis_list, b_file_idx)

save_def = false;

%  Initialize and hide the GUI as it is being constructed
hf = figure('Visible', 'off', 'Position', [500 450 300 300], 'Name', ...
    'LCModel Basis Files', 'MenuBar', 'none', 'NumberTitle', 'off');
defaultBackground = get(0, 'defaultUicontrolBackgroundColor');
set(hf, 'Color', defaultBackground);

%  Construct the components
hprompt_text = uicontrol(hf, 'Style', 'text', 'Position', [10 270 270 20], ...
    'String', 'Please select a LCModel basis file:', 'HorizontalAlignment',...
    'left');
hbasis_list = uicontrol(hf, 'Style', 'listbox', 'String', basis_list{2}, ...
    'Position', [10 85 275 180], 'Value', b_file_idx);
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
set([hDef_btn hOK_btn hCancel_btn hprompt_text hbasis_list hradio_btn], ...
    'Units', 'normalized');

% Set the callbacks
set(hbasis_list, 'Callback', {@basislist_callback});
set(hradio_btn, 'Callback', {@radio_btn_callback});
set(hDef_btn, 'Callback', {@def_callback});
set(hOK_btn, 'Callback', {@OK_callback});
set(hCancel_btn, 'Callback', {@cancel_callback});
set([hf hDef_btn hOK_btn hCancel_btn hbasis_list hradio_btn], ...
    'KeyPressFcn', {@key_press});

% Move the GUI to the center of the screen
movegui(hf, 'center');
% Make the GUI visible
set(hf, 'Visible', 'on');
uicontrol(hbasis_list);

%  Callbacks for LCM_BASIS
function basislist_callback(hObject, ~)
    b_file_idx = get(hObject, 'Value');
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
    warn = 1;
    if exist(lcm_def_file, 'file') == 2
        def_data = load(lcm_def_file);
        if isfield(def_data, 'b_file_idx')
            b_file_idx = def_data.b_file_idx;
            if ~isempty(b_file_idx)
                warn = 0;
                set(hbasis_list, 'Value', b_file_idx);
            end
        end
    end
    if warn
        warndlg('The default value is missing!');
    end
end

function OK_callback(~, ~)
    data.b_file_idx = b_file_idx;
    if exist(lcm_data_file, 'file') ~= 2
%         if exist('temp', 'dir') ~= 7
%             mkdir('temp');
%         end
        save(lcm_data_file, '-struct', 'data');
    else
        save(lcm_data_file, '-struct', 'data', '-append');
    end
    if save_def
        def_data.b_file_idx = b_file_idx;
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