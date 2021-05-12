%% LOAD DATA
workingDir='C:\Users\User\Downloads\';  % do not forget the \ at the end of folder path
cd(workingDir)
FileNames=dir(fullfile(workingDir,'*.mat'));
FileNames = {FileNames.name}';
Data = cell(length(FileNames),1);
%% extract data
for i = 1:length(FileNames)
    Data{i}=load(FileNames{i});
end
%% ALTERNATIVE
%{
[file, path] = uigetfile('Select the ncorr.mat file:','MultiSelect','on');%file must be in the path
if isa(file,'char') == true
    file = cellstr(file);
end
NameArray = transpose(string(file));
for FileNum = 1:length(file)
    Data{FileNum}=load(file{FileNum});
end
%}
%% extract and analyse data
%prealocate variables
u=cell(1,size(Data{1,1}.data_dic_save.displacements,2));
v=u;
mask=u;
exx=u;
%FFT filter constants
D=20;
thresh=70;
Cgrad=0;
absthresh=1;
lim=[-1,5];
for i=1:size(Data{1,1}.data_dic_save.displacements,2)
    u{i}=Data{1,1}.data_dic_save.displacements(i).plot_u_dic;
    v{i}=Data{1,1}.data_dic_save.displacements(i).plot_v_dic;
    try
        mask{i}=Data{1,1}.data_dic_save.displacements(i).roi_dic.mask;
    catch
        mask{i}=0;
    end
    exx{i}=Data{1,1}.data_dic_save.strains(i).plot_exx_ref_formatted;
    x=[1:size(exx{i},1)].*Data{1,1}.data_dic_save.dispinfo.pixtounits;
    y=[1:size(exx{i},2)].*Data{1,1}.data_dic_save.dispinfo.pixtounits;
    unit=Data{1,1}.data_dic_save.dispinfo.units;
    [x,y]=meshgrid(x,y);
    %filter exx
    x=x';%#meshgrid things
    y=y';%#meshgrid things
    exx2=f_reduceNoize(exx{i},D,thresh,Cgrad,absthresh);
    exx2(isnan(exx{i}))=NaN;
    exx{i}=exx2;
    %DEBUG - plot file
    %%{
    figure(2)
    subplot(1,2,1)
    h=pcolor(Data{1,1}.data_dic_save.strains(i).plot_exx_ref_formatted);
    set(h, 'EdgeColor', 'none');
    title('Raw data')
    xlabel(strcat('x',{' '},unit))
    ylabel(strcat('y',{' '},unit))
    colormap(parula)
    c=colorbar;
    axis image
    subplot(1,2,2)
    h=pcolor(exx{i});
    set(h, 'EdgeColor', 'none');
    colormap(parula)
    c=colorbar;
    title('Filtered data')
    xlabel(strcat('x',{' '},unit))
    ylabel(strcat('y',{' '},unit))
    axis image
    pause(1)
    %}
end