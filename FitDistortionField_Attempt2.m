clear all
clc
% Methodology for correcting time-dependent and time-indipendent
% distortions. This version of the code assumes input data is of the form
% produced by pydic for simplicity.

%references for methodology: Metrology in a scanning electron microscope:
%Sutton, M. A., Li, N., Garcia, D., Cornille, N., Orteu, J. J., McNeill, S. R., � Li, X. (2006). Metrology in a scanning electron microscope: Theoretical developments and experimental validation. Measurement Science and Technology, 17(10), 2613�2622. https://doi.org/10.1088/0957-0233/17/10/012
%Kammers, A. D., & Daly, S. (2013). Digital Image Correlation under Scanning Electron Microscopy: Methodology and Validation. Experimental Mechanics, 53(9), 1743�1761. https://doi.org/10.1007/s11340-013-9782-x
workingDir='Z:\RR\DIC\Example from Phani\pre-test calibration\XY disp\pydic\result\';  % do not forget the \ at the end of folder path
cd(workingDir)
imageDir='Z:\RR\DIC\Example from Phani\pre-test calibration\XY disp\';%file location of images
FileNames=dir(fullfile(workingDir,'*.csv'));
FileNames = {FileNames.name}';
data = cell(length(FileNames),1);
dispq=1; %is displacement measured relative?
%% find displacements of every image
[meandx,meandy,pixelheight,pixelwidth,tformEstimate]=f_getTform(imageDir);

%% find images pairs with no change
%initialise time data
semtime=struct();
%THESE ARE GUESSES, BUT NEED TO  BE FOUND FOR THE IMAGES YOU ARE ANALYSING
semtime.dwell=1e-4;
semtime.betweenrow=1e-6;
semtime.betweenscan=20;%may want to have a csv lookup of time taken later but for now assume constant time between images
semtime.frame=pixelheight.*pixelwidth*semtime.dwell+pixelheight*semtime.betweenrow;
for i = 1:length(meandx)
    difinx=abs(meandx(i)-meandx);
    difiny=abs(meandy(i)-meandy);
    difinx=difinx<10;
    difiny=difiny<10;
    difq(i)=sum(double(difinx).*double(difiny))>1;%find the image sets which have at least one other image with x and y displacement difference less than 10
end
XYimrange=[1:length(FileNames)];
XYimrange=XYimrange(difq==1);
udist=[];
vdist=[];
%find drift disparity
for i = 1:length(XYimrange)/2 %for every image pair
    firstidx=XYimrange(2*i-1);
    secondidx=XYimrange(2*i);
    tempdata1 = readtable(FileNames{firstidx});
    [firstxi(i,:,:),firstyi(i,:,:),firstdx,firstdy]=f_dataextract(tempdata1,dispq,meandx(firstidx),meandy(firstidx));
    tempdata2 = readtable(FileNames{secondidx});
    [secondxi(i,:,:),secondyi(i,:,:),seconddx,seconddy]=f_dataextract(tempdata2,dispq,meandx(secondidx),meandy(secondidx));
    udist(i,:)=seconddx-firstdx;
    vdist(i,:)=seconddy-firstdy;
    %{    
    subplot(2,1,1)
    pcolor(squeeze(firstxi(i,:,:)),squeeze(firstyi(i,:,:)),reshape(squeeze(udist(i,:)),size(squeeze(firstxi(i,:,:)))))
    subplot(2,1,2)
    pcolor(squeeze(firstxi(i,:,:)),squeeze(firstyi(i,:,:)),reshape(squeeze(vdist(i,:)),size(squeeze(firstxi(i,:,:)))))
    pause(1)
    %}
end
%% find the time for every pixel in the DIC image sequence
DICpixelcolumlength=pixelwidth./size(firstxi(1,:,:),2);%number of sem pixels in height of one DIC pixel
DICpixelrowheight=pixelheight./size(firstxi(1,:,:),3);%number of sem pixels in length of one DIX pixel
for i=1:length(FileNames)
    DICpixeltime(i,:)=semtime.betweenscan.*i+(i-1).*semtime.frame+tempdata1.index_y.*semtime.dwell.*...
        DICpixelcolumlength+tempdata1.index_x.*semtime.betweenrow.*...
        DICpixelrowheight; %time from start of aquisition period of every pixel in the image based on DOI:10.1007/s11340-007-9042-z
end
for i=1:length(FileNames)
    DICpixeltimeshaped(i,:,:)=reshape(DICpixeltime(i,:),size(squeeze(firstxi(1,:,:))));
end
%% fit drift disparity to polynomial
udistfitted=[];
vdistfitted=[];
for i = 1:length(XYimrange)/2 %for every image pair
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
    timediff=DICpixeltime(secondidx,:)-DICpixeltime(firstidx,:);
    timediff=reshape(timediff, size(squeeze(firstxi(1,:,:))));
    velocitymeantime(i,:,:)=squeeze(DICpixeltimeshaped(i,:,:))+timediff./2; %since we are finding the finite difference velocity, it is evaluated at the mean aquisiotion time
    uvelocity(i,:,:)=squeeze(udistfitted(i,:,:))./timediff;
    vvelocity(i,:,:)=squeeze(vdistfitted(i,:,:))./timediff;
