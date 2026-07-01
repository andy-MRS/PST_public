function raw_name = pst_make_raw_file(spec_struct, iswater)

    if ~exist([spec_struct.spec_path filesep 'lcm'], 'dir')
        mkdir(spec_struct.spec_path, 'lcm');
    end

    if ~iswater
        [path, name, ~] = fileparts(spec_struct.spec_file);
        raw_name = [path filesep 'lcm' filesep name '.RAW']; 
        create_raw(spec_struct, raw_name)
    else
        [path, name, ~] = fileparts(spec_struct.water_struct.water_file);
        raw_name = [path filesep 'lcm' filesep name '.RAW']; 
        create_raw(spec_struct.water_struct, raw_name)

    end
end

function create_raw(spec_struct, raw_name)

    if exist(raw_name, 'file')
        delete(raw_name);
    end
    
    fprintf('%s%s', 'Creating RAW file: ', raw_name);
    
    echot = spec_struct.te;
    hzpppm = spec_struct.txfrq/10^6;
    if ~spec_struct.is_sv
        volume = prod(spec_struct.geometry.vox_sz) * 10^-3;
    else
        volume = prod(spec_struct.geometry.VOI_size) * 10^-3;
    end
    fid = fopen(raw_name, 'w');
    % make namelist SEQPAR
    seq_str = sprintf(' %s\n', '$SEQPAR');
    echot_str = sprintf(' %s%.2f\n', 'echot = ', echot);
    hzpppm_str = sprintf(' %s%.4e\n', 'hzpppm = ', hzpppm);
    end_str = sprintf(' %s\n', '$END');
    fwrite(fid, seq_str, 'char');
    fwrite(fid, echot_str, 'char');
    fwrite(fid, hzpppm_str, 'char');
    fwrite(fid, end_str, 'char');
    % make namelist NMID
    nmid_str = sprintf(' %s\n', '$NMID');
    fmt_str = sprintf(' %s\n', 'fmtdat = ''(2E15.6)''');
    vol_str = sprintf(' %s%.1f\n', 'volume = ', volume);
    fwrite(fid, nmid_str, 'char');
    fwrite(fid, fmt_str, 'char');
    fwrite(fid, vol_str, 'char');
    fwrite(fid, end_str, 'char');

    % format the raw data
    raw_data_columns = spec_struct.fids(:);

    R = real(raw_data_columns);
    I = -imag(raw_data_columns);   % sign flip is for LCModel
    fprintf(fid, '%15.6e%15.6e\n', [R.'; I.']);
    
    fclose(fid);

    fprintf('%s%.0f%s', ' ...finished!');
    disp(' ');
end

