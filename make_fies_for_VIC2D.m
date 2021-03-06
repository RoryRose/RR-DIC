clear all
imageDir='C:\Users\User\OneDrive - Nexus365\Part II\Data\DIC\in-situ tests\Sample 1\Distortion images\InLens\';%file location of images
cd(imageDir)
imageNames=dir(fullfile(imageDir,'*.tif'));
imageNames = {imageNames.name}';
%% read images
refimage(:,:,1)=imread([imageDir imageNames{1}]);
pixelheight=size(refimage,1);
pixelwidth=size(refimage,2);
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
    
    Resolution=strfind(tags,'Store resolution');
    [row,~]=find(~cellfun('isempty',Resolution));
    ResolutionS{i}=tags{row,2};
    
    BeamX=strfind(tags,'Beam Offset X');
    [row,~]=find(~cellfun('isempty',BeamX));
    BeamXS{i}=tags{row,2};
    
    BeamY=strfind(tags,'Beam Offset Y');
    [row,~]=find(~cellfun('isempty',BeamY));
    BeamYS{i}=tags{row,2};

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
    
    imageTime2(i)=datetime(info.FileModDate);
end
%%
CycleTimeN=[split(CycleTimeS,{' '})];

CycleTimeN=str2double(CycleTimeN(:,:,2)).*60;%find the cycle time ad convert from minutes to seconds
DwellTimeN=[split(DwellTimeS,' ')];
DwellTimeN=str2double(DwellTimeN(:,:,2)).*1e-9;%find the cycle time ad convert from ns to seconds
LineTimeN=[split(LineTimeS,' ')];
LineTimeN=str2double(LineTimeN(:,:,2)).*1e-3;%find the cycle time ad convert from us to seconds
PixelSanity=LineTimeN-DwellTimeN.*pixelwidth
LineTimeSanity=(CycleTimeN-DwellTimeN.*(pixelheight*pixelwidth))./pixelheight;
Checkofline=(LineTimeSanity-LineTimeN)./LineTimeSanity.*100

dateandtime=join(horzcat([DateS',TimeS']),' ');
dateandtime=datetime(dateandtime,'InputFormat','dd MMM yyyy HH:mm:ss');
TimeS=strcat({' '},TimeS);
imageNames=strcat('"',imageNames,'"'); %correct format for VIC 2D imagelist file
timediff=seconds(duration(dateandtime-min(dateandtime)));
timediff=seconds(duration(imageTime2-min(imageTime2)))';
% timediff-timediff2';
XposN=split(XposS,' ');
XposN=str2double(XposN(:,:,2));
YposN=split(YposS,' ');
YposN=str2double(YposN(:,:,2));
T=table(imageNames,timediff,DwellTimeS',LineTimeS',XposS',YposS',ZposS',(XposN-min(XposN))',(YposN-min(YposN))',BeamXS',BeamYS');
T.Properties.VariableNames={'Image_Name','Time_from_First_Image_seconds','Dwell_Time','Line_Time','X_position','Y_position','Z_position','X_position_diff','Y_position_diff','X_beam_Offset','Y_beam_Offset'};
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