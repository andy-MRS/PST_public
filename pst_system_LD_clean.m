function [s, msg] = pst_system_LD_clean(CMD)

LD_PATH = getenv('LD_LIBRARY_PATH');

LD_PATH_NEW = '';
reg_exp_ml = '\S*matlab\S*';

% remove all pathnames in LD_PATH which contain 'matlab' 
col_idxs = findstr(':', LD_PATH);
start = 1;
for i = 1:length(col_idxs)
    col_idx = col_idxs(i);
    path = LD_PATH(start:col_idx-1);
    if isempty(regexpi(path, reg_exp_ml))
        if isempty(LD_PATH_NEW)
            LD_PATH_NEW = path;
        else
            LD_PATH_NEW = [LD_PATH_NEW ':' path];
        end
    end
    start = col_idx+1;
end

setenv('LD_LIBRARY_PATH',LD_PATH_NEW)
setenv('GFORTRAN_STDIN_UNIT', '5')
setenv('GFORTRAN_STDOUT_UNIT', '6')
setenv('GFORTRAN_STDERR_UNIT', '0')
[s msg]=system(CMD);
setenv('LD_LIBRARY_PATH',LD_PATH)
setenv('GFORTRAN_STDIN_UNIT', '-1')
setenv('GFORTRAN_STDOUT_UNIT', '-1')
setenv('GFORTRAN_STDERR_UNIT', '-1')
