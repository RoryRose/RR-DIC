function [Xxi,Xyi,dx,dy]=f_dataextract(FileNames,i,DICproscess,dispq,meandx,meandy,data)
if strcmp(DICproscess,'pydic')
    tempdata = readtable(FileNames{i});
    [~,xrange] = findgroups(tempdata.pos_x);
    [~,yrange] = findgroups(tempdata.pos_y);
    [Xxi, Xyi] = meshgrid(xrange,yrange);
    dx = reshape(tempdata.disp_x,size(Xxi));
    dy = reshape(tempdata.disp_y,size(Xxi));
    % dx(dx>1|dx<-1)=0;%clear clearly bad data
    % dy(dy>1|dy<-1)=0;
elseif strcmp(DICproscess,'Ncorr')
    if i==1
        %set up the reference image with zeros
        mask=data{1,1}.data_dic_save.displacements(i).plot_corrcoef_dic;
        mask(mask~=0)=1;
        [yrange,xrange]=find(mask==1);
        xrange=unique(xrange);
        yrange=unique(yrange);
        [Xxi, Xyi] = meshgrid(xrange,yrange');
        dx=zeros(size(Xxi));
        dy=dx;
    else
        i=i-1; %correct for diferent indexing of data
        dx=data{1,1}.data_dic_save.displacements(i).plot_u_dic;
        dy=data{1,1}.data_dic_save.displacements(i).plot_v_dic;
        mask=data{1,1}.data_dic_save.displacements(i).plot_corrcoef_dic;
        mask(mask~=0)=1;
        [yrange,xrange]=find(mask==1);
        xrange=unique(xrange);
        yrange=unique(yrange);
        [Xxi, Xyi] = meshgrid(xrange,yrange');
        dx=reshape(dx(mask==1),size(Xxi));
        dy=reshape(dy(mask==1),size(Xxi));
    end
end
if dispq==1
    %since it seems that some DIC software compute displacements as the
    %displacement minus any rigid body transformation
    %IMPORTANT to set to zero (or other number) if DIC software is not doing this
    dx=dx+meandx;
    dy=dy+meandy;
end