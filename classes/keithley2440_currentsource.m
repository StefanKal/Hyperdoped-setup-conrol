classdef keithley2440_currentsource < handle
    %this class sets up a keithley 2440 as a current source
    properties
        keith
        nplc;
    end
    
    properties(Constant)
        wait = 0.1;
        
    end
    
    methods
        
        function obj = keithley2440_currentsource()
            
            obj.nplc = 10;
            %nplc is the number of power line cycles (i.e. 60 cycles = 1 second over which the
            %keithley measures, then aver is the number of these samples
            %that the ketihley averages over before putting out a number
            % init Keithley
            
            obj.keith = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', 25, 'Tag', ''); %the keith multimeter address is 16, the sourcemeter is 30
            
            % Create the GPIB object if it does not exist
            % otherwise use the object that was found.
            if isempty(obj.keith)
                obj.keith = gpib('NI', 0, 25); %CHANGE THIS ADDRESS TOO IF YOU CHANGE THE ONE A FEW LINES ABOVE
            else
                fclose(obj.keith);
                obj.keith = obj.keith(1);
            end
            
            % Connect to instrument object, pulse.keith.
            fopen(obj.keith);
            pause(obj.wait)
            fprintf(obj.keith,'*RST'); %reset to standard values
            pause(obj.wait);
            fprintf(obj.keith,':SOUR:FUNC CURR');%sets the mode to source current
            pause(obj.wait);
            fprintf(obj.keith,':SOUR:CURR:MODE FIXED'); %fixed current source
            pause(obj.wait);
            fprintf(obj.keith,':SOUR:CURR:RANG 1'); %1A compliance
            pause(obj.wait);
            fprintf(obj.keith,':SENS:FUNC "CURR"'); %measure current
            pause(obj.wait);
            fprintf(obj.keith,':FORM:ELEM CURR'); %show current
            pause(obj.wait);
            fprintf(obj.keith,':SENS:VOLT:PROT MAX');%sets compliance voltage to 42V
            pause(obj.wait);
            fprintf(obj.keith,':SENS:VOLT:RANG MAX'); %sets max range
            pause(obj.wait);
            obj.write([':sens:volt:dc:nplc ',num2str(obj.nplc)]);
            pause(obj.wait);
            obj.setcurrent(0);
            pause(obj.wait);
            obj.write(':OUTP ON')
            pause(obj.wait);
        end
        
        function setcurrent(obj,current)
            obj.write([':SOUR:CURR:LEV ' num2str(current)]);
            pause(obj.wait)
        end
        
        function [voltage] = getvoltage(obj)
            obj.write(':FORM:ELEM VOLT'); %sets the output string to contain the voltage
            pause(obj.wait)
            obj.write(':MEAS:VOLT?');
            pause(obj.wait)
            voltage = str2double(fscanf(obj.keith));
        end
        
        function [current] = getcurrent(obj)
            obj.write(':FORM:ELEM CURR'); %sets the output string to contain the current
            pause(obj.wait)
            obj.write(':MEAS:CURR?');
            pause(obj.wait)
            current = str2double(fscanf(obj.keith));
        end
        
        function write(obj,str)
            fprintf(obj.keith, str);
            pause(obj.wait)
        end
        
        function output_on(obj)
            % switch output on
            obj.write(':OUTP ON')
            pause(obj.wait)
        end
        
        function output_off(obj)
            % switch output on
            obj.write(':OUTP OFF')
            pause(obj.wait)
        end
        
        function delete(obj)
            % Disconnect from instrument object, keith.
            obj.setcurrent(0);
            obj.write(':OUTP OFF')
            fclose(obj.keith);
            delete(obj.keith)
        end
    end
end
