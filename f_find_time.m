function DICpixeltimeshaped=f_find_time(pixelwidth,pixelheight,xi,FileNames,tempdata,semtime)
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
DICpixeltime=NaN(size(xi,1),size(xi,2)*size(xi,3));
for i=1:length(FileNames)
    if i==1
        DICpixeltime(i,:)=tempdata.index_y.*semtime.dwell.*...
            DICpixelcolumlength+tempdata.index_x.*semtime.betweenrow.*...
            DICpixelrowheight; %time from start of aquisition period of every pixel in the image
    else
        DICpixeltime(i,:)=semtime.scan(i-1)+tempdata.index_y.*semtime.dwell.*...
            DICpixelcolumlength+tempdata.index_x.*semtime.betweenrow.*...
            DICpixelrowheight; %time from start of aquisition period of every pixel in the image
    end
end
DICpixeltimeshaped=NaN(size(xi));
for i=1:length(FileNames)
    DICpixeltimeshaped(i,:,:)=reshape(DICpixeltime(i,:),size(squeeze(xi(1,:,:))));
end