function convert0filetocsv(folder)
    %%This function takes all Opus files in the folder (whether .0, .1, .2, etc. files) and writes them as .csv files. Files of type .1 written to csv files where the filename is appended with '-1', and likewise for '.2', etc, in order to prevent overwriting files with the same name The folder can contain other types of files too, which are ignored. 
    %%Opus must be open for this function to work.
spectrometer=bruker;

filelist=dir(folder);

for j=1:length(filelist)
    if filelist(j).isdir==0 %excludes the '.' and '..' folders, which can cause problems sometimes
        fname = filelist(j).name;
        dot_index=strfind(fname,'.');
        if ~isempty(dot_index) %if for some reason no dot is found in the filename, this prevents an error
            fname_suffix = fname(dot_index+1:length(fname));
            if sum(isstrprop(fname_suffix,'digit'))==length(fname_suffix) %returns true if every character of the file suffix is a digit
                fpath_spectrum = [folder '\' fname];
                if fname_suffix ~= '0' %if the suffix is anything other than .0 (for instance .1 or .2), then the  suffix will be appended to the name of the csv file
                    fpath_csv = [folder '\' fname(1:dot_index-1) '-' fname_suffix '.dpt'];
                    disp('Warning: Filetype .x found where x not equal to 0. CSV file named differently than spectrum.')
                else
                    fpath_csv = [folder '\' fname(1:dot_index-1) '.dpt'];
                end
                spectrometer.writeDPT(fpath_spectrum,fpath_csv)
            end
        end
    end
end


spectrometer.delete
end