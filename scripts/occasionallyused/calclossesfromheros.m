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



%%%First, plot J_thresh vs 1/cavitylength to extract gGamma and alpha_w
J_threshs = [L3mm_w31um.J_thresh L2mm_w31um.J_thresh L1470um_w31um.J_thresh];
L = [0.3 0.2 0.147];

[coeff,S] = polyfit(1./L,J_threshs,1);
y_intercept = coeff(2); %units=A
slope = coeff(1); %units = W/A
J_threshs_fitted = (1./L)*slope + y_intercept;

figure;
hold on;
set(gca,'FontSize',18)
xlabel('1/L (cm^{-1})')
ylabel('J_{thresh} (kA/cm^{2})')
set(gca,'Box','On')
title('Threshold Current Density vs. Cavity Length')
plot(1./L,J_threshs,'b.','MarkerSize',15)
plot(1./L, J_threshs_fitted,'r-')
saveas(gcf,'LL13-728a_w=31um_JthVS1overL.png','png')

R= ((3.18-1)/(3.18+1))^2

gGamma = log(1/R)/slope %units=cm/kA
alpha_w = y_intercept*gGamma %units=1/cm


%%%We can also plot 1/eta_e vs L

h = 6.626*10^-34;%J*s
c=2.99792e8;%m/s
lambda = 9.8e-6; %use 9.8microns, which is close to where the devices are lasing based on the measurements at LL
nu = c/lambda; %Hz
e=1.602e-19; %Coulombs
Np=35; %number of active stages

L=[0.147 0.2 0.3];
slope_effs = [L1470um_w31um.slope_eff L2mm_w31um.slope_eff L3mm_w31um.slope_eff];



eta_e = slope_effs/(h*nu*Np/(2*e));

[coeff,S] = polyfit(L,1./eta_e,1);
y_intercept = coeff(2); %units=A
slope = coeff(1); %units = W/A
eta_e_inverse_fitted = L*slope + y_intercept;

eta_id=1/y_intercept
alpha_w = slope*eta_id*log(1/R)

figure;
hold on;
set(gca,'FontSize',18)
xlabel('L (cm)')
ylabel('\eta_e^{-1}')
set(gca,'Box','On')
title('Inverse External DIfferential Efficiency vs. Cavity Length')
plot(L,1./eta_e,'b.','MarkerSize',15)
plot(L, eta_e_inverse_fitted,'r-')
%saveas(gcf,'LL13-728a_w=31um_oneoveretaeVScavitylength.png','png')
