classdef avtech5B < handle
    
    properties
        instr;
        voltage;
        period;
        width;
        delay;
        
    end
    
    properties(Constant)
        wait = 0.1;
        formatSpec = '%10.3e';
    end
    
    methods
        
        function obj = avtech5B()
            % init Tektronix
            
            % Find a GPIB object.
            %obj.tek = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', 3, 'Tag', '');
            %obj.tek = instrfind('Type','scope','Name', 'scope-tektronix_tds2024');
            %obj.tek = instrfind('Type','visa-usb','Name',  'VISA-USB-0-0x0699-0x03A6-C013507-0');
            obj.instr = gpib('ni',0,10);
             
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
           
           %Initialize parameters
           voltage_initial=0;
           period_initial=100e-6;
           width_initial= 100e-9;
           
           % Connect device object to hardware.
           % connect(obj);
            
            % Execute device object function(s).
            pause(obj.wait)
            obj.setvoltage(voltage_initial);
            obj.setperiod(period_initial);
            obj.setwidth(width_initial);
            
            obj.write(':output on');
            pause(obj.wait)
        end
        
        function setvoltage(obj,volt)
            obj.voltage=volt;
            obj.write([':sour:volt -' num2str(abs(obj.voltage))]); %you can enter a positive or negative voltage, but this command turns it negative no matter what
            disp(['Voltage was set to ' num2str(obj.voltage) ' V.'])
            pause(obj.wait)
        end
        
        function setperiod(obj,period)
            obj.period=period;
            obj.write([':sour:puls:per ' num2str(obj.period,obj.formatSpec)])
            disp(['Pulse period was set to ' int2str(round(obj.period*10^6)) ' us.'])
            pause(obj.wait)
        end
        
        function setwidth(obj,width)
            obj.width=width;
            obj.write([':sour:puls:width ' num2str(obj.width,obj.formatSpec)])
            disp(['Pulse width was set to ' int2str(round(obj.width*10^9)) ' ns.'])
            pause(obj.wait)
        end
        
         function setdelay(obj,delay)
            obj.delay=delay;
            obj.write([':sour:puls:del ' num2str(obj.delay,obj.formatSpec)])
            disp(['Pulse delay was set to ' int2str(round(obj.delay*10^9)) ' ns.'])
            pause(obj.wait)
        end
        
        function write(obj,str)
            fprintf(obj.instr, str);
            pause(obj.wait)
        end
        
        function delete(obj)
            % Disconnect from instrument object,
            obj.write(':sour:volt 0');
            %obj.write(':output off');
            fclose(obj.instr);
            delete(obj.instr);
        end
        
    end
    end
        
        
        