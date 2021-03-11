function [Pu,Pv]=f_DriftDistortion(uvelocity,vvelocity,velocitymeantime,sizey)
% Model the variation in each point on the surface as a function of t
%as a smoothing spline
%INPUTS
%   xval = list of x (or y) displacemenbts to evaluate the fit at
%   meandx = x (or y) translation of each image
%   vdistfitted = fit of v distortion field evaluated for every pixel
%   udistfitted = fit of u distortion field evaluated for every pixel
%   Ximrange = list of images with x or y deformation

Pxv=cell(size(vvelocity,2),size(vvelocity,3));
Pxu=Pxv;
disp('calculating fits...')
Pu=fit(squeeze(velocitymeantime),squeeze(uvelocity),'smoothingspline');
Pv=fit(squeeze(velocitymeantime),squeeze(vvelocity),'smoothingspline');


if size(vvelocity,2)*size(vvelocity,3)<60*60 %if the image is sufficiently small, we can calculate every pixel's fit
    parfor j=1:size(vvelocity,3)
        [Putemp,Pvtemp]=fit_splines(j,velocitymeantime,uvelocity,vvelocity);
        Pu(:,j)=Putemp;
        Pv(:,j)=Pvtemp;
    end
    disp('...fits calculated')
else %we need to speed up computation, so lets only sample 100 points in each axis
    parfor j=1:sizey
        
        [Putemp,Pvtemp]=fit_splines_reduced_mat(j,velocitymeantime,uvelocity,vvelocity,sizey);
        Pu(:,j)=Putemp;
        Pv(:,j)=Pvtemp;
    end
%     disp('...finished fitting, now padding out array')
%     %pad out the array of fits with the values calculated above
%     for j=1:sizey
%         indexesy=ceil(size(vvelocity,3)./sizey.*(j-1))+1:ceil(size(vvelocity,3)/sizey.*j)-1;
%         for i=1:sizey
%             indexesx=ceil(size(vvelocity,2)./sizey.*(i-1))+1:ceil(size(vvelocity,2)/sizey.*i)-1;
%             Pu(indexesx,indexesy)=PuT(i,j);
%             Pv(indexesx,indexesy)=PvT(i,j);
%         end
%     end
%     disp('...fits calculated and padded')
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
end
function [Putemp,Pvtemp]=fit_splines(j,velocitymeantime,uvelocity,vvelocity)
%this function allows for an easier implementation of parallelization
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
function [Putemp,Pvtemp]=fit_splines_reduced_mat(j,velocitymeantime,uvelocity,vvelocity,sizey)
%this function allows for an easier implementation of parallelization. This
%time we take the mean value of drift disparity across the secrtion of
%pixels we are investigating to reduce computation time.
    indexesy=ceil(size(vvelocity,3)./sizey.*(j-1))+1:ceil(size(vvelocity,3)/sizey.*j);
    for i=1:sizey
        indexesx=ceil(size(vvelocity,2)./sizey.*(i-1))+1:ceil(size(vvelocity,2)/sizey.*i);
        Putemp{i}=fit(mean(mean(velocitymeantime(:,indexesx,indexesy),2),3),mean(mean(uvelocity(:,indexesx,indexesy),2),3),'smoothingspline');
        Pvtemp{i}=fit(mean(mean(velocitymeantime(:,indexesx,indexesy),2),3),mean(mean(vvelocity(:,indexesx,indexesy),2),3),'smoothingspline');
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