fp = 'G:\Toby\experiments\LL13726a\LL13726a_p1\';
fp2 ='G:\Toby\experiments\LL13726a\LL13726a_p1_VER2\';
filelist=dir(fp);

for j=1:length(filelist)
    if ~isempty(findstr(filelist(j).name,'mat'))
       disp(filelist(j).name)
       junk = load([fp filelist(j).name]);
       data=junk.data;
       
       if ~isempty(findstr(filelist(j).name,'L=2000'))
          data.ridge_length
           data.ridge_length=2000e-6;
          disp('ridge length updated')
       data.J = 10^-7*data.I/(data.ridge_width*data.ridge_length);
       data.J_thresh = 10^-7*data.I_thresh/(data.ridge_width*data.ridge_length);
       save([fp2 filelist(j).name],'data','-mat');
       end
    end
       
       
    
    
    
    
    
end