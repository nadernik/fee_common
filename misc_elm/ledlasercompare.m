

%%
figure(2); clf; hold on

ViewingAngle = 130; %in degrees, fwhm \
LaserAngle = 36; 
PlotLength = 100; %in mm
xbins = linspace(.2,PlotLength, 500); %in mm 
ybins = linspace(-PlotLength/2, PlotLength/2, 500); %in mm 
dx = xbins(2)-xbins(1); 
dy = ybins(2)-ybins(1); 
TotalPower = .6; % in Watts, rough estimate. % I measured .3W at 13mm from detector. Datasheet says 1W
TotalPowerLaser = .03; % in Watts; 
sigma = xbins*tand(ViewingAngle/2)*2/2.355; 
WattsPerMm2 = zeros(length(ybins), length(xbins));
WattsPerMm2Laser = zeros(length(ybins), length(xbins)); 
for xi = 1:length(xbins)    
    WattsPerMm2(:,xi) = 1./(2*pi*sigma(xi)^2).*exp(-.5*(ybins.^2)/sigma(xi)^2)*TotalPower; % 2d gaussian
%     WattsPerMm2(:,xi) = mvnpdf([ybins' zeros(length(ybins),1)], [0 0], eye(2)*sigma(xi))*TotalPower; 
    WattsPerMm2Laser(abs(ybins)<xbins(xi)*tand(LaserAngle),xi) = TotalPowerLaser/(pi*(xbins(xi)*tand(LaserAngle))^2); 
end
PlotMe = [WattsPerMm2Laser; WattsPerMm2]*1000; 
PlotMe(PlotMe>200) = 200; 
imagesc(PlotMe, 'xdata', xbins)
cb = colorbar; 
xlabel('(mm)');
ylabel(cb, 'light intensity (mW/mm^2)')
axis tight; axis square
set(gca, 'yticklabel', []); 
% surf(xbins, ybins, WattsPerMm2); view(0,90);
% light intensity for laser and LED as a function of distance

distanceLaser = 10*[1 2 3 4 5] + 1.7; % in mm. fiber is recessed by 1.7mm in canula
powerLaser = .03*ones(1,5); % in Watts. 30mW total from fiber tip. 
% diameterLaser = distanceLaser*2.*tand(36); 
diameterLaser = [2.4 4.6 7.1 9 11]; % diameter of spot in mm
intensityLaser = 1000*powerLaser./(pi*(diameterLaser/2).^2); 
LaserAngle = atan(mean((diameterLaser/2)/distanceLaser))*180/pi; % this wasn't through the optrode

distanceLED = 10*[0 .5 1 2 3 4 5 6 7 8 10] + 13; % in mm. detector is 1.3cm recessed
powerLED = [.3 .19 .12 .06 .03 .02 .0135 .01 .0075 .0045 .003]; % in Watts
intensityLED = 1000*powerLED./(pi*(18/2).^2); %18mm detector surface diameter

figure(1); clf; hold on; 
plot(distanceLED, intensityLED, 'o')
plot(xbins, mean(1000*WattsPerMm2(abs(ybins)<dy,:),1))
plot(distanceLaser, intensityLaser, 'o')
plot(xbins, mean(1000*WattsPerMm2Laser(abs(ybins)<dy,:),1))
set(gca, 'xscale', 'log', 'yscale', 'log')
xlabel('distance from source (mm)')
ylabel('light intensity (mW/mm^2)')
legend('measured LED', 'calculated for LED', 'measured laser (pre optrode)', 'calculated for laser (post optrode)')
axis tight