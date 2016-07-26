close all
clear all

addpath('C:\QCL1\Stefan\matlabcode\classes')
addpath('C:\QCL1\Stefan\matlabcode\functions')

junk = instrfindall;
delete(junk); %gets rid of any instruments in memory
clear;
close all;
pause on; %enables the pause command (should be on by default, anyways)

FMIR=keithley2440_currentsource;
FMIR.setcurrent(-0.01);
FMIR_I = FMIR.getcurrent;
FMIR_V = FMIR.getvoltage;
disp(FMIR_I);
disp(FMIR_V);
%FMIR.delete;
