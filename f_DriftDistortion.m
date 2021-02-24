function [Pu,Pv]=f_DriftDistortion(uvelocity,vvelocity,velocitymeantime)
% Model the variation in each point on the surface as a function of x
%displacement as a linear function
%INPUTS
%   xval = list of x (or y) displacemenbts to evaluate the fit at
%   meandx = x (or y) translation of each image
%   vdistfitted = fit of v distortion field evaluated for every pixel
%   udistfitted = fit of u distortion field evaluated for every pixel
%   Ximrange = list of images with x or y deformation
Pxv=cell(size(vvelocity,2),size(vvelocity,3));
Pxu=Pxv;
disp('calculating fits...')
parfor j=1:size(vvelocity,3)
    [Putemp,Pvtemp]=fit_splines(j,velocitymeantime,uvelocity,vvelocity);
    Pu(:,j)=Putemp;
    Pv(:,j)=Pvtemp;
end
disp('...fits calculated')
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
end
function [Putemp,Pvtemp]=fit_splines(j,velocitymeantime,uvelocity,vvelocity)
    i=[];
    for i=1:size(vvelocity,2)
        Putemp{i}=fit(squeeze(velocitymeantime(:,i,j)),squeeze(uvelocity(:,i,j)),'smoothingspline');
        Pvtemp{i}=fit(squeeze(velocitymeantime(:,i,j)),squeeze(vvelocity(:,i,j)),'smoothingspline');
        %DEBUG - plot curves - need to remove parfor to work!
        %{
        figure(4)
        subplot(1,2,1)
        scatter(squeeze(velocitymeantime(:,i,j)),squeeze(uvelocity(:,i,j)))
        subplot(1,2,2)
        scatter(squeeze(velocitymeantime(:,i,j)),squeeze(vvelocity(:,i,j)))
        %}
    end
end