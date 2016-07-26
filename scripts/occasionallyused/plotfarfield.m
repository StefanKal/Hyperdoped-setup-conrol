figure;
hold on;
set(gca,'XLim',[-10 10])
color = char('b.-','g.-', 'r.-', 'k.-', 'y.-', 'k.-', 'b.-', 'g.-');

currents = [110 150 200 250 300];% 150 170 180 200 220 250 300];
 
for count=1:length(currents)
    current_str = num2str(currents(count));
    a=load(['C:\Users\Admin\Desktop\Toby\experiments\newtaperedlaser\LL1167a_WMOPA8_DCW_BG2_TL2f_farfield_I',current_str,'.mat']);
    farfield = a.farfield;
    intensity = farfield.intensity;
    baseline = min(intensity);
    intensity = intensity-baseline;
    [maxi center] = max(intensity);
    
    plot(farfield.angles-farfield.angles(center),intensity/maxi,color(count,:))
end

