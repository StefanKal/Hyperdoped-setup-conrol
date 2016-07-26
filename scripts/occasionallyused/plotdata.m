junk = load('G:\Toby\experiments\Eos4\2-14-2013\Eos4_DFB1_LIV');
DFB1=junk.data;

junk = load('G:\Toby\experiments\Eos4\2-14-2013\Eos4_DFB2_LIV');
DFB2=junk.data;

junk = load('G:\Toby\experiments\Eos4\2-14-2013\Eos4_FP2_LIV');
FP2=junk.data;

junk = load('G:\Toby\experiments\Eos4\2-14-2013\Eos4_FP3_LIV');
FP3=junk.data;

junk = load('G:\Toby\experiments\Eos4\2-14-2013\Eos4_FP4_LIV');
FP4=junk.data;

junk = load('G:\Toby\experiments\Eos4\2-14-2013\Eos4_FP5_LIV');
FP5=junk.data;

junk = load('G:\Toby\experiments\Eos4\2-14-2013\Eos4_FP6_LIV');
FP6=junk.data;

junk = load('G:\Toby\experiments\Eos4\2-14-2013\Eos4_FP7_LIV');
FP7=junk.data;

junk = load('G:\Toby\experiments\Eos4\2-14-2013\Eos4_FP8_LIV');
FP8=junk.data;

junk = load('G:\Toby\experiments\Eos4\2-14-2013\Eos4_9-16_SGR1_1_LIV');
SGR1=junk.data;

junk = load('G:\Toby\experiments\Eos4\2-14-2013\Eos4_9-16_SGR1_2_LIV');
SGR2=junk.data;

junk = load('G:\Toby\experiments\Eos4\2-14-2013\Eos4_9-16_SGR1_3_LIV');
SGR3=junk.data;

junk = load('G:\Toby\experiments\Eos4\2-14-2013\Eos4_9-16_SGR1_4_LIV');
SGR4=junk.data;

junk = load('G:\Toby\experiments\Eos4\2-14-2013\Eos4_9-16_SGR1_5_LIV');
SGR5=junk.data;

junk = load('G:\Toby\experiments\Eos4\2-14-2013\Eos4_9-16_SGR1_6_LIV');
SGR6=junk.data;

%{
figure;
hold on;
plot(DFB1.I,DFB1.V,'k.')
plot(DFB2.I,DFB2.V,'k.')
plot(FP2.I,FP2.V,'g')
plot(FP3.I,FP3.V,'m')
plot(FP4.I,FP4.V,'y')
plot(FP5.I,FP5.V,'r')
plot(FP6.I,FP6.V,'b')
plot(FP7.I,FP7.V,'c')
plot(FP8.I,FP8.V,'k')

set(gca,'box','on')
set(gca,'FontSize',16);
xlabel('Current (A)');
ylabel('Voltage (V)');
legend('DFB1-lases','DFB2-lases','FP2','FP3','FP4','FP5','FP6','FP7','FP8','Location','SouthEast')
saveas(gcf,'G:\Toby\experiments\Eos4\2-14-2013\Eos4_DFBvsFP_Ivcurves.png','png');
%}
figure;
hold on;
plot(DFB1.I,DFB1.V,'k.')
plot(DFB2.I,DFB2.V,'k.')
plot(SGR1.I,SGR1.V,'g')
plot(SGR2.I,SGR2.V,'m')
plot(SGR3.I,SGR3.V,'y')
plot(SGR4.I,SGR4.V,'r')
plot(SGR5.I,SGR5.V,'b')
plot(SGR6.I,SGR6.V,'c')


set(gca,'box','on')
set(gca,'FontSize',16);
xlabel('Current (A)');
ylabel('Voltage (V)');
legend('DFB1-lases','DFB2-lases','SGR1','SGR2','SGR3','SGR4','SGR5','SGR6','Location','SouthEast')
saveas(gcf,'G:\Toby\experiments\Eos4\2-14-2013\Eos4_DFBvsSGR_IVcurves.png','png');
