clear all
imageDir='Z:\RR\DIC\2021-04-09 insitu 304 steel\Summary\Sample 1\global images\';%file location of images
cd(imageDir)
imageNames=dir(fullfile(imageDir,'*.tif'));
imageNames = {imageNames.name}';
if not(isfolder('InLens'))
    mkdir InLens
end
if not(isfolder('SE2'))
    mkdir SE2
end
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
    
    Control=strfind(tags,'Control');
    [row,~]=find(~cellfun('isempty',Control));
    Controls{i}=tags{row,2};
    
    SignalA=strfind(tags,'Signal A');
    [row,~]=find(~cellfun('isempty',SignalA));
    SignalAS{i}=tags{row,2};
    
    SignalB=strfind(tags,'Signal B');
    [row,~]=find(~cellfun('isempty',SignalB));
    SignalBS{i}=tags{row,2};
    
    Detector=strfind(tags,'Detector');
    [row,~]=find(~cellfun('isempty',Detector));
    DetectorS{i}=tags{row,2};
    if strcmp(DetectorS{i},' InLens')
        movefile(imageNames{i}, 'InLens')
    end
    if strcmp(DetectorS{i},' SE2')
        movefile(imageNames{i}, 'SE2')
    end
end

%%

