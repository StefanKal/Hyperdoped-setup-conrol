classdef patterngenerator < handle
    % Created by Tobias, Mael, Stefan
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   This class is used to use Eos' custom 32-channel
    %   pulser board in pattern generator mode.
    %   To use this class, the power supply for the pulser board should be
    %   turned on and set no higher than 28V, no less than. The
    %   communication is usually established over the COM4 port (COM8 may also be used). This class allows you to turn on
    %   any number of channels in a pattern between 16 and 32, i.e. high bank only and any voltage, pulse width, and delay for each channel. 
    
    
    properties
        instr; %the communication channel to which commands are sent
        voltage; %voltage
        period; %pulse period
        last_msg; %the most recent message read from the read-buffer of the serial transmission line, which occurs after every write command in order to prevent the read buffer from overflowing            
        end
    
    properties(Constant)            % some of those are not used, need to clean up
       wait = 0.1;                  % wait time between commands sent to pulser
       CPU_clkspd = 150e6;          % clock speed of chip is 150 MHz
       width_initial=100e-9;        % at turn-on, pulse width is set to 100ns
       period_initial=10e-6;      % at turn-on, pulse period is set to 1000us, or 1kHz rep rate
       voltage_initial=4;          % at turn-on, the voltage is set to 4V   
       voltage_llimit=4;            % lower limit of the voltage
       voltage_hlimit=28;           % upper limit of the voltage
       
      
    end
    
    methods
        
        function obj = patterngenerator(varargin)
            % input arguments TBD
            disp('Initializing Eos pulser board, pattern generation mode...')
            obj.instr = serial('COM4','baudrate',57600);     % looks like we need to modify the baudrate for the board to work with the USB interface;
            fopen(obj.instr);
            
            disp('!! for now resets the memory (erases pattern) only for the first 50 memory slots')
            %INITIALIZATION
            obj.write('MO1;')                      % switches board to pattern generation mode
            obj.period=obj.period_initial;         % sets repetition rate
            obj.setvoltage(obj.voltage_initial);   % sets voltage to initial value
            obj.voltage=obj.voltage_initial;
            obj.write('HL750;');                   % allows updates of the high bank, with pattern lenght corresponding to 250 slots for now
            obj.write('LL0;');                     % command that means not interested in updating lower bank
            obj.erasepattern();
            disp('Initialization complete.')
            
        end        
        function erasepattern(obj)
            
            %% INIT VALUES
            repeatlength=5000;   % repeat length in ns
            repeat_MAX=1000;
            % corresponding fequency [kHz]
            step=13.2;            %  step size of 13.2ns
            
            %             nb_loops=int8(repeatlength/step);
            %             nb_loops_MAX=int8(repeat_MAX/step);
            
            nb_loops=round(repeatlength/step);
            nb_loops_MAX=round(repeat_MAX/step);
            %%
            
            nom_string = 'A55296;P65535';     % start of pretty much all high bank commands with adress for the first
            concstring ='';
            %             for j=1:nb_loops-1
            %                 concstring = strcat(concstring, num2str(65535), ',');
            %             end
           
            Nb=380;
            for j=1:Nb
                concstring = strcat(concstring,',', num2str(65535));
            end
            
            
            commands= [nom_string, concstring];
            
            NEW_command=zeros(nb_loops);
            nb_cut=round(repeatlength/repeat_MAX);
            
            T=length(commands);
            t=T/nb_cut;
            t=round(t);
            for ll=1:nb_cut                
                start_index=(ll-1)*t+ll-1    +1;
                end_index=ll*t+ll-1;
                
                if end_index>T
                    end_index=T;
                end
                
                NEW_command=commands(start_index:end_index);   
                
                obj.write(NEW_command);   
            end
            
            
             obj.setvoltage(5);
            
            
        end 
        function onechannel(obj,varargin)
            pattern='';
            channel=65535-varargin{1};
            concstring='';
            nom_string = strcat('A55296;P');     % start of pretty much all high bank commands with adress for the first
            for j=1:10
                concstring = strcat(concstring, ',', num2str(channel));
            end
            pattern=strcat(nom_string, concstring, ';');
            obj.write(pattern);
        end
        function createpattern(obj,Channel1,Channel2,pulse_length_1,delay_1,pulse_length_2,delay_2,varargin)
            % 
            
            
            %%%%%%%%%%%%%%%%%%%  the buffer ends up filling rather quickly when passing commands for more than ~50 to 75 slots
            %%%%%%%%%%%%%%%%%%%  => I need also to add a loop to cut up the train of commands in chunks that can be managed by the buffer
            %% BINARY TO DEC
            % BIANARY VALUE 2 CHANNEL NUMBER:  16-findstr('0', (dec2base(65535-(1024), 2, 16)))+1
            %To do: the reverse function
            warning('OFF')
            
%             obj.erasepattern;          
            
            %% Convert Channel number 1 
            Channel1_string='1';
            
            if Channel1 == 0
                fprintf(['\n Channel number must be >0  -> STOPPED!! '])
                return;
            end
            
            for oo=1:Channel1-1
                Channel1_string=[Channel1_string,'0'];
            end
            
            Channel1_bin=  base2dec(Channel1_string,2);
            fprintf([' Channel ',num2str(Channel1),'  ON \n']);
            
            %% Convert Channel number 2
            Channel2_string='1';
            
            if Channel2 == 0
                fprintf(['\n Channel number must be >0  -> STOPPED!! '])
                return;
            end
            
            for oo=1:Channel2-1
                Channel2_string=[Channel2_string,'0'];
            end
            
            Channel2_bin=  base2dec(Channel2_string,2);
            fprintf(['\n Channel ',num2str(Channel2),'  ON \n']);
            %%
            
            repeatlength=5000;   % repeat length in ns
            repeat_MAX=1000;
            % corresponding fequency [kHz]
            step=13.2;            %  step size of 13.2ns
            
