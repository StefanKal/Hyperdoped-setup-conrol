fp = 'G:\Toby\experiments\LL13728a\LL13728a_p1\';
filelist=dir(fp);
title_str='LL13-728a p1 c4 L=1470um w=27um';
filename = strrep(title_str,' ','_');

LI_fig = figure;
hold on;
LI_axes=gca;
set(gca,'FontSize',18)
xlabel('Current (A)')
ylabel('Peak Power (W)')
title(title_str)
set(gca,'Box','On')
ColorOrder=get(gca,'ColorOrder');
ColorOrder=vertcat(ColorOrder,[0.4 0.2 0.1]);
[number_of_colors junk] = size(ColorOrder);


LJ_fig=figure;
hold on;
LJ_axes=gca;
set(gca,'FontSize',18)
xlabel('Current Density (kA/cm^2)')
ylabel('Peak Power (W)')
title(title_str)
set(gca,'Box','On')


VI_fig = figure;
hold on;
VI_axes=gca;
set(gca,'FontSize',18)
xlabel('Current (A)')
ylabel('Voltage (V)')
title(title_str)
set(gca,'Box','On')


leg = {}; %initialize legend
count=0;
for j=1:length(filelist)
    if ~isempty(strfind(filelist(j).name,'mat')) && ~isempty(strfind(filelist(j).name,'1470um')) && (~isempty(findstr(filelist(j).name,'devE1')) || ~isempty(findstr(filelist(j).name,'devE4')))
        count=count+1;
        name = filelist(j).name(16:length(filelist(j).name));
        name=strrep(name,'_LIV.mat','');
        name = strrep(name,'_',' ');
        leg{count}=name;
       junk = load([fp filelist(j).name]);
       data=junk.data;
       plot(LI_axes,data.I,data.L_peak,'Color',ColorOrder(mod(count-1,number_of_colors)+1,:))
       legend(LI_axes,leg,'Location','NorthWest')
       plot(LJ_axes,data.J,data.L_peak,'Color',ColorOrder(mod(count-1,number_of_colors)+1,:))
       legend(LJ_axes,leg,'Location','NorthWest')
       plot(VI_axes,data.I,data.V,'Color',ColorOrder(mod(count-1,number_of_colors)+1,:))
       legend(VI_axes,leg,'Location','SouthEast')
       
    end
    
end

saveas(LI_fig,[filename '_LI.png'],'png');
saveas(LJ_fig,[filename '_LJ.png'],'png');
saveas(VI_fig,[filename '_VI.png'],'png');

