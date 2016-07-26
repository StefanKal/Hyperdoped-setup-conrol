fp = 'G:\Toby\experiments\LL13728a\LL13728a_p1\';

junk = load([fp 'LL13728a_p1_c3_4mm_devB2_LIV.mat']);
L4mm_w31um = junk.data;

junk = load([fp 'LL13728a_p1_c3_4mm_devC2_LIV.mat']);
L4mm_w29um = junk.data;

junk = load([fp 'LL13728a_p1_c3_4mm_devE1_LIV.mat']);
L4mm_w27um = junk.data;

junk = load([fp 'LL13728a_p1_c2_3mm_devB2_LIV.mat']);
L3mm_w31um = junk.data;

junk = load([fp 'LL13728a_p1_c2_3mm_devC2_LIV.mat']);
L3mm_w29um = junk.data;

junk = load([fp 'LL13728a_p1_c2_3mm_devE1_LIV.mat']);
L3mm_w27um = junk.data;

junk = load([fp 'LL13728a_p1_c1_2mm_devB2_LIV.mat']);
L2mm_w31um = junk.data;

junk = load([fp 'LL13728a_p1_c1_2mm_devC1_LIV.mat']);
L2mm_w29um = junk.data;

junk = load([fp 'LL13728a_p1_c1_2mm_devE1_LIV.mat']);
L2mm_w27um = junk.data;

junk = load([fp 'LL13728a_p1_c4_1470um_devB2_LIV.mat']);
L1470um_w31um = junk.data;

junk = load([fp 'LL13728a_p1_c4_1470um_devC2_LIV.mat']);
L1470um_w29um = junk.data;

junk = load([fp 'LL13728a_p1_c4_1470um_devE4_LIV.mat']);
L1470um_w27um = junk.data;


fname = '13-728a_p1_c3_4mm_varywidth';
figure;
hold on;
set(gca,'FontSize',18)
xlabel('Current (A)')
ylabel('Peak Power (W)')
set(gca,'Box','On')
title([strrep(fname,'_',' ') ' LI'])
plot(L4mm_w31um.I,L4mm_w31um.L_peak, L4mm_w29um.I,L4mm_w29um.L_peak,L4mm_w27um.I,L4mm_w27um.L_peak)
legend('30.9um','29.0um','27.3um','Location','NorthWest')
saveas(gcf,[fname '_LI.png'],'png')
figure;
hold on;
set(gca,'FontSize',18)
xlabel('Current Density (kA/cm^2)')
ylabel('Peak Power (W)')
set(gca,'Box','On')
title([strrep(fname,'_',' ') ' LJ'])
plot(L4mm_w31um.J,L4mm_w31um.L_peak, L4mm_w29um.J,L4mm_w29um.L_peak,L4mm_w27um.J,L4mm_w27um.L_peak)
legend('30.9um','29.0um','27.3um','Location','NorthWest')
saveas(gcf,[fname '_LJ.png'],'png')

fname = '13-728a_p1_c2_3mm_varywidth';
figure;
hold on;
set(gca,'FontSize',18)
xlabel('Current (A)')
ylabel('Peak Power (W)')
set(gca,'Box','On')
title([strrep(fname,'_',' ') ' LI'])
plot(L3mm_w31um.I,L3mm_w31um.L_peak, L3mm_w29um.I,L3mm_w29um.L_peak,L3mm_w27um.I,L3mm_w27um.L_peak)
legend('30.9um','29.0um','27.3um','Location','NorthWest')
saveas(gcf,[fname '_LI.png'],'png')
figure;
hold on;
set(gca,'FontSize',18)
xlabel('Current Density (kA/cm^2)')
ylabel('Peak Power (W)')
set(gca,'Box','On')
title([strrep(fname,'_',' ') ' LJ'])
plot(L3mm_w31um.J,L3mm_w31um.L_peak, L3mm_w29um.J,L3mm_w29um.L_peak,L3mm_w27um.J,L3mm_w27um.L_peak)
legend('30.9um','29.0um','27.3um','Location','NorthWest')
saveas(gcf,[fname '_LJ.png'],'png')

