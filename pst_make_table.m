function pst_make_table(spec_struct, table_file, lcmodel_processed, segmentation_analyzed, ppmShifts, parametric_analyzed, param_names, lcmodel_new_fields, sel_names_struct)
    
    spec_sz = [spec_struct.nXvoxels spec_struct.nYvoxels spec_struct.nZvoxels];
    
    disp('Generating results table...');
    csv_file = [table_file '.csv'];
    fid = fopen(csv_file, 'a');
    fprintf(fid, '%s;%s;%s;', 'i', 'j', 'k');
    
    for w = 1:length(ppmShifts)
        if segmentation_analyzed
            fprintf(fid, '%s;%s;%s;', ['GM_' num2str(ppmShifts(w))], ['WM_' num2str(ppmShifts(w))], ['CSF_' num2str(ppmShifts(w))]);
        end
        
        if parametric_analyzed
            for i = 1:size(param_names, 2)
                fprintf(fid, '%s;', [param_names{i} '_' num2str(ppmShifts(w))]);
            end
        end
    end

    if lcmodel_processed
        tmp = fieldnames(spec_struct.voxel_results.lcmodel);
        lcm_fields = fieldnames(spec_struct.voxel_results.lcmodel.(tmp{1}));
        for i=5:numel(lcm_fields)
            current_title = lcm_fields{i};
            if ismember(current_title, lcmodel_new_fields)
                current_title = strrep(current_title,'0x2B','+');
                current_title = strrep(current_title,'0x25',' %');
                current_title = strrep(current_title,'x0x2D','-');
                current_title = strrep(current_title,'0x2F','/');
                lcm_str = sprintf('%s', current_title);
                fprintf(fid, '%s;', lcm_str);
            end
        end
    end
    fprintf(fid, '%s', 'Selection');
    
    for i = 1:spec_sz(1)
        for j = 1:spec_sz(2)
            for k = 1:spec_sz(3)
                voxi_j_k = ['vox' num2str(i), '_', num2str(j), '_', num2str(k)];
                if segmentation_analyzed || parametric_analyzed
                    if isfield(spec_struct.voxel_results.voxresults_0, voxi_j_k)
                        fprintf(fid, '\n%d;%d;%d;', i, j, k);
                        for w = 1:length(ppmShifts)
                            shift_id = num2str(ppmShifts(w));
                            shift_id = strrep(shift_id, '-', 'minus');
                            shift_id = strrep(shift_id, '.', 'dot');
                            if segmentation_analyzed
                                fprintf(fid, '%.4f;', spec_struct.voxel_results.(['voxresults_' shift_id]).(voxi_j_k).fGM);
                                fprintf(fid, '%.4f;', spec_struct.voxel_results.(['voxresults_' shift_id]).(voxi_j_k).fWM);
                                fprintf(fid, '%.4f;', spec_struct.voxel_results.(['voxresults_' shift_id]).(voxi_j_k).fCSF);
                            end
                            if parametric_analyzed
                                for q = 1:length(param_names)
                                    current_value = spec_struct.voxel_results.(['voxresults_' shift_id]).(voxi_j_k).(param_names{q});
                                    if ~isnan(current_value)
                                        fprintf(fid, '%.4f;', current_value);
                                    else
                                        fprintf(fid, '%.4f;', 0);
                                    end
                                end
                            end
                        end
                        if ~lcmodel_processed
                            fprintf(fid, '%s;', sel_names_struct.(voxi_j_k));
                        end
                    end
                end

                if lcmodel_processed
                    if isfield(spec_struct.voxel_results.lcmodel, voxi_j_k)
                        current_value5 = spec_struct.voxel_results.lcmodel.(voxi_j_k).(lcm_fields{5});
                        current_value6 = spec_struct.voxel_results.lcmodel.(voxi_j_k).(lcm_fields{6});
                        if ~(segmentation_analyzed || parametric_analyzed) % it means that the new line, row, col and sli have not been written in the file
                            fprintf(fid, '\n%d;%d;%d;', i, j, k);
                        end
                        fprintf(fid, '%0.4f;', current_value5); %FWHM
                        fprintf(fid, '%1.0f;', current_value6); %SNR
                        current_value7 = spec_struct.voxel_results.lcmodel.(voxi_j_k).(lcm_fields{7});
                        fprintf(fid, '%1.0f;%d;', current_value7); %Phase Shift
    
                        for d = 8:numel(lcm_fields)
                            current_title = lcm_fields{d};
                            if ismember(current_title, lcmodel_new_fields)
                                current_value = spec_struct.voxel_results.lcmodel.(voxi_j_k).(lcm_fields{d});
                                fprintf(fid, '%.15g;', current_value);
                            end
                        end
                        fprintf(fid, '%s;', sel_names_struct.(voxi_j_k));
                    end
                end
            end
        end
    end
    fclose(fid);
end
