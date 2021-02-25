function drifxtaftertime=f_udrifteval(DICpixeltimeshaped,Driftumodel,fileidx)
%integrates the drift velocity b-spline fit up to the time that the pixel was
%recorded to find the total drift after time t for every DIC pixel in every
%image
drifxtaftertime=NaN(size(DICpixeltimeshaped,2),size(DICpixeltimeshaped,3));
%Integrate the B-spline by using trapeziodal numerical integration
for j=1:size(DICpixeltimeshaped,3)
    for i=1:size(DICpixeltimeshaped,2)
        timevals=linspace(0,max(DICpixeltimeshaped(1:fileidx,i,j)),1000);
        Splineevaluated=fnval(Driftumodel{i,j}.p,timevals);
        drifxtaftertime(i,j)=trapz(timevals,Splineevaluated);
    end
end

%'Properly' Integrate the B-spline function. More accurate, but slow
%{
drifxtaftertime=NaN(size(DICpixeltimeshaped,2),size(DICpixeltimeshaped,3));
fun=@(x,ipixel,jpixel)fnval(Driftumodel{ipixel,jpixel}.p,x);
for j=1:size(DICpixeltimeshaped,3)
    j
    for i=1:size(DICpixeltimeshaped,2)
        %Integrate from t=0 - t=t not sure why we need 'ArrayValued'....
        drifxtaftertime(:,i,j)=integral(@(x)fun(x,i,j),0,DICpixeltimeshaped(fileidx,i,j),'ArrayValued',true);
    end
    
end
%}