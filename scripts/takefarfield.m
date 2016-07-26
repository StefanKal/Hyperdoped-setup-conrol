clear all;
close all;
pause on; %enables the pause command


%CHANGE THESE PARAMETERS EVERYTIME YOU TAKE A NEW FARFIELD
fp = 'G:\Toby\experiments\LL1167a_taperedlaser\1-19-2013\';
fname = ['LL1167a_WMOPA8_DCW_BG2_TL1h_farfield_Imax_100ns_ND'];

I=13.9; %tell the program what driving current you are using
pulsewidth=100E-9; %s
reprate=20000; %Hz
sensitivity = 2E-3; %units=Volts %Romain: unit2*9.61s=mV, this is a parameter of the Princeton Applied Research Lockin
ND = 'yes';
detector = 'peltierMCT';

arm_length = 20E-2; %m from center of rotation to front of gold ring on MCT
lockin_model = 'SignalRecovery7265';
tau=0.1; % units=s, parameter of the lock-in amp
wait = tau*5; %units=suse 0.5s for tau=0.1

%angles_meas = [-20:1:-10, -9.8:0.2:9.8, 10:1:20]; %TL2
angles_meas = [-25:1:-15, -14:0.2:14, 15:1:25]; %TL1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Inititalize the Thorlabs APT Piezo Controller for the rotation stage
rot = actxcontrol('MGMOTOR.MGMotorCtrl.1');
rot.set('HWSerialNum',83813236);
rot.StartCtrl;


 
 %initialize the class keithmulti, which is the multimeter used to read the
 %signal from the lock-in amplifier
 multi = keithmulti;
 pause(5);
 

%set the min and max angle and angle step size. by coincidence I believe,
%the absolute position zero seems to correspond to the true zero, although
%this may change if you turn the device off and on again.




intensity = zeros(1,1);

fig_farfield = figure;
set(gca,'FontSize',22)
xlabel('\theta')
ylabel('Intensity (a.u.)')
hold on;


%goto initial position
rot.SetAbsMovePos(0,angles_meas(1));
rot.MoveAbsolute(0,1);

for j=1:length(angles_meas)
    rot.SetAbsMovePos(0,angles_meas(j));
    rot.MoveAbsolute(0,1);
    pause(wait);
   
    intensity(j) = str2num(multi.measvolt);
    plot(angles_meas(1:j),intensity,'b.')    
end

[intensity_max intensity_max_index] = max(intensity);
theta_max = angles_meas(intensity_max_index);
angles = angles_meas - theta_max;
intensity_range = max(intensity) - min(intensity);
normL = (intensity - min(intensity))/intensity_range;

farfield = struct('angles',angles,'normL',normL,'angles_meas',angles_meas,'intensity',intensity,'I',I,'pulsewidth',pulsewidth,'reprate',reprate,'ND',ND,'arm_length',arm_length,'lockin_model',lockin_model,'sensitivity',sensitivity,'tau',tau,'detector',detector);

save([fp,fname,'.mat'],'farfield','-mat');

rot.SetAbsMovePos(0,0);
rot.MoveAbsolute(0,1);