%This script is used to take an LIV of a laser using the Keithley 2400 or 2420 as a current source.
%Tobias Mansuripur
%Updated: October 7th, 2013

addpath('G:\Toby\matlabcode\classes')
addpath('G:\Toby\matlabcode\functions')


junk = instrfindall;
delete(junk); %gets rid of any instruments in memory
clear all;
close all;
pause on; %enables the pause command (should be on by default, anyways)



%%%%%%%%%%%%%%%%%%%USER DEFINED PARAMETERS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fp = 'G:\Toby\experiments\LL13734a\LL131734a_p2\LL131734a_p2_c10\2013-11-07\'; %where to save the data, should end in '\'
fname = 'LL131734a_p2_c10_15C_LIV'; %do not include the .mat at the end
ridge_length = 3050e-6; %%CHANGE RIDGE LENGTH WHEN CHANGING CHIPS
ridge_width = 10e-6; %give ridge width in meters or give string 'unknown'
temperature = 15; %degrees Celsius
pulser_name = 'keithley2400'; %choose from 'keithley2400',
 
%NEED TO CHOOSE THE CORRECT SIGN FOR THE CURRENT, CAN BE POSITIVE OR NEGATIVE
V_source = [0:-0.1:-9.3 -9.4:-0.025:-10.75];

scope_name = 'tektronix_3034B'; %choose from 'tektronix_3054' and 'tektronix_3034B'
    voltage_meas = 2; %the measurement number on the scope for the voltage signal
    current_meas = 1; %the measurement number on the scope for the current signal
detector_name = 'nova'; %choose from 'nova','orion','peltierMCT'
    ophir_daqchannel = 1; %if using nova or orion, specify the daqchannel on the NI board for the powermeter
    ophir_scale=30e-3; %GIVE VALUE IN WATTS this is the correctionfactor which depends on the scale the powermeter is set to
    light_meas = 3; %if using peltier MCT (together with the scope), give the measurement number on the scope for the light signal


slope_eff_criterion = 100000; %W/A; 0.05 is a good value when using the powermeter. When using an MCT, you need to figure out for yourself what a good value is
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


p=keithley_voltagesource;
%keep track of the sign of the current coming out of the keithley so we can
%make it positive later
if V_source(2)<0
    sign=-1;
else
    sign=1;
end

%keep these parameters so they are stored in the
width='cw';
period='cw';
dutycycle = 1;

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
        o = ophir(ophir_daqchannel,ophir_scale);
    case 'nova'
        o = ophir(ophir_daqchannel,ophir_scale);
    otherwise
        %do nothing, since we are using the scope to measure the peltier,
        %and scope is initialized already
end

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
    case 'orion'
        ylabel(LI_ax,'Intensity (W)');
    case 'nova'
        ylabel(LI_ax,'Intensity (W)');
    otherwise
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


for j=1:length(V_source)
    p.setvoltage(V_source(j));
    t.average; %sets average to 128 samples
    switch detector_name 
        case 'orion'
            L_ave_offset(j) = o.getpower; %takes 5 seconds. Returns a value in WATTS if you specified the ophir scalefactor in Watts, which you should
        case 'nova'
            L_ave_offset(j) = o.getpower; %takes 5 seconds. Returns a value in WATTS if you specified the ophir scalefactor in Watts, which you should
        case 'peltierMCT'
            pause(0.2); %need to pause to give scope a chance to catch up since it's now in "averaging" mode
            L_ave_offset(j) = t.measure(light_meas);
    end
    %I(j) = t.measure(current_meas)/(1-dutycycle);
    I(j) = sign*p.getcurrent;
    %V(j) = Z_ratio*t.measure(voltage_meas); 
    V(j) = sign*p.getvoltage;
    switch detector_name %slope_eff local should be calculated in peak power per amp, so you have to divide by duty cycle when using the powermeter, but not for the peltier
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
    case 'orion'
         %o.delete;
    case 'nova'
         %o.delete;
    otherwise
        %do nothing
end


%the baseline is not necessarily just the minimum power level min(L_ave).
%In cases where the laser burns at some point after threshold, I've seen
%the power dip to a lower value than before threshold (because the ambient
%temperature cooled down during that time. So we want the baseline to be
%the minimum L value between I=0 and Imax
[L_ave_offset_max L_ave_offset_max_index] = max(L_ave_offset);
baseline = min(L_ave_offset(1:L_ave_offset_max_index));
L_ave = L_ave_offset-baseline; %stores L_ave in units of Watts


L_peak = L_ave; %Watts

[L_peak_max L_peak_max_index]= max(L_peak);

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


%close all;
figure;
plot(I,L_peak,'b.-',I_fitted,L_fitted,'r')
set(gca,'FontSize',16);
xlabel('Current (A)');
switch detector_name %if powermeter is used, this plot is in Watts, otherwise the units are arbitrary
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
set(gca,'FontSize',16);
xlabel('Current (A)');
ylabel('Voltage (V)');
title_str = [strrep(fname,'_',' ') ' IV'];
title(title_str);
saveas(gcf,[fp,fname,'_VI.png'],'png');


data = struct('pulser_name',pulser_name,'scope_name',scope_name,'detector_name',detector_name,'temperature',temperature,'I',I,'V',V,'L_ave',L_ave,'L_peak',L_peak,'V_source',V_source,'I_fitted',I_fitted,'L_fitted',L_fitted,'I_thresh',I_thresh,'I_max',I_max,'slope_eff',slope_eff,'baseline',baseline,'ophir_scale',ophir_scale,'period',period,'width',width,'dutycycle',dutycycle,'ridge_width',ridge_width,'ridge_length',ridge_length,'J',J,'J_thresh',J_thresh,'isgoodlaser',isgoodlaser);


save([fp,fname,'.mat'],'data','-mat');