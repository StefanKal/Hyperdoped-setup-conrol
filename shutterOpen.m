
addpath('Z:\Stefan\Hyperdoped Germanium Photodiodes\Matlab_Control\classes')
addpath('Z:\Stefan\Hyperdoped Germanium Photodiodes\Matlab_Control\functions')

junk = instrfindall;
delete(junk); %gets rid of any instruments in memory

%% SET NI-CARD OUTPUT PIN
NIcard = ni_usb6259_digitalOutput(1);       % configure digital output channel 1
NIcard.setOutput(0)                         % Open the shutter
disp('shutter open')
NIcard.delete;
