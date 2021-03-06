clear all
clc
workingDir='C:\Users\User\OneDrive - Nexus365\Part II\Data\DIC\in-situ tests\Sample 1\Distortion images\InLens\Renamed\';  % do not forget the \ at the end of folder path
cd(workingDir)
FileNames=dir(fullfile(workingDir,'*.mat'));
FileNames = {FileNames.name}';
data = cell(length(FileNames),1);
%% extract data
for i = 1:length(FileNames)
    data{i}=load(FileNames{i});
end
%% create fits for exx, eyy and tresca
filename='Strain FFT corrected - no polyfit.gif';
D=20;
thresh=70;
Cgrad=-100;
absthresh=1;
lim=[-1,5];
mask=[];
[x,y,exx]=remove_polyfit_and_fft_filter(data{3}.x,data{3}.y,data{3}.exx,lim,mask,D,thresh,Cgrad,absthresh);%this is just one of 
%the images data which shows where we can get data from all images as a 
%first pass on culling bad data
mask=isnan(exx);
j=1;%counting variable
for i = 24%[3,5,7,12,13,17,19,21,23,25]%1:length(FileNames)
    [x,y,exx]=remove_polyfit_and_fft_filter(data{i}.x,data{i}.y,data{i}.exx,lim,mask,D,thresh,Cgrad,absthresh);
%     [x,y,exx2]=remove_polyfit(data{i}.x,data{i}.y,exx2,lim);
    [~,~,eyy]=remove_polyfit_and_fft_filter(data{i}.x,data{i}.y,data{i}.eyy,lim,mask,D,thresh,Cgrad,absthresh);
    [~,~,exy]=remove_polyfit_and_fft_filter(data{i}.x,data{i}.y,data{i}.exy,lim,mask,D,thresh,Cgrad,absthresh);
    [~,~,e_tresca]=remove_polyfit_and_fft_filter(data{i}.x,data{i}.y,data{i}.e_tresca,lim,mask,D,thresh,Cgrad,absthresh);
    [~,~,e_vonmises]=remove_polyfit_and_fft_filter(data{i}.x,data{i}.y,data{i}.e_vonmises,lim,mask,D,thresh,Cgrad,absthresh);
    [~,~,e1]=remove_polyfit_and_fft_filter(data{i}.x,data{i}.y,data{i}.e1,lim,mask,D,thresh,Cgrad,absthresh);
    [~,~,e2]=remove_polyfit_and_fft_filter(data{i}.x,data{i}.y,data{i}.e2,lim,mask,D,thresh,Cgrad,absthresh);
    f=figure(2);
    subplot(2,3,1)
    h=pcolor(x,y,exx);
    set(h,'EdgeColor','none');
    colorbar
    
    caxis([-0.01,0.04])
    title('\epsilon xx')
    axis image
    subplot(2,3,5)
    h=pcolor(x,y,eyy);
    set(h,'EdgeColor','none');
    title('\epsilon yy')
    colorbar
    
    caxis([-0.03,0.1])
    axis image
    subplot(2,3,6)
    h=pcolor(x,y,e_vonmises);
    set(h,'EdgeColor','none');
    title('Von Mises')
    colorbar
    
    caxis([0,0.15])
    axis image
    subplot(2,3,2)
    h=pcolor(x,y,e1);
    set(h,'EdgeColor','none');
    title('\epsilon 1')
    colorbar
    
    caxis([0,0.1])
    axis image
    subplot(2,3,4)
    h=pcolor(x,y,e2);
    title('\epsilon 2')
    set(h,'EdgeColor','none');
    colorbar
    
    caxis([-0.05,0.02])
    axis image
    subplot(2,3,3)
    h=pcolor(x,y,e_tresca);
    set(h,'EdgeColor','none');
    title('Tresca')
    colorbar
  
    caxis([0,0.08])
    axis image
    colormap('hot')
    sgtitle(strcat('Image Number', {' '}, num2str(i)))
    drawnow
    %CREATE GIF
    %{
    % Capture the plot as an image 
    frame = getframe(f); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256); 
    % Write to the GIF File 
    
    if j == 1 
      imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
    else 
      imwrite(imind,cm,filename,'gif','WriteMode','append'); 
    end 
    j=j+1;
    %}
end