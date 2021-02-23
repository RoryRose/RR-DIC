clear all
clc
workingDir='Z:\RR\DIC\Example from Phani\pre-test calibration\XY disp\pydic\result\';  % do not forget the \ at the end of folder path
cd(workingDir)
FileNames=dir(fullfile(workingDir,'*.csv'));
FileNames = {FileNames.name}';
data = cell(length(FileNames),1);
%% find distortion field
meandx=[];
for i = 2:length(FileNames)
    tempdata = readtable(FileNames{i});
    [xrangeidx,xrange] = findgroups(tempdata.pos_x);
    [yrangeidx,yrange] = findgroups(tempdata.pos_y);
    [xi, yi] = meshgrid(xrange,yrange);
    F = scatteredInterpolant(tempdata.pos_x,tempdata.pos_y,tempdata.disp_x);
    dx = F(xi,yi);
    F = scatteredInterpolant(tempdata.pos_x,tempdata.pos_y,tempdata.disp_y);
    dy = F(xi,yi);
    meandx(i)=mean(dx(:));
    distortioninx(i,:,:)=dx-meandx(i);
    meandy(i)=mean(dy(:));
    distortioniny(i,:,:)=dy-meandy(i);
end
Y = fft2(squeeze(distortioniny(3,:,:)));
Y(abs(Y)>600)=0;
imagesc(abs(fftshift(Y)))
colorbar
axis image
distortioniny(i,:,:)=ifft2(abs(fftshift(Y)));
contourf(squeeze(abs(distortioniny(i,:,:))));
% plot(meandx,distortioninx(:,10,10))
% figure
% plot(meandy,distortioniny(:,10,10))
%%fit the distortion for each pixel
for j=1:62
    ppm = ParforProgressbar(78);
    parfor i=1:77
        
        fitdx{i,j}=fit(meandx',distortioninx(:,i,j),'smoothingspline');
        fitdy{i,j}=fit(meandy',distortioniny(:,i,j),'smoothingspline');
        ppm.increment();
    end
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
