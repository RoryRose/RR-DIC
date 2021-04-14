function amplitudeImage3=f_reduceNoize(Image,D,amplitudeThreshold,Cgrad,absthresh)
    Image=fillmissing(Image,'constant',0);
    frequencyImage = fftshift(fft2(squeeze(Image)));
    % Take log magnitude so we can see it better in the display.
    amplitudeImage = log(abs(frequencyImage));
    minValue = min(min(amplitudeImage));
    maxValue = max(max(amplitudeImage));
    
    % Find the location of the big spikes.
    if maxValue>absthresh%only change anything if the maximum value is larger absthresh (e.g 3)
        
        amplitudeThreshold = maxValue/100*amplitudeThreshold;
    else
        amplitudeThreshold=maxValue+1;
    end
    brightSpikes = amplitudeImage > amplitudeThreshold; % Binary image.
    
    % Exclude the central DC spike with a disk of radius D
    [x,y]=size(amplitudeImage);
    Mask = fspecial('disk',D)==0;
    Mask = imresize(padarray(Mask, [floor((x/2)-D) floor((y/2)-D)], 1, 'both'), [x y]);%create a circular mask in the center to protect that information
    brightSpikes(Mask==0)=false;
    
    %Don't remove spikes if local gradient is below Cgrad
    Gmag=imgradient(amplitudeImage);
    brightSpikes(Gmag<Cgrad)=false;
    % Filter/mask the spectrum.
    brightSpikes2=imgaussfilt(double(~brightSpikes));
    brightSpikes=brightSpikes2.*double(~brightSpikes);%make zeros zero
    frequencyImage=frequencyImage.*brightSpikes;
    % Take log magnitude so we can see it better in the display.
    amplitudeImage2 = log(abs(frequencyImage));
    minValue = min(min(amplitudeImage2));
    maxValue = max(max(amplitudeImage2));
    
    % zoom(10)

    filteredImage = ifft2(fftshift(frequencyImage));
    amplitudeImage3 = abs(filteredImage);
    minValue = min(min(amplitudeImage3))
    maxValue = max(max(amplitudeImage3))
    %DEBUG - show images
    %%{
    figure(1)
    subplot(2,3,1)
    imshow(Image, [min(Image(:)) max(Image(:))]);
    axis on;
    title('Input Image');
    subplot(2,3,2)
    imagesc(Mask)
    colormap(gray)
    caxis([0,1])
    axis image
    axis on;
    title('Mask to protect values from changing')
    subplot(2,3,3)
    imshow(brightSpikes);
    title('Bright spikes other than central spike');
    subplot(2,3,4)
    imshow(amplitudeImage, []);
    caption = sprintf('Amplitude Image');
    title(caption);
    axis on;
    subplot(2,3,5)
    imshow(amplitudeImage2, []);
    axis on;
    title('Spikes zeroed out');
    subplot(2,3,6)
    imshow(amplitudeImage3, [min(Image(:)) max(Image(:))]);
    title('Filtered Image');
    axis on;
    %}
% %     %create mask
% %     [x,y]=size(Y);
% %     Mask2=Y<=max(Y(:).*thresh); %find all values in frequency space higher than the theshold fraction of max
% %     Mask = fspecial('disk',D)==0;
% %     Mask = ~imresize(padarray(Mask, [floor((x/2)-D) floor((y/2)-D)], 1, 'both'), [x y]);%create a circular mask in the center to protect that information
% %     MaskT=Mask+Mask2;
% %     MaskT(MaskT>1)=1;
% % %     MaskT=imgaussfilt(MaskT,2);
% % %     nnz(1-MaskT)
% %     % Apply mask
% %     Y=Y.*MaskT;
% %     fixedImage=abs(ifft2(ifftshift(Y),'symmetric'));



    % DEBUG - plot the mask
    %{
    figure
    subplot(1,3,1)
    imagesc(Mask)
    colormap(gray)
    caxis([0,1])
    title('Mask to protect values from changing')
    subplot(1,3,2)
    imagesc(Mask2)
    colormap(gray)
    caxis([0,1])
    title('Mask of values above threshold')
    subplot(1,3,3)
    imagesc(MaskT)
    colormap(gray)
    caxis([0,1])
    title('Overall Mask')
    sgtitle('Masks used to reduce noize')
    %}
    %DEBUG - plot the difference between the values
    
end