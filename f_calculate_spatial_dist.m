function [Pyv,Pyu]=f_calculate_spatial_dist(Ydriftudist,Ydriftvdist,xi,yi,Yimrange,meandy)
%fit a polynomial surface to the distortion data and fit the distortion as
%a function of translation to the reference image
%INPUTS:
%   tempdata = one of the data csv files as a table
%   Ydriftudist = raw u displacement field
%   Ydriftvdist = raw v displacement field
%   xi = mesh of rows of the DIC data
%   yi = mesh of colums of the DIC data
%   Yimrange = list of image numbers being analyzed
%   meandy = image translation in the direction being investigated
%OUTPUTS:
%   Pyv = linear fit of v distortion for every pixel as a function of translation to origional image position
%   Pyu = linear fit of u distortion for every pixel as a function of translation to origional image position 
%% fit the distortion fields to a 3D polynomial and evaluate at every pixel - here using a polyfit
disp('creating best fit surface...')
for i=Yimrange
    [XOut, YOut, ZOut] = prepareSurfaceData(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),squeeze(Ydriftudist(i,:,:)));
    udistfit{i} = fit( [XOut, YOut], ZOut, 'poly23');
    [XOut, YOut, ZOut] = prepareSurfaceData(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),squeeze(Ydriftvdist(i,:,:)));
    vdistfit{i} = fit( [XOut, YOut], ZOut, 'poly23');
    udistfitted(i,:,:)=udistfit{i}(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)));
    vdistfitted(i,:,:)=vdistfit{i}(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)));
    %%{    
    figure(1)
    subplot(2,2,1)
    h=surf(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),reshape(squeeze(Ydriftudist(i,:)),size(squeeze(xi(i,:,:)))));
    set(h,'Edgecolor','none')
    subplot(2,2,2)
    h=surf(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),reshape(squeeze(Ydriftvdist(i,:)),size(squeeze(xi(i,:,:)))));
    set(h,'Edgecolor','none')
    subplot(2,2,3)
    h=surf(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),squeeze(udistfitted(i,:,:)));
    set(h,'Edgecolor','none')
    subplot(2,2,4)
    h=surf(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),squeeze(vdistfitted(i,:,:)));
    set(h,'Edgecolor','none')
    pause(1)
    %}
end
%% Model the variation in each point on the surface as a function of x
%displacement as a linear function
disp('fitting data as a function of translation...')
[Pyv,Pyu]=f_SpatialDistortion(meandy,vdistfitted,udistfitted,Yimrange,yi(i,:,:));
disp('finished fitting...')