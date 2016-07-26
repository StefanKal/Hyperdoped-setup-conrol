classdef ni_usb6259_digitalOutput < handle
    
    properties
        instr;
        daq_channel; %daq_channel is which digital output channel on the DAQ is being used
        eventsthrown;
        power;
        value
    end
    
    methods
        
        function obj = ni_usb6259_digitalOutput(daq_channel)
            %ai_channel is an integer corresponding to which analog input
            %channel you are using, and scalefactor is the scale which the
            %ophir is set to
            disp('Initializing ni_usb6259 as output...')
            obj.instr = digitalio('nidaq','Dev1');
            addline(obj.instr,0,'out');
            disp('Initialization complete.')
        end
     
        function setOutput(obj,value)
            %set the output value
            switch value
                case 1
                    putvalue(obj.instr,1);
                case 0
                    putvalue(obj.instr,0);
                otherwise
                    disp('Illeagal output value')
            end
        end
        
        function delete(obj)
            delete(obj.instr);
            clear obj.instr
        end
        
    end
end


