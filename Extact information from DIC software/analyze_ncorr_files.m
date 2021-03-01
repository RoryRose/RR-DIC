[file, path] = uigetfile('Select the ncorr.mat file:','MultiSelect','on');%file must be in the path
if isa(file,'char') == true
    file = cellstr(file);
end
NameArray = transpose(string(file));
for FileNum = 1:length(file)
    Data{FileNum}=load(file{FileNum});
end
u=cell(1,size(Data{1,1}.data_dic_save.displacements,2));
v=u;
mask=u;
for i=1:size(Data{1,1}.data_dic_save.displacements,2)
    u{i}=Data{1,1}.data_dic_save.displacements(i).plot_u_dic;
    v{i}=Data{1,1}.data_dic_save.displacements(i).plot_v_dic;
    mask{i}=Data{1,1}.data_dic_save.displacements(i).roi_dic.mask;
    u{i}(mask{i}==0)=NaN;
    v{i}(mask{i}==0)=NaN;
    %DEBUG - plot file
    %{
    figure(1)
    subplot(1,2,1)
    h=pcolor(u{i});
    set(h, 'EdgeColor', 'none');
    colormap(parula)
    c=colorbar;
    subplot(1,2,2)
    h=pcolor(v{i});
    set(h, 'EdgeColor', 'none');
    colormap(parula)
    c=colorbar;
    pause(1)
    %}
end