function out = pst_io_readlcmtab(filename)
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