%             nb_loops=int8(repeatlength/step);
%             nb_loops_MAX=int8(repeat_MAX/step);
                
            nb_loops=round(repeatlength/step);
            nb_loops_MAX=round(repeat_MAX/step);
            
            % Channel - pulse parameters
            % channel 32!!
%             delay_1=30;         % delay in ns
%             pulse_length_1=200;         % pulse length in ns
%             % channel 2
%             delay_2=0;         % delay in ns
%             pulse_length_2=50;         % pulse length in ns
            %             % channel 20
            %             delay_3=80;         % delay in ns
            %             pulse_length_3=40;         % pulse length in ns
            
            ch1 = zeros(1,1);
            ch2 = zeros(1,1);
            ch3 = zeros(1,1);
            decimal= zeros(1,1);
            binary= zeros(16,1);
            
            
            k=0; % time index             
            for j=1:nb_loops
                
                k=k+1; % time incrementation               
                time=k*step; % time value    
                
                %channel 1:
                if time<=delay_1; ch1(j)=0; end;
                if time>delay_1 && time<=delay_1+pulse_length_1; ch1(j)=Channel1_bin; end;   % 2048
                if time>delay_1+pulse_length_1;ch1(j)=0; end;
                
                %channel 2:
                if time<=delay_2; ch2(j)=0; end;
                if time>delay_2 && time<=delay_2+pulse_length_2; ch2(j)=Channel2_bin; end; %0000000000001000 -> Channel 4 (hexadecimal)
                if time>delay_2+pulse_length_2;ch2(j)=0; end;
                
                %                 %channel 3:
                %                  if incr<=delay_3; ch3(j)=0; end;
                %                   if incr>delay_3 && incr<=delay_3+pulse_length_3; ch3(j)=2048; end;
                %                   if incr>delay_3+pulse_length_3;ch3(j)=0; end;
                
                decimal(j) = 65535-(ch2(j)+ch1(j)); % binary  adress   65535-(4096+16+1)
                
            end
            
            %             fprintf(['\n Channel: ',num2str(16-findstr('0', (dec2base(decimal(j), 2, 16)))+1)],'\n');
            %%
            % loop to prevent buffer overload
            
            nom_string = 'A55296;P';     % start of pretty much all high bank commands with adress for the first
            concstring ='';
            for j=1:nb_loops-1
                concstring = strcat(concstring, num2str(decimal(j)), ',');
            end
            commands=strcat(nom_string, concstring, num2str(decimal(nb_loops)), ';');           
          
            NEW_command=zeros(nb_loops);
            nb_cut=round(repeatlength/repeat_MAX);            
            
            T=length(commands);
            t=T/nb_cut;
            
            for ll=1:nb_cut                
                start_index=(ll-1)*t+ll-1;
                end_index=ll*t+ll-1;
                
                if end_index>T
                    end_index=T;
                end
                
                NEW_command=commands(start_index:end_index);   
                
                obj.write(NEW_command);   
            end
            
            %              obj.write(commands);
            warning('ON')
        end
        function setvoltage(obj,volt)
            %sets input voltage in units of V, same as for the pulse mode
            if volt>=obj.voltage_llimit && volt<=obj.voltage_hlimit %the acceptable voltage range is between 4 and 28
                volt_mV = round(1000*volt); %message must be transmitted in mV
                obj.write(['PH' int2str(volt_mV) ';']);
                obj.voltage=volt_mV/1000;
                disp(['Voltage was set to ' num2str(obj.voltage) ' V.'])
            else
                disp('ERROR: Voltage must be between 4 and 28 V. Voltage was not changed.')
            end
        end
        function setperiod(obj,period)
            %sets pulse period in units of seconds. Minimum=1us, Maximum=1000us
            if 10^6*period<1 %minimum period is 1us
                obj.write('RR1;');
                obj.period=1e-6; %update class property
                disp('CAUTION: minimum period is 1 us. Period was set to 1 us.');
            elseif 10^6*period>1000 %maximum period is 1000us
                obj.write('RR1000;');
                obj.period=1000e-6; %update class property
                disp('CAUTION: maximum period is 1000 us. Period was set to 1000 us.');
            else
                obj.write(['RR' int2str(round(10^6*period)) ';']);
                obj.period = round(10^6*period)*10^-6; %update class property
                disp(['Period was set to ' int2str(round(10^6*period)) ' us.']);
                
            end
        end        
        function write(obj,str)
            %write direct commands to the pulser as ASCII strings. Ex: write('PH10000;') would set the pulse height to 10000mV
            fprintf(obj.instr, str);
            pause(obj.wait)
            obj.last_msg = fscanf(obj.instr);
            pause(obj.wait);
        end        
        function off(obj)
            % erases pattern and then switches to pulse mode and then re-applies initialization parameters before closing communication with pulser
            
            obj.write('erase_pattern;');         % erases pattern written in the first 500 memory slots, i.e. should turn off all channels as long as previous patterns are less than 500
            obj.setvoltage(4);
            fclose(obj.instr);
            delete(obj.instr);  
        end
         
    end     %end methods
end         %end classdef