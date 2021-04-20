function [x, y, ZOut]=remove_polyfit_and_fft_filter(x,y,z,lim,mask,D,thresh,Cgrad,absthresh)

%Remove outliers and zero values as these are artifacts
% z(mask)=NaN;
z(z==0)=NaN;
% z(z<=min(lim)|z>=max(lim))=NaN;
normfit=fitdist(z(:),'normal');
z(z>normfit.mu+10*normfit.sigma)=NaN;
z(z<normfit.mu-10*normfit.sigma)=NaN;
[XOut, YOut, Z] = prepareSurfaceData(x,y,z);
distfit = fit( [XOut, YOut], Z, 'poly23');
dist=distfit(x,y);
Z=z-dist;  
Z=z;
ZOut=f_reduceNoize(Z,D,thresh,Cgrad,absthresh);
ZOut(isnan(Z))=NaN;

end