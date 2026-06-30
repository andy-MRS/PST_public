function pst_process_lcm_voxel(ij, ind, spec_struct, basis_set, selection_name, raw_name, raw_name_water, lcm_data_file)
    
    i = ij(ind, 1); 
    j = ij(ind, 2);
    lcm_i = i;
    lcm_j = spec_struct.nYvoxels - j + 1;
    if isequal(spec_struct.nucleus, '31P↵')
        ctrl_name = pst_make_ctrl_file_31P(spec_struct, basis_set, lcm_i, lcm_j, selection_name, raw_name, raw_name_water, lcm_data_file);
    else
        ctrl_name = pst_make_ctrl_file(spec_struct, basis_set, lcm_i, lcm_j, selection_name, raw_name, raw_name_water, lcm_data_file);
    end
    ctrl_name = ['"' ctrl_name '"'];
    if ~isempty(ctrl_name)
        lcm_cmd = sprintf('%s %s', '"LCModel\LCModel.exe" <', ctrl_name);
        system(lcm_cmd);
    end
end