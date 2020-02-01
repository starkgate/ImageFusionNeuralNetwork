clear all;
close all;
clc;
%% NSST tool box
addpath(genpath('shearlet'));
%% get MR volume
source_mr = h5read('sourceimages/GBM_1484481_data.h5', '/vol'); % hospital dataset
source_label = h5read('sourceimages/GBM_1484481_label.h5', '/vol');

source_mask = double(source_label ~= 0);
%source_mr = (source_mr .* source_mask) / 255; % apply mask and normalize
source_mr = source_mr / 255;

source_mr(:, 481:640, :) = ones;

max_slice = size(source_mr,3);
% apply NSST recursively to get 1 slice
while max_slice ~= 1 % 32 > 16 > 8 > 4 > 2 > 1 slice
    max_slice = max_slice / 2;
    
    % we need an even number of slices to merge 2-by-2
    if max_slice ~= floor(max_slice) 
        max_slice = ceil(max_slice);
        source_mr(:,:,max_slice*2) = zeros(size(source_mr,1),size(source_mr,2));
    end
    
    for slice = 1:max_slice % merge along z axis and halve number of slices
        slice1=source_mr(:,:,(slice-1)*2 + 1);
        slice2=source_mr(:,:,(slice-1)*2 + 2);

        %imshow(mat2gray(double(slice1)));
        %imshow(mat2gray(double(slice2)));

        % image fusion with NSST-PAPCNN 
        %slicef=(slice1+slice2)/2; % average
        %slicef=max(slice1,slice2);
        [slice1_x,slice1_y] = find(slice1); % crop
        [slice2_x,slice2_y] = find(slice2);
        
        min_x = min(min(slice1_x), min(slice2_x),'omitnan');
        max_x = max(max(slice1_x), max(slice2_x),'omitnan');
        delta_x = abs(min_x-max_x);
        min_y = min(min(slice1_y), min(slice2_y),'omitnan');
        max_y = max(max(slice1_y), max(slice2_y),'omitnan');
        delta_y = abs(min_y-max_y);
        
%         if(not(isempty(max_x) || isempty(min_x) || isempty(max_y) || isempty(min_y)))
%             if(delta_x > delta_y)
%                 square = delta_x - delta_y;
%                 if(max_y ~= 640)
%                     space = 640 - max_y; % how much larger the square can be made on the right
%                     max_y = max_y + min(space, square);
%                     square = square - space;
%                 end
%                 if(min_y ~= 1 && square > 0) % if the square isn't large enough, make it bigger on the left
%                     space = min_y - 1;
%                     min_y = min_y - min(space, square);
%                 end
%             elseif (delta_y > delta_x)
%                 square = delta_y - delta_x;
%                 if(max_x ~= 640)
%                     space = 640 - max_x; % how much larger the square can be made on the top
%                     max_x = max_x + min(space, square);
%                     square = square - space;
%                 end
%                 if(min_x ~= 1 && square > 0) % if the square isn't large enough, make it bigger on the bottom
%                     space = min_x - 1;
%                     min_x = min_x - min(space, square);
%                 end
%             end
%             slicef = zeros(640,640);
%             slicef(min_x:max_x,min_y:max_y)=fuse_NSST_PAPCNN(slice1(min_x:max_x,min_y:max_y),slice2(min_x:max_x,min_y:max_y)); 
%         else
%             slicef=fuse_NSST_PAPCNN(slice1,slice2);
%         end
        slicef = (slice1+slice2)/2;
        
    end
        
    source_mr(:,:,slice)=slicef; % fill result slice
    %imshow(mat2gray(imgf));
end

result = uint16(source_mr(:,:,1)*255);
imwrite(result,'results/fused.tif');