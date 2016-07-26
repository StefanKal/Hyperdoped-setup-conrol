classdef ophir_juno < handle
    
    properties
        instr
        USBSerialNumbers
        h_Ophir
        sensorSN
        sensorType
        sensorName
        dataStream
        valueStream
        value
        timestamp
        timestampStream
        status
        statusStream
    end
    
    
    methods
        
        % initialize
        function Initialize(obj)
            
            obj.instr = actxserver('OphirLMMeasurement.CoLMMeasurement');
            obj.USBSerialNumbers = obj.instr.ScanUSB;
            obj.h_Ophir = obj.instr.OpenUSBDevice(obj.USBSerialNumbers{1});
            [obj.sensorSN, obj.sensorType, obj.sensorName] = obj.instr.GetSensorInfo(obj.h_Ophir(1),0);
            obj.instr.SetMeasurementMode(obj.h_Ophir(1),0,0);   %set measurement mode power
            obj.instr.SetRange(obj.h_Ophir(1),0,4);             %set range to 3mW
            obj.instr.StartStream(obj.h_Ophir(1),0);            %start stream
            
%             disp('Ophir Juno initializing');
%             disp('5...');
%             pause(2);
%             disp('4...');
%             pause(2);
%             disp('3...');
%             pause(2);
%             disp('2...');
%             pause(2);
%             disp('1...');
%             pause(2);
            
            disp(' ');
            disp('Ophir juno initialized');
            disp(['Serial number: ' num2str(obj.sensorSN)]);
            disp(['Sensor type: ' num2str(obj.sensorType)]);
            disp(['Sensor name: ' num2str(obj.sensorName)]);
            disp(' ');
        end
        %% measure
        
        function value = getpower(obj)    %to be compatibel with orion and nova ophir
            value = MeasureAvg(obj);
        end
        
        % read last value from measurement stream
        function value = Measure(obj)
            [obj.dataStream, obj.timestampStream, obj.statusStream]= obj.instr.GetData(obj.h_Ophir(1),0);
            if isempty(obj.dataStream)
                disp('Ophir streaming buffer empty! Chill out, take it slower');
            else
                obj.value=obj.dataStream(end);
                value = obj.value;
                obj.status=obj.statusStream(end);
                obj.timestamp=obj.timestampStream(end);
            end
        end
        
        %clear the stream buffer before using the MeasureAvg function
        function ClearStreamBuffer(obj)
            obj.instr.GetData(obj.h_Ophir(1),0);
        end
        
        % read averaged value from measurement stream
        function value = MeasureAvg(obj)
            [obj.dataStream, obj.timestampStream, obj.statusStream]= obj.instr.GetData(obj.h_Ophir(1),0);
            if isempty(obj.dataStream)
                disp('Ophir streaming buffer empty! Chill out, take it slower');
                value = 0;
            else
                obj.value=mean(obj.dataStream);
                value = obj.value;
                obj.status=obj.statusStream(end);
                obj.timestamp=obj.timestampStream(end);
            end
        end
        
        function status = GetStatus(obj)
            [~, ~, status]= obj.instr.GetData(obj.h_Ophir(1),0);
            obj.status=status;
        end
        
        %% measurement mode
        % for the usual LIV we want only power (mode 0)
        function measurementModeString = GetMeasurementModeAsString(obj)
            measurementMode = obj.instr.GetMeasurementMode(obj.h_Ophir(1),0);
            switch measurementMode
                case 0
                    measurementModeString = 'Power';
                case 1
                    measurementModeString = 'Energy';
                case 2
                    measurementModeString = 'Power amd x/y tracking';
                otherwise
                    measurementModeString = 'dont know. Sorry.';
            end
        end
        
        function measurementMode = GetMeasurementMode(obj)
            measurementMode = obj.instr.GetMeasurementMode(obj.h_Ophir(1),0);
        end
        
        function SetMeasurementModePower(obj)
            obj.instr.StopStream(obj.h_Ophir(1),0);
            obj.instr.SetMeasurementMode(obj.h_Ophir(1),0,0);
            obj.instr.StartStream(obj.h_Ophir(1),0);
        end
        
        function SetMeasurementModeEnergy(obj)
            obj.instr.StopStream(obj.h_Ophir(1),0);
            obj.instr.SetMeasurementMode(obj.h_Ophir(1),0,1);
            obj.instr.StartStream(obj.h_Ophir(1),0);
        end
        
        function SetMeasurementModePowerAndTracking(obj)
            obj.instr.StopStream(obj.h_Ophir(1),0);
            obj.instr.SetMeasurementMode(obj.h_Ophir(1),0,2);
            obj.instr.StartStream(obj.h_Ophir(1),0);
        end
        
        %% measurement range
        function range = GetRange(obj)
            range = obj.instr.GetRanges(obj.h_Ophir(1),0);
        end
        
        function SetRange300uW(obj)
            obj.instr.SetRange(obj.h_Ophir(1),0,5);
        end
        
        function SetRange3mW(obj)
            disp(' ');
            obj.instr.SetRange(obj.h_Ophir(1),0,4);
        end
        
        function SetRange30mW(obj)
            obj.instr.SetRange(obj.h_Ophir(1),0,3);
        end
        
        function SetRange300mW(obj)
            obj.instr.SetRange(obj.h_Ophir(1),0,2);
        end
        
        function SetRange3W(obj)
            obj.instr.SetRange(obj.h_Ophir(1),0,1);
        end
        
        function SetRangeAuto(obj)
            obj.instr.SetRange(obj.h_Ophir(1),0);
        end
        
        %% data streaming
        function StartStream(obj)
            obj.instr.StartStream(obj.h_Ophir(1),0);
        end
        
        function StopStream(obj)
            obj.instr.StopStream(obj.h_Ophir(1),0);
        end
        
        %% close
        function delete(obj)    %to be compatibel with orion and nova ophir
            Close(obj);
        end
        
        function Close(obj)
            obj.instr.StopAllStreams;
            obj.instr.CloseAll;
            obj.instr.delete;
            clear obj.instr;
        end
        
    end
    
end