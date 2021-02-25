% Methodology for correcting time-dependent and time-indipendent
% distortions. This version of the code assumes input data is of the form
% produced by pydic for simplicity.

%references for methodology:
%Sutton, M. A., Li, N., Garcia, D., Cornille, N., Orteu, J. J., McNeill, S. R., � Li, X. (2006). Metrology in a scanning electron microscope: Theoretical developments and experimental validation. Measurement Science and Technology, 17(10), 2613�2622. https://doi.org/10.1088/0957-0233/17/10/012
%Kammers, A. D., & Daly, S. (2013). Digital Image Correlation under Scanning Electron Microscopy: Methodology and Validation. Experimental Mechanics, 53(9), 1743�1761. https://doi.org/10.1007/s11340-013-9782-x
clc
workingDir='Z:\RR\DIC\Example from Phani\pre-test calibration\XY disp\pydic\result\';  % do not forget the \ at the end of folder path
cd(workingDir)
imageDir='Z:\RR\DIC\Example from Phani\pre-test calibration\XY disp\';%file location of images
FileNames=dir(fullfile(workingDir,'*.csv'));
FileNames = {FileNames.name}';
data = cell(length(FileNames),1);
dispq=1; %is displacement measured relative? = 1 for pydic data
%% find displacements of every image assuming rigid monomodal trasnformation
%this looks at the origional images
[imageTime,meandx,meandy,pixelheight,pixelwidth,tformEstimate]=f_getTform(imageDir);

%% initialise time data - this must use the imaging parameters in the future
semtime=struct();
%THESE ARE GUESSES for now, BUT NEED TO  BE FOUND FOR THE IMAGES YOU ARE ANALYSING
semtime.dwell=1e-4;
semtime.betweenrow=1e-6;
semtime.scan=seconds(duration(imageTime-imageTime(1)));%Time is in seconds, This relies on the time in the metadata being correct!
semtime.frame=pixelheight.*pixelwidth*semtime.dwell+pixelheight*semtime.betweenrow;
%% find images pairs with no change
[Ximrange,Yimrange,XYimrange]=f_findimageindex(meandx,meandy);
for runindex=1:2
    if runindex == 1
        %% for all images, find the distortion field u and v
        for i=1:length(FileNames)
            tempdata = readtable(FileNames{i});
            [xi(i,:,:),yi(i,:,:),dx,dy]=f_dataextract(tempdata,dispq,meandx(i),meandy(i));
            rawudist(i,:,:)=dx-meandx(i);
            rawvdist(i,:,:)=dy-meandy(i);
        end
    else %if we have alrady done at least one run of the model, we need to calculate corrected distortions
        %% for all images, find the distortion field u and v correcting for the previousley calculated drift and spatial distortions
        for i = 1:length(FileNames)
            tempdata = readtable(FileNames{i});
            [xi(i,:,:),yi(i,:,:),dx,dy]=f_dataextract(tempdata,dispq,meandx(i),meandy(i));
            dxdrift=dx+drifxtaftertime(i,:)';%account for drift distortion
            dydrift=dy+drifytaftertime(i,:)';%account for drift distortion
            %account for spatial distortion
            for jdx=1:size(xi,3)
                for idx=1:size(xi,2)
                    Pxufitvals(idx,jdx) = Pxu{idx,jdx}(1)*meandx(i)+Pxu{idx,jdx}(2);%for each pixel evaluate the fit at a x disp to first
                    Pyufitvals(idx,jdx) = Pyu{idx,jdx}(1)*meandy(i)+Pyu{idx,jdx}(2);%for each pixel evaluate the fit at a x disp to first
                end
            end
            dxspatial=squeeze(dxdrift)-reshape(Pxufitvals,size(squeeze(dxdrift)));
            dyspatial=squeeze(dydrift)-reshape(Pyufitvals,size(squeeze(dydrift)));
            rawudist(i,:,:)=dxspatial-meandx(i);
            rawvdist(i,:,:)=dyspatial-meandy(i);
        end
    end
    
    %% find the time for every pixel in the DIC image sequence
    DICpixeltime=f_find_time(pixelwidth,pixelheight,xi,FileNames,tempdata,semtime);
    %% find the drift distortion for every pixel in every image
    [drifxtaftertime,drifytaftertime]=f_calculate_drift_dist(XYimrange,FileNames,DICpixeltime,dispq,meandx,meandy);
    %% find the distortion field u and v corrected for drift
    driftudist=NaN(size(xi,1),size(xi,2)*size(xi,3));
    driftvdist=driftudist;
    for i=1:length(FileNames)
        tempdata = readtable(FileNames{i});
        [~,~,dx,dy]=f_dataextract(tempdata,dispq,meandx(i),meandy(i));
        dxcorr=dx+drifxtaftertime(i,:)';%account for drift distortion
        dycorr=dy+drifytaftertime(i,:)';%account for drift distortion
        driftudist(i,:)=dxcorr-meandx(i);
        driftvdist(i,:)=dycorr-meandy(i);
    end
    %% fit the distortion fields to a 3D polynomial and fit distortion at every pixel as a function of displacement
    [Pxv,Pxu]=f_calculate_spatial_dist(tempdata,driftudist,driftvdist,xi,yi,Ximrange,meandx);
    %% for y displacements find the distortion field u and v changing the reference to the first image of the sequence
    Ymeandy=meandy-meandy(Yimrange(1));%reference image is first image prior to first translation along the direction
    Ymeandx=meandx-meandx(Yimrange(1));
    Ydriftudist=NaN(size(xi,1),size(xi,2)*size(xi,3));
    Ydriftvdist=Ydriftudist;
    for i = Yimrange
        Ydriftudist(i,:,:)=dx-Ymeandx(i);
        Ydriftvdist(i,:,:)=dy-Ymeandy(i);
    end
    %% fit the distortion fields to a 3D polynomial and fit distortion at every pixel as a function of displacement
    [Pyv,Pyu]=f_calculate_spatial_dist(tempdata,Ydriftudist,Ydriftvdist,xi,yi,Yimrange,meandy);
