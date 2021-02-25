clear all
clc
workingDir='Z:\RR\DIC\Example from Phani\pre-test calibration\pydic\result\';  % do not forget the \ at the end of folder path
cd(workingDir)
FileNames=dir(fullfile(workingDir,'*.csv'));
FileNames = {FileNames.name}';
data = cell(length(FileNames),1);
%% plot xx strain
for i = 2:length(FileNames)
    %subplot(1,2,i-1)
    figure
    tempdata = readtable(FileNames{i});
    [xrangeidx,xrange] = findgroups(tempdata.pos_x);
    [yrangeidx,yrange] = findgroups(tempdata.pos_y);
    [xi, yi] = meshgrid(xrange,yrange);
    F = scatteredInterpolant(tempdata.pos_x,tempdata.pos_y,tempdata.strain_xx);
    zi = F(xi,yi);
    s = pcolor(xi,yi,zi);
%     s = scatter3(tempdata.pos_x,tempdata.pos_y,tempdata.strain_xx,3, tempdata.strain_xx, 'filled')
%     view(0,90);
%     colormap jet
    c=colorbar;
    caxis([-0.02,0.02]);
    title(strcat('xx strain from deformation  ',string(i)));
    set(s, 'edgecolor','none');
    disp('image started');
end
%% plot yy strain
for i = 2:length(FileNames)
    %subplot(1,2,i-1)
    figure
    tempdata = readtable(FileNames{i});
    [xrangeidx,xrange] = findgroups(tempdata.pos_x);
    [yrangeidx,yrange] = findgroups(tempdata.pos_y);
    [xi, yi] = meshgrid(xrange,yrange);
    F = scatteredInterpolant(tempdata.pos_x,tempdata.pos_y,tempdata.strain_yy);
    zi = F(xi,yi);
    s = pcolor(xi,yi,zi);
%     s = scatter3(tempdata.pos_x,tempdata.pos_y,tempdata.strain_xx,3, tempdata.strain_xx, 'filled')
%     view(0,90);
%     colormap jet
    c=colorbar;
    caxis([-0.02,0.02]);
    title(strcat('yy strain from deformation  ',string(i)));
    set(s, 'edgecolor','none');
    disp('image started');
end
%% plot xy strain
for i = 2:length(FileNames)
    %subplot(1,2,i-1)
    tempdata = readtable(FileNames{i});
    [xrangeidx,xrange] = findgroups(tempdata.pos_x);
    [yrangeidx,yrange] = findgroups(tempdata.pos_y);
    [xi, yi] = meshgrid(xrange,yrange);
    F = scatteredInterpolant(tempdata.pos_x,tempdata.pos_y,tempdata.strain_xx);
    zi = F(xi,yi);
    s = pcolor(xi,yi,zi);
%     s = scatter3(tempdata.pos_x,tempdata.pos_y,tempdata.strain_xx,3, tempdata.strain_xx, 'filled')
%     view(0,90);
%     colormap jet
    c=colorbar;
    caxis([-0.1,0.1]);
    title(strcat('xx strain from deformation  ',string(i)));
    set(s, 'edgecolor','none');
    disp('image started');
end
%% plot dx rotation
for i = 2:length(FileNames)
    figure
    tempdata = readtable(FileNames{i});
    [xrangeidx,xrange] = findgroups(tempdata.pos_x);
    [yrangeidx,yrange] = findgroups(tempdata.pos_y);
    [xi, yi] = meshgrid(xrange,yrange);
    F = scatteredInterpolant(tempdata.pos_x,tempdata.pos_y,tempdata.disp_x);
    zi = F(xi,yi);
    s = pcolor(xi,yi,zi);
%     s = scatter3(tempdata.pos_x,tempdata.pos_y,tempdata.strain_xx,3, tempdata.strain_xx, 'filled')
%     view(0,90);
%     colormap jet
    c=colorbar;
%     caxis([0,0.01]);
    title(strcat('x disp from deformation  ',string(i)));
    set(s, 'edgecolor','none');
    disp('image started');
end
%% plot dy rotation
for i = 2:length(FileNames)
    %subplot(1,2,i-1)
    tempdata = readtable(FileNames{i});
    [xrangeidx,xrange] = findgroups(tempdata.pos_x);
    [yrangeidx,yrange] = findgroups(tempdata.pos_y);
    [xi, yi] = meshgrid(xrange,yrange);
    F = scatteredInterpolant(tempdata.pos_x,tempdata.pos_y,tempdata.disp_y);
    zi = F(xi,yi);
    s = pcolor(xi,yi,zi);
%     s = scatter3(tempdata.pos_x,tempdata.pos_y,tempdata.strain_xx,3, tempdata.strain_xx, 'filled')
%     view(0,90);
%     colormap jet
    c=colorbar;
    caxis([-25,25]);
    title(strcat('y disp from deformation  ',string(i)));
    set(s, 'edgecolor','none');
    disp('image started');
end