function [Xxi,Xyi,dx,dy]=f_dataextract(tempdata,dispq,meandx,meandy)
[~,xrange] = findgroups(tempdata.pos_x);
[~,yrange] = findgroups(tempdata.pos_y);
[Xxi, Xyi] = meshgrid(xrange,yrange);
dx = tempdata.disp_x;
dy = tempdata.disp_y;
dx(dx>1|dx<-1)=0;%clear clearly bad data
dy(dy>1|dy<-1)=0;
if dispq==1
    %since it seems that pydic computes displacements as relative
    %IMPORTANT to remove if DIC software is not doing this
    dx=dx+meandx;
    dy=dy+meandy;
end