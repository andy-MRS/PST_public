function [segmentation_analyzed, parametric_analyzed] = pst_segm(mask_name, voxel_results_folders, files, segmentation_is_there, qMRI_names, ppmShift)

    % this function is GannetSegment, adapted for PST
    warning('off'); 
    
    segmentation_analyzed = false;
    parametric_analyzed = false;
    
    % Define the tissues
    if segmentation_is_there
        tissues = {'GM', 'WM', 'CSF'};
    else
        tissues = {};
    end
    parametric_image_names = [tissues, qMRI_names];

    % Load volumes
    vols = cell(1, size(files, 2));
    for i = 1:size(files,2)
        vols{i} = spm_vol(files{i});
    end
    
    % Voxel mask
    voxmaskvol = spm_vol(mask_name);

    % Initialize sums
    sums = zeros(size(files, 2), 1);
    nonZeros = zeros(size(files, 2), 1);
    for i = 1:size(files, 2)
        % Calculate voxel mask volume
        voxmask_data = vols{i}.private.dat(:,:,:) .* voxmaskvol.private.dat(:,:,:);
        voxmask_data = voxmask_data(~isnan(voxmask_data));
        % Calculate sum for current tissue type
        sums(i) = sum(voxmask_data(:));
        nonZeros(i) = nnz(voxmask_data);
    end
    
    t = 1; % tissue loop 
    if segmentation_is_there

        % Calculate total sum of GM, WM and CSF
        c_sum = sum(sums(1:3));

        % Calculate GM/WM/CSF fractions and output to the structure
        parametric_data.fGM = sums(1) / c_sum;
        parametric_data.fWM = sums(2) / c_sum;
        parametric_data.fCSF = sums(3) / c_sum;
        t = 4; % later start with the 4th tissue
        segmentation_analyzed = true;
    end
    
    for i = t:size(files,2)
        parametric_data.(parametric_image_names{i}) = (sums(i)/nonZeros(i));
        parametric_analyzed = true;
    end
    
    warning('on');
    
    shift_str = pst_get_shift_value_string(ppmShift);
    
    [~, param_results_name, ~] = fileparts(mask_name);
    param_results_ext = '.json';
    param_results_fname = [voxel_results_folders.(['folder_' shift_str]) filesep param_results_name param_results_ext];
    writestruct(parametric_data, param_results_fname)
end