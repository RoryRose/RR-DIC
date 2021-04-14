function [x, y, ZOut]=remove_polyfit(x,y,z)
%Remove outliers and zero values as these are artifacts
z(z==0)=NaN;
normfit=fitdist(z(:),'normal');
z(z>normfit.mu+3*normfit.sigma)=NaN;
z(z<normfit.mu-3*normfit.sigma)=NaN;
[XOut, YOut, ZOut] = prepareSurfaceData(x,y,z);
distfit = fit( [XOut, YOut], ZOut, 'poly23');
dist=distfit(x,y);
ZOut=z-dist;

end