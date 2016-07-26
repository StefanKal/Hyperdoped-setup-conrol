fp = 'G:\Toby\experiments\LL13734a\LL131734a_p2\LL131734a_p2_c1\2013-10-11\'; %folder where csv file of scope trace is located
fname = 'TEK00000'; %do not include the .csv at the end

data = csvread([fp fname '.csv']);

x=data(:,1);
y=data(:,2);

figure;
plot(x,y)
set(gca,'FontSize',16);
xlabel('Time');
ylabel('Intensity (a.u.)');
%set(gca,'XLim',[-10 1000]);
%set(gca,'YLim',[-0.1 1.1]);
title_str = ['Scope Trace:' strrep(fname,'_',' ')];
title(title_str);
saveas(gcf,[fp,fname,'_scopetrace.png'],'png');