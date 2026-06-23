function [is_sv, manufacturer] = pst_get_is_sv_and_vendor(spec)

    is_sv = 0;
    
    [spec_path, spec_name, spec_ext] = fileparts(spec);
    spec_ext = lower(spec_ext);
    if isequal(spec_ext, '.rda')
        manufacturer = 'Siemens';
        lines = readlines(spec);
        file_content = strjoin(lines, newline);
        tokens = regexp(file_content, 'CSIMatrixSize\[\d+\]:\s*(\d+)', 'tokens');
        values = cellfun(@(x) str2double(x{1}), tokens);
        is_sv = ~any(values > 1);
    elseif isequal(spec_ext, '.sdat')
        manufacturer = 'Philips';
        spar_file = fullfile(spec_path, [spec_name, '.SPAR']);
        if exist(spar_file, 'file') == 2
            fid = fopen(spar_file, 'r');
            if fid == -1
                return;
            end
            while ~feof(fid)
                line = fgetl(fid);
                if contains(line, 'phase_encoding_enable')
                    parts = strsplit(line, ':');
                    value = strtrim(parts{2});
                    value=strrep(value,'"','');
                    value=strrep(value,'''','');
                    if strcmpi(value, 'no')
                        is_sv = 1;
                    end
                    break; 
                end
            end
            fclose(fid);
        end
    end
end
    
