classdef ni_usb6009 < handle
    
    properties
        instr;
        scalefactor; %scalefactor is the maximum power level of the scale which the ophir is set to, and should be expressed in W, i.e. for the 3mW setting on the ophir, scalefactor=0.003.
        daq_channel; %daq_channel is which analog input channel on the DAQ is being used
        SampleRate = 1000; %can be between 0.1 and 48000 per second
        AcquisitionTime = 5; %AcquisitionTime is initialized to 5 seconds
        datastream;
        %timestream;
        %abstime;
        %eventsthrown;
        power;
        datastream_smoothed;
    end
         
    methods
        
        function obj = ni_usb6009(daq_channel,scalefactor)
            %daq_channel is an integer corresponding to which analog input
            %channel you are using, and scalefactor is the scale which the
            %ophir is set to
            disp('Initializing ophir...')
            obj.instr = daq.createSession('ni');
            obj.instr.addAnalogInputChannel('Dev1',['ai' num2str(daq_channel)],'Voltage')
            obj.instr.Channels.Range=[-1 1];
            obj.daq_channel = daq_channel;
            obj.scalefactor = scalefactor;
            obj.instr.Rate = obj.SampleRate;
            obj.instr.DurationInSeconds = obj.AcquisitionTime;
            disp(['SampleRate set to ',num2str(obj.SampleRate),' Hz ', 'with AcquisitionTime ', num2str(obj.AcquisitionTime), 's.']);
            disp('Initialization complete.')
        end
        
        function setSampleRate(obj,SampleRate)
            %Sets the SampleRate while keeping the AcquisitionTime constant
            obj.instr.Rate=SampleRate;
            obj.SampleRate=SampleRate;
            disp(['SampleRate set to ',num2str(obj.SampleRate),' Hz ', 'with AcquisitionTime ', num2str(obj.AcquisitionTime), 's.']);
        end
        
               
        function setAcquisitionTime(obj,AcquisitionTime)
            %sets AcquisitionTime while keeping SampleRate constant
            obj.instr.DurationInSeconds=AcquisitionTime;
            obj.AcquisitionTime=AcquisitionTime;
            disp(['AcquisitionTime set to ',num2str(obj.AcquisitionTime),'s with SampleRate ',num2str(obj.SampleRate),' Hz.']);
        end
        
        function stream(obj,varargin)
            %the method stream will collect the time and voltage data from
            %the DAQ card using the current SampleRate and AcquisitionTime.
            %You have the option to pass an Acquisition Time as an
            %argument. When stream is finished the obj.datastream, obj.timestream,obj.abstime, and obj.eventsthrown properties will be updated
            switch nargin
                case 2 %if the arguments are obj and another number, set this number to the AcquisitionTime
                    obj.setAcquisitionTime(varargin{1});
                otherwise %otherwise, do nothing and use the current settings
            end
            
            disp('Acquiring data from powermeter...');
            obj.datastream = obj.instr.startForeground;
            wait(obj.instr,1.1*obj.AcquisitionTime); %waits 1.1 times the expected AcquisitionTime
            %[obj.datastream,obj.timestream,obj.abstime,obj.eventsthrown] = getdata(obj.instr);
            disp('Acquisition completed.')
             
        end
        
        function power = getpower(obj)
            %getpower first calls stream and then analyzes the stream to
            %return one value for the power. REQUIRES A LOT OF
            %OPTIMIZATION to allow for different acquisition times and
            %setting the delay before starting to average. Right now the
            %delay is fixed to 3 seconds.
            obj.stream;
            obj.datastream_smoothed = moving_average(obj.datastream,100); %averages each element with the 100 elements to the left and 100 elements to the right
            power = obj.scalefactor*mean(obj.datastream(3*obj.SampleRate:end)); %Only averages over data starting 3 seconds after beginning of datastream
        end
                    
        
        function delete(obj)
            delete(obj.instr);
            clear obj.instr
        end
        
    end
end


