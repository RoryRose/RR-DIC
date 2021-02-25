function [Pxv,Pxu]=f_SpatialDistortion(meandx,vdistfitted,udistfitted,Ximrange)
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
Pxv=cell(size(vdistfitted,2),size(vdistfitted,3));
Pxu=Pxv;
for j=1:size(vdistfitted,3)
    for i=1:size(vdistfitted,2)   
        %DEBUG - For every pixel, plot the distortion as a function of
        %displacement
        %{
        figure(3)
        scatter(meandx(2:7),squeeze(udistfitted(2:end,i,j))')
        hold off
        %}
        %IMPORTANT ASSUMPTION: I have ignored the first (zero) value for
        %every one as this might skew the fits and cause problems
        Pxv{i,j} = polyfit(meandx(Ximrange(2:end)),squeeze(vdistfitted(Ximrange(2:end),i,j))',1);
        Pxu{i,j} = polyfit(meandx(Ximrange(2:end)),squeeze(udistfitted(Ximrange(2:end),i,j))',1);
    end
end
%DEBUG - plot all of the distortions as a function of displacement
% plot(meandx(1:7),reshape(udistfitted,[7,size(xi,3).*size(xi,2) ]),'o')

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