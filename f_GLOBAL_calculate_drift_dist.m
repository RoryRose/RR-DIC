function [drifxtaftertime,drifytaftertime,timevals]=f_GLOBAL_calculate_drift_dist(XYimrange,FileNames,DICpixeltimeshaped,dispq,meandx,meandy,DICproscess,data,DICpixeltime,semtime)
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
    udist(i,:,:)=seconddx-firstdx;%find the distortion of the second image in the pair compared to the first image
    vdist(i,:,:)=seconddy-firstdy;
%% fit drift disparity to polynomial
    [XOut, YOut, ZOut] = prepareSurfaceData(squeeze(firstxi(i,:,:)),squeeze(firstyi(i,:,:)),squeeze(udist(i,:,:)));
    udistfit{i} = fit( [XOut, YOut], ZOut, 'poly23');
    [XOut, YOut, ZOut] = prepareSurfaceData(squeeze(firstxi(i,:,:)),squeeze(firstyi(i,:,:)),squeeze(vdist(i,:,:)));
    vdistfit{i} = fit( [XOut, YOut], ZOut, 'poly23');
    udistfitted(i,:,:)=udistfit{i}(squeeze(firstxi(i,:,:)),squeeze(firstyi(i,:,:)));
    vdistfitted(i,:,:)=vdistfit{i}(squeeze(firstxi(i,:,:)),squeeze(firstyi(i,:,:)));
    %DEBUG - plot the inpu and fitted surfaces
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
velocitymeantime=NaN(length(XYimrange)/2,size(DICpixeltime,1));
uvelocity=velocitymeantime;
vvelocity=uvelocity;
for FileN = 1:length(XYimrange)/2 %for every image pair
    firstidx=XYimrange(2*FileN-1);
    secondidx=XYimrange(2*FileN);
    for i=1:size(DICpixeltime,2)
        timediff=DICpixeltime(secondidx,i)-DICpixeltime(firstidx,i);
        velocitymeantime(FileN,i)=DICpixeltime(firstidx,i)+timediff./2; %since we are finding the finite difference velocity, it is evaluated at the mean aquisiotion time
        uvelocity(FileN,i)=udistfitted(FileN,i)./timediff;
        vvelocity(FileN,i)=vdistfitted(FileN,i)./timediff;
    end
end
%old code which made incorrect assumptions about the model
%{
for i = 1:length(XYimrange)/2 %for every image pair
    firstidx=XYimrange(2*i-1);
    secondidx=XYimrange(2*i);
    timediff=DICpixeltimeshaped(secondidx,:,:)-DICpixeltimeshaped(firstidx,:,:);
    velocitymeantime(i,:,:)=squeeze(DICpixeltimeshaped(firstidx,:,:))+squeeze(timediff)./2; %since we are finding the finite difference velocity, it is evaluated at the mean aquisiotion time
    uvelocity(i,:,:)=squeeze(udistfitted(i,:,:))./squeeze(timediff);
    vvelocity(i,:,:)=squeeze(vdistfitted(i,:,:))./squeeze(timediff);
end
%}
%% model the global drift velocity  as a function of time with a smothing spline fit 

disp('calculating fits...')
%reshape arrays into a line
velocitymeantime=reshape(velocitymeantime',size(velocitymeantime,1)*size(velocitymeantime,2),1);
vvelocity=reshape(vvelocity',size(vvelocity,1)*size(vvelocity,2),1);
uvelocity=reshape(uvelocity',size(uvelocity,1)*size(uvelocity,2),1);
totallength=length(velocitymeantime);
fitidx=round(1:floor(totallength/100):totallength);
fitt=velocitymeantime;
fitvvelocity=vvelocity;
fituvelocity=uvelocity;
% smoothness=0.07;
% Pu=fit(fitt,fituvelocity,'smoothingspline','SmoothingParam',smoothness);
% Pv=fit(fitt,fitvvelocity,'smoothingspline','SmoothingParam',smoothness);
Pu = slmengine(fitt,fituvelocity,'plot','off','knots',[semtime.scan;max(fitt(:))]');%set the drift %FOR DEBUG set plot to on
Pv = slmengine(fitt,fitvvelocity,'plot','off','knots',[semtime.scan;max(fitt(:))]');%set the drift %FOR DEBUG set plot to on
%This uses the matworks toolbox to allow for constraints and easy integrating


%integrate for every pixel in every image - 
%Old version uses Trapezoidal method for speed. 
%Fit is evaluated for 5000 time points from 0 to the
%maximum pixel time and then integrated.
evalidx=round(1:floor(totallength/5000):totallength);
timevals=[0;fitt(evalidx);max(DICpixeltimeshaped(:))];%add a zero at the start for the first image values and the maximum time value at the end
evaldrifxtaftertime=zeros(size(timevals));
evaldrifytaftertime=evaldrifxtaftertime;
disp('Integrating drift fits...')
% Splineeualuated=Pu(timevals);
% Splineevaluated=Pv(timevals);
for i = 2:length(timevals)
%     evaldrifytaftertime(i)=trapz(timevals(1:i),Splineevaluated(1:i));
%     evaldrifxtaftertime(i)=trapz(timevals(1:i),Splineeualuated(1:i));
    evaldrifxtaftertime(i) = slmpar(Pu,'integral',[0,timevals(i)]);
    evaldrifytaftertime(i) = slmpar(Pv,'integral',[0,timevals(i)]);
end
%DEBUG - plot the global models
%{
plot(timevals,evaldrifxtaftertime)
hold on
plot(timevals,evaldrifytaftertime)
%}
disp('evaluating integrated fit for every pixel...')
%round the evaluation time for every pixel to the time nearest value in timevals
roundedDICpixeltime=interp1(timevals,timevals,DICpixeltimeshaped,'nearest');
%for every pixel in every frame, evaluate the fit given the rounded
%aquizition time of that pixel
drifxtaftertime=NaN(size(DICpixeltimeshaped));
drifytaftertime=drifxtaftertime;
for t=1:length(timevals)
    drifxtaftertime(roundedDICpixeltime==timevals(t))=evaldrifxtaftertime(t);
    drifytaftertime(roundedDICpixeltime==timevals(t))=evaldrifytaftertime(t);
end
%OLD CODE
% drifxtaftertime=f_udrifteval(DICpixeltimeshaped,Driftumodel,fileidx,sizey);
% drifytaftertime=f_udrifteval(DICpixeltimeshaped,Driftvmodel,fileidx,sizey);
disp('finished global drift model')
