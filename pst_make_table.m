function pst_make_table(spec_struct, table_file, lcmodel_processed, segmentation_analyzed, ppmShifts, parametric_analyzed, param_names, lcmodel_new_fields, sel_names_struct)
    
    spec_sz = [spec_struct.nXvoxels spec_struct.nYvoxels spec_struct.nZvoxels];

    disp('Generating results table...');
    csv_file = [table_file '.csv'];
    fid = fopen(csv_file, 'a');
    fprintf(fid, '%s;%s;', 'i', 'j');
    
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
        for i=4:numel(lcm_fields)
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
            voxi_j = ['vox' num2str(i), '_', num2str(j)];
            if segmentation_analyzed || parametric_analyzed
                if isfield(spec_struct.voxel_results.voxresults_0, voxi_j)
                    fprintf(fid, '\n%d;%d;', i, j);
                    for w = 1:length(ppmShifts)
                        shift_id = num2str(ppmShifts(w));
                        shift_id = strrep(shift_id, '-', 'minus');
                        shift_id = strrep(shift_id, '.', 'dot');
                        if segmentation_analyzed
                            fprintf(fid, '%.4f;', spec_struct.voxel_results.(['voxresults_' shift_id]).(voxi_j).fGM);
                            fprintf(fid, '%.4f;', spec_struct.voxel_results.(['voxresults_' shift_id]).(voxi_j).fWM);
                            fprintf(fid, '%.4f;', spec_struct.voxel_results.(['voxresults_' shift_id]).(voxi_j).fCSF);
                        end
                        if parametric_analyzed
                            for q = 1:length(param_names)
                                current_value = spec_struct.voxel_results.(['voxresults_' shift_id]).(voxi_j).(param_names{q});
                                if ~isnan(current_value)
                                    fprintf(fid, '%.4f;', current_value);
                                else
                                    fprintf(fid, '%.4f;', 0);
                                end
                            end
                        end
                    end
                    if ~lcmodel_processed
                        fprintf(fid, '%s;', sel_names_struct.(voxi_j));
                    end
                end
            end

            if lcmodel_processed
                if isfield(spec_struct.voxel_results.lcmodel, voxi_j)
                    current_value4 = spec_struct.voxel_results.lcmodel.(voxi_j).(lcm_fields{4});
                    current_value5 = spec_struct.voxel_results.lcmodel.(voxi_j).(lcm_fields{5});
                    if ~(segmentation_analyzed || parametric_analyzed) % it means that the new line, row and col have not been written in the file
                        fprintf(fid, '\n%d;%d;', i, j);
                    end
                    fprintf(fid, '%0.4f;', current_value4); %FWHM
                    fprintf(fid, '%1.0f;', current_value5); %SNR
                    current_value6 = spec_struct.voxel_results.lcmodel.(voxi_j).(lcm_fields{6});
                    fprintf(fid, '%1.0f;%d;', current_value6); %Phase Shift

                    for d = 7:numel(lcm_fields)
                        current_title = lcm_fields{d};
                        if ismember(current_title, lcmodel_new_fields)
                            current_value = spec_struct.voxel_results.lcmodel.(voxi_j).(lcm_fields{d});
                            if rem(d,2) == 1 
                                fprintf(fid, '%.15g;', current_value);
                            else
                                fprintf(fid, '%1.0f;', current_value);
                            end
                        end
                    end
                    fprintf(fid, '%s;', sel_names_struct.(voxi_j));
                end
            end

        end
    end
    fclose(fid);
end
