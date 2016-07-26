classdef pulse < handle
    
    properties
        keith
        agi
        per
        pw
        compl
        volt
    end
    
    properties(Constant)
        wait = 0.1;
    end
    
    methods
        
        function obj = pulse()
            
            % init Keithley
            
            obj.keith = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', 24, 'Tag', '');
            
            % Create the GPIB object if it does not exist
            % otherwise use the object that was found.
            if isempty(obj.keith)
                obj.keith = gpib('NI', 0, 24);
            else
                fclose(obj.keith);
                obj.keith = obj.keith(1);
            end
            
            % Connect to instrument object, pulse.keith.
            fopen(obj.keith);
            pause(obj.wait)
            
            fprintf(obj.keith, ':OUTPUT OFF');
            pause(obj.wait)
            fprintf(obj.keith, ':SENS:CURR:PROT 1.00')
            pause(obj.wait)
            fprintf(obj.keith, ':SENS:CURR:RANG:UPP 1.00');
            pause(obj.wait)
            fprintf(obj.keith, ':SOUR:VOLT:RANG 63');
            pause(obj.wait)
            
            obj.setvolt(0);
            
            fprintf(obj.keith, ':OUTPUT ON');
            pause(obj.wait)
            
            
            
            % init Agilent
            
            % Find a GPIB object.
            obj.agi = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', 10, 'Tag', '');
            
            % Create the GPIB object if it does not exist
            % otherwise use the object that was found.
            if isempty(obj.agi)
                obj.agi = gpib('NI', 0, 10);
            else
                fclose(obj.agi);
                obj.agi = obj.agi(1);
            end
            
            % Connect to instrument object, obj.agi.
            fopen(obj.agi);
            pause(obj.wait)
            
            fprintf(obj.agi, ':OUTP OFF');
            pause(obj.wait)
            fprintf(obj.agi, ':FUNC PULS');
            pause(obj.wait)
            
            obj.setper(10e-6);
            obj.setpw(50e-9);
            
            fprintf(obj.agi, ':VOLT:HIGH 5');
            pause(obj.wait)
            fprintf(obj.agi, ':VOLT:LOW 0');
            pause(obj.wait)
            fprintf(obj.agi, ':OUTP ON');
            pause(obj.wait)
            
        end
        
        
        
        function setvolt(obj, volt)
            fprintf(obj.keith, [':SOUR:VOLT:LEV:IMM ', num2str(volt)]);
            obj.volt = volt;
            pause(obj.wait)
        end
            
        
        
        function setper(obj, per)
            fprintf(obj.agi, [':PULS:PER ',num2str(per)]);
            pause(obj.wait)
            obj.per = per;
        end
        
        
        
        function setpw(obj, pw)
            fprintf(obj.agi, [':PULS:WIDT ',num2str(pw)]);
            pause(obj.wait)
            obj.pw = pw;
        end
        
        
        
        function on(obj)
            fprintf(obj.keith, ':OUTP ON')
            pause(obj.wait)
        end
        
        
        
        function off(obj)
            fprintf(obj.keith, ':OUTP OFF')
            pause(obj.wait)
        end
        
        
        function delete(obj)
            
            obj.off
            
            % Disconnect from instrument object, keith.
            fclose(obj.keith);
            
            % Disconnect from instrument object, obj.agi.
            fclose(obj.agi);
            
            delete(obj.keith)
            delete(obj.agi)
            
        end
    end
end