close all
clear all

addpath('Z:\Stefan\Hyperdoped Germanium Photodiodes\Matlab_Control\classes')
addpath('Z:\Stefan\Hyperdoped Germanium Photodiodes\Matlab_Control\functions')

junk = instrfindall;
delete(junk); %gets rid of any instruments in memory
clear;
close all;
pause on; %enables the pause command (should be on by default, anyways)

sampleName = 'GeTe3_IV_Laser300mA_polarityInv_roomlightsOff_chopOff_shutter10avg';
subfolder='GeTe3_IV';
datafolder=['Z:\Stefan\Hyperdoped Germanium Photodiodes\data\IVdata\' subfolder '\'];
mkdir(datafolder)

voltageRange = [0:-1e-2:-5];  %voltage scan range

%% SET KEITHLEY
Vsource=keithley_voltagesource;
Vsource.setvoltage(0);

%% SET NI-CARD OUTPUT PIN
NIcard = ni_usb6259_digitalOutput(1);   % configure digital output channel 1

%% take LIV
disp('Taking IV')
disp(' ')

figure('Position', [250, 250, 1000, 400]); %build figure panel
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
title('Delta I','FontSize',14);
text(0.5,0.98,sampleName,'Interpreter','none','FontSize',8,'Units','normalized','HorizontalAlignment','center');
set(IV_diff_fig,'FontSize',10);
xlabel(IV_diff_fig,'Voltage (V)','FontSize',12);
ylabel(IV_diff_fig,'Current (uA)','FontSize',12);
hold on;
%axis([-2.1 -2 -1e-6 1e-6])

pause(0.500)                                % wait a second before starting
for ii=1:length(voltageRange)
    startTime = tic;
    
    setVoltage = voltageRange(ii);
    
    %% Measure with closed shutter
    Vsource.setvoltage(setVoltage);             % Set Keithley voltage
    V_set(ii) = setVoltage;
    pause(0.600)                                % wait a few ms
    
    for jj = 1:10
        %% Measure with open shutter
        NIcard.setOutput(1)                         % Open the shutter
        pause(0.100)                                % wait a few ms
        Iopen(jj) = Vsource.getcurrent;

        NIcard.setOutput(0)                         % Close the shutter
        pause(0.100)                                % wait a few ms
        Iclosed(jj) = Vsource.getcurrent;    %#ok<*SAGROW>
    end
    I_meas_SOpen_single(ii) = Iopen(1);
    I_meas_SClosed_single(ii) = Iclosed(1);
    I_meas_SOpen(ii) = mean(Iopen);
    I_meas_SClosed(ii) = mean(Iclosed);
    disp(['Shutter open:   Vset=' num2str(V_set(ii)), ' V, I=' num2str(I_meas_SOpen(ii)) ' A']);

    plot(IV_ax,V_set,I_meas_SOpen*1e3,'r')
    plot(IV_ax,V_set,I_meas_SClosed*1e3,'k')
    plot(IV_diff_ax,V_set,-(I_meas_SOpen-I_meas_SClosed)*1e6,'k')
    plot(IV_diff_ax,V_set,-(I_meas_SOpen_single-I_meas_SClosed_single)*1e6,'g')
        
    % remaining time prediction
    singlePointTime = toc(startTime);       % in seconds
    totalTime = singlePointTime*length(voltageRange);
    remainingTime = totalTime-ii*singlePointTime;
    disp(['Point ' num2str(ii) ' of ' num2str(length(voltageRange)), ', remaining time ' num2str(remainingTime/60,'%0.2f') ' min of ' num2str(totalTime/60,'%0.2f') ' min']);
    disp(' ');
end

NIcard.setOutput(0)                         % Close the shutter
%% Clean up
Vsource.setvoltage(0);
Vsource.delete;
NIcard.delete;

%% save data
filename = [sampleName '_' datestr(now,'yyyy-mm-dd_HHhMM')];

% save text file with headers
fid = fopen([datafolder,'\',filename '.txt'], 'w');
header1 = ['V_set' '\t' 'I_meas_SOpen' '\t' 'I_meas_SClosed' '\t' 'delta_I' '\r\n'];
header2 = ['V' '\t' 'A' '\t' 'A' '\t' 'A' '\r\n'];
header3 = [' ' '\t' 'Shutter open' '\t' 'Shutter closed' '\t' 'Delta I' '\r\n'];
fprintf(fid, header1);
fprintf(fid, header2);
fprintf(fid, header3);
for ii = 1:length(V_set)
    fprintf(fid, '%g\t%g\t%g\t%g\r\n', V_set(ii),I_meas_SOpen(ii),I_meas_SClosed(ii),I_meas_SOpen(ii)-I_meas_SClosed(ii));
end
fclose(fid);
disp('data saved');

% save figure
set(gcf, 'PaperPositionMode','auto')   
saveas(IV_fig,[datafolder,'\',filename '.png'],'png')
disp('figure saved');

