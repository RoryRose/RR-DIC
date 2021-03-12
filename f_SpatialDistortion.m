function [Pxv,Pxu]=f_SpatialDistortion(meandx,meandy,xyq,vdistfitted,udistfitted,Ximrange,xi,yi)
% Model the variation in each point on the surface as a function of x
%displacement as a linear function
%INPUTS:
%   xval = list of x (or y) displacemenbts to evaluate the fit at
%   meandx = x (or y) translation of each image
%   vdistfitted = fit of v distortion field evaluated for every pixel
%   udistfitted = fit of u distortion field evaluated for every pixel
%   Ximrange = list of images with x or y deformation
%OUTPUTS:
%   Pxv = cell array of v distortion fits for each pixel as a function of translation
%       required to get to the first image
%   Pxu = cell array of u distortion fits for each pixel as a function of translation
%       required to get to the first image
Pv=cell(size(xi,2),size(xi,3));
Pu=Pv;
if xyq==1
    variable=meandx;
else
    variable=meandy;
end
parfor i=1:size(xi,2)
    PvT=cell(1,size(xi,3));
    PuT=cell(1,size(xi,3));
    for j=1:1:size(xi,3)
        PvT{j} = slmengine(variable(Ximrange),squeeze(vdistfitted(Ximrange,i,j))','Degree',1,'plot','off','knots',2);%currently set up as a linear fit, but it is set up to be easy to change
        PuT{j} = slmengine(variable(Ximrange),squeeze(udistfitted(Ximrange,i,j))','Degree',1,'plot','off','knots',2);%currently set up as a linear fit, but it is set up to be easy to change
    end
    Pu(i,:)=PuT;
    Pv(i,:)=PvT;
end
        

%DEBUG - plot all of the distortions as a function of displacement
% figure
% plot(meandx(Ximrange),reshape(udistfitted(Ximrange,1:50,1:50),[size(udistfitted(Ximrange,:,:),1),50.*50 ]),'o')

% DEBUG - Plot all of the possible deformation correction surfaces
%{

figure
for i=1:100
    subplot(1,2,1)
    surf(squeeze(xi(2,:,:)),squeeze(yi(2,:,:)),squeeze(Pxvfitvals(:,:,i)))
    subplot(1,2,2)
    surf(squeeze(xi(2,:,:)),squeeze(yi(2,:,:)),squeeze(Pxufitvals(:,:,i)))
    pause(0.1)
end
%}
end
