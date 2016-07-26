function [voltages currents peakpowers] = findvoltagesfromLIV(fpath_LIV,number_of_spectra)
    %function findvoltagesfromLIV take an LIV mat file and determines which voltages to apply
    %which yield equally spaced currents between I_thresh+0.1*range and I_thresh+0.9*range
    %where range = I_max - I_thresh

    junk = load(fpath_LIV);
    laser_LIV = junk.data; %'data' is the name of the struct, which is saved during the LIV program
    clear junk;
    I=laser_LIV.I;
    V_pulser=laser_LIV.V_pulser(1:length(laser_LIV.I)); %note that laser_LIV.V_pulser typically has more elements than laser_LIV.I due to the rollover detector which halts acquisition. Here, V_pulser is truncated to have the same length as I
    L_peak = laser_LIV.L_peak;
    I_thresh = laser_LIV.I_thresh;
    I_max = laser_LIV.I_max;
    range=I_max-I_thresh;

    %{
    figure;
    plot(laser_LIV.V_pulser(1:length(laser_LIV.I)),laser_LIV.I,'.')
    figure;
    plot(laser_LIV.V_pulser(1:length(laser_LIV.I)),laser_LIV.L_peak,'.')
    %}

    currents = zeros(1,number_of_spectra);
    for j=1:number_of_spectra
        currents(j) = I_thresh + (0.1 + 0.8*(j-1)/(number_of_spectra-1))*range; %yields equally spaced currents between I_thresh+0.1*range and I_thresh+0.9*range
    end

    %Once you know the current, you have to find which voltage to apply in
    %order to achieve that current. This is not trivial because during the LIV
    %we collected a finite number of data points, so we dont know which voltage
    %corresponds to every imaginable current. Strategy: find the measured
    %current values immediately below and above the desired current, then do a
    %linear interpolation to determine which voltage should be applied to
    %reach the desired current. A linear interpolation should be pretty good,
    %provided that we took a good number of data points during the LIV.
    
    %We will also use the linear interpolation to determine what the output
    %power at that current is.

    voltages = zeros(1,length(currents)); %initialize voltages vector
    peakpowers = zeros(1,length(currents)); %initialize peakpowers vector
    for j=1:number_of_spectra
        current = currents(j);
        %find the current from the LIV which is immediately below this current
        %value, because then this current and the next current data point
        %will be data points that we know we have collected, and we don't
        %have to worry about making a call to an element index that is
        %larger than the vector size
        currents_below = I<current; %returns a 1 for all values of I less than current
        I_low_index = find(currents_below,1,'last'); %returns the index of the current just below the desired current
        I_low = I(I_low_index);
        L_peak_low = L_peak(I_low_index);
        V_low = V_pulser(I_low_index);
        I_high = I(I_low_index+1);
        L_peak_high = L_peak(I_low_index+1);
        V_high = V_pulser(I_low_index+1);
    
        V_desired = V_low+((current - I_low)/(I_high - I_low))*(V_high - V_low); %simple linear interpolation
        voltages(j) = round(1000*V_desired)/1000; %since the resolution of the pulser is mV, we choose the nearest mV reading
        peakpowers(j) = L_peak_low+((current - I_low)/(I_high - I_low))*(L_peak_high - L_peak_low); %simple linear interpolation
    end


end