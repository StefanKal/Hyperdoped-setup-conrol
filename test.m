junk = instrfindall;
delete(junk); %gets rid of any instruments in memory
clear;
close all;
pause on; %enables the pause command (should be on by default, anyways)

Vsource=keithley_voltagesource;
%Vsource.setvoltage(voltageRange(1));
Vsource.setvoltage(-1);
disp(['Vset=' num2str(voltageRange(1))]);
