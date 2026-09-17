function spec_struct = pst_combine_lcm_tables(spec_struct, ijk)

    %check if lcm folder exists
    lcm_dir = fullfile(spec_struct.spec_processing_path, 'lcm');
    if ~isfolder(lcm_dir)
        fprintf('LCM folder not found. Creating table without LCM data.\n');
        return;
    end
    
    % try cleaning the spec_struct.voxel_results.lcmodel field (if processing was run before)
    try
        spec_struct.voxel_results = rmfield(spec_struct.voxel_results, "lcmodel");
    catch
    end
    
    % take only tables from the folder
    cd([spec_struct.spec_processing_path filesep 'lcm']);
    lcm_contents = dir();
    
    fprintf('%s\n', 'Combining the LCModel results into spec_struct.voxel_results...');
    % use selection to choose the files that will go into the table this time
    selected_files = {};
    for ind = 1:size(ijk, 1)
        i = ijk(ind, 1);
        j = ijk(ind, 2);
        k = ijk(ind, 3);
        lcm_i = i; % have to switch to lcm style here
        lcm_j = spec_struct.nYvoxels - j + 1;
        lcm_k = k;
        for q = 1:size(lcm_contents, 1)
            if contains(lcm_contents(q).name, [num2str(lcm_j) '-' num2str(lcm_i) '-' num2str(lcm_k) '.table'])
                selected_files{ind} = lcm_contents(q).name;
            end
        end
    end
    
    for m = 1:numel(selected_files)
        try 
            dataStruct = local_io_readlcmtab(selected_files{m}); % brilliant solution.
            spec_struct.voxel_results.lcmodel.(['vox' num2str(dataStruct.col) '_' num2str(dataStruct.row) '_' num2str(dataStruct.sli)]) = dataStruct; % save the file content to spec_struct
        catch
            fprintf('%s\n', 'ERROR: Could not read the LCModel result .table file!')
            row_col_sli = regexp(selected_files(m),'\d*-\d*-\d*','match');
            row_col_sli_split = regexp(row_col_sli{1},'-','split');
            row = [row_col_sli_split{1} ','];
            col = [row_col_sli_split{2} ','];
            sli = [row_col_sli_split{3} ','];
            spec_struct.voxel_results.lcmodel.(['vox' col '_' row '_' sli]) = [];
        end
    end
    fprintf('%s\n\n', 'Finished!')
    
end

function out = local_io_readlcmtab(filename)
%io_readlcmtab.m
%Jamie Near, McGill University 2014.
%
% USAGE:
% out = io_readlcmtab(filename) 
% 
% DESCRIPTION:
% Reads a LCModel .table output file and stores the metabolite 
% concentrations into a matlab structure array.
% 
% INPUTS:
% filename   = filename of the LCModel .table file.
%
% OUTPUTS:
% out        = A structure containing the LCmodel concentration estimates 
%               and CRLB values for each metabolite.

%try to incorporate the header information into a structure called 'info'
fid=fopen(filename);

try 
    row_col_sli_minuses = strfind(filename,'-'); 
    row_col_sli_minuses = row_col_sli_minuses(end); % the last minus in the filename is between the cols and slices
    
    row_col_sli_ending = filename(row_col_sli_minuses-5:row_col_sli_minuses+2);
    b = regexp(row_col_sli_ending,'\d*','Match');
    
    out.row = str2double(b{1});
    out.col = str2double(b{2});
    out.sli = str2double(b{3});

    if isempty(out.row)
        out.row = 1;
        out.col = 1;
        out.sli = 1;
    end
catch e
        out.row = 1;
        out.col = 1;
        out.sli = 1;
end

line=fgets(fid);
line=fgets(fid);
expr = 'Row#\d+\s+Col#\d+\s+(?<name>.+)$';
tok = regexp(line, expr, 'names');
try
    out.selection = strtrim(tok.name);
catch exception
    out.selection = 'SV';
end

line=fgets(fid);
line=fgets(fid);

FWHM_index=strfind(line,'FWHM');
while isempty(FWHM_index) && ~feof(fid)
    line=fgets(fid);
    FWHM_index=strfind(line,'FWHM');
end

equals_indices = strfind(line,'=');
ppm_index = strfind(line,'ppm');
SN_index = strfind(line,'S/N');

out.FWHM=str2double(line(equals_indices(1)+1:ppm_index-1));
out.SNR=str2double(line(equals_indices(2)+1:end));
line=fgets(fid);
line=fgets(fid);
ph_index = strfind(line,'Ph');
deg_index = strfind(line,'deg');
out.Ph_shift = str2double(line(ph_index+4:deg_index(1,1)-1));

fclose(fid);

fid=fopen(filename);

CONC_index=[];
while isempty(CONC_index) && ~feof(fid)
    line=fgets(fid);
    CONC_index=strfind(line,'$$CONC');
end

line=fgets(fid);
line=fgets(fid);

% Now begin to read the data.  LCModel table files have a % sign marking each
% line of Data.  Search for the semicolon on each line and read only the 
%data that preceeds it.  

line_index = 3;
while length(line)>2
    out.(genvarname(strtrim(line(24:end))))=str2double(line(1:9));
    out.(genvarname([strtrim(line(24:end)) ' %SD']))=str2double(line(11:13));
    line=fgets(fid);
    line_index = line_index + 2;
end

fclose(fid);

end