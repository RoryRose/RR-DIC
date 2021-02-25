
%% for x displacements find the distortion field u and v
%for this set - first 7 have x disp and rest have y disp
Pxufitvals=[];
Pyufitvals=[];
dxspatial=[];
dyspatial=[];
spatialudist=[];
spatialvdist=[];
for i = 1:length(FileNames)
    tempdata = readtable(FileNames{i});
    [Xi(i,:,:),Yi(i,:,:),dx,dy]=f_dataextract(tempdata,dispq,meandx(i),meandy(i));
    
    dxdrift=dx+drifxtaftertime(i,:)';%account for drift distortion
    dydrift=dy+drifytaftertime(i,:)';%account for drift distortion
    for jdx=1:size(vdistfitted,3)
        for idx=1:size(vdistfitted,2)
            Pxufitvals(idx,jdx) = Pxu{idx,jdx}(1)*meandx(i)+Pxu{idx,jdx}(2);%for each pixel evaluate the fit at a x disp to first
            Pyufitvals(idx,jdx) = Pyu{idx,jdx}(1)*meandy(i)+Pyu{idx,jdx}(2);%for each pixel evaluate the fit at a x disp to first
        end
    end
    dxspatial=squeeze(dxdrift)-reshape(Pxufitvals,size(squeeze(dxdrift)));
    dyspatial=squeeze(dydrift)-reshape(Pyufitvals,size(squeeze(dydrift)));
    driftudist(i,:,:)=dxdrift-meandx(i);
    driftvdist(i,:,:)=dydrift-meandy(i);
    rawtudist(i,:,:)=dx-meandx(i);
    rawvdist(i,:,:)=dy-meandy(i);
    spatialudist(i,:,:)=dxspatial-meandx(i);
    spatialvdist(i,:,:)=dyspatial-meandy(i);
end
%% plot
h1=figure;
filename='Distortion correction example with two evaluations.gif';
Xi=xi;
Yi=yi;
for i=2:13
    subplot(2,3,1)
    h=pcolor(squeeze(Xi(i,:,:)),squeeze(Yi(i,:,:)),squeeze(reshape(rawtudist(i,:,:),size(squeeze(Xi(i,:,:))))));
    set(h,'Edgecolor','none')
    xlabel('x1')
    ylabel('x2')
    zlabel('u displacement')
    caxis([-0.2,0.2])
    title('Raw data')
    subplot(2,3,2)
    h=pcolor(squeeze(Xi(i,:,:)),squeeze(Yi(i,:,:)),squeeze(reshape(driftudist(i,:,:),size(squeeze(Xi(i,:,:))))));
    set(h,'Edgecolor','none')
    xlabel('x1')
    ylabel('x2')
    zlabel('u displacement')
    caxis([-0.2,0.2])
    title('Drift corrected data')
    subplot(2,3,3)
    h=pcolor(squeeze(Xi(i,:,:)),squeeze(Yi(i,:,:)),squeeze(reshape(spatialudist(i,:,:),size(squeeze(Xi(i,:,:))))));
    set(h,'Edgecolor','none')
    xlabel('x1')
    ylabel('x2')
    zlabel('u displacement')
    caxis([-0.2,0.2])
    title('Drift and spatial corrected data')
    subplot(2,3,4)
    h=pcolor(squeeze(Xi(i,:,:)),squeeze(Yi(i,:,:)),squeeze(reshape(rawvdist(i,:,:),size(squeeze(Xi(i,:,:))))));
    set(h,'Edgecolor','none')
    xlabel('x1')
    ylabel('x2')
    zlabel('v displacement')
    caxis([-0.2,0.2])
    subplot(2,3,5)
    h=pcolor(squeeze(Xi(i,:,:)),squeeze(Yi(i,:,:)),squeeze(reshape(driftvdist(i,:,:),size(squeeze(Xi(i,:,:))))));
    set(h,'Edgecolor','none')
    xlabel('x1')
    ylabel('x2')
    zlabel('v displacement')
    caxis([-0.2,0.2])
    subplot(2,3,6)
    h=pcolor(squeeze(Xi(i,:,:)),squeeze(Yi(i,:,:)),squeeze(reshape(spatialvdist(i,:,:),size(squeeze(Xi(i,:,:))))));
    set(h,'Edgecolor','none')
    xlabel('x1')
    ylabel('x2')
    zlabel('v displacement')
    caxis([-0.2,0.2])
    sgtitle(strcat('Image number = ',num2str(i)))
    n=i-1;
    drawnow
    pause(0.1)
    % Capture the plot as an image
    frame = getframe(h1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    % Write to the GIF File
    if n == 1
        imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append');
    end
end