[file, path] = uigetfile('Select the report file:','MultiSelect','on');
if isa(file,'char') == true
    file = cellstr(file);
end
NameArray = transpose(string(file));
for FileNum = 1:length(file)
    Data{FileNum}=load(file{FileNum});
end
u=cell(1,size(Data{1,1}.data_dic_save.displacements,2));
v=u;
for i=1:size(Data{1,1}.data_dic_save.displacements,2)
    u{i}=Data{1,1}.data_dic_save.displacements(i).plot_u_ref_formatted;
    v{i}=Data{1,1}.data_dic_save.displacements(i).plot_v_ref_formatted;
    u{i}(u{i}==0)=NaN;
    figure
    h=pcolor(u{i});
    set(h, 'EdgeColor', 'none');
    colormap(parula)
    c=colorbar;
end