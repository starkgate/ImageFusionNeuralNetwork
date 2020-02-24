clear all;
close all;
clc;
%% NSST tool box

% take all files in basepath
basepath = "P:\Cours\DIPLOM\GROSSER_BELEG\medical-image-fusion-neural-network\img\";
mris = dir(basepath + "training\*_MRI.nii"); mris = struct2cell(mris); mris = mris(1,1:end);
labels = dir(basepath + "training\*_LABEL.nii"); labels = struct2cell(labels); labels = labels(1,1:end);
siz=size(mris); siz=siz(2); fprintf("Loaded %d MRI images\n", siz);

parfor i = 1:100
    %% get MR volume
    mri = mris(i); mri = mri{1};
    label = labels(i); label = label{1};
    fprintf("[%d/%d] Merging %s\n", i, siz, mri);

    result_name = mri;

    if(exist(basepath + "groundtruth-training/" + result_name, 'file') ~= 2)
        source_mask = int16(or(source_label == 4, source_label == 1)); % ignore edema

        source_mri = source_mri .* source_mask; % apply mask
        source_mri = double(source_mri)/255;

        max_slice = size(source_mri,3);
        % apply NSST recursively to get 1 slice
        while max_slice ~= 1 % 32 > 16 > 8 > 4 > 2 > 1 slice
            max_slice = max_slice / 2;

            % we need an even number of slices to merge 2-by-2
            if max_slice ~= floor(max_slice)
                max_slice = ceil(max_slice);
                source_mri(:,:,max_slice*2) = zeros(size(source_mri,1),size(source_mri,2));
            end

            for slice = 1:max_slice % merge along z axis and halve number of slices
                slice1=source_mri(:,:,(slice-1)*2 + 1);
                slice2=source_mri(:,:,(slice-1)*2 + 2);

                %imshow(mat2gray(double(slice1)));
                %imshow(mat2gray(double(slice2)));

                % image fusion with NSST-PAPCNN
                %slicef=(slice1+slice2)/2; % average
                slicef=fuse_NSST_PAPCNN(slice1,slice2);

                source_mri(:,:,slice)=slicef; % fill result slice
                %imshow(mat2gray(imgf));
            end
        end
        result = uint16(source_mri(:,:,1)*255);
        imwrite(result, basepath + "groundtruth-training/" + result_name + ".png");
        fprintf("[%d/%d] Saved %s as %s\n", i, siz, mri, result_name);
    end
end