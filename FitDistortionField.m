clear all
clc
workingDir='Z:\RR\DIC\Example from Phani\pre-test calibration\XY disp\pydic\result\';  % do not forget the \ at the end of folder path
cd(workingDir)
FileNames=dir(fullfile(workingDir,'*.csv'));
FileNames = {FileNames.name}';
data = cell(length(FileNames),1);
%% plot dx rotation
meandx=[];
for i = 2:length(FileNames)
    tempdata = readtable(FileNames{i});
    [xrangeidx,xrange] = findgroups(tempdata.pos_x);
    [yrangeidx,yrange] = findgroups(tempdata.pos_y);
    [xi, yi] = meshgrid(xrange,yrange);
    Fx{i} = scatteredInterpolant(tempdata.pos_x,tempdata.pos_y,tempdata.disp_x);
    dx = Fx{i}(xi,yi);
    Fy{i} = scatteredInterpolant(tempdata.pos_x,tempdata.pos_y,tempdata.disp_y);
    dy = Fy{i}(xi,yi);
    meandx(i)=mean(dx(:));
    distortioninx(i,:,:)=dx-meandx(i);
    meandy(i)=mean(dy(:));
    distortioniny(i,:,:)=dy-meandy(i);
end
pcolor(xi, yi,squeeze(distortioninx(5,:,:)))
caxis([0,0.1])
%% For all pixel positions - find the mean of dx and dy 
[xrangeidx,xrange] = findgroups(tempdata.pos_x);
[yrangeidx,yrange] = findgroups(tempdata.pos_y);
[xi, yi] = meshgrid(xrange,yrange);
%{
for i = 2:length(FileNames)
    dxC(i,:,:) = Fx{i}(xi,yi);
    dyC(i,:,:) = Fy{i}(xi,yi);

end
distx=squeeze(mean(dxC,1));
disty=squeeze(mean(dyC,1));
%}
distx=squeeze(mean(distortioninx,1));
disty=squeeze(mean(distortioniny,1));
pcolor(xi, yi,distx)
caxis([0,7])
pcolor(xi, yi,disty)
caxis([0,0.1])
%% Create a disparity map for spatial distortion correction
disparityRange=[0,8];
for i = 2:length(FileNames)-1
    Jx1=squeeze(distortioninx(i,:,:));
    Jx2=squeeze(distortioninx(i+1,:,:));
    Jy1=squeeze(distortioninx(i,:,:));
    Jy2=squeeze(distortioninx(i+1,:,:));
    disparityMap = disparitySGM(Jx1,Jx2,'DisparityRange',disparityRange);
    figure
    imshow(disparityMap)
end
% plot(meandx,distortioninx(:,10,10))
% figure
% plot(meandy,distortioniny(:,10,10))
%%fit the distortion for each pixel
parfor j=1:size(xi,2)
    ppm = ParforProgressbar(78);
    for i=1:size(xi,1)
        
        fitdistxdxtemp{i}=fit(meandx',distortioninx(:,i,j),'smoothingspline');
        fitdistydytemp{i}=fit(meandy',distortioniny(:,i,j),'smoothingspline');
        
    end
    fitdx(:,j)=fitdistxdxtemp;
    fitdy(:,j)=fitdistydytemp;
    ppm.increment();
end
%% undo the distortion on the images
for i = 2:length(FileNames)
    tempdata = readtable(FileNames{i});
    [xi, yi] = meshgrid(xrange,yrange);
    for j=1:62
        for k=1:77
            dx(k,j)=tempdata.disp_x(sub2ind(size(xi),k,j))-feval(fitdx{k,j},meandx(i));
            dy(k,j)=tempdata.disp_y(sub2ind(size(xi),k,j))-feval(fitdy{k,j},meandy(i));
        end
    end
    s = pcolor(xi,yi,dx);
    c=colorbar;

    title(strcat('xx strain distortion fixed  ',string(i)));
    set(s, 'edgecolor','none');
    disp('image started');
    figure
    s = pcolor(xi,yi,dy);
    c=colorbar;
    
    title(strcat('yy strain distortion fixed  ',string(i)));
    set(s, 'edgecolor','none');
    disp('image started');
end
