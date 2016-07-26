%MAKE SURE OPUS IS ALREADY OPEN

%This script will load the .mat file containing the LIV information from a
%laser, and then capture multiple spectra at equally spaced current values
%within the laser's dynamic range

%There should be one folder containing all the LIV .mat files from the
%chip. Each .mat file should have the name 'chipname_laserXX_LIV.mat'
%This script will loop through all the lasers, load the LIV.mat file,
%determine which voltages to take spectra at, take the spectra and save it
%as a .0 file in addition to saving the spectral data in the struct along
%with the LIV data, but saving it under the new name
%'chipname_laserCC_LIVspectra.mat'

a=instrfindall;
delete(a);
clear a;
pause on; %enables the pause command (should be on by default, anyways)
unload=1; %after opus takes a spectrum, the file will be unloaded from the opus window, which speeds up the process. Change to unload=0 if needed.


addpath('G:\Toby\IV\classes')
addpath('G:\Toby\IV\functions')

%%%%%%%%%%%%%%%%%%%%%USER SPECIFIED PARAMETERS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
number_of_spectra = 9; %number of spectra to take for each laser
fpath_LIVfolder = 'G:\Toby\experiments\Hamamatsu_taperedlaser'; %folder path where the LIV mat files from the entire array are stored
array_name = 'Hamamatsu_taperedlaser_NRLchip'; %this is the part of the filename that precedes '_laserXX_LIV.mat'
xpm_name = 'laser.xpm'; %xpm file that opus will use
xpm_path = 'G:\Toby\experiments\Hamamatsu_taperedlaser'; %path of the xpm file, no '\' at the end
pulse_width=100e-9;
pulse_period=100e-6;
%%END OF USER SPECIFIED DATA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%create a folder to save the spectra to within the LIV folder
spec_path = [fpath_LIVfolder '\spectra']; %path of the folder you want to save the resulting spectra to, no '\' at the end
if ~exist(spec_path,'dir')
    mkdir(spec_path)
end

%Initialize Pulser
pulser=avtech5B;
    pulser.setwidth(pulse_width)
    pulser.setperiod(pulse_period)

%Initialize Bruker
spectrometer=bruker;
    
for laser=3 %include all laser number in the folder for which you want to take spectra
    
%We need to convert the laser number to a 2-character string to load the
%LIV file. (i.e. laser 1 becomes '01', laser 12 remains '12')
    laser_str = num2str(laser);
    while length(laser_str)<2
        laser_str = ['0' laser_str];
    end
    laser_name = ['laser' laser_str]; %this string is 'laserXX'

    fpath_LIVmat = [fpath_LIVfolder '\' array_name '_' laser_name '_LIV.mat'];
    fpath_LIVspecmat = [spec_path '\' array_name '_' laser_name '_LIVspectra.mat']; %this is the fname that will be used to save the structure containing the spectral data and LIV data together
    [spectra_V spectra_I spectra_L_peak]= findvoltagesfromLIV(fpath_LIVmat,number_of_spectra); %finds the voltages to apply to the laser to get currents equally spaced within dynamic range of LI curve
    
    spectra_V = round(spectra_V); %when using the avtech, convert the voltages to integers
    
    junk = load(fpath_LIVmat);
    data = junk.data; %'data' is the name of the struct which contains all the LIV data. We will add the spectral data to this and re-save as a new struct
    clear junk;


    data.spectra_V = spectra_V; %update struct
    data.spectra_I = spectra_I; %update struct
    data.spectra_L_peak = spectra_L_peak; %update struct
    
    data.spectra_SMSR = zeros(1,number_of_spectra);
    data.spectra_maxk = zeros(1,number_of_spectra);

   
    for j=1:number_of_spectra
        pulser.setvoltage(spectra_V(j));
        pause(2); %pause for good measure, let the laser reach steady state electrically and thermally
        spec_name = [array_name '_' laser_name '_V=' int2str(spectra_V(j)) 'V']; %appends the voltage in mV to the laser_name to create the spectrum's name
        spectrometer.takespectrum(xpm_name,xpm_path,spec_name,spec_path,unload); % Saves the spectrum as an Opus file
        spectrum = spectrometer.getdata([spec_path '\' spec_name '.0']); %THE .0 AT THE END OF THE FILENAME IS AN ASSUMPTION; MAKE SURE YOU DONT TAKE MULTIPLE SPECTRA WHICH WOULD RESULT IN .1 AND SO ON
    
        if j==1
             spectra = zeros(length(spectrum),2,number_of_spectra); %I have to initialize the 3d matrix spectra within the for loop so that I get the size right, which I can only know once I've taken the first spectrum
        end
        spectra(:,:,j) = spectrum; %stores all the spectra in a Nx2xnumber_of_spectra matrix, where 1st column is k-values, 2nd column is intensity, and the 3rd index corresponds to the voltage value at which the spectrum was taken
        data.spectra_SMSR(j) = findSMSR(spectrum(:,2));%THIS LINE WAS ADDED 5/6/2013 without checking to see if it works when run live
        [spectrum_max spectrum_max_index] = max(spectrum(:,2));
        data.spectra_maxk(j) = spectrum(spectrum_max_index,1); %the wavenumber at the maximum intensity
        clear spectrum spectrum_max spectrum_max_index;
    end

    data.spectra=spectra; %update struct
    clear spectra;

    save(fpath_LIVspecmat,'data','-mat');%save the new struct under a different filename just to be safe not to overwrite anything somehow

end;

pulser.delete
spectrometer.delete;



