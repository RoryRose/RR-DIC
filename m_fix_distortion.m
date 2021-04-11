% Methodology for correcting time-dependent and time-indipendent
% distortions. This version of the code assumes input data is of the form
% produced by pydic or ncorr for simplicity.
 
%references for methodology:
%Sutton, M. A., Li, N., Garcia, D., Cornille, N., Orteu, J. J., McNeill, S. R., … Li, X. (2006). Metrology in a scanning electron microscope: Theoretical developments and experimental validation. Measurement Science and Technology, 17(10), 2613–2622. https://doi.org/10.1088/0957-0233/17/10/012
%Kammers, A. D., & Daly, S. (2013). Digital Image Correlation under Scanning Electron Microscopy: Methodology and Validation. Experimental Mechanics, 53(9), 1743–1761. https://doi.org/10.1007/s11340-013-9782-x
%Cornille, Nicolas. (2004). Accurate 3D Shape and Displacement Measurement using a Scanning Electron Microscope. Signal and Image processing. INSA de Toulouse, 2005. English. https://tel.archives-ouvertes.fr/file/index/docid/166423/filename/cornille_2005.pdf
clc
%workingDir='Z:\RR\DIC\Example from Phani\pre-test calibration\XY disp\pydic\result\';  % do not forget the \ at the end of folder path
workingDir='C:\Users\User\OneDrive - Nexus365\Part II\Data\DIC\beamshiftimages\';  % do not forget the \ at the end of folder path
cd(workingDir)
imageDir='C:\Users\User\OneDrive - Nexus365\Part II\Data\DIC\beamshiftimages\';%file location of images
DICproscess='Ncorr';
if strcmp(DICproscess,'pydic')
    FileNames=dir(fullfile(workingDir,'*.csv'));
    FileNames = {FileNames.name}';
    data = cell(length(FileNames),1);
    dispq=1; %is displacement measured relative? = 1 if displacements are zero for a ideal rigid body translation
elseif strcmp(DICproscess,'Ncorr')
    FileNames=dir(fullfile(workingDir,'*.mat'));
    FileNames = {FileNames.name}';
    if isa(FileNames,'char') == true
        file = cellstr(file);
    end
    NameArray = transpose(string(FileNames));
    data=cell(length(FileNames),1);
    for FileNum = 1:length(FileNames)
        data{FileNum}=load(FileNames{FileNum});
    end
    FileNames=1:size(data{1,1}.data_dic_save.displacements,2)+1;%the plus 1 is to be able to add the reference image at the start with zero displacements for compatability
    dispq=0; %is displacement measured relative? = 1 if displacements are zero for a ideal rigid body translation
else
    error('DIC Input not supported')
end
%% find displacements of every image assuming rigid monomodal trasnformation
%this looks at the origional images
imagedispq=2;%set to 1 if using an image set not made by zeiss smart software which generates lot's of TIF tags which we can use
if imagedispq==1 %if images were collected by moving the beam OR not collected on a SEM that produces the recognized tiff tags
    [imageTime,meandx,meandy,pixelheight,pixelwidth,tformEstimate]=f_getTform(imageDir);
    DwellTime=90e-9.*ones(size(meandx));%GUESS, but put in real values!
    LineTime=7e-4.*ones(size(meandx));%GUESS, but put in real values!
    %IMPORTANT: this method will deal with displacements in pixels based on
    %the calculated transformation between the images
else
    [~,meandx,meandy,~,~,tformEstimate]=f_getTform(imageDir);
    [pixelheight,pixelwidth,DwellTime,LineTime,imageTime]=f_getImageData(imageDir);
    %IMPORTANT: this method will deal with displacements in pixels based on
    %the calculated transformation between the images!
