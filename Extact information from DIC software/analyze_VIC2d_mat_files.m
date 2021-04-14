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
thresh=60;
Cgrad=0;
absthresh=6;
for i = 3%4:2:length(FileNames)
    
    [x,y,exx]=remove_polyfit(data{i}.x,data{i}.y,data{i}.exx);
%     histogram(exx(:));
    
    exx2=f_reduceNoize(exx,D,thresh,Cgrad,absthresh);
    exx2(isnan(exx))=NaN;
    [~,~,eyy]=remove_polyfit(data{i}.x,data{i}.y,data{i}.eyy);
    [~,~,exy]=remove_polyfit(data{i}.x,data{i}.y,data{i}.exy);
    [~,~,e_tresca]=remove_polyfit(data{i}.x,data{i}.y,data{i}.e_tresca);
    [~,~,e_vonmises]=remove_polyfit(data{i}.x,data{i}.y,data{i}.e_vonmises);
    e1=data{i}.e1;
    e2=data{i}.e2;
    figure(2)
%     subplot(floor(length(FileNames)/8),4,i/2-1)
    h=pcolor(x,y,exx2);
    set(h,'EdgeColor','none');
    colorbar
    colormap('hot')
%     caxis([0,nanmean(exx(:))+2*std(exx(:),[],'omitnan')])
    axis image
    drawnow
end