end
%% model drift velocity for each pixel as a function of time with a smothing spline fit and integrate to get the drift from start to any time
[Driftumodel,Driftvmodel]=f_DriftDistortion(uvelocity,vvelocity,velocitymeantime);
%to find drift for any time after the start do: 
ipixel=3;
jpixel=5;
tpixel=100;
fun=@(t)feval(Driftumodel{ipixel,jpixel},t);
drifxtaftertime=integral(fun,0,tpixel);
%% for x displacements find the distortion field u and v
%for this set - first 7 have x disp and rest have y disp
Ximrange=1:7;
Yimrange=7:13;
for i = Ximrange
    tempdata = readtable(FileNames{i});
    [Xxi(i,:,:),Xyi(i,:,:),dx,dy]=f_dataextract(tempdata,dispq,meandx(i),meandy(i));
    udist(i,:,:)=dx-meandx(i);
    vdist(i,:,:)=dy-meandy(i);
end
%% fit the distortion fields to a 3D polynomial and evaluate at every pixel
udistfitted=[];
vdistfitted=[];
for i=Ximrange
    [XOut, YOut, ZOut] = prepareSurfaceData(tempdata.pos_x,tempdata.pos_y,squeeze(udist(i,:,:)));
    udistfit{i} = fit( [XOut, YOut], ZOut, 'poly23');
    [XOut, YOut, ZOut] = prepareSurfaceData(tempdata.pos_x,tempdata.pos_y,squeeze(vdist(i,:,:)));
    vdistfit{i} = fit( [XOut, YOut], ZOut, 'poly23');
    udistfitted(i,:,:)=udistfit{i}(squeeze(Xxi(i,:,:)),squeeze(Xyi(i,:,:)));
    vdistfitted(i,:,:)=vdistfit{i}(squeeze(Xxi(i,:,:)),squeeze(Xyi(i,:,:)));
end
%% Model the variation in each point on the surface as a function of x
%displacement as a linear function
xval=linspace(min(Xxi(:)),max(Xxi(:)),100);
[Pxv,Pxu,Pxvfitvals,Pxufitvals]=f_SpatialDistortion(xval,meandx,vdistfitted,udistfitted,Ximrange);
%% for y displacements
%find the distortion field u and v

meandy=meandy-meandy(Yimrange(1));%reference image is first image prior to first translation along the direction
meandx=meandx-meandx(Yimrange(1));
for i = Yimrange
    tempdata = readtable(FileNames{i});
    [Yxi(i,:,:),Yyi(i,:,:),dx,dy]=f_dataextract(tempdata,dispq,meandx(i),meandy(i));
    udist(i,:,:)=dx-meandx(i);
    vdist(i,:,:)=dy-meandy(i);
end
%% fit the distortion fields to a 3D polynomial and evaluate at every pixel - here using a polyfit
udistfitted=[];
vdistfitted=[];
for i=Ximrange
    [XOut, YOut, ZOut] = prepareSurfaceData(tempdata.pos_x,tempdata.pos_y,squeeze(udist(i,:,:)));
    udistfit{i} = fit( [XOut, YOut], ZOut, 'poly23');
    [XOut, YOut, ZOut] = prepareSurfaceData(tempdata.pos_x,tempdata.pos_y,squeeze(vdist(i,:,:)));
    vdistfit{i} = fit( [XOut, YOut], ZOut, 'poly23');
    udistfitted(i,:,:)=udistfit{i}(squeeze(Yxi(i,:,:)),squeeze(Yyi(i,:,:)));
    vdistfitted(i,:,:)=vdistfit{i}(squeeze(Yxi(i,:,:)),squeeze(Yyi(i,:,:)));
end
%% Model the variation in each point on the surface as a function of x
%displacement as a linear function
yval=linspace(min(Yyi(:)),max(Yyi(:)),100);
[Pyv,Pyu,Pyvfitvals,Pyufitvals]=f_SpatialDistortion(yval,meandy,vdistfitted,udistfitted,Yimrange);


%% let's reduce noize by filtering out some points in frequency space
%{
thresh=0.4;
D=5;%radius in pixels of the mask of values to test
udistcorr=reshape(udist,size(squeeze(xi)))-udistfitted;
vdistcorr=reshape(vdist,size(squeeze(xi)))-vdistfitted;
for i=Ximrange
    fixedudistcorr(i,:,:)=f_reduceNoize(udistcorr(i,:,:),D,thresh);%Use FFt mask which keeps values within radius D of center of shifted FFt but reduces values above the theshold percentage of max
    fixedvdistcorr(i,:,:)=f_reduceNoize(vdistcorr(i,:,:),D,thresh);
end
udistcorr=fixedudistcorr+udistfitted;
vdistcorr=fixedvdistcorr+vdistfitted;
%DEBUG - Plot the surfaces of the fit, origional data, and noize reduced data
%{
for i=2:7
    subplot(3,2,1)
    surf(squeeze(xi(i,:,:)),squeeze(Xyi(i,:,:)),squeeze(udistfitted(i,:,:)))
    subplot(3,2,2)
    surf(squeeze(xi(i,:,:)),squeeze(Xyi(i,:,:)),squeeze(vdistfitted(i,:,:)))
    subplot(3,2,3)
    surf(squeeze(xi(i,:,:)),squeeze(Xyi(i,:,:)),squeeze(reshape(udist(i,:,:),size(squeeze(xi(i,:,:))))))
    subplot(3,2,4)
    surf(squeeze(xi(i,:,:)),squeeze(Xyi(i,:,:)),squeeze(reshape(vdist(i,:,:),size(squeeze(xi(i,:,:))))))
    subplot(3,2,5)
    surf(squeeze(xi(i,:,:)),squeeze(Xyi(i,:,:)),squeeze(udistcorr(i,:,:)))
    subplot(3,2,6)
    surf(squeeze(xi(i,:,:)),squeeze(Xyi(i,:,:)),squeeze(vdistcorr(i,:,:)))
    pause(5)
end
%}
%}
