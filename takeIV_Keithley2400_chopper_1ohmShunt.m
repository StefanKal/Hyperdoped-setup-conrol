close all
clear all

addpath('Z:\Stefan\Hyperdoped Germanium Photodiodes\Matlab_Control\classes')
addpath('Z:\Stefan\Hyperdoped Germanium Photodiodes\Matlab_Control\functions')

junk = instrfindall;
delete(junk); %gets rid of any instruments in memory
clear;
close all;
pause on; %enables the pause command (should be on by default, anyways)

sampleName = 'GeSb4_IV_contactedge_Laser300mA_roomlightsOff_chop986Hz_';
subfolder='GeSb4_IV';
datafolder=['Z:\Stefan\Hyperdoped Germanium Photodiodes\data\2016-03-01\GeSb4\' subfolder '\'];
mkdir(datafolder)

voltageRange = [0:-1e-2:-5];    % voltage scan range

lockinSensitivity = 20e-6;      % lockin sensitivty in [V] (used as conversion factor)
lockinTimeConstant = 300e-3;    % lockin time constant [sec]
lockinAnalogOutputRange = 10;   % 10 V output range of analog output (DONT CHANGE)
shuntResistor = 1;              % 1 Ohm shunt resistor

%% SET KEITHLEY
Vsource=keithley_voltagesource;
Vsource.setvoltage(voltageRange(1));
disp(['Vset=' num2str(voltageRange(1))]);
pause(1)                 % wait a few ms


%% SET NI-CARD OUTPUT PIN
NIcard = ni_usb6259_analogInput(0);   % configure digital output channel 1

%% take LIV
disp('Taking IV')
disp(' ')

hfig1 = figure('Position', [100, 250, 1300, 550]); %build figure panel
IV_fig = subplot(1,2,1);
IV_ax = gca;
title('IV','FontSize',14);
text(0.5,0.98,sampleName,'Interpreter','none','FontSize',8,'Units','normalized','HorizontalAlignment','center');
set(IV_ax,'FontSize',10);
xlabel(IV_ax,'Voltage (V)','FontSize',12);
ylabel(IV_ax,'Current (mA)','FontSize',12);
hold on;

IV_diff_fig = subplot(1,2,2);
IV_diff_ax = gca;
title('Photocurrent','FontSize',14);
text(0.5,0.98,sampleName,'Interpreter','none','FontSize',8,'Units','normalized','HorizontalAlignment','center');
set(IV_diff_fig,'FontSize',10);
xlabel(IV_diff_fig,'Voltage (V)','FontSize',12);
ylabel(IV_diff_fig,'Current (uA)','FontSize',12);
hold on;
%axis([-2.1 -2 -1e-6 1e-6])

for ii=1:length(voltageRange)
    startTime = tic;
    
    %% set voltage
    V_set(ii) = voltageRange(ii);
    Vsource.setvoltage(V_set(ii));             % Set Keithley voltage
    pause(lockinTimeConstant*3)                                   % wait for voltage to stabilize
    
    %% Measure 
    %#ok<*SAGROW>
    V_meas_NIcard(ii) = NIcard.getvoltage;          % The voltage from the NI card, corresponds to photocurrent
    I_meas_Keith(ii) = Vsource.getcurrent;          % The current from Keithley = average chopped laser current

    V_LockIn(ii) = V_meas_NIcard(ii) * lockinSensitivity / lockinAnalogOutputRange;  %
    lockinConversionFactor = 0.5*1.273/sqrt(2);     %1.273=1st harmonic component, sqrt(2)=RMS, 0.5=chopper
    I_photo(ii) = V_LockIn(ii)/lockinConversionFactor / shuntResistor;
    
    disp(['Vset=' num2str(V_set(ii)), ' V, I=' num2str(I_meas_Keith(ii)) ' A, I_photo =' num2str(I_photo(ii)) ' A']);

    %% plot
    plot(IV_ax,V_set,I_meas_Keith*1e3,'r')
    plot(IV_diff_ax,V_set,I_photo*1e6,'k')
    
    % remaining time prediction
    singlePointTime = toc(startTime);       % in seconds
    totalTime = singlePointTime*length(voltageRange);
    remainingTime = totalTime-ii*singlePointTime;
    disp(['Point ' num2str(ii) ' of ' num2str(length(voltageRange)), ', remaining time ' num2str(remainingTime/60,'%0.2f') ' min of ' num2str(totalTime/60,'%0.2f') ' min']);
    disp(' ');
end

%% Clean up
Vsource.setvoltage(0);
Vsource.delete;
NIcard.delete;

%% save data
filename = [sampleName '_Sens=' num2str(lockinSensitivity*1e6) 'uV_' ...
    'TC=' num2str(lockinTimeConstant*1e3) 'ms_' datestr(now,'yyyy-mm-dd_HHhMM')];

% save text file with headers
fid = fopen([datafolder,'\',filename '.txt'], 'w');
header1 = ['V_set' '\t' 'I_Keithley' '\t' 'I_photo' '\r\n'];
header2 = ['V' '\t' 'A' '\t' 'A' '\r\n'];
header3 = [' ' '\t' 'DC current' '\t' 'Photocurrent' '\r\n'];
fprintf(fid, header1);
fprintf(fid, header2);
fprintf(fid, header3);
for ii = 1:length(V_set)
    fprintf(fid, '%g\t%g\t%g\r\n', V_set(ii),I_meas_Keith(ii),I_photo(ii));
end
fclose(fid);
disp('data saved');

% save figure
set(gcf, 'PaperPositionMode','auto')   
%set(hfig1,'PaperPosition', [0 0 2 1], 'PaperUnits', 'normalized');
saveas(hfig1,[datafolder,'\',filename '.png'],'png')
disp('figure saved');