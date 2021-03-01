function drifxtaftertime=f_udrifteval(DICpixeltimeshaped,Driftumodel,fileidx,sizey)
%integrates the drift velocity b-spline fit up to the time that the pixel was
%recorded to find the total drift after time t for every DIC pixel in every
%image
%UPDATE 26/02/2021 - Now looking at time only information --> don't look at
%every pixel, just the time 
drifxtaftertime=NaN(size(Driftumodel,2),size(Driftumodel,3));
if size(Driftumodel,2)*size(Driftumodel,3)==size(DICpixeltimeshaped,2)*size(DICpixeltimeshaped,3) %if the image has been re-sampled to increase efficiency
    %Integrate the B-spline by using trapeziodal numerical integration
    for j=1:size(DICpixeltimeshaped,3)
        for i=1:size(DICpixeltimeshaped,2)
            timevals=linspace(0,max(DICpixeltimeshaped(1:fileidx,i,j)),1000);
            Splineevaluated=fnval(Driftumodel{i,j}.p,timevals);
            drifxtaftertime(i,j)=trapz(timevals,Splineevaluated);
        end
    end
else
    for j=1:sizey
        indexesy=ceil(size(DICpixeltimeshaped,3)./sizey.*(j-1))+1:ceil(size(DICpixeltimeshaped,3)/sizey.*j);
        for i=1:sizey
            indexesx=ceil(size(DICpixeltimeshaped,2)./sizey.*(i-1))+1:ceil(size(DICpixeltimeshaped,2)/sizey.*i);
            timevals=linspace(0,max(max(max(DICpixeltimeshaped(1:fileidx,indexesx,indexesy)))),1000);
            Splineevaluated=fnval(Driftumodel{i,j}.p,timevals);
            drifxtaftertime(indexesx,indexesy)=trapz(timevals,Splineevaluated);
        end
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