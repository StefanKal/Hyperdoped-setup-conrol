

%Tobias Mansuripur
%June 18th, 2013: started the script with Mael


addpath('G:\Toby\matlabcode\classes')
addpath('G:\Toby\matlabcode\functions')


junk = instrfindall;
delete(junk); %gets rid of any instruments in memory
clear;
close all;
pause on; %enables the pause command (should be on by default, anyways)

SGR1 = agilent8114A;
spectrometer = bruker;
%FP_SGR2 = avtech4b;
%FP = avtech5b;

SGR1_voltages = [5:5:25];
SGR1_delays = 1e-9*[0:50];





fpath_LIVfolder ='G:\Mael\EOS_SG\Full_device'; %folder path where the LIV mat files from the entire array are stored
array_name = 'test1'; %this is the part of the filename that precedes '_laserXX_LIV.mat'
% xpm_name = 'laser.xpm'; %xpm file that opus will use
xpm_name ='fastscan.xpm'
xpm_path = 'G:\Mael\matlabcode_Toby\'; %path of the xpm file, no '\' at the end
unload=0; %unload=1 during massive data acquisition else crash
spec_path = 'G:\Mael\EOS_SG\Full_device';
spec_name = 'junkmael'

% fpath_LIVfolder ='G:\Toby\experiments\Hamamatsu_taperedlaser'; %folder path where the LIV mat files from the entire array are stored
% array_name = 'Hamamatsu_taperedlaser_NRLchip'; %this is the part of the filename that precedes '_laserXX_LIV.mat'
% % xpm_name = 'laser.xpm'; %xpm file that opus will use
% xpm_name ='G:\Mael\matlabcode_Toby\fastscan.xpm'
% xpm_path = 'G:\Toby\experiments\Hamamatsu_taperedlaser'; %path of the xpm file, no '\' at the end
% unload=0; %unload=1 during massive data acquisition else crash
% spec_path = 'G:\Toby\experiments\Hamamatsu_taperedlaser';
% spec_name = 'junkmael'
spectrometer.takespectrum(xpm_name,xpm_path,spec_name,spec_path,unload); % Saves the spectrum as an Opus file
        
%% Get file
newfile =[spec_path,'\junkmael.0']

spec = spectrometer.getdata(newfile);
figure(10)
hold on
plot(spec(:,1),spec(:,2),'r')


