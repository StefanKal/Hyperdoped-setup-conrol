%This script is used to take an LIV of a laser using the Alpes Box,
%Tektronix scope, and Ophir powermeter. Put the current meter to channel 1
%on the scope and measurement 1, channels 2 and 3 are the single ended
%outputs of the differential voltage across the QCL, and channel 4 (and measurement 4) is the
%MATH channel which calculates the difference between channels 

%Tobias Mansuripur, Stefan Kalchmair
%Updated: October 4th, 2013
%October 4th, 2013: added the capability to use 'peltierMCT' as the
%detector, and detector_name is now a field which is either 'juno', 'orion', 'nova', or 'peltierMCT'
%June 17th, 2013: added 'isgoodlaser' and 'temperature' fields

addpath('C:\QCL1\Stefan\matlabcode\classes')
addpath('C:\QCL1\Stefan\matlabcode\functions')

junk = instrfindall;
delete(junk); %gets rid of any instruments in memory
clear all;
close all;
pause on; %enables the pause command (should be on by default, anyways)

%%%%%%%%%%%%%%%%%%%USER DEFINED PARAMETERS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fp = 'C:\QCL1\Stefan\Samples\'; %where to save the data, should end in '\'
fname = 'Test0_LIV'; %do not include the .mat at the end
ridge_length = 3000e-6; %%CHANGE RIDGE LENGTH WHEN CHANGING CHIPS
ridge_width = 15e-6; %give ridge width in meters or give string 'unknown'
temperature = 20; %degrees Celsius
pulser_name = 'avtech4B'; %choose from 'avtech4B','avtech5B','agilent8114A','alpes'
    %V_pulser= [1:0.5:19 20:0.5:45];
    %V_pulser= [1:0.2:4 4.5:0.5:15 15.2:0.2:17 17.5:0.5:26.5 27:0.2:28.8];
    V_pulser= 0:10:110;
    
    period=100e-6;  %10kHz --> 100e-6 us 
    width=100e-9;
    
scope_name = 'tektronix_3034B'; %choose from 'tektronix_3054' and 'tektronix_3034B'
    voltage_meas = 2; %the measurement number on the scope for the voltage signal
    current_meas = 1; %the measurement number on the scope for the current signal

detector_name = 'juno'; %choose from 'juno', 'nova','orion','peltierMCT'
    ophir_daqchannel = 0; %if using nova or orion, specify the daqchannel on the NI board for the powermeter
    ophir_scale=3e-3; %GIVE VALUE IN WATTS this is the correctionfactor which depends on the scale the powermeter is set to
    light_meas = 3; %if using peltier MCT (together with the scope), give the measurement number on the scope for the light signal


slope_eff_criterion = 0.05; %W/A; 0.05 is a good value when using the powermeter. When using an MCT, you need to figure out for yourself what a good value is
%when the slope efficiency evaluated locally exceeds this criterion for three consecutive
%current values, the laser is known to be above threshold

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist([fp fname '.mat'],'file')==2
    flag=input('File already exists. Do you want to overwrite? (0=no, 1=yes):');
    switch flag
        case 0
            error('Choose new filename. Program terminated.')
        case 1
            %do nothing, let the program go on
        otherwise
            error('Not a valid response. Program terminated.')
    end
    clear flag;
end


switch pulser_name
    case 'avtech4B'
        p=avtech4B;
        Z_ratio=1;
    case 'avtech5B'
        p=avtech5B;
        Z_ratio=1;
    case 'agilent8114A'
        p=agilent8114A;
        Z_ratio=1;
    case 'alpes'
        error('Still need to program the Alpes class into this LIV program. Program terminated.');
    otherwise
        error('Not a valid pulser. Program terminated.');
end

%the measured voltage is multipled by Z_ratio to account for the voltage divider between
%the voltage measuring box and the 50ohm scope input when
%using the alpes box due to the differential line. This
%Zratio=505 when using the alpes box and measuring the
%differential voltage using Meinrad's voltage divider pomona box



