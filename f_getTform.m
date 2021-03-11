function [imageTime,meandx,meandy,pixelheight,pixelwidth,tformEstimate]=f_getTform(imageDir)
%Find Images and calculate the x and y translation between images
%INPUTS:
%   imageDir = Directory containing all of the images and no other tif
%       files
%OUTPUTS:
%   meandx = trandlation in x between images
%   meandy = translation in y between images
%   tformEstimate = cell array of complete affine 2D transformation between images
%   imageTime = duration vector of when the images were last modified
%   pixelheight = height of the reference image in SEM pixels
%   pixelwidth = width of the reference image in SEM pixels
% find images
imageNames=dir(fullfile(imageDir,'*.tif'));
imageNames = {imageNames.name}';
%read images
for i =1:length(imageNames)
    image1(:,:,i)=imread([imageDir imageNames{i}]);
    info=imfinfo([imageDir imageNames{i}]);
    imageTime(i)=datetime(info.FileModDate);
end
disp('Finding Translations to reference image....')
%adapted from Angus's code - set up optimizer
[optimizer, metric]  = imregconfig('monomodal');
optimizer.MaximumIterations=50;
optimizer.GradientMagnitudeTolerance=1e-3;
optimizer.MinimumStepLength=1e-8;
tformEstimate=cell(length(imageNames),1);
refimage=image1(:,:,1);
pixelheight=size(refimage,1);
pixelwidth=size(refimage,2);
%run optimiser to find transformations
parfor i=2:length(imageNames)
    currentimage=image1(:,:,i);
    tformEstimate{i} = imregcorr(currentimage,refimage,'similarity');
    
end
disp('...Finished finding translations');
%calculate x and y displacements
for i = 1:length(imageNames)
    if i==1
        meandx(i)=0;
        mendy(i)=0;
    else
        %ignore any non-rigid body translations in the transform estimate!
        meandx(i)=-tformEstimate{i}.T(3,1); %get x translation in pixels by looking at the transformation matrix
        meandy(i)=-tformEstimate{i}.T(3,2); %get y translation in pixels by looking at the transformation matrix
    end
end
end
