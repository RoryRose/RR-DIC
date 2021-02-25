function q_createfigures
figure(1)
for i = 1:length(XYimrange)/2 %for every image pair
    subplot(2,1,1)
    surf(squeeze(firstxi(i,:,:)),squeeze(firstyi(i,:,:)),reshape(squeeze(udist(i,:)),size(squeeze(firstxi(i,:,:)))))
    xlabel('x1')
    ylabel('x2')
    zlabel('u displacement')
    title(strcat('Uncorrected u displacement field for image pair number =',num2str(i)))
    subplot(2,1,2)
    surf(squeeze(firstxi(i,:,:)),squeeze(firstyi(i,:,:)),reshape(squeeze(vdist(i,:)),size(squeeze(firstxi(i,:,:)))))
    xlabel('x1')
    ylabel('x2')
    zlabel('v displacement')
    title(strcat('Uncorrected u displacement field for image pair number = ',num2str(i)))
    pause(1)
    sgtitle('Drift distortion between pairs of images taken in the same location')
end