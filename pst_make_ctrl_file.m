function ctrl_name = pst_make_ctrl_file(spec_struct, defdir, basis_file, icolst, irowst, select_name, raw_name, raw_name_water, lcm_data_file)

[path, name] = fileparts(spec_struct.spec_file);
if isempty(select_name)
    new_name = name;
else
    new_name = sprintf('%s', select_name, '_', name);
end

col_str = num2str(icolst);
row_str = num2str(irowst);
ps_name = fullfile(path, 'lcm', [new_name '.ps']);
table_name = fullfile(path, 'lcm', [new_name '.table']);
csv_name = fullfile(path, 'lcm', [new_name '_' row_str '-' col_str '.csv']);
print_name = fullfile(path, 'lcm', [new_name '_' row_str '-' col_str '.print']);
coord_name = fullfile(path, 'lcm', [new_name '.coord']);
ctrl_name = fullfile(path, 'lcm', [name '_' row_str '-' col_str '.control']);
hzpppm = spec_struct.txfrq/10^6;
nunfil = spec_struct.samples;
t_dwell = 1/spec_struct.spectralwidth;
deltat = t_dwell;
ndrows = spec_struct.nYvoxels;
ndcols = spec_struct.nXvoxels;
ndslic = spec_struct.nZvoxels;
key = 210387309;
atth2o = '1.0';
attmet = '1.0';
wconc = '1.0';

if ~isempty(raw_name_water)
    dows = 'T';
else
    dows = 'F';
end

fid = fopen(ctrl_name, 'w');
data = load(lcm_data_file);
lcm_str = sprintf(' %s\n', '$LCMODL');

title = sprintf(' %s''%s''\n', 'title = ', select_name);
if ispc
    filbas_str = sprintf(' %s''%s''\n', 'filbas = ', [defdir filesep 'LCModel' filesep 'basis-sets' filesep basis_file]);
elseif isunix
    [~, home] = system('echo -n $HOME');
    filbas_str = sprintf(' %s''%s''\n', 'filbas = ', [home filesep '.lcmodel' filesep 'basis-sets' filesep basis_file]);
end
filraw_str = sprintf(' %s''%s''\n', 'filraw = ', raw_name);
if ~isempty(raw_name_water) 
    filwater_str = sprintf(' %s''%s''\n', 'filh2o = ', raw_name_water);
end
filps_str = sprintf(' %s''%s''\n', 'filps = ', ps_name);
filtab_str = sprintf(' %s''%s''\n', 'filtab = ', table_name);
ltable_str = sprintf(' %s%d\n', 'ltable = ', 7);
filcsv_str = sprintf(' %s''%s''\n', 'filcsv = ', csv_name);
lcsv_str = sprintf(' %s%d\n', 'lcsv = ', 0);
filcoo_str = sprintf(' %s''%s''\n', 'filcoo = ', coord_name);
filpri_str = sprintf(' %s''%s''\n', 'filpri = ', print_name);

varNames = {};
varValues = {};
if isfield(data , 'new_params') && ~isempty(data.new_params)
    new_params = data.new_params;
    for i =1:length(new_params)
        line = strtrim(new_params{i});

        if ~isempty(line)
            tokens = strsplit(line , '=');
            varName = strtrim(tokens{1});
            varValue= strtrim(tokens{2});

            varNames{end+1} = varName;
            varValues{end+1} = varValue;

        end
    end
end 


hzpppm_str = sprintf(' %s%.4e\n', 'hzpppm = ', hzpppm);
nunfil_str = sprintf(' %s%d\n', 'nunfil = ', nunfil);
deltat_str = sprintf(' %s%.3e\n', 'deltat = ', deltat);
ndcols_str = sprintf(' %s%d\n', 'ndcols = ', ndcols);
ndrows_str = sprintf(' %s%d\n', 'ndrows = ', ndrows);
ndslic_str = sprintf(' %s%d\n', 'ndslic = ', ndslic);
icolst_str = sprintf(' %s%d\n', 'icolst = ', icolst);
icolen_str = sprintf(' %s%d\n', 'icolen = ', icolst);
irowst_str = sprintf(' %s%d\n', 'irowst = ', irowst);
irowen_str = sprintf(' %s%d\n', 'irowen = ', irowst);
key_str = sprintf(' %s%d\n', 'key = ', key);

newparams_str = {};

for i =1:length(varNames)
     newparams_str{end+1}=sprintf(' %s = %s\n', varNames{i}, varValues{i});
end

