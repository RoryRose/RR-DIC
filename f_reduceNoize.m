function amplitudeImage3=f_reduceNoize(Image,D,amplitudeThreshold,Cgrad,absthresh)
    if min(Image(:))<0
        shift=abs(min(Image(:)));
    else
        shift=0;
    end
    Image=Image+shift;
    Image=fillmissing(Image,'constant',0);
    
    frequencyImage = fftshift(fft2(squeeze(Image)));
    % Take log magnitude for calculation.
    amplitudeImage = log(abs(frequencyImage));
    % Exclude the central DC spike with a disk of radius D
    [x,y]=size(amplitudeImage);
    Mask = fspecial('disk',D)==0;
    Mask = imresize(padarray(Mask, [floor((x/2)-D) floor((y/2)-D)], 1, 'both'), [x y]);%create a circular mask in the center to protect that information
    minValue = min(min(amplitudeImage(Mask==1)));
    maxValue = max(max(amplitudeImage(Mask==1)));
    
    % Find the location of the big spikes.
    if maxValue>absthresh%only change anything if the maximum value is larger absthresh (e.g 3)
        
        Threshold = maxValue/100*amplitudeThreshold;
    else
        Threshold=maxValue+1;
    end
    brightSpikes = amplitudeImage > Threshold; % Binary image.
    
    
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
    amplitudeImage3 = abs(filteredImage)-shift;
    minValue = min(min(amplitudeImage3));
    maxValue = max(max(amplitudeImage3));
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
    imshow(amplitudeImage3, []);
    title('Filtered Image');
    axis on;
    %}

    
end