end
%% initialise time data - this must use the imaging parameters in the future
semtime=struct();
%THESE ARE GUESSES for now, BUT NEED TO  BE FOUND FOR THE IMAGES YOU ARE ANALYSING
semtime.dwell=DwellTime;
semtime.betweenrow=LineTime;
semtime.scan=seconds(imageTime-imageTime(1));%Time is in seconds, This relies on the time in the metadata being correct!
semtime.frame=pixelheight.*pixelwidth*semtime.dwell+pixelheight*semtime.betweenrow; %time to complete a frame
%% find images pairs for analysis by seperating into those that have a displacement between them and those that do not
[Ximrange,Yimrange,XYimrange]=f_findimageindex(meandx,meandy);
meandy(min(Ximrange):min(Yimrange))=0;%assume that the translations were done correctly and that any values in here are just incorrect from f_getTform
meandx(min(Yimrange):end)=meandx(min(Yimrange)+1);%assume that the translations were done correctly and that any values in here are just incorrect from f_getTform
meandx=round(meandx);%round the displacements to the nearest pixel
meandy=round(meandy);
%% 
% for runindex=1:2
runindex=1;%temporarilly setting the loop variable to one for testing
    if runindex == 1
        %% for all images, find the distortion field u and v
        for i=1:length(FileNames)
            [xi(i,:,:),yi(i,:,:),dx(i,:,:),dy(i,:,:)]=f_dataextract(FileNames,i,DICproscess,dispq,meandx(i),meandy(i),data);
            rawudist(i,:,:)=squeeze(dx(i,:,:))-meandx(i);
            rawvdist(i,:,:)=squeeze(dy(i,:,:))-meandy(i);
            %DEBUG - plot file
            %{
            figure(1)
            subplot(2,2,1)
            h=pcolor(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),squeeze(dx(i,:,:)));
            set(h, 'EdgeColor', 'none');
            colormap(parula)
            c=colorbar;
            subplot(2,2,2)
            h=pcolor(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),squeeze(dy(i,:,:)));
            set(h, 'EdgeColor', 'none');
            colormap(parula)
            c=colorbar;
            subplot(2,2,3)
            h=pcolor(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),squeeze(rawudist(i,:,:)));
            set(h, 'EdgeColor', 'none');
            colormap(parula)
            c=colorbar;
            subplot(2,2,4)
            h=pcolor(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),squeeze(rawvdist(i,:,:)));
            set(h, 'EdgeColor', 'none');
            colormap(parula)
            c=colorbar;
            pause(1)
            %}
        end
    else %if we have alrady done at least one run of the model, we need to calculate corrected distortions
        %% for all images, find the distortion field u and v correcting for the previousley calculated drift and spatial distortions
        for i = 1:length(FileNames)
            dxdrift=squeeze(dx(i,:,:))+squeeze(drifutaftertime(i,:,:));%account for drift distortion
            dydrift=squeeze(dy(i,:,:))+squeeze(drifvtaftertime(i,:,:));%account for drift distortion
            %account for spatial distortion
            for jdx=1:size(xi,3)
                for idx=1:size(xi,2)
                    Pxufitvals(idx,jdx) = Pxu{idx,jdx}(1)*meandx(i)+Pxu{idx,jdx}(2);%for each pixel evaluate the fit at a x disp to first
                    Pyufitvals(idx,jdx) = Pyu{idx,jdx}(1)*meandy(i)+Pyu{idx,jdx}(2);%for each pixel evaluate the fit at a x disp to first
                end
            end
            dxspatial=squeeze(dxdrift)-Pxufitvals;
            dyspatial=squeeze(dydrift)-Pyufitvals;
            rawudist(i,:,:)=dxspatial-meandx(i);
            rawvdist(i,:,:)=dyspatial-meandy(i);
            %DEBUG - plot file
            %{
            figure(1)
            subplot(2,2,1)
            h=pcolor(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),dx);
            set(h, 'EdgeColor', 'none');
            colormap(parula)
            c=colorbar;
            subplot(2,2,2)
            h=pcolor(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),dy);
            set(h, 'EdgeColor', 'none');
            colormap(parula)
            c=colorbar;
            subplot(2,2,3)
            h=pcolor(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),squeeze(rawudist(i,:,:)));
            set(h, 'EdgeColor', 'none');
            colormap(parula)
            c=colorbar;
            subplot(2,2,4)
            h=pcolor(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),squeeze(rawvdist(i,:,:)));
            set(h, 'EdgeColor', 'none');
            colormap(parula)
            c=colorbar;
            pause(1)
            %}
        end
    end
    
    %% find the time for every pixel in the DIC image sequence
    [DICpixeltimeshaped,DICpixeltime]=f_find_time(pixelwidth,pixelheight,FileNames,xi,yi,semtime);
    %% find the drift distortion for every pixel in every image
    globalq=0;%Type of drif distortion that you want to correct for. 
    %GLOBAL(1) gives the global fit of drift as a function of pixel aquizition time 
    %(not recommended by literature)
    %LOCAL(0) computes global distortion, but also compares the two images taken at the same position and
    %creates a local drift distorion model for every image and so you only
    %locally fix drift distortion. (recommended by literature)
    if globalq==1
        [drifutaftertime,drifvtaftertime,timevals]=f_GLOBAL_calculate_drift_dist(XYimrange,FileNames,DICpixeltimeshaped,dispq,meandx,meandy,DICproscess,data,DICpixeltime,semtime);
    elseif globalq==0
        [drifutaftertime,drifvtaftertime,timevals]=f_GLOBAL_calculate_drift_dist(XYimrange,FileNames,DICpixeltimeshaped,dispq,meandx,meandy,DICproscess,data,DICpixeltime,semtime);
        [Pu,Pv]=f_LOCAL_calculate_drift_dist(XYimrange,FileNames,DICpixeltimeshaped,dispq,meandx,meandy,DICproscess,data);
        %combine the local and global model to find the total drift by
        %addin the value of the global model at the start of each image to
        %the local model for every pixel
        disp('Combining local and global drift models')
        for i = 1:length(XYimrange)/2
            firstidx=XYimrange(2*i-1);
            secondidx=XYimrange(2*i);    
            timediff2=DICpixeltimeshaped(secondidx,:,:)-DICpixeltimeshaped(firstidx,1,1);
            timediff1=DICpixeltimeshaped(firstidx,:,:)-DICpixeltimeshaped(firstidx,1,1);
            ufit1 = slmeval(timediff1,Pu{i},0);%evaluate the fit for all of the time values
            ufit2 = slmeval(timediff2,Pu{i},0);
            vfit1 = slmeval(timediff1,Pv{i},0);
            vfit2 = slmeval(timediff2,Pv{i},0);
            drifutaftertime(firstidx,:,:)=reshape(drifutaftertime(firstidx,1,1)+ufit1,size(drifutaftertime,2),size(drifutaftertime,3));
            drifutaftertime(secondidx,:,:)=reshape(drifutaftertime(firstidx,1,1)+ufit2,size(drifutaftertime,2),size(drifutaftertime,3));
            drifvtaftertime(firstidx,:,:)=reshape(drifvtaftertime(firstidx,1,1)+vfit1,size(drifutaftertime,2),size(drifutaftertime,3));
            drifvtaftertime(secondidx,:,:)=reshape(drifvtaftertime(firstidx,1,1)+vfit2,size(drifutaftertime,2),size(drifutaftertime,3));
        end
    end
    disp('Finished Drift Correction')
    %% find the distortion field u and v corrected for drift
    driftudist=NaN(size(xi));
    driftvdist=driftudist;
    for i=1:length(FileNames)
        dxcorr=squeeze(dx(i,:,:))-squeeze(drifutaftertime(i,:,:));%account for drift distortion
        dycorr=squeeze(dy(i,:,:))-squeeze(drifvtaftertime(i,:,:));%account for drift distortion
        driftudist(i,:,:)=dxcorr-meandx(i);
        driftvdist(i,:,:)=dycorr-meandy(i);
    end
    %% fit the distortion fields to a 3D polynomial and fit distortion at every pixel as a function of displacement
    %I AM NOT CONVINCED BY WHAT I HAVE DONE IN THIS SECTION
    [Pxv,Pxu]=f_calculate_spatial_dist(driftudist,driftvdist,xi,yi,Ximrange,meandx,meandy,1);
    %% for y displacements find the distortion field u and v changing the reference to the first image of the sequence
    Ymeandy=meandy;%reference image is first image prior to first translation along the direction
    Ymeandx=meandx-meandx(Yimrange(1));
    Ydriftudist=NaN(size(xi));
    Ydriftvdist=Ydriftudist;
    for i = Yimrange
        Ydriftudist(i,:,:)=squeeze(dx(i,:,:))-meandx(i);
        Ydriftvdist(i,:,:)=squeeze(dy(i,:,:))-meandy(i);
    end
    %% fit the distortion fields to a 3D polynomial and fit distortion at every pixel as a function of displacement
    [Pyv,Pyu]=f_calculate_spatial_dist(Ydriftudist,Ydriftvdist,xi,yi,Yimrange,meandx,meandy,0);
