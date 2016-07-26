classdef bruker < handle
    
    properties
        opus_TakeSample_server;
        opus_LoadData_server;
        opus_CheckOpus_server;
        opus_StartOpus_server;
                wait = 0.1;
    end
      
    methods
        
        function obj = bruker
            obj.opus_TakeSample_server = actxserver('OpusCMD334.TakeSample');
            obj.opus_LoadData_server = actxserver('OpusCMD334.LoadData');
            obj.opus_CheckOpus_server = actxserver('OpusCMD334.CheckOpus');
            obj.opus_StartOpus_server = actxserver('OpusCMD334.StartOpus');
        end
        
        
        function takespectrum(obj,xpm_name,xpm_path,spec_name,spec_path,unload)
            %xpm_name is the string of the .xpm filename (for instance,
            %'example.xpm') used in this measurement.
            %unload is a boolean value: 0 means to leave the spectrum in
            %the OPUS window after taking it, 1 means to unload the
            %spectrum
            disp('Taking spectrum...')
            obj.opus_TakeSample_server.invoke('TakeSample',xpm_name,xpm_path,spec_name,spec_path,unload);
            disp('Spectrum complete.')
        end
        
        function IsOpusRunning(obj)
            %this function doesnt seem to work. returns same value
            %regardless of OPUS state
            obj.opus_CheckOpus_server.invoke('IsOpusRunning')
            
        end
        
        function StartOpus(obj)
%             obj.opus_StartOpus_server.invoke('StartOpus','C:\OPUS_7.0.129\opus.exe','OPUS')
             obj.opus_StartOpus_server.invoke('StartOpus','C:\OPUS_7.2.139.1294\opus.exe','OPUS')
            
            
            
        end
        
        function writeDPT(obj,filepath,varargin)
            %filepath points to an opus spectrum file, which could end in
            %.0, .1, etc. The additional argument can be the writepath,
            %which should end in '.dpt'. If no additional argument is
            %provided then the writepath will be the same as the filepath
            switch nargin
                case 3
                    filepath_csv = varargin{1};
                case 2
                    filetype_startindex = strfind(filepath,'.');
                    filepath_csv = [filepath(1:filetype_startindex-1) '.dpt']; %replaces the suffix of the spectrum file with .dpt
                otherwise
                    error('Must pass either 1 or 2 arguments to writeDPT.')
            end
            
            obj.opus_LoadData_server.invoke('LoadData',filepath,1); %This loads the data from the specified opus spectrum file into the properties of the active x server opus_LoadData_server. The 1 indicates to unload the spectrum from the opus window.
            k = linspace(obj.opus_LoadData_server.HighLimit,obj.opus_LoadData_server.LowLimit,obj.opus_LoadData_server.SizeofArray);
            intensity = obj.opus_LoadData_server.DataArray(1:obj.opus_LoadData_server.SizeofArray); %for some reason DataArray can contain one element more than SizeofArray specifies, but this extra element is just the value 0 and has no meaning. This code ensures that k and intensity have the same size;
            
            
            spectrum = [transpose(k) transpose(intensity)];
            dlmwrite(filepath_csv,spectrum)            
        end
        
         function spectrum = getdata(obj,filepath)
            %getdata returns the spectrum k and intensity values so that you can manipulate them in matlab.
            %It does the same things as writeDPT, except returns the data
            %rather than writing it to a dpt file. The spectrum it returns
            %is an Nx2 matrix, where column one contains the k-values and
            %column 2 the intensity values. filepath points to an opus spectrum file, which MUST end in
            %.0, .1, etc. 
                      
            obj.opus_LoadData_server.invoke('LoadData',filepath,1); %This loads the data from the specified opus spectrum file into the properties of the active x server opus_LoadData_server. The 1 indicates to unload the spectrum from the opus window.
            k = linspace(obj.opus_LoadData_server.HighLimit,obj.opus_LoadData_server.LowLimit,obj.opus_LoadData_server.SizeofArray);
            intensity = obj.opus_LoadData_server.DataArray(1:obj.opus_LoadData_server.SizeofArray); %for some reason DataArray can contain one element more than SizeofArray specifies, but this extra element is just the value 0 and has no meaning. This code ensures that k and intensity have the same size;
            spectrum = [transpose(k) transpose(intensity)];
        end
        
        function delete(obj)
            delete(obj.opus_TakeSample_server)
            delete(obj.opus_LoadData_server)
            delete(obj.opus_CheckOpus_server);
            delete(obj.opus_StartOpus_server);
        end
        
    end
end