fname = '13-728a_p1_c1_2mm_varywidth';
figure;
hold on;
set(gca,'FontSize',18)
xlabel('Current (A)')
ylabel('Peak Power (W)')
set(gca,'Box','On')
title([strrep(fname,'_',' ') ' LI'])
plot(L2mm_w31um.I,L2mm_w31um.L_peak, L2mm_w29um.I,L2mm_w29um.L_peak,L2mm_w27um.I,L2mm_w27um.L_peak)
legend('30.9um','29.0um','27.3um','Location','NorthWest')
saveas(gcf,[fname '_LI.png'],'png')
figure;
hold on;
set(gca,'FontSize',18)
xlabel('Current Density (kA/cm^2)')
ylabel('Peak Power (W)')
set(gca,'Box','On')
title([strrep(fname,'_',' ') ' LJ'])
plot(L2mm_w31um.J,L2mm_w31um.L_peak, L2mm_w29um.J,L2mm_w29um.L_peak,L2mm_w27um.J,L2mm_w27um.L_peak)
legend('30.9um','29.0um','27.3um','Location','NorthWest')
saveas(gcf,[fname '_LJ.png'],'png')

fname = '13-728a_p1_c4_1470um_varywidth';
figure;
hold on;
set(gca,'FontSize',18)
xlabel('Current (A)')
ylabel('Peak Power (W)')
set(gca,'Box','On')
title([strrep(fname,'_',' ') ' LI'])
plot(L1470um_w31um.I,L1470um_w31um.L_peak, L1470um_w29um.I,L1470um_w29um.L_peak,L1470um_w27um.I,L1470um_w27um.L_peak)
legend('30.9um','29.0um','27.3um','Location','NorthWest')
saveas(gcf,[fname '_LI.png'],'png')
figure;
hold on;
set(gca,'FontSize',18)
xlabel('Current Density (kA/cm^2)')
ylabel('Peak Power (W)')
set(gca,'Box','On')
title([strrep(fname,'_',' ') ' LJ'])
plot(L1470um_w31um.J,L1470um_w31um.L_peak, L1470um_w29um.J,L1470um_w29um.L_peak,L1470um_w27um.J,L1470um_w27um.L_peak)
legend('30.9um','29.0um','27.3um','Location','NorthWest')
saveas(gcf,[fname '_LJ.png'],'png')

fname = '13-728a_p1_width31um_varylength';
figure;
hold on;
set(gca,'FontSize',18)
xlabel('Current (A)')
ylabel('Peak Power (W)')
set(gca,'Box','On')
title([strrep(fname,'_',' ') ' LI'])
plot(L1470um_w31um.I,L1470um_w31um.L_peak, L2mm_w31um.I,L2mm_w31um.L_peak,L3mm_w31um.I,L3mm_w31um.L_peak,L4mm_w31um.I,L4mm_w31um.L_peak)
legend('1.47mm','2mm','3mm','4mm','Location','NorthWest')
saveas(gcf,[fname '_LI.png'],'png')
figure;
hold on;
set(gca,'FontSize',18)
xlabel('Current Density (kA/cm^2)')
ylabel('Peak Power (W)')
set(gca,'Box','On')
title([strrep(fname,'_',' ') ' LJ'])
plot(L1470um_w31um.J,L1470um_w31um.L_peak, L2mm_w31um.J,L2mm_w31um.L_peak,L3mm_w31um.J,L3mm_w31um.L_peak,L4mm_w31um.J,L4mm_w31um.L_peak)
legend('1.47mm','2mm','3mm','4mm','Location','NorthWest')
saveas(gcf,[fname '_LJ.png'],'png')
figure;
hold on;
set(gca,'FontSize',18)
xlabel('Current Density (kA/cm^2)')
ylabel('Voltage (V)')
set(gca,'Box','On')
title([strrep(fname,'_',' ') ' VJ'])
plot(L1470um_w31um.J,L1470um_w31um.V, L2mm_w31um.J,L2mm_w31um.V,L3mm_w31um.J,L3mm_w31um.V,L4mm_w31um.J,L4mm_w31um.V)
legend('1.47mm','2mm','3mm','4mm','Location','SouthEast')
saveas(gcf,[fname '_VJ.png'],'png')
figure;
hold on;
set(gca,'FontSize',18)
xlabel('Current (A)')
ylabel('Voltage (V)')
set(gca,'Box','On')
title([strrep(fname,'_',' ') ' VJ'])
plot(L1470um_w31um.I,L1470um_w31um.V, L2mm_w31um.I,L2mm_w31um.V,L3mm_w31um.I,L3mm_w31um.V,L4mm_w31um.I,L4mm_w31um.V)
legend('1.47mm','2mm','3mm','4mm','Location','SouthEast')
saveas(gcf,[fname '_VI.png'],'png')
