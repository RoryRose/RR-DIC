function [drifxtaftertime,drifytaftertime,timevals]=f_LOCAL_calculate_drift_dist(XYimrange,FileNames,DICpixeltimeshaped,dispq,meandx,meandy,DICproscess,data)
%For every image pair, find the ditsortion field corrected for drift and
%fit to a polynomial surface. The drift velocity is then found by doin
%finite difference gradient for each pixel in each image pair. The velocity
%is then fitted as a function of time with a smoothing spline and
%integrated to get the drift displacement for every pixel in every image

%INPUTS:
%   XYimrange = Images numbers of the image pairs
%   FileNames = list of file names
%   DICpixeltime = Time that every pixel was recoreded
%   dispq = format of displacement data
%   meandx = list of x translations for each image
%   meandy = list of y translations for each image
%   DICproscess = DIC software used as input data
%   data = the raw input data
%OUTPUTS:
%   drifxtaftertime = fitted x(u) drift distortion value for every pixel in every image
%   drifytaftertime = fitted y(v) drift distortion value for every pixel in every image

%find drift disparity
for i = 1:length(XYimrange)/2 %for every image pair
    firstidx=XYimrange(2*i-1);
    secondidx=XYimrange(2*i);
    [firstxi(i,:,:),firstyi(i,:,:),firstdx,firstdy]=f_dataextract(FileNames,firstidx,DICproscess,dispq,meandx(firstidx),meandy(firstidx),data);
    [~,~,seconddx,seconddy]=f_dataextract(FileNames,secondidx,DICproscess,dispq,meandx(secondidx),meandy(secondidx),data);
    udist(i,:,:)=seconddx-firstdx;
    vdist(i,:,:)=seconddy-firstdy;
%% fit drift disparity to polynomial
    [XOut, YOut, ZOut] = prepareSurfaceData(squeeze(firstxi(i,:,:)),squeeze(firstyi(i,:,:)),squeeze(udist(i,:,:)));
    udistfit{i} = fit( [XOut, YOut], ZOut, 'poly23');
    [XOut, YOut, ZOut] = prepareSurfaceData(squeeze(firstxi(i,:,:)),squeeze(firstyi(i,:,:)),squeeze(vdist(i,:,:)));
    vdistfit{i} = fit( [XOut, YOut], ZOut, 'poly23');
    udistfitted(i,:,:)=udistfit{i}(squeeze(firstxi(i,:,:)),squeeze(firstyi(i,:,:)));
    vdistfitted(i,:,:)=vdistfit{i}(squeeze(firstxi(i,:,:)),squeeze(firstyi(i,:,:)));
    %{    
    figure(1)
    subplot(2,2,1)
    h=surf(squeeze(firstxi(i,:,:)),squeeze(firstyi(i,:,:)),squeeze(udist(i,:,:)));
    set(h,'Edgecolor','none')
    subplot(2,2,2)
    h=surf(squeeze(firstxi(i,:,:)),squeeze(firstyi(i,:,:)),squeeze(vdist(i,:,:)));
    set(h,'Edgecolor','none')
    subplot(2,2,3)
    h=surf(squeeze(firstxi(i,:,:)),squeeze(firstyi(i,:,:)),squeeze(udistfitted(i,:,:)));
    set(h,'Edgecolor','none')
    subplot(2,2,4)
    h=surf(squeeze(firstxi(i,:,:)),squeeze(firstyi(i,:,:)),squeeze(vdistfitted(i,:,:)));
    set(h,'Edgecolor','none')
    pause(1)
    %}
end
%% Find drift velocity
%for every pixel find the finite difference of the drift velocity
velocitymeantime=NaN(length(XYimrange)/2,size(firstxi,2),size(firstxi,3));
uvelocity=velocitymeantime;
vvelocity=uvelocity;
for i = 1:length(XYimrange)/2 %for every image pair
    firstidx=XYimrange(2*i-1);
    secondidx=XYimrange(2*i);
    timediff=DICpixeltimeshaped(secondidx,:,:)-DICpixeltimeshaped(firstidx,:,:);
    velocitymeantime(i,:,:)=squeeze(DICpixeltimeshaped(firstidx,:,:))+squeeze(timediff)./2; %since we are finding the finite difference velocity, it is evaluated at the mean aquisiotion time
    uvelocity(i,:,:)=squeeze(udistfitted(i,:,:))./squeeze(timediff);
    vvelocity(i,:,:)=squeeze(vdistfitted(i,:,:))./squeeze(timediff);
end
%% model drift velocity for each pixel as a function of time with a smothing spline fit 
% sizey=50; %this is the number of pixels to exaluate the fit for to increase efficiency. The function samples in sizeyxsizey blocks taking the mean distortion within each block
disp('calculating fits...')
totallength=size(velocitymeantime,1)*size(velocitymeantime,2)*size(velocitymeantime,3);
fitidx=round(1:floor(totallength/1000):totallength);
Pu=fit(velocitymeantime(fitidx)',uvelocity(fitidx)','smoothingspline');
Pv=fit(velocitymeantime(fitidx)',vvelocity(fitidx)','smoothingspline');
[Driftumodel,Driftvmodel]=f_DriftDistortion(uvelocity,vvelocity,velocitymeantime,sizey);

%integrate for every pixel in every image - Currently uses Trapezoidal
%method for speed. Fit is evaluated for 1000 time points from 0 to the
%pixel time and then integrated.

drifxtaftertime=f_udrifteval(DICpixeltimeshaped,Driftumodel,fileidx,sizey);
drifytaftertime=f_udrifteval(DICpixeltimeshaped,Driftvmodel,fileidx,sizey);
disp('finished drift')
%DEBUG - plot the drift distortion after fitting and the drift velocity
%before fitting for 50 pixels along the diagonal
%{
figure
plot(timevals,drifytaftertime)
hold on
plot(timevals,drifxtaftertime)
%}