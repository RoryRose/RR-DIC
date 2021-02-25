clear all
clc


workingDir='Z:\RR\DIC\Example from Phani\pre-test calibration\imagenames for ncorr\';  % do not forget the \ at the end of folder path
cd(workingDir)
imageNames=dir(fullfile(workingDir,'*.tif'));
imageNames = {imageNames.name}';

for i =1:length(imageNames)
    image1(:,:,i)=imread([workingDir imageNames{i}]);
end


disp('Aligning images....')
%adapted from Angus's code
[optimizer, metric]  = imregconfig('monomodal');
optimizer.MaximumIterations=50;
optimizer.GradientMagnitudeTolerance=1e-4;
optimizer.MinimumStepLength=1e-8;
imageset=[];
h = waitbar(0,'Please wait...');

currentFolder = pwd;
refimage=image1(:,:,1);
imageset(:,:,1)=refimage;
mkdir transformed-imgs
for i=1:size(image1,3)
    if i~=1
         currentimage=image1(:,:,i);
         tformEstimate{i} = imregcorr(currentimage,refimage,'similarity');
         Reg{i} = imwarp(currentimage,tformEstimate{i},'OutputView',imref2d(size(refimage)));
         imageset(:,:,i)=Reg{i};
    else
        imageset(:,:,i) = image1(:,:,1);
    end
    %      a=figure;
    %      set(a, 'Visible', 'off');
    %      a=imagesc(imageset(:,:,i));colormap('gray');caxis([0, 255]);
    %      saveas(a,strcat(workingDir,'transformed-img',string(i),'.tiff'));
    %      waitbar(i/length(theta),h,sprintf('%i of %i',i,length(theta)));
    %      close all;
    X=imageset(:,:,i);
    %X = round(1 + (imageset(:,:,i) - min(imageset(:,:,i)) .* 255 ./ (max(imageset(:,:,i)) - min(imageset(:,:,i)))));  %using double
     map=gray(255);
     imwrite(X,map,strcat(currentFolder,'\transformed-imgs\transformed-img',string(i),'.tif'));
     waitbar(i/size(image1,3),h,sprintf('%i of %i',i,size(image1,3)));
end
close(h)
disp('Completed rotate, align and stack of the images');
%toc;
close all