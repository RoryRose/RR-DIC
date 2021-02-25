function [Ximrange,Yimrange,XYimrange]=f_findimageindex(meandx,meandy)
%find the images which correspond to the first image after the x
%translations, y translations, and the image pairs. It is assumed that
%images with no stage translation will have a calculated translation less than 10
%pixels
%INPUTS:
%   meandx = x distortions for each image (defined as distortion from image
%       to reference image)
%   meandy = y distortions for each image (defined as distortion from image
%       to reference image)
%OUTPUTS:
%   Ximrange = image number of first images after x displacements
%   Yimrange = image number of first images after y displacements
%   XYimrange = image numbers of the image pairs taken with no translation
%       between them
for i = 1:length(meandx)
    difinx=abs(meandx(i)-meandx);
    difiny=abs(meandy(i)-meandy);
    difinx=difinx<10;
    difiny=difiny<10;
    difq(i)=sum(double(difinx).*double(difiny))>1;%find the image sets which have at least one other image with x and y displacement difference less than 10
end
difinx=diff(abs(meandx(1)-meandx));%find the x images to be used as they have a large x translation to the last image
difiny=diff(abs(meandy(1)-meandy));%find the y images to be used as they have a large y translation to the last image
XYimrange=[1:length(meandx)];
Ximrange=XYimrange(difinx>10);
Yimrange=XYimrange(difiny>10);
XYimrange=XYimrange(difq==1);