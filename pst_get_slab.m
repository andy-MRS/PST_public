function [spec_struct, quantitative_slabs_only_VOI] = pst_get_slab(spec_struct, cell_of_anat_files, ppmShift, do_PSF_blurring)

% This code creates a slab from the anatomical image centered around MRSI 
% and tilted accordingly:
%       __                  z    
%      / /      _______    ^
%     / /  --> |_______|   | 
%    /_/                   |————>x  
%                         /  
%                        /   
%                        y

    quantitative_slabs_only_VOI = {};
    
    for i = 1:size(cell_of_anat_files, 2)
    
        anat_file = cell_of_anat_files{i};

        % init
        geo = spec_struct.geometry;
        
        [anat_path, anat_name, ~] = fileparts(anat_file);
    
        if ~exist([anat_path filesep 'slabs' filesep 'slabs_' num2str(ppmShift)], "dir")
            mkdir([anat_path filesep 'slabs' filesep 'slabs_' num2str(ppmShift)]);
        end
        
        shift_val_str = pst_get_shift_value_string(ppmShift);
    
        % 
        anat_vol = spm_vol(anat_file);
        anat_vox_sz = sqrt(sum(anat_vol.mat(1:3,1:3).^2));
        
        % find the image size based on the real FOV size and create it
        img_size = floor(geo.FOV_size ./ anat_vox_sz);
        img_size = img_size+1;
        img = ones(img_size);
        
        % Get spectroscopic imaging offcenter from Philips SPAR. These values
        % are assigned in helper located at pst_coreg
        p0 = [-geo.FOV_shift(1); -geo.FOV_shift(2); geo.FOV_shift(3)];
        
        % 
        R = geo.FOV_rotation_matrix;
            
        % Calculate the FOV offset vector p
        % p1 points from the first point of the slice to the center. 
        p1 = R * diag(anat_vox_sz) * ([img_size(1)/2; img_size(2)/2; img_size(3)/2+1]);
        
        % p is the corner offset vector, so the center p0 can be reached by p + p1, thus p + p1 = p0. 
        p = p0 - p1;
    
        % Create the MRSI slab mask
        slab_mask_vol = anat_vol; % predefine
        slab_mask_vol.dim = img_size;
        slab_mask_vol.fname = [spec_struct.ref_path filesep 'slabs' filesep 'slabs_' num2str(ppmShift) filesep spec_struct.ref_name '_' spec_struct.spec_name '_slab_mask.nii'];
        slab_mask_vol.pinfo = [1; 0; 0];
        slab_mask_vol.dt = [16 0];
        slab_mask_vol.mat = [R * diag(anat_vox_sz), p(:); 0 0 0 1];
        warning('off')
        spm_write_vol(slab_mask_vol, img);
        
        if spec_struct.geometry.exist_VOI
            mask_file = spec_struct.VOI_mask_filename; % it is not unused, it is used in the evalc form
        else
            mask_file = spec_struct.FOV_mask_filename;
        end
    
        if isequal(anat_file, spec_struct.ref_file)
            
            % find the slab: slab mask x anat_img
            slab_filename = [spec_struct.ref_path filesep 'slabs' filesep 'slabs_' num2str(ppmShift) filesep spec_struct.ref_name '_' spec_struct.spec_name '_slab_image.nii'];
            spm_imcalc_slab_cmd = "spm_imcalc([slab_mask_vol, anat_vol]', slab_filename, 'i2 .* (i1 > 0)', struct('dtype', 16));";
            evalc(spm_imcalc_slab_cmd);
            spec_struct.(['shifted_' shift_val_str]).image_slab_filename = slab_filename;
            disp(['The image slab corresponding to the MRS FOV for delta ppm = ' num2str(ppmShift) ' saved.'])
           
            % create VOI mask in the slab space
            slab_VOI_mask_filename = [spec_struct.ref_path filesep 'slabs' filesep 'slabs_' num2str(ppmShift) filesep spec_struct.ref_name '_' spec_struct.spec_name '_slab_VOI_mask.nii'];
            spm_imcalc_cmd = "spm_imcalc([spm_vol(slab_filename), spm_vol(mask_file)], slab_VOI_mask_filename, 'i1 .* (i2 > 0)', struct('dtype', 16));";
            evalc(spm_imcalc_cmd);
            spec_struct.(['shifted_' shift_val_str]).slab_VOI_mask_filename = slab_VOI_mask_filename;
            disp(['VOI mask in the MRS space for delta ppm = ' num2str(ppmShift) ' saved.'])
        
            return % save only the slab mask and the slab itself if current file is the ref image. Otherwise if it is quantitative image, go on finding slabs
        end
    
        % read the slab mask, find VOI mask in the slab 
        slab_mask_vol = spm_vol([spec_struct.ref_path filesep 'slabs' filesep 'slabs_' num2str(ppmShift) filesep spec_struct.ref_name '_' spec_struct.spec_name '_slab_mask.nii']);
    
        slab_VOI_filename = [anat_path filesep 'slabs' filesep 'slabs_' num2str(ppmShift) filesep anat_name '_' spec_struct.spec_name '_slab_VOI.nii'];
        spm_imcalc_cmd = "spm_imcalc([slab_mask_vol, anat_vol, spm_vol(mask_file)], slab_VOI_filename, 'i2 .* (i1 > 0) .* (i3 > 0)', struct('dtype', 16));";
        evalc(spm_imcalc_cmd);
        VOI_vol = spm_vol(slab_VOI_filename);
        VOI_img = spm_read_vols(VOI_vol);
        VOI_img(isnan(VOI_img)) = 0;
        disp([anat_name ' slab containing only VOI for delta ppm = ' num2str(ppmShift) ' saved.'])
    
        % apply PSF blurring to this VOI

        % That's how we take into account the difference between the anatomical image and the MRSI resolution (-> PSF). 
        % It's possible to switch it off in the Settings tab of the interface, setting do_PSF_blurring = False.
        
        if do_PSF_blurring
            blurred_VOI_img = PSF_blurring(VOI_img, [spec_struct.nAcqXvoxels spec_struct.nAcqYvoxels]);
        else
            blurred_VOI_img = VOI_img;
        end
        blurred_VOI_vol = slab_mask_vol; % predefine
        blurred_VOI_vol.fname = [anat_path filesep 'slabs' filesep 'slabs_' num2str(ppmShift) filesep anat_name '_' spec_struct.spec_name '_blurred_VOI.nii'];
        spm_write_vol(blurred_VOI_vol, blurred_VOI_img);
        disp(['PSF blurring of the ' anat_name ' slab containing only VOI for delta ppm = ' num2str(ppmShift) ' is performed.'])
        quantitative_slabs_only_VOI{i} = blurred_VOI_vol.fname;
    
        warning('on')
    end

end

function out_img = PSF_blurring(in_img, window)

    % for Philips, this function undersamples the k-space of the image.
    % TODO 1: take elliptical weighting into account
    % TODO 2: add Hamming filter for Siemens (if it's ON in MRSI)
    
    in_2d = mean(in_img, 3);
    F = fftshift(fft2(in_2d));
    
    % target central low-frequency window
    center = floor(size(F)/2) + 1;
    half = floor(window/2);
    
    % build mask same size as F
    mask = zeros(size(F));
    r = (center(1)-half(1)):(center(1)+half(1)-1);
    c = (center(2)-half(2)):(center(2)+half(2)-1);
    mask(r, c) = 1;
    
    % apply mask
    F_masked = F .* mask;
    
    % inverse fft
    out_2d = ifft2(ifftshift(F_masked));

    % replicate for all slices
    out_img = repmat(out_2d, [1, 1, size(in_img, 3)]);
end
