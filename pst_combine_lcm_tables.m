function spec_struct = pst_combine_lcm_tables(spec_struct, filename, ij)

    filename(filename == '^') = '_';
    cur_dir = pwd;
    [path, ~] = fileparts(filename);
    
    %check if lcm folder exists
    lcm_dir = fullfile(path, 'lcm');
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
    cd([path filesep 'lcm']);
    lcm_contents = dir();
    
    fprintf('%s\n', 'Combining the LCModel results into spec_struct.voxel_results...');
    % use selection to choose the files that will go into the table this time
    selected_files = {};
    for ind = 1:size(ij, 1)
        i = ij(ind, 1);
        j = ij(ind, 2);
        lcm_i = i; % have to switch to lcm style here
        lcm_j = spec_struct.nYvoxels - j + 1;
        for k = 1:size(lcm_contents, 1)
            if contains(lcm_contents(k).name, [num2str(lcm_j) '-' num2str(lcm_i) '.table'])
                selected_files{ind} = lcm_contents(k).name;
            end
        end
    end
    
    for m = 1:numel(selected_files)
        try 
            dataStruct = local_io_readlcmtab(selected_files{m}); % brilliant solution.
            spec_struct.voxel_results.lcmodel.(['vox' num2str(dataStruct.col) '_' num2str(dataStruct.row)]) = dataStruct; % save the file content to spec_struct
        catch
            % fprintf('%s %s%s\n', 'ERROR: Could not read the LCModel result .table file', selected_files(m), '!')
            fprintf('%s\n', 'ERROR: Could not read the LCModel result .table file!')
            row_col = regexp(selected_files(m),'\d*-\d*','match');
            row_col_split = regexp(row_col{1},'-','split');
            row = [row_col_split{1} ','];
            col = [row_col_split{2} ','];
            spec_struct.voxel_results.lcmodel.(['vox' col '_' row]) = [];
        end
    end
    fprintf('%s\n\n', 'Finished!')
    
    cd(cur_dir);
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
    row_col_minus = strfind(filename,'-'); 
    row_col_minus = row_col_minus(end); % the last minus in the filename is between the rows and cols
    
    row_col_end = filename(row_col_minus-2:row_col_minus+2);
    b = regexp(row_col_end,'\d*','Match');
    
    out.row = str2double(b{1});
    out.col = str2double(b{2});

    if isempty(out.row)
        out.row = 1;
        out.col = 1;
    end
catch e
        out.row = 1;
        out.col = 1;
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