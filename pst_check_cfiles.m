function [s, segmentation_files] = pst_check_cfiles(file_name)
    
    [path, name, ext] = fileparts(file_name);
    [matchstart, matchend] = regexp(name, '(m?w)?c[1-3]');
    if ~isempty(matchstart) && matchstart(1) == 1
        name = name(matchend(1)+1:end);
    end
    
    c1name = strcat('c1', name); 
    c2name = strcat('c2', name); 
    c3name = strcat('c3', name);
    
    gm_check = fullfile(path, [c1name ext]);
    wm_check = fullfile(path, [c2name ext]);
    csf_check = fullfile(path, [c3name ext]);
    
    dictionary_for_segmentation_folder_name = {'segmentation', 'Segmentation', 'segm', 'Segm'};
    
    for i=1:length(dictionary_for_segmentation_folder_name)
        if ~isfile(gm_check) || ~isfile(csf_check) || ~isfile(csf_check) 
            path_c = [path filesep dictionary_for_segmentation_folder_name{i}];
            contents = dir(path_c);
            if ~isempty(contents)
                for i=3:5
                    if contains(contents(i).name, 'c1')
                        gm_check = fullfile(path_c, contents(i).name);
                    elseif contains(contents(i).name, 'c2')
                        wm_check = fullfile(path_c, contents(i).name);
                    elseif contains(contents(i).name, 'c3')
                        csf_check = fullfile(path_c, contents(i).name);
                    end
                end
            end
        end
    end
    s = -2;
    segmentation_files = {};
    
    if exist(gm_check, 'file') == 2
        segmentation_files = [segmentation_files, gm_check];
        s = s + 1;
    end
    if exist(wm_check, 'file') == 2
        segmentation_files = [segmentation_files, wm_check];
        s = s + 1;
    end
    if exist(csf_check, 'file') == 2
        segmentation_files = [segmentation_files, csf_check];
        s = s + 1;
    end

    if s == 1
        disp('Segmentation files are:');
        for i = 1:length(segmentation_files)
            fprintf('%s\n', segmentation_files{i});
        end
    else
        disp('Warning! Segmentation files not found!');
    end
end