%Initialize the pulse properties
    p.setperiod(period); 
    p.setwidth(width);
    dutycycle = p.width/p.period;

%Initialize the oscilloscope
switch scope_name
    case 'tektronix_3054'
        t = tektronix_3054;
    case 'tektronix_3034B'
        t = tektronix_3034B;
    otherwise
        error('Not a valid oscilloscope. Program terminated.');
end
t.sample; %sets averaging to single sample mode

%initialize the powermeter
switch detector_name
    case 'orion'
        o = ni_usb6009(ophir_daqchannel,ophir_scale);
    case 'nova'
        o = ni_usb6009(ophir_daqchannel,ophir_scale);
    case 'juno'
        o = ophir_juno;
        o.Initialize;
    otherwise
        %do nothing, since we are using the scope to measure the peltier,
        %and scope is initialized already
end

%% wait for powermeter to stabilize
clear x i power power;
disp('here we start');

h_powerStab = figure('name','power meter stabilization'); i=0;
while ishghandle(h_powerStab);
i=i+1; x(i)=i;
power(i) = o.getpower;
plot(x,power,'b');
%yMax = max(power)+0.1*abs(max(power))+1e-9;
yMax = 10e-6;    % yMax = 10 uW
yMin= min(power); yRange = yMax - yMin;
axis([max(x)-100 max(x) yMin yMax]);
text(x(i)-70,yRange*0.7+yMin,'Wait until power is stabilized.');
text(x(i)-70,yRange*0.65+yMin,'Close figure to start measurement.');
pause(0.2);
end

disp('and here we go');


%%
figure;
VI_fig = subplot(2,2,1);
VI_ax = gca;
set(VI_ax,'FontSize',16);
xlabel(VI_ax,'Current (A)');
ylabel(VI_ax,'Voltage (V)');
title('VI');
hold on;

LI_fig = subplot(2,2,2);
LI_ax = gca;
set(LI_ax,'FontSize',16);
xlabel(LI_ax,'Current (A)');
switch detector_name %if powermeter is used, this plot is in Watts, otherwise the units are arbitrary
    case 'juno'
        ylabel(LI_ax,'Intensity (W)');
    case 'orion'
        ylabel(LI_ax,'Intensity (W)');
    case 'nova'
        ylabel(LI_ax,'Intensity (W)');
    case 'peltierMCT'
        ylabel(LI_ax,'Intensity (a.u.)');
end
title('LI');
hold on;


slope_eff_fig = subplot(2,2,3);
slope_eff_ax = gca;
set(slope_eff_ax,'FontSize',16);
xlabel(slope_eff_ax,'Current (A)');
ylabel(slope_eff_ax,'Slope Efficiency (W/A)');
title('SlopeEfficiency');
hold on;

I = zeros(1,1);
V = zeros(1,1);
L_ave_offset = zeros(1,1); %called 'offset because it is offset by a baseline reading
isgoodlaser = 0; %flag will be set to 1 when threshold is reached

