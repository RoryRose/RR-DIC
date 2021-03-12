function [DICpixeltime,DICpixeltimeshaped]=f_find_time(pixelwidth,pixelheight,FileNames,xi,yi,semtime)
%find the time that every pixel was recorded
%INPUTS:
%   pixelwidth = width of SEM images in pixels
%   pixelheight = height of SEM images in pixels
%   xi = x coordinates of DIC data
%   FileNames = names of the DIC files
%   tempdata = one of the DIC data files csv as a table
%   semtime = structure of SEM pixel collection time data
%OUTPUTS:
%   DICpixeltimeshaped = time for each pixel arranged in the same shape as
%       xi

DICpixelcolumlength=pixelwidth./size(xi(1,:,:),2);%number of sem pixels in height of one DIC pixel
DICpixelrowheight=pixelheight./size(xi(1,:,:),3);%number of sem pixels in length of one DIC pixel
DICpixeltime=NaN(size(xi));
for i=1:length(FileNames)
    if i==1
        DICpixeltime(i,:,:)=squeeze(xi(1,:,:))*semtime.dwell(i).*...
            DICpixelcolumlength+squeeze(yi(1,:,:)).*semtime.betweenrow(i).*...
            DICpixelrowheight; %time from start of aquisition period of every pixel in the image
    else
        DICpixeltime(i,:,:)=semtime.scan(i)+squeeze(xi(1,:,:)).*semtime.dwell(i).*...
            DICpixelcolumlength+squeeze(yi(1,:,:)).*semtime.betweenrow(i).*...
            DICpixelrowheight; %time from start of aquisition period of every pixel in the image
    end
end
% h=pcolor(squeeze(xi(1,:,:)),squeeze(yi(1,:,:)),squeeze(DICpixeltime(1,:,:)));
% set(h,'EdgeColor','none')

DICpixeltimeshaped=NaN(size(xi,1),size(xi,2)*size(xi,3));
for i=1:length(FileNames)
    for j=1:size(xi,3)
        for k=1:size(xi,2)
            DICpixeltimeshaped(i,j+(k-1)*size(xi,3))=DICpixeltime(i,k,j);
        end
    end
    %DEBUG - plot the picel time for every image
    %{
    plot(DICpixeltimeshaped(i,:))
    hold on
    pause(1)
    %}
end
