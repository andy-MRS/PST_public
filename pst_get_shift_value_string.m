function str = pst_get_shift_value_string(val)

        str = num2str(val);
        str = strrep(str, '-', 'minus');
        str = strrep(str, '.', 'dot');
end