for j=1:length(V_pulser)
    p.setvoltage(V_pulser(j));
    t.average(16); %sets average to 4 samples
    switch detector_name 
        case 'juno'
            L_ave_offset(j) = o.getpower; %takes 5 seconds. Returns a value in WATTS if you specified the ophir scalefactor in Watts, which you should
            pause(5);
        case 'orion'
            L_ave_offset(j) = o.getpower; %takes 5 seconds. Returns a value in WATTS if you specified the ophir scalefactor in Watts, which you should
        case 'nova'
            L_ave_offset(j) = o.getpower; %takes 5 seconds. Returns a value in WATTS if you specified the ophir scalefactor in Watts, which you should
        otherwise
            pause(0.1); %need to pause to give scope a chance to catch up since it's now in "averaging" mode
            L_ave_offset(j) = t.measure(light_meas);
    end
    I(j) = t.measure(current_meas)/(1-dutycycle); 
    V(j) = Z_ratio*t.measure(voltage_meas); 
    
    switch detector_name %slope_eff local should be calculated in peak power per amp, so you have to divide by duty cycle when using the powermeter, but not for the peltier
        case 'juno'
            slope_eff_local = (diff(L_ave_offset)./diff(I))/dutycycle; %live monitor of slope eff
        case 'orion'
            slope_eff_local = (diff(L_ave_offset)./diff(I))/dutycycle; %live monitor of slope eff
        case 'nova'
            slope_eff_local = (diff(L_ave_offset)./diff(I))/dutycycle; %live monitor of slope eff
        otherwise
            slope_eff_local = (diff(L_ave_offset)./diff(I)); %live monitor of slope eff
    end
    
    t.sample; %switch back to sample mode to allow the waveform to update quickly, i.e. clear the averaging buffer
    
    plot(VI_ax,I,V,'.')
    plot(LI_ax,I,L_ave_offset,'.')
    
    
    if length(I)>1 %required so that length(I) and length(slopeeff_local) are the same
        plot(slope_eff_ax,I(2:length(I)),slope_eff_local,'.')
    end
    
    
    if isgoodlaser==0 %If we are below threshold, check to see when we reach threshold
        if length(slope_eff_local)>=3
            if slope_eff_local(length(slope_eff_local))>slope_eff_criterion && slope_eff_local(length(slope_eff_local)-1)>slope_eff_criterion && slope_eff_local(length(slope_eff_local-2))>slope_eff_criterion
            isgoodlaser = 1;
            disp('LASER THRESHOLD HAS BEEN REACHED.')
            end
        end
    end
    
    %rollover detector looks for four consecutive dips in the output power,
    %provided the estimate for V_thresh_est has been exceeded, or when half
    %the max output power is reached
    if isgoodlaser==1; %if we are above threshold, check to see when we reach rollover
        if ((L_ave_offset(j)-min(L_ave_offset))<0.5*(max(L_ave_offset)-min(L_ave_offset)) || (slope_eff_local(length(slope_eff_local))<0 && slope_eff_local(length(slope_eff_local)-1)<0 && slope_eff_local(length(slope_eff_local)-2)<0))
            disp('ROLLOVER HAS BEEN REACHED.')
            break;
        end
    end
    
end




p.delete;
t.delete;
clear p t;
switch detector_name 
    case 'juno'
         o.delete;
    case 'orion'
         o.delete;
    case 'nova'
         o.delete;
    otherwise
        %do nothing
end


