function spec_struct = pst_combine_voxel_jsons(spec_struct, voxel_results_folders, shift_id, vox_ids)

spec_struct.processed_voxels = {};

% clear the structure containing previously processed stuff
try
    spec_struct.voxel_results = rmfield(spec_struct.voxel_results, ['voxresults_' shift_id]);
catch
end

if isequal(vox_ids, 'SV')
    parametric_json_name = strcat(voxel_results_folders.(['folder_' shift_id]), filesep, 'SV.json');
    spec_struct.voxel_results.(['voxresults_' shift_id]).('SV') = readstruct(parametric_json_name); % read the data from individual files
else
    for k = 1:numel(vox_ids)
        voxel_id = [num2str(vox_ids{k}(1)) '_', num2str(vox_ids{k}(2))];
        parametric_json_name = strcat(voxel_results_folders.(['folder_' shift_id]), filesep, voxel_id, '.json');
        if exist(parametric_json_name, 'file')
            spec_struct.voxel_results.(['voxresults_' shift_id]).(['vox' voxel_id]) = readstruct(parametric_json_name); % read the data from individual files
        else
            spec_struct.voxel_results.(['voxresults_' shift_id]).(['vox' voxel_id]) = []; % save the fact that the voxel was selected
        end
    end
end