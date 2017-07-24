% MATLAB script for Assessment Item-1
close all;

% Step-1: Load input image
InputImage = imread('AssignmentInput.jpg');
figure;
imshow(InputImage);
title('Step-1: Load input image');

% Step-2: Conversion of input image to greyscale
% Using NTSC conversion formula, greyscale image can be created by
% performing a weighted sum on each R,G,B section of an RGB image.
red = InputImage(:,:,1); 
green = InputImage(:,:,2);
blue = InputImage(:,:,3);
I = (0.299 * red) + (0.587 * green) + (0.114 * blue);
figure;
imshow(I);
title('Step-2: Conversion of input image to greyscale');

% Step-3: Noise removal
% Median filter performs neighbourhood operation on each pixel to change
% the value of the pixel to the median of it's neighbourhood.
% 3x3 kernal, Symmetric padding at the image boundary 
mf = medfilt2(I, [3 3], 'symmetric');
figure;
imshow(mf);
title('Step-3: Median filter Noise removal - 3x3 mask');

% Step-4: Enhancing the image - justify choice
% adaptive histeq
% This is the chosen enhancement to contue to step 5 with.
% Splits the image into sections before performing histogram functions on
% each section seperately rather than the whole image at once.
mfadaptHE = adapthisteq(mf);
figure;
imshow(mfadaptHE);
title('Step-4: Enhanced with adaptive histogram equalisation');
%figure;
%imhist(mfadaptHE);
%title('Image enhanced with adaptive histogram equalisation');

% The other tested enhancements are commented out below should they be
% needed.

% Contrast stretching
% Replaces each pixel value with a darker or lighter value depending on the
% chosen threshold (currently set at 0.75).
%Im2D = 255*im2double(mf);
%mi = min(min(Im2D));
%ma = max(max(Im2D));
%contStretchedIm = imadjust(mf, [0.75; ma/255], [0;1]);
%figure;
%imshow(contStretchedIm);
%title('Step-4: Enhanced with contrast stretching');
%figure;
%imhist(contStretchedIm);
%title('Image enhanced with contrast stretching');

% Histogram equalisation
% Equalises the image histogram based on the probability values for each
% pixel value.
%mfhe = histeq(mf);
%figure;
%imshow(mfhe);
%title('Step-4: Enhanced with histogram equalisation');
%figure;
%imhist(mfhe);
%title('Image enhanced with histogram equalisation');

% Step-5: Segment the image into foreground and background
% Loops through image and assigns pixels to 1 or 0 (225 or 0) depending on 
% if they are above or below a certain intensity value. Uses Otsu method to
% get the optimal threshold.
bi = zeros(size(mfadaptHE));
threshold = (graythresh(mfadaptHE)) * 255;

for row = 1:size(bi, 1)
    for col = 1:size(bi, 2)
        if ((mfadaptHE(row,col)) > (threshold))
            bi(row,col) = 255;
        end
    end
end

figure;
imshow(~bi); % Tilde character inverts the binary image so that it is white objects on a black background and not the other way around.
title('Step-5: Segmented image');

% Step-6: Use of morphological processing
se = strel('disk', 2); % Disk with radius of 2, found using heuristics. 

% Opening the image to remove noise and smooth out shapes.
biOpen = imopen(~bi, se);
% Closing the already imopened image to close some remaining holes in the starfish
biClose = imclose(biOpen, se);
figure;
imshow(biClose);
title('Step 6: Use of morphological processing - imopen + imclose');

% Step-7: Recognition of starfishes
% First labels all components in the image, then accesses the properties of
% each component using regionprops.
CC = bwconncomp(biClose);
stats = regionprops('table',CC, 'Area', 'Perimeter');
area = mean(stats.Area);
perim = mean(stats.Perimeter);

metric = 0;
E = zeros(size(biClose)); % Creating a new empty image to write starfish into. 

for i = 1:CC.NumObjects
    area = stats.Area(i);
    perim = stats.Perimeter(i);   
    metric = ( (4 * pi * area) / (perim.^2) ); % Formula taken from assessment brief
    
    % If the component falls within a certain range then it is a starfish.
    % This component is then written to the image (E).
    if ( (metric < 0.253) && (metric > 0.21) )  
       E(CC.PixelIdxList{i}) = 255;
    end
end

figure;
imshow(E);
title('Step 7:  Recognition of starfishes');

