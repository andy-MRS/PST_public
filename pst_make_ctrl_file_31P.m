function ctrl_name = pst_make_ctrl_file_31P(defdir, filename, basis_file, icolst, irowst, select_name, raw_name, raw_name_water, lcm_data_file)

hdr = pst_read_spec_header(filename);
[path, name] = fileparts(filename);
if isempty(select_name)
    new_name = name;
else
    new_name = sprintf('%s', select_name, '_', name);
end
if exist([path filesep 'lcm'], 'dir') ~= 7
    mkdir(path, 'lcm');
end

col_str = num2str(icolst);
row_str = num2str(irowst);
ps_name = fullfile(path, 'lcm', [new_name '.ps']);
table_name = fullfile(path, 'lcm', [new_name '.table']);
csv_name = fullfile(path, 'lcm', [new_name '_' row_str '-' col_str '.csv']);
coord_name = fullfile(path, 'lcm', [new_name '.coord']);
ctrl_name = fullfile(path, 'lcm', [name '_' row_str '-' col_str '.control']);
hzpppm = hdr.transmit_frequency/10^6;
nunfil = hdr.samples;
t_dwell = 1/hdr.BW;
deltat = t_dwell;
ndrows = hdr.dim(1);
ndcols = hdr.dim(2);
ndslic = hdr.dim(3);
lcoord = 0;
key = 210387309;


fid = fopen(ctrl_name, 'w');
% data = load(lcm_data_file);
lcm_str = sprintf(' %s\n', '$LCMODL');

title = sprintf(' %s''%s''\n', 'title = ', select_name);
if ispc
    filbas_str = sprintf(' %s''%s''\n', 'filbas = ', [defdir filesep 'LCModel' filesep 'basis-sets' filesep basis_file]);
elseif isunix
    filbas_str = sprintf(' %s''%s''\n', 'filbas = ', ['~' filesep '.lcmodel' filesep 'basis-sets' filesep basis_file]);
end
filraw_str = sprintf(' %s''%s''\n', 'filraw = ', raw_name);
filps_str = sprintf(' %s''%s''\n', 'filps = ', ps_name);
filtab_str = sprintf(' %s''%s''\n', 'filtab = ', table_name);
ltable_str = sprintf(' %s%d\n', 'ltable = ', 7);
filcsv_str = sprintf(' %s''%s''\n', 'filcsv = ', csv_name);
lcsv_str = sprintf(' %s%d\n', 'lcsv = ', 0);
filcoo_str = sprintf(' %s''%s''\n', 'filcoo = ', coord_name);
% if isfield(data, 'lcm_coord')
%     lcm_coord = data.lcm_coord;
%     if lcm_coord
%         lcoord = 9;
%     end
% end
varNames = {};
varValues = {};
% if isfield(data , 'new_params') && ~isempty(data.new_params)
%     new_params = data.new_params;
%     for i =1:length(new_params)
%         line = strtrim(new_params{i});
% 
%         if ~isempty(line)
%             tokens = strsplit(line , '=');
%             varName = strtrim(tokens{1});
%             varValue= strtrim(tokens{2});
% 
%             varNames{end+1} = varName;
%             varValues{end+1} = varValue;
% 
%         end
%     end
% end 


lcoord_str = sprintf(' %s%d\n', 'lcoord = ', lcoord);
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

% degzer = data.degzer;
% sddegz = data.sddegz;
% degppm = data.degppm;
% sddegp = data.sddegp;
% ppmend = data.ppmend;
% dkntmn = data.dkntmn;
% nsimul = data.nsimul;
% VITRO = 'F'; % Default value
% if isfield(data, 'VITRO')
%     VITRO = data.VITRO;  % Retrieve VITRO value
% end

% ppmst = data.ppmst;

% degzer_str = sprintf(' %s%d\n', 'degzer = ', degzer);
% sddegz_str = sprintf(' %s%1.1f\n', 'sddegz = ', sddegz);
% degppm_str = sprintf(' %s%1.1f\n', 'degppm = ', degppm);
% sddegp_str = sprintf(' %s%1.1f\n', 'sddegp = ', sddegp);
% ppmend_str = sprintf(' %s%1.1f\n', 'ppmend = ', ppmend);
% dkntmn_str = sprintf(' %s%1.1f\n', 'dkntmn = ', dkntmn);
% nsimul_str = sprintf(' %s%d\n', 'nsimul = ', nsimul);
% vitro_str = sprintf(' %s%s\n', 'VITRO = ', VITRO);
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
fwrite(fid, lcoord_str, 'char');
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
% fwrite(fid, vitro_str, 'char');

