addpath('C:\QCL1\Toby\matlabcode\classes')
source.delete;
clear source;

fp='C:\QCL1\Toby\experiments\Thales\Thales_9826\2014-01-29\';%ends in '\'
source = keithley_currentsource; %NOTE: simply creating this instance will turn the Keithley off automatically
final_current = 1200e-3; %current will be ramped to final value in steps of no greater than 10mA with 2 seconds pause in between
step_current = 10e-3;
time_meas = 300; %time that you want to measure the voltage, in seconds


for j=1:ceil(final_current/step_current)
    if j==ceil(final_current/step_current)
        source.setcurrent(final_current)
    else
        source.setcurrent(j*step_current)
    end
    source.getvoltage; %allow the volatage to be displayed on the Keithley so I can watch it and make sure it looks normal
    pause(2)
end


pause(30); %allow time for temperature to stabilize

samples = ceil(time_meas/0.73); %for nplc=10, each measurement takes ~0.73 seconds. I calibrated this myself.
voltage=zeros(1,samples);
source.getvoltage; %the first getvoltage measurement takes ~1.2 seconds while the rest take ~0.74 seconds, so we call the command here
%once so all subsequent measurements take about the same duration

tic
for j=1:samples
    voltage(j)=source.getvoltage;
end
elapsed_time=toc;


time=linspace(0,elapsed_time,samples);
plot(time,voltage)
data =struct('time',time,'voltage',voltage,'final_current',final_current,'step_current',step_current','time_meas',time_meas);
fname=['VoltageVsTime_I=' num2str(final_current*1000) 'mA'];
save([fp,fname,'.mat'],'data','-mat');