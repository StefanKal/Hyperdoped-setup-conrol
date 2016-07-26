classdef keithley < handle
    
    properties
        keith
        nplc;
        rang;
        aver;
    end
    
    properties(Constant)
        wait = 0.1;
   
    end
    
    methods
        
        function obj = keithley()
            
            obj.nplc = 10; obj.rang = 10; obj.aver = 60;
            
            %nplc is the number of power line cycles (i.e. 60 cycles = 1 second over which the
            %keithley measures, then aver is the number of these samples
            %that the ketihley averages over before putting out a number
            % init Keithley
            
            obj.keith = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', 30, 'Tag', ''); %the keith multimeter address is 16, the sourcemeter is 30
            
            % Create the GPIB object if it does not exist
            % otherwise use the object that was found.
            if isempty(obj.keith)
                obj.keith = gpib('NI', 0, 30); %CHANGE THIS ADDRESS TOO IF YOU CHANGE THE ONE A FEW LINES ABOVE
            else
                fclose(obj.keith);
                obj.keith = obj.keith(1);
            end
            
            % Connect to instrument object, pulse.keith.
            fopen(obj.keith);
            pause(obj.wait)
            %fprintf(obj.keith,':CONF:CURR:DC');
            fprintf(obj.keith,'*RST'); %reset to standard values
            fprintf(obj.keith,':SOUR:FUNC CURR');%sets the mode to source current
            pause(obj.wait);
            fprintf(obj.keith,':SOUR:CURR:RANG 1'); %sets range to 1A, which allows you to source up to 1.05A. This is the maximum the 2400 can do (22W power max).
            pause(obj.wait);
            fprintf(obj.keith,':SENS:VOLT:RANGE 20');%sets compliance voltage range to 20V
            pause(obj.wait);
            fprintf(obj.keith,':SENS:VOLT:PROT 15');%sets compliance voltage to 15V
            obj.write([':sens:volt:dc:nplc ',num2str(obj.nplc)]);
            %obj.write([':sens:volt:dc:rang:upper ',num2str(obj.rang)]);
            %obj.write([':sens:volt:dc:aver:count ',num2str(obj.aver)]);
            
            pause(obj.wait)
        end
            
        function setcurrent(current)
            obj.write([':SOUR:CURR ' num2str(current)]);
            pause(obj.wait)
        end
           
        function [voltage] = getvoltage(obj)
            obj.write(':FORM:ELEM VOLT'); %sets the output string to contain the voltage
            pause(obj.wait)
            obj.write(':MEAS:VOLT?');
            pause(obj.wait)
            voltage = fscanf(obj.keith);
        end
        
          function [current] = getcurrent(obj)
            obj.write(':FORM:ELEM CURR'); %sets the output string to contain the current
            pause(obj.wait)
            obj.write(':MEAS:CURR?');
            pause(obj.wait)
            current = fscanf(obj.keith);
        end
        
         function write(obj,str)
            fprintf(obj.keith, str);
            pause(obj.wait)
        end 
        
        function delete(obj)
            % Disconnect from instrument object, keith.
            fclose(obj.keith);
            delete(obj.keith)
            
            
        end
    end
end
