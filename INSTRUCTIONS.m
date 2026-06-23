% Parametric maps and Spectroscopy Tool (PST)

% INSTRUCTIONS:

% EXAMPLE FOLDER STRUCTURE:
% subject_folder\
%     -- .SDAT or .RDA
%
%     subject_folder\mri\
%                      --any_ref_image_for_example_T2w.nii
%
%     subject_folder\mri\segm\
%                             --c1Any_name.nii, c2Any_name.nii, c3Any_name.nii
%
%     subject_folder\mri\qmri
%                             --qmri1.nii, qmri2.nii

% 1. Load .nii reference image

% 2. Load Metabolite MRSI (.SDAT or .RDA). Currently, only Transverse orientation of MRSI is supported.

% 3. Load Water MRSI (should have the same matrix size as metabolite MRSI).

% 4. Click 'Load data'

% 5. Select voxels by drawing a rectangular. You can define several selections one after another with different names.

% 6. Prior to clicking 'LCModel', set up parameters in the LCModel tab of the main menu

% 7. Click LCModel to run the processing. If Parallel Computing Toolbox is available, it will be used.

% 8. After processing, you may click on the processed voxel to open the LCModel PS (converted to PNG). Use mouse wheel to scroll the pages and CTRL+mouse wheel to zoom in and out.

% 9. If you provide T1 segmentation and/or qMRI maps, the 'Process composition button will become active. 
% The segmentation and/or qMRI maps should be generated in advance, PST does not produce them.
% Segmentation files should be named c1whatever, c2whatever and c3whatever and 
% SHOULD BE LOCATED in the sub-folder of the reference images' folder named 'segmentation', or 'Segmentation', or 'segm', or 'Segm'.
% If T1w is used as a reference image, the c1T1w, c2T1w and c3T1w may stay in the folder of the reference image.
% The parametric maps SHOULD BE LOCATED in the sub-folder of the reference images' folder named 'qMRI', or 'qmri, or 'QMRI'.


% 10. After running LCModel and/or voxel composition processing, 'Make table' button becomes active. You may type-in the filename and click on 'Browse' to select the directory where to save it
% (or just click make table and the Browser will open if the path was left empty).
% On clicking 'Make table' a window will pop up allowing to select the metabolites that should be saved in the final CSV table. Be aware that the ';' sign is currently a separator and not '\t'. Might be changed in future.

% Optional: check out the CSDE feature. For that you should know some parameters of the pulse sequence and the pulses used. 
% WARNING!: Siemens CSDE is still under development and not in any way verified!
% WARNING [2]: Presets should be checked for every scanner used! There's no guarantee that the pulse properties 100% match.
