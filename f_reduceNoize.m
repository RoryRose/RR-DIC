function fixedImage=f_reduceNoize(Image,D,thresh)
    Y = fft2(squeeze(Image));
    Y=abs(fftshift(Y));
    %create mask
    [x,y]=size(Y);
    Mask2=Y<=max(Y(:).*thresh); %find all values in frequency space higher than the theshold fraction of max
    Mask = fspecial('disk',D)==0;
    Mask = ~imresize(padarray(Mask, [floor((x/2)-D) floor((y/2)-D)], 1, 'both'), [x y]);%create a circular mask in the center to protect that information
    MaskT=Mask+Mask2;
    MaskT(MaskT>1)=1;
    % Apply mask
    Y=Y.*MaskT;
    fixedImage=abs(ifft2(Y));
end