% fwrite(fid, atth2o_str, 'char');
% fwrite(fid, attmet_str, 'char');
% fwrite(fid, wconc_str, 'char');
% if isfield(data, 'omit_list')
%     omit_list = data.omit_list;
%     size = omit_list.size;
%     if size > 0
%         nomit_str = sprintf(' %s%d\n', 'nomit = ', size);
%         fwrite(fid, nomit_str, 'char');
%         it = omit_list.iterator; 
%         i = 1;
%         while it.hasNext
%             chomit_str = sprintf(' %s%d%s''%s''\n', 'chomit(', i, ') = ', ...
%                 it.next);
%             fwrite(fid, chomit_str, 'char');
%             i = i + 1;
%         end
%     end
% end
% if isfield(data, 'sptype')
%     sptype = data.sptype;
%     sptype_str = sprintf(' %s''%s''\n', 'sptype = ', sptype);
%     fwrite(fid, sptype_str, 'char');
% end
% fwrite(fid, degzer_str, 'char');
% fwrite(fid, sddegz_str, 'char');
% fwrite(fid, degppm_str, 'char');
% fwrite(fid, sddegp_str, 'char');
% fwrite(fid, ppmend_str, 'char');
% fwrite(fid, dkntmn_str, 'char');
% fwrite(fid, nsimul_str, 'char');
 
for i =1:length(newparams_str)
     fwrite(fid, newparams_str{i}, 'char');
end
% if ppmst ~= 4.0
%     ppmst_str = sprintf(' %s%1.1f\n', 'ppmst = ', ppmst);
%     fwrite(fid, ppmst_str, 'char');
% end
fprintf(fid, ' PHASE1=-59.7\n');

fwrite(fid, [' PPMCEN=0' newline], 'char');
fwrite(fid, [' NUSE1=3' newline], 'char');
fprintf(fid, " CHUSE1(1)='PCr'\n");
fprintf(fid, " CHUSE1(2)='Pi'\n");
fprintf(fid, " CHUSE1(3)='NADP'\n");
fwrite(fid, [' DOREFS=.FALSE.,.TRUE.' newline], 'char');
fwrite(fid, [' NREFPK(2)=1' newline], 'char');
fwrite(fid, [' PPMREF(1,2)=0' newline], 'char');
fwrite(fid, [' HZREF(1,2)=2*0.' newline], 'char');
fwrite(fid, [' ECCDON=.FALSE.' newline], 'char');

fprintf(fid, " NAMREL='PCr'\n");
fprintf(fid, " CHCOMB(1)='PE+PC'\n");
fprintf(fid, " CHCOMB(2)='GPE+GPC'\n");
fprintf(fid, " CHCOMB(3)='ATPa+ATPb+ATPg'\n");
fprintf(fid, " CHEXT2(1)='MP'\n");

fwrite(fid, [' RFWHM=3' newline], 'char');
fwrite(fid, [' XSTEP=5.' newline], 'char');
fwrite(fid, [' FWHMBA=0.049' newline], 'char');
fwrite(fid, [' NSIDMN=2' newline], 'char');
fwrite(fid, [' ALPBMN=108' newline], 'char');
fwrite(fid, [' ALPBMX=54000' newline], 'char');
fwrite(fid, [' ALPBPN=135' newline], 'char');
fwrite(fid, [' ALPBST=162' newline], 'char');
fwrite(fid, [' DESDSH=0.01' newline], 'char');
fwrite(fid, [' CONREL=4.00' newline], 'char');
fwrite(fid, [' NEACH=0' newline], 'char');
fwrite(fid, [' NCOMBI=3' newline], 'char');

fwrite(fid, [' NOMIT=0' newline], 'char');
fwrite(fid, [' NRATIO=0' newline], 'char');
fwrite(fid, [' SHIFMN=-1' newline], 'char');
fwrite(fid, [' SHIFMX=1' newline], 'char');
fwrite(fid, [' PPMSHF=0' newline], 'char');

fwrite(fid, [' DEEXT2=7' newline], 'char');
fwrite(fid, [' DESDT2=7' newline], 'char');
fwrite(fid, [' NEXT2=1' newline], 'char');

fwrite(fid, [' ALEXT2(1)=400' newline], 'char');
fwrite(fid, [' ALEXT2(2)=400' newline], 'char');

fwrite(fid, [' DEGZER=0' newline], 'char');
fwrite(fid, [' DEGPPM=0' newline], 'char');
fwrite(fid, [' SDDEGZ=5.' newline], 'char');
fwrite(fid, [' SDDEGP=0.15' newline], 'char');
fwrite(fid, [' DKNTMN=2*99.' newline], 'char');
fwrite(fid, [' VITRO=.FALSE.' newline], 'char');
fwrite(fid, [' PPMST=19.5' newline], 'char');
fwrite(fid, [' PPMEND=-19.5' newline], 'char');

fwrite(fid, end_str, 'char');
fclose(fid);
end