atth2o_str = sprintf(' %s%s\n', 'ATTH2O = ', atth2o);
attmet_str = sprintf(' %s%s\n', 'ATTMET = ', attmet);
wconc_str = sprintf(' %s%s\n', 'WCONC = ', wconc);
degzer = data.degzer;
sddegz = data.sddegz;
degppm = data.degppm;
sddegp = data.sddegp;
ppmend = data.ppmend;
dkntmn = data.dkntmn;
if isfield(data, 'neach')
    neach = data.neach;
end
nsimul = data.nsimul;
VITRO = 'F'; % Default value
if isfield(data, 'VITRO')
    VITRO = data.VITRO;  % Retrieve VITRO value
end

ppmst = data.ppmst;
degzer_str = sprintf(' %s%d\n', 'degzer = ', degzer);
sddegz_str = sprintf(' %s%1.1f\n', 'sddegz = ', sddegz);
degppm_str = sprintf(' %s%1.1f\n', 'degppm = ', degppm);
sddegp_str = sprintf(' %s%1.1f\n', 'sddegp = ', sddegp);
ppmend_str = sprintf(' %s%1.1f\n', 'ppmend = ', ppmend);
dkntmn_str = sprintf(' %s%1.1f\n', 'dkntmn = ', dkntmn);
neach_str = sprintf(' %s%d\n', 'neach = ', neach);
nsimul_str = sprintf(' %s%d\n', 'nsimul = ', nsimul);
vitro_str = sprintf(' %s%s\n', 'VITRO = ', VITRO);
dows_str = sprintf(' %s%s\n', 'dows = ', dows);
end_str = sprintf(' %s\n', '$END');

fwrite(fid, lcm_str, 'char');
fwrite(fid, title, 'char');
fwrite(fid, filbas_str, 'char');
fwrite(fid, filraw_str, 'char');
if ~isempty(raw_name_water) 
    fwrite(fid, filwater_str, 'char');
end
fwrite(fid, filps_str, 'char');
fwrite(fid, filtab_str, 'char');
fwrite(fid, ltable_str, 'char');
fwrite(fid, filcsv_str, 'char');
fwrite(fid, lcsv_str, 'char');
fwrite(fid, filcoo_str, 'char');
fwrite(fid, filpri_str, 'char');
fwrite(fid, hzpppm_str, 'char');
fwrite(fid, nunfil_str, 'char');
fwrite(fid, deltat_str, 'char');
fwrite(fid, ndcols_str, 'char');
fwrite(fid, ndrows_str, 'char');
fwrite(fid, ndslic_str, 'char');
fwrite(fid, icolst_str, 'char');
fwrite(fid, icolen_str, 'char');
fwrite(fid, irowst_str, 'char');
fwrite(fid, irowen_str, 'char');
fwrite(fid, key_str, 'char');
fwrite(fid, vitro_str, 'char');

fwrite(fid, atth2o_str, 'char');
fwrite(fid, attmet_str, 'char');
fwrite(fid, wconc_str, 'char');
if isfield(data, 'omit_list')
    omit_list = data.omit_list;
    size = omit_list.size;
    if size > 0
        nomit_str = sprintf(' %s%d\n', 'nomit = ', size);
        fwrite(fid, nomit_str, 'char');
        it = omit_list.iterator; 
        i = 1;
        while it.hasNext
            chomit_str = sprintf(' %s%d%s''%s''\n', 'chomit(', i, ') = ', ...
                it.next);
            fwrite(fid, chomit_str, 'char');
            i = i + 1;
        end
    end
end
if isfield(data, 'sptype')
    sptype = data.sptype;
    sptype_str = sprintf(' %s''%s''\n', 'sptype = ', sptype);
    fwrite(fid, sptype_str, 'char');
end
fwrite(fid, degzer_str, 'char');
fwrite(fid, sddegz_str, 'char');
fwrite(fid, degppm_str, 'char');
fwrite(fid, sddegp_str, 'char');
fwrite(fid, ppmend_str, 'char');
fwrite(fid, dkntmn_str, 'char');
fwrite(fid, neach_str, 'char');
fwrite(fid, nsimul_str, 'char');
fwrite(fid, dows_str, 'char');
 
for i =1:length(newparams_str)
     fwrite(fid, newparams_str{i}, 'char');
end
if ppmst ~= 4.0
    ppmst_str = sprintf(' %s%1.1f\n', 'ppmst = ', ppmst);
    fwrite(fid, ppmst_str, 'char');
end
fwrite(fid, end_str, 'char');
fclose(fid);
end