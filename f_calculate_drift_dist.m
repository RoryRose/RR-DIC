function [drifxtaftertime,drifytaftertime]=f_calculate_drift_dist(XYimrange,FileNames,DICpixeltimeshaped,dispq,meandx,meandy)
%For every image pair, find the ditsortion field corrected for drift and
%fit to a polynomial surface. The drift velocity is then found by doin
%finite difference gradient for each pixel in each image pair. The velocity
%is then fitted as a function of time with a smoothing spline and
%integrated to get the drift displacement for every pixel in every image

%INPUTS:
%   XYimrange = Images numbers of the image pairs
%   FileNames = list of file names
%   DICpixeltime = Time that every pixel was recoreded
%OUTPUTS:
%   drifxtaftertime = fitted x(u) drift distortion value for every pixel in every image
%   drifytaftertime = fitted y(v) drift distortion value for every pixel in every image

%find drift disparity
for i = 1:length(XYimrange)/2 %for every image pair
    firstidx=XYimrange(2*i-1);
    secondidx=XYimrange(2*i);
    tempdata1 = readtable(FileNames{firstidx});
    [firstxi(i,:,:),firstyi(i,:,:),firstdx,firstdy]=f_dataextract(tempdata1,dispq,meandx(firstidx),meandy(firstidx));
    tempdata2 = readtable(FileNames{secondidx});
    [~,~,seconddx,seconddy]=f_dataextract(tempdata2,dispq,meandx(secondidx),meandy(secondidx));
    udist(i,:)=seconddx-firstdx;
    vdist(i,:)=seconddy-firstdy;
    %{    
    subplot(2,1,1)
    pcolor(squeeze(firstxi(i,:,:)),squeeze(firstyi(i,:,:)),reshape(squeeze(udist(i,:)),size(squeeze(firstxi(i,:,:)))))
    subplot(2,1,2)
    pcolor(squeeze(firstxi(i,:,:)),squeeze(firstyi(i,:,:)),reshape(squeeze(vdist(i,:)),size(squeeze(firstxi(i,:,:)))))
    pause(1)
    %}
%% fit drift disparity to polynomial
    [XOut, YOut, ZOut] = prepareSurfaceData(tempdata1.pos_x,tempdata1.pos_y,squeeze(udist(i,:,:)));
    udistfit{i} = fit( [XOut, YOut], ZOut, 'poly23');
    [XOut, YOut, ZOut] = prepareSurfaceData(tempdata1.pos_x,tempdata1.pos_y,squeeze(vdist(i,:,:)));
    vdistfit{i} = fit( [XOut, YOut], ZOut, 'poly23');
    udistfitted(i,:,:)=udistfit{i}(squeeze(firstxi(i,:,:)),squeeze(firstyi(i,:,:)));
    vdistfitted(i,:,:)=vdistfit{i}(squeeze(firstxi(i,:,:)),squeeze(firstyi(i,:,:)));
end
%% Find drift velocity
for i = 1:length(XYimrange)/2 %for every image pair
    firstidx=XYimrange(2*i-1);
    secondidx=XYimrange(2*i);
    timediff=DICpixeltimeshaped(secondidx,:,:)-DICpixeltimeshaped(firstidx,:,:);
    velocitymeantime(i,:,:)=squeeze(DICpixeltimeshaped(firstidx,:,:))+squeeze(timediff)./2; %since we are finding the finite difference velocity, it is evaluated at the mean aquisiotion time
    uvelocity(i,:,:)=squeeze(udistfitted(i,:,:))./squeeze(timediff);
    vvelocity(i,:,:)=squeeze(vdistfitted(i,:,:))./squeeze(timediff);
end
%% model drift velocity for each pixel as a function of time with a smothing spline fit
[Driftumodel,Driftvmodel]=f_DriftDistortion(uvelocity,vvelocity,velocitymeantime);

%integrate for every pixel in every image - Currently uses Trapezoidal
%method for speed. Fit is evaluated for 1000 time points from 0 to the
%pixel time and then integrated.
drifxtaftertime=NaN(size(DICpixeltimeshaped));
drifytaftertime=drifxtaftertime;
disp('Integrating drift fits...')
parfor fileidx=1:length(FileNames)
    drifxtaftertime(fileidx,:,:)=f_udrifteval(DICpixeltimeshaped,Driftumodel,fileidx);
    drifytaftertime(fileidx,:,:)=f_udrifteval(DICpixeltimeshaped,Driftvmodel,fileidx);
end
disp('finished integrating drift')
%DEBUG - plot the drift distortion after fitting and the drift velocity
%before fitting for 50 pixels along the diagonal
%{
for i=1:50
    yyaxis left
    plot(DICpixeltimeshaped(:,i,i),drifxtaftertime(:,i,i))
    hold on
    yyaxis right
    plot(velocitymeantime(:,i,i),uvelocity(:,i,i))
    hold on
    pause(0.2)
end
%}