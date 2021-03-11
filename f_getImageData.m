function [pixelheight,pixelwidth,DwellTimeN,LineTimeN,dateandtime,XposN,YposN]=f_getImageData(imageDir)
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
CycleTimeN=[split(CycleTimeS,' ')];
CycleTimeN=str2double(CycleTimeN(:,:,2)).*60;%find the cycle time ad convert from minutes to seconds
DwellTimeN=[split(DwellTimeS,' ')];
DwellTimeN=str2double(DwellTimeN(:,:,2)).*1e-9;%find the cycle time ad convert from ns to seconds
LineTimeN=[split(LineTimeS,' ')];
LineTimeN=str2double(LineTimeN(:,:,2)).*1e-3;%find the cycle time ad convert from ns to seconds
PixelSanity=LineTimeN-DwellTimeN.*pixelwidth;
LineTimeSanity=(CycleTimeN-DwellTimeN.*(pixelheight*pixelwidth))./pixelheight;
Checkofline=(LineTimeSanity-LineTimeN)./LineTimeSanity.*100;

dateandtime=join(horzcat([DateS',TimeS']),' ');
dateandtime=datetime(dateandtime,'InputFormat','dd MMM yyyy HH:mm:ss');
TimeS=strcat({' '},TimeS);
imageNames=strcat('"',imageNames,'"'); %correct format for VIC 2D imagelist file
timediff=seconds(duration(dateandtime-min(dateandtime)));
XposN=split(XposS,' ');
XposN=str2double(XposN(:,:,2));
XposN=XposN-XposN(1);
YposN=split(YposS,' ');
YposN=str2double(YposN(:,:,2));
YposN=YposN-YposN(1);