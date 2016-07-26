function SMSR = findSMSR(spectrum)
%findSMSR takes as input 1xN spectrum, first finds the peak, then removes all the data points to
%the left and right of the peak provided the slope remains negative. The
%maximum of this remaining subset of the original spectrum is compared to
%the original spectrum's maximum to determine the SMSR.
%Note: Due to artifacts from the Bruker, sometimes you get negative
%intensity values. It is my opinion that to get the most fair SMSR value
%possible, one must take the maximum of the absolute value of the spectrum
%to include some of these strange negative spikes.

%Written by: Toby Mansuripur
%Last updated: 5/6/2013

%junk = load('C:\Users\tmansur\Dropbox\Measurements - data\Bruker characterization setup\matlab\5-6-2013\experiments\dummyarraydata\spectra\dummyarray_laser01_LIVspectra.mat');


[spectrum_max spectrum_max_index] = max(spectrum);

%search to the right of the peak to find where the mode hits its minimum 
flag=0;
right_index = spectrum_max_index;
while flag==0
   if (right_index+1) <= length(spectrum) %make sure we dont run out of bounds
        if (spectrum(right_index+1) - spectrum(right_index)) <=0
            right_index = right_index+1;
        else
            flag=1;
        end
   else
       flag=1;
   end
   %when the while loop ends, right_index will be the right end of the most
   %intense mode of the laser, or it will be the last index of the spectrum
end

%search to the left of the peak to find where the mode hits its minimum
flag=0;
left_index = spectrum_max_index;
while flag==0
   if (left_index-1) >= 1 %make sure we don't run out of bounds
        if (spectrum(left_index-1) - spectrum(left_index)) <=0
            left_index = left_index-1;
        else
            flag=1;
        end
   else
       flag=1;
   end
   %when the while loop ends, left_index will be the left end of the most
   %intense mode of the laser
end

spectrum_secondarymax = max([max(abs(spectrum(1:left_index))) max(abs(spectrum(right_index:length(spectrum))))]);

SMSR = 10*log10(spectrum_max/spectrum_secondarymax);

end