end
%% let's reduce noize by filtering out some points in frequency space
%{
thresh=0.4;
D=5;%radius in pixels of the mask of values to test
udistcorr=reshape(udist(Yimrange,:,:),size(squeeze(Yxi(Yimrange,:,:))))-udistfitted(Yimrange,:,:);
vdistcorr=reshape(vdist(Yimrange,:,:),size(squeeze(Yxi(Yimrange,:,:))))-vdistfitted(Yimrange,:,:);
for i=1:length(Yimrange)
    
    fixedudistcorr(i,:,:)=f_reduceNoize(udistcorr(i,:,:),D,thresh);%Use FFt mask which keeps values within radius D of center of shifted FFt but reduces values above the theshold percentage of max
    fixedvdistcorr(i,:,:)=f_reduceNoize(vdistcorr(i,:,:),D,thresh);
end
udistcorr=fixedudistcorr+udistfitted(Yimrange,:,:);
vdistcorr=fixedvdistcorr+vdistfitted(Yimrange,:,:);
%for x disp
thresh=0.7;
D=5;%radius in pixels of the mask of values to test
udistcorr=reshape(udist(Ximrange,:,:),size(squeeze(Xxi(Ximrange,:,:))))-udistfitted(Ximrange,:,:);
vdistcorr=reshape(vdist(Ximrange,:,:),size(squeeze(Xxi(Ximrange,:,:))))-vdistfitted(Ximrange,:,:);
for i=1:length(Ximrange)
    
    fixedudistcorr(i,:,:)=f_reduceNoize(udistcorr(i,:,:),D,thresh);%Use FFt mask which keeps values within radius D of center of shifted FFt but reduces values above the theshold percentage of max
    fixedvdistcorr(i,:,:)=f_reduceNoize(vdistcorr(i,:,:),D,thresh);
end
udistcorr=fixedudistcorr+udistfitted(Ximrange,:,:);
vdistcorr=fixedvdistcorr+vdistfitted(Ximrange,:,:);
%DEBUG - Plot the surfaces of the fit, origional data, and noize reduced data
%{
for i=Yimrange
    subplot(2,2,1)
    surf(squeeze(Yxi(i,:,:)),squeeze(Yyi(i,:,:)),squeeze(reshape(udist(i,:,:),size(squeeze(Yxi(i,:,:))))))
    subplot(2,2,2)
    surf(squeeze(Yxi(i,:,:)),squeeze(Yyi(i,:,:)),squeeze(reshape(vdist(i,:,:),size(squeeze(Yxi(i,:,:))))))
    subplot(2,2,3)
    surf(squeeze(Yxi(i,:,:)),squeeze(Yyi(i,:,:)),squeeze(udistcorr(i,:,:)))
    subplot(2,2,4)
    surf(squeeze(Yxi(i,:,:)),squeeze(Yyi(i,:,:)),squeeze(vdistcorr(i,:,:)))
    pause(5)
end
%}
%}
