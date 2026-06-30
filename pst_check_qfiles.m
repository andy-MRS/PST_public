function [q, filenames, names] = pst_check_qfiles(file_name)

    names = {};
    filenames = {};
    [path, ~, ~] = fileparts(file_name);
    qmri_folder_names_dictionary = {'qMRI', 'qmri', 'QMRI'};
    
    for j = 1:length(qmri_folder_names_dictionary)
        path_q = [path filesep qmri_folder_names_dictionary{j}];
        contents = dir(path_q);
        if length(contents) > 2 % for some reason this is case independent here. But let it stay like this.
            filesAndDirs = dir(path_q);
            names = {filesAndDirs(~[filesAndDirs.isdir]).name};
            
            for i = 1:length(names)
                filenames{i} = [path_q filesep names{i}];
                names{i} = names{i}(1:end-4);
            end
        end
    end
    q = ~isempty(names);

    if q == 1
        disp('qMRI files are:');
        for i = 1:length(filenames)
            fprintf('%s\n', [path_q filesep filenames{i}]);
        end
    else
        disp('Warning! Segmentation files not found!');
    end
end
