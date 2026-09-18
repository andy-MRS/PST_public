function spec_struct = pst_load_spec(spec, water, ref_file, is_sv, is_3d, Manufacturer)
    
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
            spec_struct.mrsi_slice_thkn = spec_struct.geometry.si_size.cc / spec_struct.nZvoxels;
        end

    elseif isequal(Manufacturer, 'Siemens')  
        disp("Loading Siemens rda in pst_load_spec (line 24)")
        spec_struct = pst_loadspec_rda(spec);

        % fill geo information 
        spec_struct.geometry.VOI_size = [spec_struct.geometry.size.VoI_RoFOV, spec_struct.geometry.size.VoI_PeFOV, spec_struct.geometry.size.VoIThickness];
        spec_struct.geometry.VOI_shift = [spec_struct.geometry.pos.PosSag, spec_struct.geometry.pos.PosCor, spec_struct.geometry.pos.PosTra]; % this is used in SV case
        spec_struct.geometry.VOI_ang = [spec_struct.geometry.rot.NormSag, spec_struct.geometry.rot.NormCor, spec_struct.geometry.rot.NormTra];
        if ~is_sv
            spec_struct.geometry.FOV_size = [spec_struct.geometry.si_size.VoI_RoFOV, spec_struct.geometry.si_size.VoI_PeFOV, spec_struct.geometry.si_size.VoIThickness];
            spec_struct.geometry.FOV_shift = [spec_struct.geometry.si_pos.PosSag, spec_struct.geometry.si_pos.PosCor, spec_struct.geometry.si_pos.PosTra];
            % in Siemens, VOI and FoV are aligned and centered, right? So, reassign the center point = center of the FOV
            spec_struct.geometry.VOI_shift = spec_struct.geometry.FOV_shift;
            spec_struct.geometry.FOV_ang = spec_struct.geometry.VOI_ang; 
            spec_struct.mrsi_slice_thkn = spec_struct.geometry.si_size.VoIThickness / spec_struct.nZvoxels;
        end
    end
    
    % rename vendor to Manufacturer
    spec_struct.Manufacturer = Manufacturer;
    if isfield(spec_struct,'vendor')
        spec_struct = rmfield(spec_struct,'vendor');
    end

    % same into struct:
    spec_struct.is_sv = is_sv;
    spec_struct.is_3d = is_3d;

    % is it a volume selection technique?
    disp("Checking if it is a volume selection MRSI technique in pst_load_spec (line 36)");
    if ~is_sv
        if (any(spec_struct.geometry.VOI_size < spec_struct.geometry.FOV_size)) || (contains(spec_struct.volume_selection_enable, 'yes'))
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

    % This current spec processing path here
    spec_struct.spec_processing_path = [spec_struct.spec_path filesep 'processing_' spec_struct.spec_name];

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
     
    % Need to reslice the anatomical image in such way that a complete amount
    % of pixels of the reference image are forming the MRSI FOV. 

    old_ref_vox = sqrt(sum(ref_nii.mat(1:3,1:3).^2));

    factor = spec_struct.geometry.vox_sz ./ old_ref_vox;

    to_bring_to = ceil(factor); % how many image pixels will be there in one MRS voxel

    new_ref_vox = spec_struct.geometry.vox_sz ./ to_bring_to;

    new_dim = ref_nii.dim .* old_ref_vox ./ new_ref_vox;
    new_dim = round(new_dim); % more or less correct now. Shall be adjusted.
    
    newM = ref_nii.mat; % use old matrix
    
    for i = 1:3
        newM(1:3,i) = ref_nii.mat(1:3,i) / old_ref_vox(i) * new_ref_vox(i); % adjust elements
    end
    
    % keep the center point 
    old_center = ref_nii.mat * [(ref_nii.dim(:)+1)/2; 1];
    new_center = newM * [(new_dim(:)+1)/2; 1];
    
    newM(1:3,4) = newM(1:3,4) + (old_center(1:3) - new_center(1:3));

    % create new ref file "template"
    new_ref_file = [ref_file(1:end-4) '_reslice_template.nii'];
    
    Vref = ref_nii;
    Vref.fname = new_ref_file;
    Vref.dim   = new_dim;
    Vref.mat   = newM;
    Vref.dt    = [spm_type('float32') 0];
    
    Vref = spm_create_vol(Vref);
    spm_write_vol(Vref, zeros(new_dim));

    % write resliced image into new ref

    flags = struct('mask', false, ...
        'mean', false, ...
        'interp', 1, ...
        'which', 1, ...
        'wrap', [0 0 0], ...
        'prefix', 'resliced/resliced_');

    [ref_path, ref_name, ref_ext] = fileparts(ref_file);

    if ~exist([ref_path filesep 'resliced'],'dir')
        mkdir([ref_path filesep 'resliced'])
    end
    spm_reslice_cmd = "spm_reslice([Vref; ref_nii], flags);";

    evalc(spm_reslice_cmd);
    delete(new_ref_file)

    % save new ref info
    ref_file = [ref_path filesep 'resliced' filesep 'resliced_' ref_name ref_ext];
    ref_path = [ref_path filesep 'resliced'];

    spec_struct.geometry.ref_vox_sz = new_ref_vox;
    spec_struct.ref_file = ref_file;
    spec_struct.ref_path = ref_path;
    spec_struct.ref_name = ref_name;
    spec_struct.ref_ext = ref_ext;




    


end