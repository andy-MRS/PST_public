function Spectro = pst_coreg(Spectro, is_sv, anat, ppmShift)
    
    % This function is adapted from coreg_sdat.m by Georg Oeltzschner, Johns Hopkins University 2019.
    % originally taken from core_sdat, but in PST works for Siemens .rda too.
    % The chemical shift displacement for the FOV and VOI (2D case) and for SV are taken into account here.

    % save masks path
    masks_path = [Spectro.ref_path filesep 'masks' filesep 'masks_' num2str(ppmShift)];
    if exist(masks_path, 'dir') ~= 7
        mkdir(masks_path);
    end
    Spectro.masks_path = masks_path;
    
    % save the VOI and FOV mask filenames
    if ~is_sv
        Spectro.VOI_mask_filename = strcat(masks_path, filesep, 'VOI', Spectro.ref_ext);
        Spectro.FOV_mask_filename = strcat(masks_path, filesep, 'FOV', Spectro.ref_ext);
    else
        Spectro.VOI_mask_filename = strcat(masks_path, filesep, 'SV', Spectro.ref_ext);
    end

    % Deactivate MATLAB warnings and load geometry parameters

    warning('off','all');
   
    %%% 1. PREPARE THE STRUCTURAL IMAGE
    % Create SPM volume and read in the NIfTI file with the structural image.
    vol_image   = spm_vol(anat);
    [T1,XYZ]    = spm_read_vols(vol_image);
    T1_max      = max(T1(:));

    %Shift imaging voxel coordinates by half an imaging voxel so that the XYZ matrix
    %tells us the x,y,z coordinates of the MIDDLE of that imaging voxel.
    [~,voxdim] = spm_get_bbox(vol_image,'fv');
    voxdim = abs(voxdim)';
    halfpixshift = -voxdim(1:3)/2;
    halfpixshift(3) = -halfpixshift(3);
    XYZ = XYZ + repmat(halfpixshift, [1 size(XYZ,2)]);

    %%% 2. GENERATE THE COORDINATES OF THE VOXEL CORNERS
    
    % Address the case when we save initial Rotation matrix
    try
        if isequal(Spectro.case, 'Get_rotation_matrix')
            Spectro.voxID = 'VOI';
        end
    catch
    end

    % Get information from the structure depending on the cases 
    if isequal(Spectro.voxID,'FOV')
        ap_size = Spectro.geometry.FOV_size(2);
        lr_size = Spectro.geometry.FOV_size(1);
        cc_size = Spectro.geometry.FOV_size(3);
        ap_off  = Spectro.geometry.FOV_shift(2);
        lr_off  = Spectro.geometry.FOV_shift(1);
        cc_off  = Spectro.geometry.FOV_shift(3);
        ap_ang  = Spectro.geometry.FOV_ang(2);
        lr_ang  = Spectro.geometry.FOV_ang(1);
        cc_ang  = Spectro.geometry.FOV_ang(3);
    elseif isequal(Spectro.voxID,'VOI') || isequal(Spectro.voxID,'SV')
        ap_size = Spectro.geometry.VOI_size(2);
        lr_size = Spectro.geometry.VOI_size(1);
        cc_size = Spectro.geometry.VOI_size(3);
        ap_off  = Spectro.geometry.VOI_shift(2);
        lr_off  = Spectro.geometry.VOI_shift(1);
        cc_off  = Spectro.geometry.VOI_shift(3);
        ap_ang  = Spectro.geometry.VOI_ang(2);
        lr_ang  = Spectro.geometry.VOI_ang(1);
        cc_ang  = Spectro.geometry.VOI_ang(3);
    else % voxID = individual voxels
        ap_size = Spectro.geometry.VOI_size(2);
        lr_size = Spectro.geometry.VOI_size(1);
        cc_size = Spectro.geometry.VOI_size(3);
        ap_off  = Spectro.geometry.VOI_shift(2);
        lr_off  = Spectro.geometry.VOI_shift(1);
        cc_off  = Spectro.geometry.VOI_shift(3);
        ap_ang  = Spectro.geometry.VOI_ang(2);
        lr_ang  = Spectro.geometry.VOI_ang(1);
        cc_ang  = Spectro.geometry.VOI_ang(3);
    end

    % We need to flip ap and lr axes to match NIFTI convention
    ap_off = -ap_off;
    lr_off = -lr_off;
    ap_ang = -ap_ang;
    lr_ang = -lr_ang;

    % Define voxel coordinates before rotation and transition
    vox_ctr = ...
        [lr_size/2 -ap_size/2  cc_size/2;
        -lr_size/2 -ap_size/2  cc_size/2;
        -lr_size/2  ap_size/2  cc_size/2;
         lr_size/2  ap_size/2  cc_size/2;
        -lr_size/2  ap_size/2 -cc_size/2;
         lr_size/2  ap_size/2 -cc_size/2;
         lr_size/2 -ap_size/2 -cc_size/2;
        -lr_size/2 -ap_size/2 -cc_size/2];

    % Make rotations on voxel
    rad = pi/180;
    initrot = zeros(3,3);

    xrot      = initrot;
    xrot(1,1) = 1;
    xrot(2,2) = cos(lr_ang*rad);
    xrot(2,3) = -sin(lr_ang*rad);
    xrot(3,2) = sin(lr_ang*rad);
    xrot(3,3) = cos(lr_ang*rad);

    yrot      = initrot;
    yrot(1,1) = cos(ap_ang*rad);
    yrot(1,3) = sin(ap_ang*rad);
    yrot(2,2) = 1;
    yrot(3,1) = -sin(ap_ang*rad);
    yrot(3,3) = cos(ap_ang*rad);

    zrot      = initrot;
    zrot(1,1) = cos(cc_ang*rad);
    zrot(1,2) = -sin(cc_ang*rad);
    zrot(2,1) = sin(cc_ang*rad);
    zrot(2,2) = cos(cc_ang*rad);
    zrot(3,3) = 1;

    % Apply rotation as prescribed
    R = xrot * yrot * zrot; 
    
    % return this matrix
    if isequal(Spectro.voxID,'FOV')
        Spectro.geometry.FOV_rotation_matrix = R;
    elseif isequal(Spectro.voxID,'VOI')
        Spectro.geometry.VOI_rotation_matrix = R;
    end

    % exit from here if we just need a matrix
    try
        if isequal(Spectro.case, 'Get_rotation_matrix')
            Spectro = rmfield(Spectro, "case");
            return
        end
    catch
    end

    % go on if we need to apply the matrix to actually get the masks
    vox_rot = R * vox_ctr.';

    % Apply chemical shift displacement
    % REMINDER: in 2D MRSI, the FOV is shifted only in the slice selection 
    % direction because the FOV thickness is defined by the slice-selective 
    % pulse (last 180 for PRESS/sLASER) and the in-plane is phase-encoded.
    % The VOI and SV are shifted in all 3 directions of course.
    
    if ~isequal(ppmShift,0)

        HzShift = ppmShift * 10^-6;
        if isequal(Spectro.Manufacturer, 'Philips') % using BW approach, although it's possible to use gradient too
            if isequal(Spectro.voxID,'FOV')
                csd_shift_ap = 0;
                csd_shift_lr = 0;
            elseif isequal(Spectro.voxID,'VOI') || isequal(Spectro.voxID,'SV')
                csd_shift_ap = Spectro.geometry.signShiftAP * HzShift * Spectro.txfrq * ap_size / Spectro.BW_ap;
                csd_shift_lr = Spectro.geometry.signShiftLR * HzShift * Spectro.txfrq * lr_size / Spectro.BW_lr;
            end
            csd_shift_cc = Spectro.geometry.signShiftFH * HzShift * Spectro.txfrq * cc_size / Spectro.BW_cc;
        
        elseif isequal(Spectro.Manufacturer, 'Siemens') % using gradient approach here: csd_shift = -HzShift * txfrq / (gamma * GR_ampl); gamma = txfrq * B0 -> csd_shift = -HzShift / (B0 * GR_ampl)
            if isequal(Spectro.voxID,'FOV')
                csd_shift_ap = 0;
                csd_shift_lr = 0;
            elseif isequal(Spectro.voxID,'VOI') || isequal(Spectro.voxID,'SV')
                csd_shift_ap = -ppmShift  / (Spectro.Bo * Spectro.GR_ap);
                csd_shift_lr = -ppmShift  / (Spectro.Bo * Spectro.GR_lr);
            end
            csd_shift_cc = -ppmShift / (Spectro.Bo * Spectro.GR_cc);

        end
        % Rotate the shift to bring it to the scanner space
        shift = [csd_shift_lr csd_shift_ap csd_shift_cc];
        shift_R = R * shift';
    
        lr_off = lr_off + shift_R(1);
        ap_off = ap_off + shift_R(2);
        cc_off = cc_off + shift_R(3);
    end
    
    % OFFTOP: helper field for the pst_get_slab function:
    if isequal(Spectro.voxID,'FOV') 
        Spectro.geometry.FOV_shift = [-lr_off, -ap_off, cc_off];
    end

    % Shift rotated voxel by the center offset to its final position
    vox_ctr_coor = [lr_off ap_off cc_off];
    vox_ctr_coor = repmat(vox_ctr_coor.', [1,8]);
    vox_corner = vox_rot+vox_ctr_coor;

    %%% 3. CREATE AND SAVE THE VOXEL MASK
    % Create a mask with all voxels that are inside the voxel

    for rr = 1:size(vox_ctr_coor,3)
        mask = zeros(1,size(XYZ,2));
        sphere_radius = sqrt((lr_size/2)^2+(ap_size/2)^2+(cc_size/2)^2);
        distance2voxctr = sqrt(sum((XYZ-repmat([vox_ctr_coor(1,1,rr) vox_ctr_coor(2,1,rr) vox_ctr_coor(3,1,rr)].',[1 size(XYZ,2)])).^2,1));
        sphere_mask(distance2voxctr <= sphere_radius) = 1;

        mask(sphere_mask == 1) = 1;
        XYZ_sphere = XYZ(:,sphere_mask == 1);

        tri = delaunayn([vox_corner(:,:,rr).'; [vox_ctr_coor(1,1,rr) vox_ctr_coor(2,1,rr) vox_ctr_coor(3,1,rr)]]);
        %suppreSpectroing warnings
        warning('off', 'MATLAB:singularMatrix');
        warning('off', 'MATLAB:nearlySingularMatrix');
        tn = tsearchn([vox_corner(:,:,rr).'; [vox_ctr_coor(1,1,rr) vox_ctr_coor(2,1,rr) vox_ctr_coor(3,1,rr)]], tri, XYZ_sphere.');
        warning('on', 'MATLAB:singularMatrix');
        warning('on', 'MATLAB:nearlySingularMatrix');
        isinside = ~isnan(tn);
        mask(sphere_mask==1) = isinside;
        mask = reshape(mask, vol_image.dim);

        maskFileOut = [Spectro.masks_path filesep Spectro.voxID '.nii'];
    
        % Fill in the SPM volume header information
        vol_mask.fname   = maskFileOut;
        vol_mask.dim     = vol_image.dim;
        vol_mask.dt      = vol_image.dt;
        vol_mask.mat     = vol_image.mat;
        vol_mask.descrip = 'MRS_voxel_mask';
        
        % Write the SPM volume to disk
        vol_mask = spm_write_vol(vol_mask, mask);

    end

    Spectro.Vol_mask = vol_mask;
	
    if isequal(Spectro.voxID,'FOV')
        Spectro.geometry.FOV_rotation_matrix = R;
    elseif isequal(Spectro.voxID,'VOI')
        Spectro.geometry.VOI_rotation_matrix = R;
    end

    % Reactivate MATLAB warnings
    warning('on','all');

end