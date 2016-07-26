
close all;
clear;


%% Detector
d=ophir_juno;
d.Initialize;
%pause(3);


%% measure

d.GetRange
d.SetRange3mW
d.GetRange



% 
% figure(1)
% hold on;
% 
% for i=1:1000
%  pause(0.5);
%  value(i) = d.getpower;
%  x(i) = i;
%  plot(x,value); 
%  axis([0 max(x) 0 1e-4]);
% end

%%

%d.Close;

%%
% events(d.instr)
% 
% addlistener(d.,'DataReady',@dataReadyHandler)
% 
% 
%      %            gethandle
%             % Define the listener callback function
%             
%             %            htest=@obj.instr
%             %            events(obj)
%             
%             %            obj.h_Ophir(1)
%             %            addlistener(obj.h_Ophir(1),'ObjectBeingDestroyed',@dataReadyHandler)
%             %            obj.instr.events
%             %            obj.instr.GetMeasurementMode