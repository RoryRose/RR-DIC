function q_createfigures
%Raw Drift Distortion
figure(1)
udist=rawudist;
vdist=rawvdist;
for i = 1:length(XYimrange)/2 %for every image pair
    subplot(2,1,1)
    surf(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),reshape(squeeze(udist(i,:)),size(squeeze(xi(i,:,:)))))
    xlabel('x1')
    ylabel('x2')
    zlabel('u displacement')
    title(strcat('Uncorrected u displacement field for image pair number =',num2str(i)))
    subplot(2,1,2)
    surf(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),reshape(squeeze(vdist(i,:)),size(squeeze(xi(i,:,:)))))
    xlabel('x1')
    ylabel('x2')
    zlabel('v displacement')
    title(strcat('Uncorrected u displacement field for image pair number = ',num2str(i)))
    pause(1)
    sgtitle('Drift distortion between pairs of images taken in the same location')
end
%Raw Pixel Time
figure(2)
for i = 1:length(XYimrange)/2 %for every image pair
    h=pcolor(squeeze(firstxi(i,:,:)),squeeze(firstyi(i,:,:)),squeeze(DICpixeltimeshaped(i,:,:)));
    set(h,'Edgecolor','none')
    xlabel('x1')
    ylabel('x2')
    zlabel('v displacement')
    title(strcat('DIC pixel time for image number = ',num2str(i)))
    colorbar
    pause(1)
end
%Drift Distortion surface
figure(3)
for i=1:length(XYimrange)/2
    subplot(2,2,1)
    h=surf(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),squeeze(udistfitted(i,:,:)));
    set(h,'Edgecolor','none')
    xlabel('x1')
    ylabel('x2')
    zlabel('u displacement')
    title(strcat('Fitted u displacement field'))
    subplot(2,2,2)
    h=surf(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),squeeze(vdistfitted(i,:,:)))
    set(h,'Edgecolor','none')
    xlabel('x1')
    ylabel('x2')
    zlabel('u displacement')
    title(strcat('Fitted v displacement field'))
    subplot(2,2,3)
    h=surf(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),squeeze(reshape(udist(i,:,:),size(squeeze(xi(i,:,:))))))
    set(h,'Edgecolor','none')
    xlabel('x1')
    ylabel('x2')
    zlabel('u displacement')
    title(strcat('Raw u displacement field'))
    subplot(2,2,4)
    h=surf(squeeze(xi(i,:,:)),squeeze(yi(i,:,:)),squeeze(reshape(vdist(i,:,:),size(squeeze(xi(i,:,:))))))
    set(h,'Edgecolor','none')
    xlabel('x1')
    ylabel('x2')
    zlabel('u displacement')
    title(strcat('Raw v displacement field'))
    sgtitle(strcat('Drift Corrected displacement fields for x displacement on image number =',num2str(i)))
    pause(5)
end

%drift model
figure(4)
for i=1:50
    yyaxis left
    plot(DICpixeltimeshaped(:,i,i),drifxtaftertime(:,i,i),'-')
    ylabel('Moddeled Drift Distortion (pix)')
    hold on
    yyaxis right
    plot(velocitymeantime(:,i,i),uvelocity(:,i,i),'-')
    ylabel('Raw Drift Velocity')
    xlabel('Time (s)')
    hold on
    pause(0.2)
end
title('Drift Distortion for 50 pixels along the diagonal of the image with time')
%x Distortion model
figure(5)
subplot(2,2,1)
plot(meandx(1:7),reshape(udistfitted,[7,size(Xxi,3).*size(Xxi,2) ]),'o')
xlabel('x displacement to first image')
ylabel('fitted u distortion')
title('u distortion for all pixels')
subplot(2,2,2)
plot(meandx(1:7),reshape(vdistfitted,[7,size(Xxi,3).*size(Xxi,2) ]),'o')
xlabel('x displacement to first image')
ylabel('fitted v distortion')
title('v distortion for all pixels')
subplot(2,2,3)
plot(meandy(7:13),reshape(udistfitted(7:13,:,:),[7,size(Xxi,3).*size(Xxi,2) ]),'o')
xlabel('y displacement to first image')
ylabel('fitted u distortion')
title('u distortion for all pixels')
subplot(2,2,4)
plot(meandy(7:13),reshape(vdistfitted(7:13,:,:),[7,size(Xxi,3).*size(Xxi,2) ]),'o')
xlabel('y displacement to first image')
ylabel('fitted v distortion')
title('v distortion for all pixels')
sgtitle('Drift Corrected Fitted distortion field data as a function of x and y displacement for all images')
%smooth data
for i=Yimrange
    subplot(2,2,1)
    h=surf(squeeze(Xxi(i,:,:)),squeeze(Xyi(i,:,:)),squeeze(reshape(udist(i,:,:),size(squeeze(Xxi(i,:,:))))));
    set(h,'Edgecolor','none')
    xlabel('x1')
    ylabel('x2')
    zlabel('u displacement')
    title(strcat('Raw u displacement field'))
    subplot(2,2,2)
    imagesc(abs(fftshift(fft2(squeeze(reshape(udist(i,:,:),size(squeeze(Xxi(i,:,:)))))))));
    caxis([0,max(max(abs(fftshift(fft2(squeeze(reshape(udist(i,:,:),size(squeeze(Xxi(i,:,:))))))))))*0.4])
    title(strcat('FFT of Raw u displacement field'))
    subplot(2,2,3)
    h=surf(squeeze(Xxi(i,:,:)),squeeze(Xyi(i,:,:)),squeeze(udistcorr(i,:,:)));
    set(h,'Edgecolor','none')
    xlabel('x1')
    ylabel('x2')
    zlabel('u displacement')
    title(strcat('FFT filtered u displacement field'))
    subplot(2,2,4)
    imagesc(abs(fftshift(fft2(squeeze(reshape(udistcorr(i,:,:),size(squeeze(Xxi(i,:,:)))))))));
    caxis([0,max(max(abs(fftshift(fft2(squeeze(reshape(udist(i,:,:),size(squeeze(Xxi(i,:,:))))))))))*0.4])
    title(strcat('FFT of u displacement field after mask applied'))
    sgtitle('Drift Corrected X displacement distortion fields showing FFT filtering')
    pause(5)
end
