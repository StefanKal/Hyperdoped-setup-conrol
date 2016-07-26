classdef keithley_voltagesource < handle
    %this class sets up a keithley 2400 or 2420 as a current source
    properties
        keith
        nplc;
    end
    
    properties(Constant)
        wait = 0.1;
   
    end
    
    methods
        
        function obj = keithley_voltagesource()
            
            obj.nplc = 1;
            %nplc is the number of power line cycles (i.e. 60 cycles = 1 second over which the
            %keithley measures, then aver is the number of these samples
            %that the ketihley averages over before putting out a number
            % init Keithley
            KEITHLEY_GPIB_ADDRESS = 23;
            
            obj.keith = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', KEITHLEY_GPIB_ADDRESS, 'Tag', '');
            
            % Create the GPIB object if it does not exist
            % otherwise use the object that was found.
            if isempty(obj.keith)
                obj.keith = gpib('NI', 0, KEITHLEY_GPIB_ADDRESS); %CHANGE THIS ADDRESS TOO IF YOU CHANGE THE ONE A FEW LINES ABOVE
            else
                fclose(obj.keith);
                obj.keith = obj.keith(1);
            end
            
            % Connect to instrument object, pulse.keith.
            fopen(obj.keith);
            pause(obj.wait)
            fprintf(obj.keith,'*RST'); %reset to standard values
            pause(obj.wait);
            fprintf(obj.keith,':SOUR:FUNC VOLT');%sets the mode to source current
            pause(obj.wait);
            fprintf(obj.keith,':SENS:CURR:PROT 0.1');%sets compliance voltage to 15V
            pause(obj.wait);
            fprintf(obj.keith,':SOUR:CURR:RANG 0.1'); %sets range
            %fprintf(obj.keith,':SOUR:CURR:RANG:AUTO 1'); %sets range
            pause(obj.wait);
            obj.write([':SENS:VOLT:DC:NPLC ',num2str(obj.nplc)]);
            obj.setvoltage(0);
            obj.write(':OUTP ON')
            pause(obj.wait);
        end
            
        function setcurrent(obj,current)
            obj.write([':SOUR:CURR ' num2str(current)]);
            pause(obj.wait);
        end
        
        function setvoltage(obj,voltage)
            obj.write([':SOUR:VOLT ' num2str(voltage)]);
            obj.write(':OUTP ON')
            obj.write(':INIT');
        end
           
        function [voltage] = getvoltage(obj)
            obj.write(':FORM:ELEM VOLT'); %sets the output string to contain the voltage
            obj.write(':MEAS:VOLT?');
            voltage = str2double(fscanf(obj.keith));
        end
        
          function [current] = getcurrent(obj)
            obj.write(':FORM:ELEM CURR'); %sets the output string to contain the current
            obj.write(':MEAS:CURR?');
            current = str2double(fscanf(obj.keith));
        end
        
         function write(obj,str)
            fprintf(obj.keith, str);
            pause(5e-3) %wait 5 ms after each command, just to be sure
        end 
        
        function delete(obj)
            % Disconnect from instrument object, keith.
            obj.setvoltage(0);
            obj.write(':OUTP OFF')
            fclose(obj.keith);
            delete(obj.keith)
        end
    end
end
