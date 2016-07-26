classdef agilent8114A < handle
    
    properties
        instr;
        voltage;
        period;
        width;
        delay;
    end
    
    properties(Constant)
        wait = 0.3;
        formatSpec = '%10.3e'; %this is used to convert numbers to strings in exponential form with 3 decimal places after, which is useful when setting pulse parameters
    end
    
    methods
        
        function obj = agilent8114A()
            % init Tektronix
            
            % Find a GPIB object.
            %obj.tek = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', 3, 'Tag', '');
            %obj.tek = instrfind('Type','scope','Name', 'scope-tektronix_tds2024');
            %obj.tek = instrfind('Type','visa-usb','Name',  'VISA-USB-0-0x0699-0x03A6-C013507-0');
            obj.instr = gpib('ni',0,14);
             
            % Create the GPIB object if it does not exist
            % otherwise use the object that was found.
           % if isempty(obj.tek)
            %    obj.tek = gpib('NI', 0, 3);
            %else
             %   fclose(obj.tek);
              %  obj.tek = obj.tek(1);
            %end
            
            % Connect to instrument object, obj.tek.
           fopen(obj.instr);
           pause(obj.wait)
           
           %Initialize parameters
           voltage_initial=1; %Agilent8114A pulser needs to have a voltage of 1, dont try to write 0
           period_initial=50e-6;
           width_initial= 100e-9;
           delay_initial = 0;
           
           % Connect device object to hardware.
           % connect(obj);
            
            % Execute device object function(s).
            obj.write(':outp:pol neg');
            obj.write(':hold volt'); %sets the source to voltage rather than current
            obj.write(':pulse:hold width'); %holds the pulse width constant when the period is changed, as opposed to holding duty cycle constant
%             obj.write(':outp:imp 50OHM'); %sets output impedance to 50ohm
            obj.write(':sour:pulse:del:unit s')
            obj.setvoltage(voltage_initial);
            obj.setperiod(period_initial);
            obj.setwidth(width_initial);
            obj.setdelay(delay_initial);
            obj.write(':outp on');
            
        end
        
        function setvoltage(obj,volt)
            obj.voltage=volt;
            obj.write([':volt ' num2str(abs(obj.voltage)) 'V']);
            pause(obj.wait)
        end
        
        function setperiod(obj,period)
            obj.period=period;
            obj.write([':puls:per ' num2str(obj.period,obj.formatSpec)]);
            pause(obj.wait)
        end
        
        function setwidth(obj,width)
            obj.width=width;
            obj.write([':puls:width ' num2str(obj.width,obj.formatSpec)]);
            pause(obj.wait)
        end
        
         function setdelay(obj,delay)
            obj.delay=delay;
            obj.write([':puls:del ' num2str(obj.delay,obj.formatSpec)]);
            pause(obj.wait)
        end
        
        function write(obj,str)
            fprintf(obj.instr, str);
            pause(obj.wait)
        end
        
        function delete(obj)
            % Disconnect from instrument object,
            obj.write(':volt 1V');
            %obj.write(':outp off');
            fclose(obj.instr);
            delete(obj.instr);
        end
        
    end
    end
        
        
        