function [Pu,Pv]=f_LOCAL_calculate_drift_dist(XYimrange,FileNames,DICpixeltimeshaped,dispq,meandx,meandy,DICproscess,data)
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
%   Pu = array of spline fits for the u drift disparity within each pair to be added to the global model 
%   Pv = array of spline fits for the v drift disparity within each pair to be added to the global model 

%find drift disparity
disp('Finding local drift disparity...')
for i = 1:length(XYimrange)/2 %for every image pair
    firstidx=XYimrange(2*i-1);
    secondidx=XYimrange(2*i);
    [firstxi(i,:,:),firstyi(i,:,:),firstdx,firstdy]=f_dataextract(FileNames,firstidx,DICproscess,dispq,meandx(firstidx),meandy(firstidx),data);
    [~,~,seconddx,seconddy]=f_dataextract(FileNames,secondidx,DICproscess,dispq,meandx(secondidx),meandy(secondidx),data);
    udist(i,:,:)=seconddx-firstdx;
    vdist(i,:,:)=seconddy-firstdy;
end
disp('Fitting Local Drift Disparity with smoothing splines')
% smoothness=0.07;
for i = 1:length(XYimrange)/2 %for every image pair
    firstidx=XYimrange(2*i-1);
    secondidx=XYimrange(2*i);    
    timediff=DICpixeltimeshaped(secondidx,:)-DICpixeltimeshaped(firstidx,1);
%     Pu{i}=fit(timediff(1:10:end)',squeeze(udist(i,1:10:end))','smoothingspline','SmoothingParam',smoothness);%fit the drift data to a spline
%     Pv{i}=fit(timediff(1:10:end)',squeeze(vdist(i,1:10:end))','smoothingspline','SmoothingParam',smoothness);
    [Pu{i},yval,xval] = slmengine(timediff,udist(i,:),'plot','off');%FOR DEBUG set plot to on
    [Pv{i}] = slmengine(timediff,vdist(i,:),'plot','off');%FOR DEBUG set plot to on
    %DEBUG - plot the fit and raw data of the local drift distortion
    %%{
    t=min(timediff):max(timediff);
    subplot(2,length(XYimrange)/2,i)
    scatter(timediff(:),udist(i,:))
    xlabel('Time(s)')
    ylabel('U distortion')
    title(strcat('U Distortion for image pair',{' '},num2str(i)))
    hold on
    plot(t,slmeval(t,Pu{i},0),'LineWidth',3);
    hold off
    subplot(2,length(XYimrange)/2,i+length(XYimrange)/2)
    scatter(timediff(:),vdist(i,:))
    hold on
    xlabel('Time(s)')
    ylabel('V distortion')
    title(strcat('V Distortion for image pair',{' '},num2str(i)))
    plot(t,slmeval(t,Pv{i},0),'LineWidth',3)
    hold off
    pause(0.1)
    %}
end
disp('Finished local drift model')
