function spec_struct = pst_check_water_dim(spec_struct)

% Work in progress


% this function checks if water MRSI resolution is equal to the metabolite
% MRSI resolution. If not, water is interpolated 
    spec_struct = spec_struct;
    if spec_struct.water_struct.nXvoxels < spec_struct.nXvoxels || spec_struct.water_struct.nYvoxels < spec_struct.nYvoxels || spec_struct.water_struct.nZvoxels < spec_struct.nZvoxels
        fprintf('%s\n', 'Interpolating the MRSI water reference data...');
        diff(1) = spec_struct.nXvoxels - spec_struct.water_struct.nXvoxels;
        diff(2) = spec_struct.nYvoxels - spec_struct.water_struct.nYvoxels;
        diff(3) = spec_struct.nZvoxels - spec_struct.water_struct.nZvoxels;
        
        % split into dims
        spec_struct.water_struct.fids_reshaped = reshape(spec_struct.water_struct.fids, spec_struct.water_struct.sz(1), spec_struct.water_struct.nXvoxels, spec_struct.water_struct.nYvoxels, spec_struct.water_struct.nZvoxels);

        % interpolate 
        fftdata = spec_struct.water_struct.fids_reshaped;
        if (diff(1) > 0)
            fftdata = fftshift(fft(fftdata, [], 2), 2);
            fftdata = padarray(fftdata, [0 diff(1)/2 0 0]);
            newdata = ifft(ifftshift(fftdata, 2), [], 2);
        end
        if (diff(2) > 0)
            fftdata = fftshift(fft(newdata, [], 3), 3);
            fftdata = padarray(fftdata, [0 0 diff(2)/2 0]);
            newdata = ifft(ifftshift(fftdata, 3), [], 3);
        end
        if (diff(3) > 0)
            fftdata = fftshift(fft(newdata, [], 4), 4);
            fftdata = padarray(fftdata, [0 0 0 diff(3)/2]);
            newdata = ifft(ifftshift(fftdata, 4), [], 4);
        end
        spec_struct.water_struct.fids_reshaped = newdata;
        
        % merge dims back
        spec_struct.water_struct.fids = reshape(spec_struct.water_struct.fids_reshaped, spec_struct.water_struct.sz(1), []);
    end

end
