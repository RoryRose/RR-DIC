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
D=20;
thresh=90;
Cgrad=0;
absthresh=6;
lim=[-1,0.05];
[x,y,exx]=remove_polyfit(data{3}.x,data{3}.y,exx,lim);
mask=isnan(exx);
for i = 1:5%1:length(FileNames)
    exx=data{i}.exx;
    exx(mask)=0;
    [x,y,exx]=remove_polyfit(data{i}.x,data{i}.y,exx,lim);
%     histogram(exx(:));
    
    exx2=f_reduceNoize(exx,D,thresh,Cgrad,absthresh);
    exx2(isnan(exx))=NaN;
    [x,y,exx2]=remove_polyfit(data{i}.x,data{i}.y,exx2,lim);
    [~,~,eyy]=remove_polyfit(data{i}.x,data{i}.y,data{i}.eyy,lim);
    [~,~,exy]=remove_polyfit(data{i}.x,data{i}.y,data{i}.exy,lim);
    [~,~,e_tresca]=remove_polyfit(data{i}.x,data{i}.y,data{i}.e_tresca,lim);
    [~,~,e_vonmises]=remove_polyfit(data{i}.x,data{i}.y,data{i}.e_vonmises,lim);
    e1=data{i}.e1;
    e2=data{i}.e2;
    figure(2)
    subplot(1,2,1)
    h=pcolor(x,y,exx);
    set(h,'EdgeColor','none');
    colorbar
    colormap('parula')
    caxis([0,0.04])
    axis image
    subplot(1,2,2)
    h=pcolor(x,y,exx2);
    set(h,'EdgeColor','none');
    colorbar
    colormap('parula')
    caxis([0,0.04])
    
    axis image
    drawnow
    sgtitle(i)
end