classdef tektronix_3034B < handle
    
    properties
        tek;
        tkx;
        groupObj;
    end
    
    methods
        
        function obj = tektronix_3034B()
            % init Tektronix
            
            % Find a GPIB object.
            obj.tek = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', 3, 'Tag', '');
            
            % Create the GPIB object if it does not exist
            % otherwise use the object that was found.
            if isempty(obj.tek)
                obj.tek = gpib('NI', 0, 3);
            else
                fclose(obj.tek);
                obj.tek = obj.tek(1);
            end
            
            % Connect to instrument object, obj.tek.
            fopen(obj.tek);
            
            % Create a device object.
            obj.tkx = icdevice('tektronix_tds3034B.mdd', obj.tek);
            
            % Connect device object to hardware.
            % connect(obj.tkx);
            
            % Execute device object function(s).
            obj.groupObj = get(obj.tkx, 'System');
            
            obj.groupObj = obj.groupObj(1);
            invoke(obj.groupObj, 'savestate', 10);
        end
        
        
        
        function average(obj,varargin)
            set(obj.tkx.Acquisition(1), 'Mode', 'sample');
            switch nargin
                case 2
                    if sum(varargin{1}(1)==[4, 16, 64, 128])
                        set(obj.tkx.Acquisition(1), 'NumberOfAverages', varargin{1}(1));
                    else
                        set(obj.tkx.Acquisition(1), 'NumberOfAverages', 128);
                    end
                otherwise
                    set(obj.tkx.Acquisition(1), 'NumberOfAverages', 128);
            end
            set(obj.tkx.Acquisition(1), 'Mode', 'average');
        end
        
        
        
        function sample(obj)
            set(obj.tkx.Acquisition(1), 'Mode', 'sample');
        end
        
        
        
        function out = measure(obj,varargin)
            if nargin==2
                out = get(obj.tkx.Measurement(varargin{1}), 'Value');
            else
                out = get(obj.tkx.Measurement(1:4), 'Value');
            end
        end
                
        
        
        function delete(obj)
            
            % close Tektronix
            
            % Disconnect device object from hardware.
            disconnect(obj.tkx);
            
            % Disconnect from instrument object, tek.
            fclose(obj.tek);
            
            % Clean up all objects.
%             delete(obj.tek);
            
        end
    end
end