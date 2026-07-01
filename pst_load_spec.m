function spec_struct = pst_load_spec(spec, water, ref_file, is_sv, Manufacturer)
    
    % this function calls the modified loadspec function from FID-A package
    % depending on the vendor. In addition, it saves the geo
    % information and makes some checks

    if isequal(Manufacturer, 'Philips')
        disp("Loading Philips SDAT in pst_load_spec (line 8)")
        
        % create MRS/I structure
        spec_struct = pst_loadspec_sdat(spec, 1);
        
        % fill geo information 
        spec_struct.geometry.VOI_size = [spec_struct.geometry.size.lr, spec_struct.geometry.size.ap, spec_struct.geometry.size.cc];
        spec_struct.geometry.VOI_shift = [spec_struct.geometry.pos.lr, spec_struct.geometry.pos.ap, spec_struct.geometry.pos.cc];
        spec_struct.geometry.VOI_ang = [spec_struct.geometry.rot.lr, spec_struct.geometry.rot.ap, spec_struct.geometry.rot.cc];
        if ~is_sv
            spec_struct.geometry.FOV_size = [spec_struct.geometry.si_size.lr, spec_struct.geometry.si_size.ap, spec_struct.geometry.si_size.cc];
            spec_struct.geometry.FOV_shift = [spec_struct.geometry.si_pos.lr, spec_struct.geometry.si_pos.ap, spec_struct.geometry.si_pos.cc];
            spec_struct.geometry.FOV_ang = [spec_struct.geometry.si_rot.lr, spec_struct.geometry.si_rot.ap, spec_struct.geometry.si_rot.cc];
        end
    
    elseif isequal(Manufacturer, 'Siemens')  
        disp("Loading Siemens rda in pst_load_spec (line 24)")
        spec_struct = pst_loadspec_rda(spec);

        % fill geo information 
        spec_struct.geometry.VOI_size = [spec_struct.geometry.size.VoI_RoFOV, spec_struct.geometry.size.VoI_PeFOV, spec_struct.geometry.size.VoIThickness];
        spec_struct.geometry.VOI_shift = [spec_struct.geometry.pos.PosSag, spec_struct.geometry.pos.PosCor, spec_struct.geometry.pos.PosTra];
        spec_struct.geometry.VOI_ang = [spec_struct.geometry.rot.NormSag, spec_struct.geometry.rot.NormCor, spec_struct.geometry.rot.NormTra];
        if ~is_sv
            spec_struct.geometry.FOV_size = [spec_struct.geometry.si_size.VoI_RoFOV, spec_struct.geometry.si_size.VoI_PeFOV, spec_struct.geometry.si_size.VoIThickness];
            % in Siemens, VOI and FoV are aligned and centered, right?
            spec_struct.geometry.FOV_shift = spec_struct.geometry.VOI_shift;
            spec_struct.geometry.FOV_ang = spec_struct.geometry.VOI_ang;
        end
    end
    
    % rename vendor to Manufacturer
    spec_struct.Manufacturer = Manufacturer;
    spec_struct.is_sv = is_sv;
    if isfield(spec_struct,'vendor')
        spec_struct = rmfield(spec_struct,'vendor');
    end

    % is it a volume selection technique?
    disp("Checking if it is a volume selection MRSI technique in pst_load_spec (line 36)");
    if ~is_sv
        if any(spec_struct.geometry.VOI_size < spec_struct.geometry.FOV_size)
            spec_struct.geometry.exist_VOI = true;
        else
            spec_struct.geometry.exist_VOI = false;
        end
    else
        spec_struct.geometry.exist_VOI = true;
    end

    % MRS full name here
    spec_struct.spec_file = spec;
    [spec_struct.spec_path, spec_struct.spec_name, spec_struct.spec_ext] = fileparts(spec);
    
    if ~isempty(water)
        if isequal(Manufacturer, 'Philips')
            spec_struct.water_struct = pst_loadspec_sdat(water, 1);
        elseif isequal(Manufacturer,'Siemens')  
            spec_struct.water_struct = pst_loadspec_rda(water);
        end

        spec_struct.water_struct.is_sv = is_sv;
        spec_struct.water_struct.Manufacturer = Manufacturer;
        spec_struct.water_struct.water_file = water;
        [spec_struct.water_struct.water_path, spec_struct.water_struct.water_name, spec_struct.water_struct.water_ext] = fileparts(water); 
    end
    
    % find and store the voxel size of the reference image
    ref_nii = spm_vol(ref_file);
    spec_struct.geometry.ref_vox_sz = sqrt(sum(ref_nii.mat(1:3,1:3).^2));
    
    % save ref path 
    [ref_path, ref_name, ref_ext] = fileparts(ref_file);
    spec_struct.ref_file = ref_file;
    spec_struct.ref_path = ref_path;
    spec_struct.ref_name = ref_name;
    spec_struct.ref_ext = ref_ext;

end