% end
%% let's reduce noize by filtering out some points in frequency space
%%{
for i=1:size(xi,1)
    xi(i,:,:)=squeeze(xi(i,:,:))+meandx(i);%the real pixel positions for every point in the DIC image
    yi(i,:,:)=squeeze(yi(i,:,:))+meandy(i);
    [XOut, YOut, ZOut] = prepareSurfaceData(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),squeeze(rawudist(i,:,:)));
    udistfit{i} = fit( [XOut, YOut], ZOut, 'poly23');
    [XOut, YOut, ZOut] = prepareSurfaceData(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),squeeze(rawudist(i,:,:)));
    vdistfit{i} = fit( [XOut, YOut], ZOut, 'poly23');
    udistfitted(i,:,:)=udistfit{i}(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)));
    vdistfitted(i,:,:)=vdistfit{i}(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)));
end
%%
thresh=0.4;
D=100;%radius in pixels of the mask of values to test
udistcorr=rawudist(:,:,:)-udistfitted(:,:,:);
vdistcorr=rawvdist(:,:,:)-vdistfitted(:,:,:);
fixedvdistcorr=[];
fixedudistcorr=[];
for i=Yimrange
    fixedudistcorr(i,:,:)=f_reduceNoize(udistcorr(i,:,:),D,thresh);%Use FFt mask which keeps values within radius D of center of shifted FFt but reduces values above the theshold percentage of max
    fixedvdistcorr(i,:,:)=f_reduceNoize(vdistcorr(i,:,:),D,thresh);