%the baseline is not necessarily just the minimum power level min(L_ave).
%In cases where the laser burns at some point after threshold, I've seen
%the power dip to a lower value than before threshold (because the ambient
%temperature cooled down during that time. So we want the baseline to be
%the minimum L value between I=0 and Imax
[L_ave_offset_max, L_ave_offset_max_index] = max(L_ave_offset);
baseline = min(L_ave_offset(1:L_ave_offset_max_index));
L_ave = L_ave_offset-baseline; %stores L_ave in units of Watts

switch detector_name 
    case 'juno'
         L_peak = L_ave/dutycycle; %peak power in Watts
    case 'orion'
         L_peak = L_ave/dutycycle; %peak power in Watts
    case 'nova'
         L_peak = L_ave/dutycycle; %peak power in Watts
    case 'peltierMCT'
         L_peak = L_ave; %peak power in arbitrary units;
end

[L_peak_max, L_peak_max_index]= max(L_peak);

I_max = I(L_peak_max_index);

%define the region over which to do the regression fit, lets say between
%10% and 60% of L_max

region = L_peak<0.6*L_peak_max & L_peak>0.1*L_peak_max;
I_fitted = I(region(1:L_peak_max_index)); %restricting the region to 1:L_peak_max_index makes sure not to include any points after the roll-over, or if the laser burns
L_fitted = L_peak(region(1:L_peak_max_index));

%linear regression fit to find threshold
[coeff,S] = polyfit(I_fitted,L_fitted,1);
I_thresh = -coeff(2)/coeff(1); %units=A
slope_eff = coeff(1); %units = W/A
L_fitted = I_fitted*coeff(1) + coeff(2);

if ~ischar(ridge_width) %if ridge_width is 'unknown', then dont calculate J and J_thresh
    J = 10^(-7)*I/(ridge_width*ridge_length);
    J_thresh = 10^(-7)*I_thresh/(ridge_width*ridge_length);
else
    J='unknown';
    J_thresh='unknown';
end

%% figures

%close all;
figure;
plot(I,L_peak,'b.-',I_fitted,L_fitted,'r')
axis([0 1.1*max(I) 0 1.1*max(L_peak)]);
set(gca,'FontSize',12);
xlabel('Current (A)');
switch detector_name %if powermeter is used, this plot is in Watts, otherwise the units are arbitrary
    case 'juno'
        ylabel('Peak Power (W)');
    case 'orion'
        ylabel('Peak Power (W)');
    case 'nova'
        ylabel('Peak Power (W)');
    case 'peltierMCT'
        ylabel('Intensity (MCT Voltage)');
end
title_str = [strrep(fname,'_',' ') ' LI'];
title(title_str);
saveas(gcf,[fp,fname,'_LI.png'],'png');

figure;
plot(I,V,'b.-')
axis([0 1.1*max(I) 0 1.1*max(V)]);
set(gca,'FontSize',12);
xlabel('Current (A)');
ylabel('Voltage (V)');
title_str = [strrep(fname,'_',' ') ' IV'];
title(title_str);
saveas(gcf,[fp,fname,'_VI.png'],'png');

data = struct('pulser_name',pulser_name,'scope_name',scope_name,'detector_name',detector_name,'temperature',temperature,'I',I,'V',V,'L_ave',L_ave,'L_peak',L_peak,'V_pulser',V_pulser,'I_fitted',I_fitted,'L_fitted',L_fitted,'I_thresh',I_thresh,'I_max',I_max,'slope_eff',slope_eff,'baseline',baseline,'ophir_scale',ophir_scale,'period',period,'width',width,'dutycycle',dutycycle,'Z_ratio',Z_ratio,'ridge_width',ridge_width,'ridge_length',ridge_length,'J',J,'J_thresh',J_thresh,'isgoodlaser',isgoodlaser);

%disp(temperature);
%disp(I_thresh);
%disp(slope_eff);
save([fp,fname,'.mat'],'data','-mat');

%% Export data to *.txt files ready for Origin

%[status,message,messageid] = mkdir('dptx');

% export origin friendly data file
clear dataArray;
dataArray(1,:) = I;
dataArray(2,:) = V(1:length(I));
dataArray(3,:) = L_ave(1:length(I));
dataArray(4,:) = L_peak(1:length(I));
dataArray(5,:) = V_pulser(1:length(I));

fullpath = [fp,fname,'.txt'];
txt=sprintf('%s\t%s\t%s\t%s\t%s','Current','Voltage','Average Power','Peak power','Pulser voltage');
dlmwrite(fullpath,txt,'delimiter','');
txt=sprintf('%s\t%s\t%s\t%s\t%s','A','V','W','W','V');
dlmwrite(fullpath,txt,'-append','delimiter','');
txt=sprintf('%s\t%s\t%s\t%s\t%s',fname(1:14),fname(1:14),fname(1:14),fname(1:14),fname(1:14));
dlmwrite(fullpath,txt,'-append','delimiter','');
txt=sprintf('%i\t%i\t%i\t%i\t%i\n',dataArray);
dlmwrite(fullpath,txt,'-append','delimiter','');

%export settings info file
fullpath_settings = [fp,fname,'_setting.txt'];
% save simvalues as text file
expr = 'disp(data)';
simvaluesText = evalc(expr);
fid = fopen(fullpath_settings,'w');
if fid ~= -1
    fprintf(fid,'%s',simvaluesText);
    fclose(fid);
end

