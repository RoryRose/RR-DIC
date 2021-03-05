imageDir='Z:\RR\DIC\Example from Phani\pre-test calibration\XY disp\';%file location of images
cd(imageDir)
imageNames=dir(fullfile(imageDir,'*.tif'));
imageNames = {imageNames.name}';
%% read images
for i=1:length(imageNames)
    info=imfinfo([imageDir imageNames{i}],'TIF');
    tags=info.UnknownTags.Value;

    tags=splitlines(tags);
    idx=strfind(tags,' = ');
    TF=cellfun('isempty',idx);
    tags=tags(~TF);
    tags=split(tags,'=');
    CycleTime=strfind(tags,'Cycle Time');
    [row,~]=find(~cellfun('isempty',CycleTime));
    CycleTimeS{i}=tags{row,2};

    DwellTime=strfind(tags,'Dwell Time');
    [row,~]=find(~cellfun('isempty',DwellTime));
    DwellTimeS{i}=tags{row,2};

    LineTime=strfind(tags,'Line Time');
    [row,~]=find(~cellfun('isempty',LineTime));
    LineTimeS{i}=tags{row,2};
    
    Ypos=strfind(tags,'Stage at Y');
    [row,~]=find(~cellfun('isempty',Ypos));
    YposS{i}=tags{row,2};
    
    Xpos=strfind(tags,'Stage at X');
    [row,~]=find(~cellfun('isempty',Xpos));
    XposS{i}=tags{row,2};
    
    Zpos=strfind(tags,'Stage at Z');
    [row,~]=find(~cellfun('isempty',Zpos));
    ZposS{i}=tags{row,2};
    
    tags=info.UnknownTags.Value;
    tags=splitlines(tags);
    idx=strfind(tags,' :');
    TF=cellfun('isempty',idx);
    tags=tags(~TF);
    tags=split(tags,' :');

    Time=strfind(tags,'Time');
    [row,~]=find(~cellfun('isempty',Time));
    TimeS{i}=tags{row,2};

    Date=strfind(tags,'Date');
    [row,~]=find(~cellfun('isempty',Date));
    DateS{i}=tags{row,2};
end
%%

dateandtime=join(horzcat([DateS',TimeS']),' ');
dateandtime=datetime(dateandtime,'InputFormat','dd MMM yyyy HH:mm:ss');
TimeS=strcat(' ',TimeS);
imageNames=strcat('"',imageNames,'"'); %correct format for VIC 2D imagelist file
timediff=seconds(duration(dateandtime-min(dateandtime)));
XposN=split(XposS,' ');
XposN=str2double(XposN(:,:,2));
YposN=split(YposS,' ');
YposN=str2double(YposN(:,:,2));
T=table(imageNames,timediff,DwellTimeS',LineTimeS',XposS',YposS',ZposS',(XposN-min(XposN))',(YposN-min(YposN))');
T.Properties.VariableNames={'Image_Name','Time_from_First_Image_seconds','Dwell_Time','Line_Time','X_position','Y_position','Z_position','X_position_diff','Y_position_diff'};
T2=table(imageNames,TimeS');
writetable(T2,'imglist.lst','FileType','text','WriteVariableNames',false);
writetable(T,'Imagedetails.csv','WriteVariableNames',true);
%% sanity check for date and time
%{
for i =1:length(imageNames)
    info=imfinfo([imageDir imageNames{i}],'TIF');
    imageTime2(i)=datetime(info.FileModDate);
end

imageTime2'
%}