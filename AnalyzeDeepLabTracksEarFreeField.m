function AnalyzeDeepLabTracksEarFreeField(varargin)
%this function loads tracking data from indivual sessions, computes several
%things like speed, range, azimuth, creates several plots and prints them
%to a postscript file, and saves the output to a groupdata file.
%
%This function is meant to be called by preycapturebatch using a file list preycapturefilelist
%or jsut run it from the data directory
%
close all
datapath = pwd;
analysis_plots_dir = pwd;
temp = dir('Behavior*.mat');
load(temp.name);
% try
%     start_frame = varargin{1};
% catch
%     start_frame=find(SkyTrack.Chead(:,3)>0.8,1); %use first frame with high cricket-confidence
% end
start_frame=1; %no cricket in free field so start everything from frame 1
stop_frame = SkyTrack.skystop;

%target directory for appended plotting output file
groupdatadir = analysis_plots_dir; %where to accumulate groupdata file
groupdatafilename='preycapture_groupdata.mat';

%adjust filenames to work on a mac
if ismac
    datapath= strrep(datapath, '\', '/');
    datapath= strrep(datapath, 'C:', '/Volumes/C');
    
    analysis_plots_dir= strrep(analysis_plots_dir, '\', '/');
    analysis_plots_dir= strrep(analysis_plots_dir, 'C:', '/Volumes/C');
    
    groupdatadir= strrep(groupdatadir, '\', '/');
    groupdatadir= strrep(groupdatadir, 'C:', '/Volumes/C');
    
end

out=LoadDeepCutTracksFreeField();

mouseCOMxy=out.mouseCOMxy;
mouseNosexy=out.mouseNosexy;
framerate=30;

%%%%%%    Clip SkyTracking from start:stop     %%%%%%
mouseCOMxy=mouseCOMxy(start_frame:stop_frame,:);
mouseNosexy=mouseNosexy(start_frame:stop_frame,:);

%%%%%%    Clip LearTracking from start:stop     %%%%%%
LearStart = find(Lear.skysync==start_frame,1);
if isempty(LearStart)
    LearStart = Lear.skysync(1);
end
LearStop = find(Lear.skysync==stop_frame,1);
if isempty(LearStop)
    LearStop = find(Lear.skysync==stop_frame-1,1);
end
LcDorMed1 = out.LcDorMed1((LearStart:LearStop),:);
LcDorMed2 = out.LcDorMed2((LearStart:LearStop),:);
LcDorLat1 = out.LcDorLat1((LearStart:LearStop),:);
LcDorLat2 = out.LcDorLat2((LearStart:LearStop),:);
LcDist = out.LcDist((LearStart:LearStop),:);
LcVenMed1 = out.LcVenMed1((LearStart:LearStop),:);
LcVenMed2 = out.LcVenMed2((LearStart:LearStop),:);
LcVenLat1 = out.LcVenLat1((LearStart:LearStop),:);
LcVenLat2 = out.LcVenLat2((LearStart:LearStop),:);
LiDorMed1 = out.LiDorMed1((LearStart:LearStop),:);
LiDorMed2 = out.LiDorMed2((LearStart:LearStop),:);
LiDorLat1 = out.LiDorLat1((LearStart:LearStop),:);
LiDorLat2 = out.LiDorLat2((LearStart:LearStop),:);
LiDist = out.LiDist((LearStart:LearStop),:);
LiVenLat1 = out.LiVenLat1((LearStart:LearStop),:);
LiVenLat2 = out.LiVenLat2((LearStart:LearStop),:);
LiVenMed1 = out.LiVenMed1((LearStart:LearStop),:);
LiVenMed2 = out.LiVenMed2((LearStart:LearStop),:);
LiThetaAverage = out.LiThetaAverage((LearStart:LearStop),:);
%%%%%%    Clip RearTracking from start:stop     %%%%%%
RearStart = find(Lear.skysync==start_frame,1);
if isempty(RearStart)
    RearStart = Rear.skysync(1);
end
RearStop = find(Rear.skysync==stop_frame,1);
if isempty(RearStop)
    RearStop = find(Rear.skysync==stop_frame-1,1);
end
RcDorMed1 = out.RcDorMed1((RearStart:RearStop),:);
RcDorMed2 = out.RcDorMed2((RearStart:RearStop),:);
RcDorLat1 = out.RcDorLat1((RearStart:RearStop),:);
RcDorLat2 = out.RcDorLat2((RearStart:RearStop),:);
RcDist = out.RcDist((RearStart:RearStop),:);
RcVenLat1 = out.RcVenLat1((RearStart:RearStop),:);
RcVenLat2 = out.RcVenLat2((RearStart:RearStop),:);
RcVenMed1 = out.RcVenMed1((RearStart:RearStop),:);
RcVenMed2 = out.RcVenMed2((RearStart:RearStop),:);
RiDorMed1 = out.RiDorMed1((RearStart:RearStop),:);%%%%%
RiDorMed2 = out.RiDorMed2((RearStart:RearStop),:);
RiDorLat1 = out.RiDorLat1((RearStart:RearStop),:);
RiDorLat2 = out.RiDorLat2((RearStart:RearStop),:);
RiDist = out.RiDist((RearStart:RearStop),:);
RiVenLat1 = out.RiVenLat1((RearStart:RearStop),:);
RiVenLat2 = out.RiVenLat2((RearStart:RearStop),:);
RiVenMed1 = out.RiVenMed1((RearStart:RearStop),:);
RiVenMed2 = out.RiVenMed2((RearStart:RearStop),:);
RiThetaAverage = out.RiThetaAverage((RearStart:RearStop),:);
%%%%%%    End of clipping section     %%%%%%

t=1:length(mouseCOMxy);
t=t/framerate; % t is in seconds
LeftCamtime = linspace(t(1),t(end),length(LcDorMed1));
RightCamtime = linspace(t(1),t(end),length(RcDorMed2));

figure
plot(mouseCOMxy(:,1), mouseCOMxy(:,2))
hold on
plot(mouseNosexy(:,1), mouseNosexy(:,2))
title('raw data')
legend('mouse COM', 'mouse nose')





%smooth

[b,a]=butter(3, .25);
smouseCOMx=filtfilt(b,a,mouseCOMxy(:,1));
smouseCOMy=filtfilt(b,a,mouseCOMxy(:,2));
smouseNosex=filtfilt(b,a,mouseNosexy(:,1));
smouseNosey=filtfilt(b,a,mouseNosexy(:,2));


ftracks=figure('position', [418        1         788        1069]);
ax= axes('pos', [0.1300    0.7093    0.52    0.22]);
hold on
plot(smouseCOMx, smouseCOMy, smouseNosex, smouseNosey)
text(smouseCOMx(1), smouseCOMy(1), 'start')
axis([300 1600 0 1200])
title('mouse positions, smoothed')
set(gca, 'ydir', 'reverse')

figure
hold on
plot(smouseCOMx)
plot(smouseCOMy)
plot( smouseNosex)
plot(smouseNosey)
legend('COMx', 'COMy', 'noseX', 'noseY')
% animate the mouse and cricket
% if(1)
%     h=plot(smouseCOMx(1), smouseCOMy(1), 'bo', smouseNosex(1), smouseNosey(1), 'ro');
%     for f=1:length(smouseCOMx)
%         hnew=plot(smouseCOMx(f), smouseCOMy(f), 'bo', ...
%             smouseNosex(f), smouseNosey(f), 'ro', ...
%             scricketx(f), scrickety(f), 'ko');
%         set(h, 'visible', 'off');
%         h=hnew;
%         pause(.01)
%     end
% end

%atan2d does the full circle (-180 to 180)
%atand does the half circle (-90 to 90)


%mouse bearing: mouse body-to-nose angle, in absolute coordinates
deltax=smouseNosex-smouseCOMx;
deltay=smouseNosey-smouseCOMy;
mouse_bearing=atan2d(deltay, deltax);





figure
hold on

plot(mouse_bearing)
title('absolute angles')
legend( 'mouse bearing')

mouse_bearing_unwrapped = 180/pi * unwrap(mouse_bearing * pi/180);

figure(ftracks)
subplot(312)
hold on
plot(mouse_bearing_unwrapped, 'k')
title('unwrapped absolute mouse bearing')
 print -dpsc2 'analysis_plots.ps' -append

% legend('mouse COM to cricket', 'mouse nose to cricket', 'mouse bearing')

% animate the mouse and cricket
% if(1)
%     h=plot(smouseCOMx(1), smouseCOMy(1), 'bo', smouseNosex(1), smouseNosey(1), 'ro');
%     for f=1:length(smouseCOMx)
%         hnew=plot(smouseCOMx(f), smouseCOMy(f), 'bo', ...
%             smouseNosex(f), smouseNosey(f), 'ro', ...
%             scricketx(f), scrickety(f), 'ko');
%         set(h, 'visible', 'off');
%         h=hnew;
%         pause(.01)
%     end
% end

%calculating Relative Azimuth instead of using absolute angles
% %solve the triangle using the cosine rule
% a=COM-to-nose distance
% b=COM-to-cricket
% c=nose-to-cricket
% then azimuth=arccos((a2 + b2 - c2)/(2ab))
% a=sqrt((smouseCOMx-smouseNosex).^2 + (smouseCOMy-smouseNosey).^2);
% b=sqrt((smouseCOMx-scricketx).^2 + (smouseCOMy-scrickety).^2);
% c=sqrt((smouseNosex-scricketx).^2 + (smouseNosey-scrickety).^2);
% RelativeAzimuth=acosd((a.^2+b.^2-c.^2)./(2.*a.*b));

% 
% figure;
% plot(azimuth1)
% hold on
% plot(azimuth2)
% plot(azimuth3)
% plot(azimuth4)
% plot(RelativeAzimuth)
% xlabel('frames')
% ylabel('azimuth in degrees')
% title('comparison of azimuth computations')
% legend('azimuth (COM-to-cricket)', 'azimuth (nose-to-cricket)', 'unwrapped (COM-to-cricket)', 'unwrapped (nose-to-cricket)', 'RelativeAzimuth')
% 
% %azimuth3 is the best, so we keep that one and rename it azimuth
% % azimuth=azimuth3;
% azimuth = RelativeAzimuth;

% 
% figure(ftracks)
% subplot(313)
% hold on
% plot(RelativeAzimuth)
% xlabel('frames')
% ylabel('azimuth in degrees')
% title(' azimuth')
% cd(analysis_plots_dir)
% if exist('analysis_plots.ps')==2
%     print -dpsc2 'analysis_plots.ps' -append -bestfit
% else
%     print -dpsc2 'analysis_plots.ps' -bestfit
% end
% 
% % also print to pdf -jls
% 
% 
% line(xlim, [0 0], 'linestyle', '--')

%animate the mouse and cricket, along with angles, write to video
% if 0
%     [p, f, e]=fileparts(datapath);
%     
%     vidfname=sprintf('%s.avi', f);
%     v=VideoWriter(vidfname);
%     open(v);
%     figure(ftracks)
%     axes(ax) %     subplot(311)
%     h=plot(smouseCOMx(1), smouseCOMy(1), 'bo', smouseNosex(1), smouseNosey(1), 'ro',scricketx(1), scrickety(1), 'ko');
%     legend('mouse COM', 'mouse nose', 'cricket','mouse COM', 'mouse nose', 'cricket', 'Location', 'EastOutside')
%     subplot(312)
%     h2=plot(1,cricket_angle_nose_unwrapped(1), 'ko', 1, mouse_bearing_unwrapped(1), 'ro');
%     subplot(313)
%     h3=plot(azimuth(1), 'bo');
%     
%     wb=waitbar(0, 'building animation');
%     for f=1:length(smouseCOMx)
%         waitbar(f/length(smouseCOMx), wb);
%         axes(ax)
%         set(h(1), 'xdata', smouseCOMx(f), 'ydata', smouseCOMy(f))
%         set(h(2), 'xdata', smouseNosex(f), 'ydata', smouseNosey(f))
%         set(h(3), 'xdata', scricketx(f), 'ydata', scrickety(f))
%         
%         subplot(312) 
%         hnew2=plot(f, cricket_angle_nose_unwrapped(f), 'ko', f, mouse_bearing_unwrapped(f), 'ro');
%         set(h2, 'visible', 'off');
%         h2=hnew2;
%         
%         subplot(313) 
%         hnew3=plot(f, azimuth(f), 'bo');
%         set(h3, 'visible', 'off');
%         h3=hnew3;
%         
%         drawnow
%         frame = getframe(gcf);
%         writeVideo(v,frame);
%     end
%     close(v)
%     close(wb)
% end

% %range (distance to target)
% range=sqrt(deltax_cnose.^2 + deltay_cnose.^2);
% firstContact = find(range<10,1); %finds first frame where mouse and cricket are within 10 pixels of eachother
% %frame number is defined as the framenumber after the 'startframe' defined
% %earlier in this script


%mouse speed
speed=sqrt(diff(smouseCOMx).^2 + diff(smouseCOMx).^2);
[b,a]=butter(3, .5);
speed=filtfilt(b,a,speed);
tspeed=t(2:end);
figure
plot(tspeed, speed)
xlabel('time, s')
ylabel('speed, px/frame')
title('mouse speed vs. time')


figure
subplot(2,1,1);
title(' speed over time ')
% plot(tspeed, 10*speed, tspeed, 10*cspeed, t, range, t, RelativeAzimuth) %careful, these are in different units
hold on;
region=[1:1000];
plot(tspeed(region), 10*speed(region), 'LineWidth',2)
% plot(t,mouse_bearing_unwrapped,'c-','LineWidth',4);

legend('mouse speed')
xlabel('time, s')
ylabel('speed, px/frame')
grid on
% line(xlim, [0 0], 'color', 'k')
th=title(datapath, 'interpreter', 'none');
set(th,'fontsize', 8)



% Ear plots, added by Nick:
subplot(2,1,2);
hold on;
% plot(LeftCamtime,LcVenMed(:,1),'g-')
% plot(LeftCamtime,LcVenLat(:,1),'g-')
% plot(LeftCamtime,LcDorMed(:,1),'g-')
% plot(LeftCamtime,LcDorLat(:,1),'g-')
% plot(LeftCamtime,LcDist(:,1),'g-')
% plot(LeftCamtime,LcVenMed(:,2),'g-')
% plot(LeftCamtime,LcVenLat(:,2),'g-')
% plot(LeftCamtime,LcDorMed(:,2),'g-')
% plot(LeftCamtime,LcDorLat(:,2),'g-')
% plot(LeftCamtime,LcDist(:,2),'g-')
plot(LeftCamtime(region),LiVenMed1(region,1),'g--')
plot(LeftCamtime(region),LiVenMed2(region,1),'g--')
plot(LeftCamtime(region),LiVenLat1(region,1),'g--')
plot(LeftCamtime(region),LiVenLat2(region,1),'g--')
plot(LeftCamtime(region),LiDorMed1(region,1),'g--')
plot(LeftCamtime(region),LiDorMed2(region,1),'g--')
plot(LeftCamtime(region),LiDorLat1(region,1),'g--')
plot(LeftCamtime(region),LiDorLat2(region,1),'g--')
plot(LeftCamtime(region),LiDist(region,1),'g--')
plot(LeftCamtime(region),LiThetaAverage(region),'g-','LineWidth',4)
% plot(LeftCamtime,LiVenMed(:,2),'g-')
% plot(LeftCamtime,LiVenLat(:,2),'g-')
% plot(LeftCamtime,LiDorMed(:,2),'g-')
% plot(LeftCamtime,LiDorLat(:,2),'g-')
% plot(LeftCamtime,LiDist(:,2),'g-')
% ylim([0,(pi/2)]);
% ylabel('anterior -> posterior')
% title('LeftEarTracks')

% subplot(3,1,3);
% hold on;
% plot(RightCamtime,RcVenMed(:,1),'r-')
% plot(RightCamtime,RcVenLat(:,1),'r-')
% plot(RightCamtime,RcDorMed(:,1),'r-')
% plot(RightCamtime,RcDorLat(:,1),'r-')
% plot(RightCamtime,RcDist(:,1),'r-')
% plot(RightCamtime,RcVenMed(:,2),'r-')
% plot(RightCamtime,RcVenLat(:,2),'r-')
% plot(RightCamtime,RcDorMed(:,2),'r-')
% plot(RightCamtime,RcDorLat(:,2),'r-')
% plot(RightCamtime,RcDist(:,2),'r-')
plot(RightCamtime(region),RiDorMed1(region,1),'r--')
plot(RightCamtime(region),RiDorMed2(region,1),'r--')
plot(RightCamtime(region),RiDorLat1(region,1),'r--')
plot(RightCamtime(region),RiDorLat2(region,1),'r--')
plot(RightCamtime(region),RiDist(region,1),'r--')
plot(RightCamtime(region),RiVenLat1(region,1),'r--')
plot(RightCamtime(region),RiVenLat2(region,1),'r--')
plot(RightCamtime(region),RiVenMed1(region,1),'r--')
plot(RightCamtime(region),RiVenMed2(region,1),'r--')
plot(RightCamtime(region),RiThetaAverage(region),'r-','LineWidth',4)
midline = ones(length(RightCamtime));
midline = midline*(pi/2);
plot(RightCamtime(region),midline(region),'k-','LineWidth',4);

ylim([0,pi]);
yticks([0 pi/2 pi])
yticklabels({'0','pi/2','pi'});
ylabel('(L-ear)ANTERIOR <-- POSTERIOR --> ANTERIOR(R-ear)');


%yyaxis right
% plot(t,mouse_bearing,'-','LineWidth',3);
deltaAzimuth = nan;
for i = 2:(length(t)-1)
    newdelta = mouse_bearing_unwrapped(i+1)-mouse_bearing_unwrapped(i-1);
    deltaAzimuth = [deltaAzimuth;newdelta];
end
deltaAzimuth = [deltaAzimuth;nan];
plot(t(round(region/2)),pi/2+deg2rad(deltaAzimuth(round(region/2))),'-','LineWidth',3);
ylabel('Slope of Absolute Azimuth');
% set(gca,'YDir','reverse');
% ylabel('anterior -> posterior')
% plot(RightCamtime,RiDorMed1(:,2),'r-')
% plot(RightCamtime,RiDorMed2(:,2),'r-')
% plot(RightCamtime,RiDorLat1(:,2),'r-')
% plot(RightCamtime,RiDorLat2(:,2),'r-')
% plot(RightCamtime,RiDist(:,2),'r-')
% plot(RightCamtime,RiVenLat1(:,2),'r-')
% plot(RightCamtime,RiVenLat2(:,2),'r-')
% plot(RightCamtime,RiVenMed1(:,2),'r-')
% plot(RightCamtime,RiVenMed2(:,2),'r-')

% title('RightEarTracks')
title('EarTracks')
hold off;
    print -dpsc2 'analysis_plots.ps' -append

%end of example addition

%plot cross-correlations of ear motion and mouse steering
%      resample DeltaAzimuth (in skycam time) into earcam time
deltaAzimuthI=resample(deltaAzimuth, length(RightCamtime),length(t));
deltaAzimuthI(find(isnan(deltaAzimuthI)))=0; %remove nans because xcorr can't handle nans
deltaAzimuthIr=deg2rad(deltaAzimuthI); %convert to radians

LiThetaAverage(isnan(LiThetaAverage))=0;
RiThetaAverage(isnan(RiThetaAverage))=0;
deltaAzimuthIr(isnan(deltaAzimuthIr))=0;

[cRAz, lags]=xcov(RiThetaAverage, deltaAzimuthIr, 128);
[cLAz, lags]=xcov(LiThetaAverage, deltaAzimuthIr, 128);
[c, lags]=xcov(LiThetaAverage, RiThetaAverage, 128);
figure
plot(lags, cRAz,'r', lags, cLAz,'g', lags, c, 'k')
legend('Right ear -> deltaAzimuth', 'Left ear -> deltaAzimuth', 'Left ear -> Right ear');
xlabel('cross-covariance in frames')
grid on
title(pwd)

print -dpdf xcorr
 print -dpsc2 'analysis_plots.ps' -append


%plot cross-correlations of cricket speed and ear motion 
%  cspeedI=resample(cspeed, length(RightCamtime),length(t));
% [cLE_cspeed, lags]=xcov( cspeedI, LiThetaAverage, 128);
% [cRE_cspeed, lags]=xcov( cspeedI, RiThetaAverage, 128);
% figure
% plot(lags, cLE_cspeed,'g',lags, cRE_cspeed,'r')
% legend( 'Left ear <- cricket speed', 'Right ear <- cricket speed')
% xlabel('cross-covariance in frames')
% grid on


% 
% figure
% plot(speed, range(2:end), 'k')
% hold on
numframes=length(smouseCOMx);

% 
% cmap=colormap;
% for j=1:3; cmap2(:,j)=interp(cmap(:,j), ceil(numframes/64));end
% cmap2(find(cmap2>1))=1;
% for f=1:numframes-1
%     plot(speed(f), range(1+f), '.', 'color', cmap2(f,:))
% end
% text(speed(1), range(2), 'start')
% text(speed(end), range(end), 'end')
% xlabel('speed')
% ylabel('range')
% title('range vs. speed')
% print -dpsc2 'analysis_plots.ps' -append

% figure
% h=plot(range, RelativeAzimuth);
% set(h, 'color', [.7 .7 .7]) %grey
% hold on
% cmap=colormap;
% for j=1:3; cmap2(:,j)=interp(cmap(:,j), ceil(numframes/64));end
% cmap2(find(cmap2>1))=1;
% for f=1:numframes
%     h=plot(range(f), RelativeAzimuth(f), '.', 'color', cmap2(f,:));
%     set(h, 'markersize', 20)
% end
% text(range(1), RelativeAzimuth(2), 'start')
% text(range(end), RelativeAzimuth(end), 'end')
% xl=xlim;yl=ylim;
% xlim([0 xl(2)]);
% xlabel('range, pixels')
% ylabel('azimuth, degrees')
% title('azimuth vs. range')
% print -dpsc2 'analysis_plots.ps' -append

%cross-correlations of cricket speed, mouse speed, and range
%we are trying to capture a canonical sequence:
% 1. mouse gets close (range gets low)
% 2. cricket jumps
% 3. range increases immediately
% 4. mouse hears the cricket and approaches cricket
% 5. mouse speed increases
% 6. range decreases


% 
% figure;hold on
% maxlag=1*framerate;
% [xc1, lag]=xcorr(speed, cspeed, maxlag, 'unbiased');%unbiased
% [xc2, lag]=xcorr(range, cspeed, maxlag);%unbiased
% [xc3, lag]=xcorr(range, speed, maxlag);%unbiased
% xc1=xc1- mean(xc1);
% xc1=xc1./max(abs(xc1));
% 
% xc2=xc2- mean(xc2);
% xc2=xc2./max(abs(xc2));
% 
% xc3=xc3- mean(xc3);
% xc3=xc3./max(abs(xc3));
% 
% %xcov is really similar
% lag=1000*lag/framerate; % lag now in ms
% plot(lag, xc1)
% plot(lag, xc2)
% plot(lag, xc3)
% grid on
% title('xcorr of mouse speed and cricket speed')
% legend('cricket speed -> mouse speed','cricket speed -> range','mouse speed -> range')
% xlabel('time lag, ms')

% keyboard
%save results to groupdata file
cd(groupdatadir)
if exist(groupdatafilename)
    load(groupdatafilename)
    i=length(groupdata)+1;
else
    i=1;
end
groupdata(i).speed=speed;
% groupdata(i).cspeed=cspeed;
% Rgroupdata(i).range=range;
% groupdata(i).lag=lag; %time vector for xcorrs
% groupdata(i).xc1=xc1; %xcorr of cricket speed -> mouse speed
% groupdata(i).xc2=xc2; %xcorr of cricket speed -> range
% groupdata(i).xc3=xc3; %xcorr of mouse speed -> range
% groupdata(i).azimuth=RelativeAzimuth;
groupdata(i).t=t; %time vector for distances, in seconds
groupdata(i).tspeed=tspeed; %%time vector for speeds, in seconds (=1 sample shorter than t)
groupdata(i).framerate=framerate;
groupdata(i).smouseCOMx=smouseCOMx;
groupdata(i).smouseCOMy=smouseCOMy;
% groupdata(i).scricketx=scricketx;
% groupdata(i).scrickety=scrickety;
groupdata(i).smouseNosex=smouseNosex;
groupdata(i).smouseNosey=smouseNosey;
groupdata(i).numframes=numframes;
groupdata(i).start_frame=start_frame;
groupdata(i).stop_frame=stop_frame;
% groupdata(i).timepoints= [start_frame, firstContact, stop_frame];
groupdata(i).datapath=datapath;
groupdata(i).analysis_plots_dir=analysis_plots_dir;
save(groupdatafilename, 'groupdata')




