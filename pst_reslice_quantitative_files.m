function resliced_files = pst_reslice_quantitative_files(quantitative_files, ref_file)
    
    if ~isempty(quantitative_files)
        disp(' ')
        disp('Reslicing quantitative images into the space of the reference image...')
    end
    
    resliced_files = cell(1, size(quantitative_files, 2));

    for i=1:size(quantitative_files, 2)
        
        [path, name, ext] = fileparts(quantitative_files{i});
        path = [path filesep 'resliced'];
        resliced_name = ['resliced_' name ext];        
        if exist(fullfile(path, resliced_name), "file")
            fprintf('%s%d%s%d%s\n', 'Reslicing of the quantitative image ', i, '/', size(quantitative_files,2), ' has already been performed.');
        else
            fprintf('%s%d%s%d%s', 'Reslicing the quantitative image ', i, '/', size(quantitative_files,2), '...');
            pst_reslice(quantitative_files{i}, ref_file);
        end
        resliced_files{i} = fullfile(path, resliced_name);

    end
    fprintf('\n')
end


function pst_reslice(input_file, ref_file)

    % initialization
    [anat_path, anat_name, ~] = fileparts(input_file);
    resliced = fullfile(anat_path, 'resliced');
    
    cur_path = fileparts(mfilename('fullpath'));
    cd(cur_path)
    
    % make directory to save resliced files
    if exist(resliced, 'dir') ~= 7
        mkdir(resliced);
    end

    % load the quantitative image that will be affinely transformed into MRS space
   
    anat_vol = spm_vol(input_file);
    ref_vol = spm_vol(ref_file);
    aff_diff = abs(anat_vol.mat - ref_vol.mat);
    
    if all(aff_diff(:) < 0.05)       % 0.05 mm difference in the affine is okay, no need to reslice

        fprintf('\n%s\n', 'Affine matrices are close — skipping reslicing.');
        resliced_file = fullfile([resliced filesep 'resliced_' anat_name '.nii']);
        copyfile(input_file, resliced_file);
    else    
        flags = struct('mask', false, ...
                   'mean', false, ...
                   'interp', 0, ...
                   'which', 1, ...
                   'wrap', [0 0 0], ...
                   'prefix', 'resliced/resliced_');

        reslice_cmd = "spm_reslice([ref_vol, anat_vol], flags);";
        evalc(reslice_cmd);
        fprintf('%s\n', 'finished.');

    end
end
