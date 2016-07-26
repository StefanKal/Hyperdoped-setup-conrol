figure;
hold on;

%color = char('b.-','r.-','g.-');

 slope_effs = zeros(1,5);
 I_maxs = zeros(1,5);
 I_threshs = zeros(1,5);
for count=1:5
    count_str = num2str(count);
    a=load(['C:\Users\Admin\Desktop\Toby\experiments\taperedlaser\LL1167a_WMOPA8_DCW_BG2_TL1a_LIV',count_str,'.mat']);
    data = a.data;
    plot(data.I,data.L)
    slope_effs(count) = data.slope_eff;
    I_maxs(count) = data.I_max;
    I_threshs(count) = data.I_thresh;
end