end
SMudistcorr=fixedudistcorr(Yimrange,:,:);
SMvdistcorr=fixedvdistcorr(Yimrange,:,:);

%DEBUG - Plot the surfaces of the fit, origional data, and noize reduced data
%{
for i=Ximrange
    subplot(2,2,1)
    h=surf(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),squeeze(rawudist(i,:,:)))
    subplot(2,2,2)
    h=surf(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),squeeze(rawvdist(i,:,:)))
    subplot(2,2,3)
    h=surf(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),squeeze(udistcorr(i,:,:)))
    subplot(2,2,4)
    h=surf(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),squeeze(vdistcorr(i,:,:)))
    pause(5)
end
%}
%DEBUG - plot surfaces pre and post filtering with fft shown
%smooth data
%%{
for i=Yimrange
    subplot(2,2,1)
    h=surf(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),squeeze(udistcorr(i,:,:)));
    set(h,'Edgecolor','none')
    xlabel('x1')
    ylabel('x2')
    zlabel('u displacement')
    title(strcat('Raw u displacement field'))
    subplot(2,2,2)
    imagesc(abs(fftshift(fft2(squeeze(udistcorr(i,:,:))))));
    caxis([0,max(max(abs(fftshift(fft2(squeeze(udistcorr(i,:,:)))))))*thresh])
    title(strcat('FFT of Raw u displacement field'))
    subplot(2,2,3)
    h=surf(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),squeeze(SMudistcorr(Yimrange==i,:,:)));
    set(h,'Edgecolor','none')
    xlabel('x1')
    ylabel('x2')
    zlabel('u displacement')
    title(strcat('FFT filtered u displacement field'))
    subplot(2,2,4)
    imagesc(abs(fftshift(fft2(squeeze(SMudistcorr(Yimrange==i,:,:))))));
    caxis([0,max(max(abs(fftshift(fft2(squeeze(SMudistcorr(Yimrange==i,:,:)))))))*thresh])
    title(strcat('FFT of u displacement field after mask applied'))
    sgtitle('Drift Corrected X displacement distortion fields showing FFT filtering')
    pause(5)
end
%}