%{
%%%%%%%%%%%%%%%%%%%USER DEFINED PARAMETERS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fp = 'G:\Toby\experiments\Hamamatsu_taperedlaser\'; %where to save the data
fname = 'Hamamatsu_taperedlaser_NRLchip_laser05_LIV'; %do not include the .mat at the end
ridge_length = 3000e-6; %%CHANGE RIDGE LENGTH WHEN CHANGING CHIPS
temperature = 17; %degrees Celsius
pulser_name = 'avtech5B'; %choose from 'avtech4B','avtech5B','agilent8114A','alpes'
    %V_pulser = [0:5:100 110:10:510];
    %V_pulser = [0:5:50 60:10:300 310:5:500];
    V_pulser= [0:20:100 110:10:500];
    
    period=100e-6;%10kHz=100e-6
    width=100e-9;
scope_name = 'tektronix_3054'; %choose from 'tektronix_3054' and 'tektronix_3034B'
    voltage_meas = 1; %the measurement number on the scope for the voltage signal
    current_meas = 2; %the measurement number on the scope for the current signal
ophir_daqchannel = 1;
    ophir_scale=30e-3; %GIVE VALUE IN WATTS this is the correctionfactor which depends on the scale the powermeter is set to


slope_eff_criterion = 0.1; %W/A
%when the slope efficiency evaluated locally exceeds this criterion for three consecutive
%current values, the laser is known to be above threshold

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(strfind(fname,'devA'))
    ridge_width = 30.9e-6
elseif ~isempty(strfind(fname,'devB'))
    ridge_width = 29e-6
elseif ~isempty(strfind(fname,'devC'))
    ridge_width = 27.3e-6
else
    ridge_width = 'unknown';
end

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
o = ophir(ophir_daqchannel,ophir_scale);

VI_fig = figure;
VI_ax = gca;
set(VI_ax,'FontSize',16);
xlabel(VI_ax,'Current (A)');
ylabel(VI_ax,'Voltage (V)');
title('VI');
hold on;

LI_fig = figure;
LI_ax = gca;
set(LI_ax,'FontSize',16);
xlabel(LI_ax,'Current (A)');
ylabel(LI_ax,'Intensity (W)');
title('LI');
hold on;

%{
slope_eff_fig = figure;
slope_eff_ax = gca;
set(slope_eff_ax,'FontSize',16);
xlabel(slope_eff_ax,'Current (A)');
ylabel(slope_eff_ax,'Slope Efficiency (W/A)');
title('SlopeEfficiency');
hold on;
%}



I = zeros(1,1);
V = zeros(1,1);
L_ave_offset = zeros(1,1); %called 'offset because it is offset by a baseline reading
isgoodlaser = 0; %flag will be set to 1 when threshold is reached


for j=1:length(V_pulser)
    p.setvoltage(V_pulser(j));
    t.average; %sets average to 128 samples
    L_ave_offset(j) = o.getpower; %takes 5 seconds. Returns a value in WATTS if you specified the ophir scalefactor in Watts, which you should
    I(j) = t.measure(current_meas)/(1-dutycycle); 
    V(j) = Z_ratio*t.measure(voltage_meas); 
    slope_eff_local = (diff(L_ave_offset)./diff(I))/dutycycle; %live monitor of slope eff
    
    t.sample; %switch back to sample mode to allow the waveform to update quickly, i.e. clear the averaging buffer
    
    plot(VI_ax,I,V,'.')
    plot(LI_ax,I,L_ave_offset,'.')
    
    %{
    if length(I)>1 %required so that length(I) and length(slopeeff_local) are the same
        plot(slope_eff_ax,I(2:length(I)),slope_eff_local,'.')
    end
    %}
    
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
        if ((L_ave_offset(j)-min(L_ave_offset))<0.5*(max(L_ave_offset)-min(L_ave_offset)) || (slope_eff_local(length(slope_eff_local))<0 && slope_eff_local(length(slope_eff_local)-1)<0 && slope_eff_local(length(slope_eff_local)-2)<0 && slope_eff_local(length(slope_eff_local)-3)<0))
            disp('ROLLOVER HAS BEEN REACHED.')
            break;
        end
    end
    
end




p.delete;
t.delete;
o.delete;
clear p t o;



%the baseline is not necessarily just the minimum power level min(L_ave).
%In cases where the laser burns at some point after threshold, I've seen
%the power dip to a lower value than before threshold (because the ambient
%temperature cooled down during that time. So we want the baseline to be
%the minimum L value between I=0 and Imax
[L_ave_offset_max L_ave_offset_max_index] = max(L_ave_offset);
baseline = min(L_ave_offset(1:L_ave_offset_max_index));
L_ave = L_ave_offset-baseline; %stores L_ave in units of Watts
L_peak = L_ave/dutycycle; %peak power in Watts

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


close all;
figure;
plot(I,L_peak,'b.-',I_fitted,L_fitted,'r')
set(gca,'FontSize',16);
xlabel('Current (A)');
ylabel('Peak Power (W)');
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


data = struct('pulser_name',pulser_name,'scope_name',scope_name,'I',I,'V',V,'L_ave',L_ave,'L_peak',L_peak,'V_pulser',V_pulser,'I_fitted',I_fitted,'L_fitted',L_fitted,'I_thresh',I_thresh,'I_max',I_max,'slope_eff',slope_eff,'baseline',baseline,'ophir_scale',ophir_scale,'period',period,'width',width,'dutycycle',dutycycle,'Z_ratio',Z_ratio,'ridge_width',ridge_width,'ridge_length',ridge_length,'J',J,'J_thresh',J_thresh,'isgoodlaser',isgoodlaser,'temperature',temperature);


save([fp,fname,'.mat'],'data','-mat');
%}

