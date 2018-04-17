%look at prey capture video tracking groupdata
%groupdata generated by AnalyzeBonsaiTrackingData
%which is called by preycapturebatch using file list preycapturefilelist

%mount wehrrig4
%system('mount_smbfs smb://wehrrig4/C /Volumes/C')
close all

groupdatadir= 'C:\Users\lab\Desktop\826 mice bonsai';
groupdatafilename='preycapture_groupdata';

%adjust filenames to work on a mac
if ismac
    groupdatadir= strrep(groupdatadir, '\', '/');
    groupdatadir= strrep(groupdatadir, 'C:', '/Volumes/C');
    
end

cd(groupdatadir)
load(groupdatafilename)
numfiles=length(groupdata);

%     speed=groupdata(i).speed;
%     cspeed=groupdata(i).cspeed;
%     range=groupdata(i).range;
%     lag=groupdata(i).lag; %time vector for xcorrs
%     xc1=groupdata(i).xc1; %xcorr of cricket speed -> mouse speed
%     xc2=groupdata(i).xc2; %xcorr of cricket speed -> range
%     xc3=groupdata(i).xc3; %xcorr of mouse speed -> range
%     azimuth=groupdata(i).azimuth;
%     t=groupdata(i).t; %time vector for distances, in seconds
%     tspeed=groupdata(i).tspeed; %%time vector for speeds, in seconds (=1 sample shorter than t)
%     framerate=groupdata(i).framerate;
%     smouseCOMx=groupdata(i).smouseCOMx;
%     smouseCOMy=groupdata(i).smouseCOMy;
%     scricketx=groupdata(i).scricketx;
%     scrickety=groupdata(i).scrickety;
%     smouseNosex=groupdata(i).smouseNosex;
%     smouseNosey=groupdata(i).smouseNosey;
%     numframes=groupdata(i).numframes;
%     start_frame=groupdata(i).start_frame;
%     stop_frame=groupdata(i).stop_frame;
Range=[];
Speed=[];
CSpeed=[];
Azimuth=[];
T=[];
Numframes=[];

for i=1:length(groupdata)
    Numframes(i)=groupdata(i).numframes;
end
maxnumframes=max(Numframes);

%matrices to hold range etc. on each trial
RangeM=nan*ones(numfiles, maxnumframes);
SpeedM=RangeM;
CSpeedM=RangeM;
AzimuthM=RangeM;

framerate=groupdata(1).framerate;

for i=1:length(groupdata)
    if ~mod(i,10)
        fprintf('\nfile %d/%d', i, numfiles)
    end
    %     xc1=groupdata(i).xc1; %xcorr of cricket speed -> mouse speed
    %     xc2=groupdata(i).xc2; %xcorr of cricket speed -> range
    %     xc3=groupdata(i).xc3; %xcorr of mouse speed -> range
    
    range=groupdata(i).range;
    speed=groupdata(i).speed;
    cspeed=groupdata(i).cspeed;
    t=groupdata(i).t;
    azimuth=groupdata(i).azimuth;
    Range=[Range; range(1:end-1)];
    T=[T t(1:end-1)];
    Speed=[Speed; speed];
    CSpeed=[CSpeed; cspeed];
    Azimuth=[Azimuth; azimuth(1:end-1)];
    numframes=groupdata(i).numframes;
    
    RangeM(i,maxnumframes-numframes+1:maxnumframes)=range;
    SpeedM(i,maxnumframes-numframes+2:maxnumframes)=speed;
    CSpeedM(i,maxnumframes-numframes+2:maxnumframes)=cspeed;
    AzimuthM(i,maxnumframes-numframes+1:maxnumframes)=azimuth;

    
    %recompute xcorr but thresholding for cricket speed
    maxlag=1*framerate;
    thresh=100;
    cspeed_th=nan(size(cspeed));
    x=find(cspeed>thresh);
    cspeed_th(x)=cspeed(x);
    
    %grow to +- 1 s window around jumps
    win=1; %seconds
    for y=x(:)'
        start=y-win*framerate;
        if start<1 start=1;end
        stop=y+win*framerate;
        if stop>=numframes-1 stop=numframes-1;end
        cspeed_th(start:stop)= cspeed(start:stop);
    end
    cspeed_th(isnan(cspeed_th))=0; %this artificially sets speed to zero more than 1s from where cricket is below thresh
    
    %in order to compute xcorr of cricket speed -> mouse speed, conditioned
    %on whether the range is below some threshold, prepare cricket and
    %mouse speed conditioned on range below threshold
    cspeed_rth=nan(size(cspeed)); %rth = "range theshold"
    mspeed_rth=nan(size(cspeed));
    rthresh=50;
    x=find(range<rthresh);
    x=x(x<=length(cspeed_rth)); %trim to size of speed vector 
    cspeed_rth(x)=cspeed(x);
    mspeed_rth(x)=speed(x);
    mspeed_rth(isnan(mspeed_rth))=0; %this artificially sets speed to zero wherever range is above thresh (xcorr cannot accept nans)
    cspeed_rth(isnan(cspeed_rth))=0; %this artificially sets speed to zero wherever range is above thresh (xcorr cannot accept nans)

    
    [xc1, lag]=xcorr(speed, cspeed, maxlag, 'unbiased');%unbiased
    [xc1_th, lag]=xcorr(speed, cspeed_th, maxlag, 'unbiased');%unbiased
    [xc1_rth, lag]=xcorr(mspeed_rth, cspeed_rth, maxlag, 'unbiased');%unbiased
    [xc2, lag]=xcorr(range, cspeed, maxlag);%unbiased
    [xc2_th, lag]=xcorr(range, cspeed_th, maxlag);%unbiased
    [xc3, lag]=xcorr(range, speed, maxlag);%unbiased
    xc1=xc1- mean(xc1);
    xc1=xc1./max(abs(xc1));
    xc1_th=xc1_th- mean(xc1_th);
    xc1_th=xc1_th./max(abs(xc1_th));
    xc1_rth=xc1_rth- mean(xc1_rth);
    xc1_rth=xc1_rth./max(abs(xc1_rth));
    xc2=xc2- mean(xc2);
    xc2=xc2./max(abs(xc2));
    xc2_th=xc2_th- mean(xc2_th);
    xc2_th=xc2_th./max(abs(xc2_th));
    xc3=xc3- mean(xc3);
    xc3=xc3./max(abs(xc3));
    
    XC1(i,:)=xc1;
    XC2(i,:)=xc2;
    XC1_th(i,:)=xc1_th;
    XC1_rth(i,:)=xc1_rth;
    XC2_th(i,:)=xc2_th;
    XC3(i,:)=xc3;
    
end

lag=1000*lag/framerate;
%plot average xcorrs of mouse speed, cricket speed, and range
figure;hold on
semxc1=std(XC1)./sqrt(numfiles);
semxc2=std(XC2)./sqrt(numfiles);
semxc1_th=nanstd(XC1_th)./sqrt(numfiles);
semxc1_rth=nanstd(XC1_rth)./sqrt(numfiles);
semxc2_th=nanstd(XC2_th)./sqrt(numfiles);
semxc3=std(XC3)./sqrt(numfiles);

plot(0,0, 'b', 0,0, 'c', 0,0, 'k',0,0, 'r',0,0, 'm', 0,0, 'g') %dummy for legend
legend('cricket speed -> mouse speed','cricket speed th -> mouse speed',...
    'cricket speed (range th) -> mouse speed (range th)',...
    'cricket speed -> range','cricket speed th -> range','mouse speed -> range', ...
    'location', 'NorthWest')
shadedErrorBar(lag, mean(XC1), semxc1, 'b', 1);
shadedErrorBar(lag, nanmean(XC1_th), semxc1_th, 'c', 1);
shadedErrorBar(lag, nanmean(XC1_rth), semxc1_rth, 'k', 1);
shadedErrorBar(lag, mean(XC2), semxc2, 'r', 1);
shadedErrorBar(lag, nanmean(XC2_th), semxc2_th, 'm', 1);
shadedErrorBar(lag, mean(XC3), semxc3, 'g', 1);
grid on
title('xcorr of mouse speed and cricket speed')
xlabel('time lag, ms')


%2-D histogram of azimuth vs range
%histogram azimuth -360-3600 degrees in 60 bins, and ranges 0-1200 px in 60 bins
Azimuthedges=linspace(0, 180, 20);
Rangeedges=linspace(0, 1200, 20);
histmat=hist2(Azimuth, Range, Azimuthedges, Rangeedges);
figure;
pcolor(Azimuthedges,Rangeedges,histmat);
shading interp
xlabel('Azimuth, degrees')
ylabel('Range, px')
% colorbar ;
title(sprintf('Azimuth vs. Range, n=%d', numfiles))


% 2-D histogram of range vs speed
%histogram speeds 0-40 px/s  in 30 bins, and ranges 0-1200 px in 60 bins
Speededges=linspace(0, 40, 20);
Rangeedges=linspace(0, 1200, 30);
histmat=hist2(Speed, Range, Speededges, Rangeedges);
figure;
pcolor(Speededges,Rangeedges,histmat);
shading interp
xlabel('mouse speed, px/s')
ylabel('range, px')
% colorbar ;
title(sprintf('Mouse Speed vs. Range, n=%d', numfiles))

% 2-D histogram of range vs cricket speed
%histogram speeds 0-40 px/s  in 30 bins, and ranges 0-1200 px in 60 bins
CSpeededges=linspace(0, 40, 20);
Rangeedges=linspace(0, 1200, 30);
histmat=hist2(CSpeed, Range, CSpeededges, Rangeedges);
figure;
pcolor(CSpeededges,Rangeedges,histmat);
shading interp
xlabel('cricket speed, px/s')
ylabel('range, px')
% colorbar ;
title(sprintf('cricket Speed vs. Range, n=%d', numfiles))

% 2-D histogram of mouse speed vs cricket speed
%histogram speeds 0-40 px/s  in 30 bins, and ranges 0-1200 px in 60 bins
CSpeededges=linspace(0, 50, 25);
Speededges=linspace(0, 40, 20);
histmat=hist2(Speed, CSpeed, Speededges, CSpeededges);
figure;
pcolor(Speededges,CSpeededges,histmat);
shading interp
xlabel('mouse speed, px/s')
ylabel('cricket speed, px/s')
% colorbar ;
title(sprintf('mouse speed vs cricket Speed , n=%d', numfiles))



%things to try:
% only look where cricket speed is above a threshold
% only look for last n seconds (i.e. prior to catch)


figure
hold on
offset=0;
for i=1:numfiles
    plot(lag, XC1_th(i,:)+offset, 'k')
offset=offset+.1;
end
grid on


% looks flat, presumably because without a threshold, most of the time the cricket is holding still
% figure
% hold on
% offset=0;
% for i=1:numfiles
%     plot(lag, XC1(i,:)+offset, 'k')
% offset=offset+10;
% end
% grid on

%how about a 2-d histogram of range over time, aligned to capture

% or for that matter a population average range vs time, aligned to capture
% and azimuth, speed, etc. as well
figure
F=-size(RangeM,2)+1:1:0;
t=F/framerate;
shadedErrorBar(t, nanmean(RangeM), nanstd(RangeM), 'b', 1);
xlim([-20 0])
xlabel('time to capture, s')
ylabel('range, pixels')

figure
shadedErrorBar(t, nanmean(AzimuthM), nanstd(AzimuthM), 'b', 1);
xlim([-20 0])
xlabel('time to capture, s')
ylabel('Azimuth, degrees')

figure
hold on
shadedErrorBar(t, nanmean(SpeedM), nanstd(SpeedM), 'b', 1);
shadedErrorBar(t, nanmean(CSpeedM), nanstd(CSpeedM), 'r', 1);
xlim([-20 0])
xlabel('time to capture, s')
ylabel('speed, pixels/sec')

figure
hist(Numframes/framerate, 50)
title(sprintf('Time to capture, median=%.1f s +- %.1f s', median(Numframes)/framerate, std(Numframes/framerate)/sqrt(numfiles)))
xlabel('time to capture, s')
ylabel('count')

% how about a 2-d histogram (e.g. azimuth vs range) where color indicates
% time-to-capture (cool to warm), and data density is indicated by
% brightness

%%%%%%%%%%%%%%%%%%
% look for motifs

%motifs are composed of elements (events). We can first identify the
%events, and then look for combinations of them.
%cricket starts to move
%cricket stops moving
%cricket jumps

cspeed_thresh=40;
i=find(CSpeed>cspeed_thresh);

t=1:length(Speed);t=t/30;
figure
hold on
plot(t, CSpeed, t(i), CSpeed(i), '.')
xlabel('time, s')
ylabel('cricket speed')
xlim([100 200])
tt=t(i);
tt=tt(1:end-1);

%plot(tt, diff(i)-10, 'ro')

cspeed_onsetsi=1+find(diff(i)>1);
cspeed_offsetsi=find(diff(i)>1);
%these are indexed into i, convert back into frames
cspeed_onsets=round(tt(cspeed_onsetsi)*30);
cspeed_offsets=round(tt(cspeed_offsetsi)*30);

stem(t(cspeed_onsets), 20*ones(size(cspeed_onsets)), 'go')
stem(t(cspeed_offsets), 20*ones(size(cspeed_offsets)), 'mo')

figure
plot(CSpeed)
hold on
stem((cspeed_onsets), 20*ones(size(cspeed_onsets)), 'go')

k=0;
winstart=-200;
winstop=200;
for j=cspeed_onsets
    if j>-winstart & j+winstop<length(Azimuth)
        k=k+1;
        Az_cspeedonset(k,:)=Azimuth(j+winstart:j+winstop);
        Range_cspeedonset(k,:)=Range(j+winstart:j+winstop);
    end
end

for j=cspeed_offsets
    if j>-winstart & j+winstop<length(Azimuth)
        k=k+1;
        Az_cspeedoffset(k,:)=Azimuth(j+winstart:j+winstop);
        Range_cspeedoffset(k,:)=Range(j+winstart:j+winstop);
    end
end

figure
shadedErrorBar(winstart:winstop, mean(Az_cspeedonset), nanstd(Az_cspeedonset), 'b', 1);
xlabel('frames relative to cricket starts moving')
ylabel('Azimuth')
grid on

figure
shadedErrorBar(winstart:winstop, mean(Range_cspeedonset), nanstd(Range_cspeedonset), 'b', 1);
xlabel('frames relative to cricket starts moving')
ylabel('Range')
grid on


figure
shadedErrorBar(winstart:winstop, mean(Az_cspeedoffset), nanstd(Az_cspeedoffset), 'b', 1);
xlabel('frames relative to cricket stops moving')
ylabel('Azimuth')
grid on

figure
shadedErrorBar(winstart:winstop, mean(Range_cspeedoffset), nanstd(Range_cspeedoffset), 'b', 1);
xlabel('frames relative to cricket stops moving')
ylabel('Range')
grid on
