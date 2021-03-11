function f_Im_Rotate90(imageDir)
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
disp('transforming images....')
%calculate x and y displacements
imageset=[];

currentFolder = pwd;
mkdir transformed-imgs
for i=1:size(image1,3)
    imageset(:,:,i) = image1(:,:,i)';
    X=imageset(:,:,i);
    %X = round(1 + (imageset(:,:,i) - min(imageset(:,:,i)) .* 255 ./ (max(imageset(:,:,i)) - min(imageset(:,:,i)))));  %using double
    map=gray(255);
    imwrite(X,map,strcat(currentFolder,'\transformed-imgs\transformed-img',string(i),'.tif'));
end
end