figure
set(gcf, 'papersize', [8 12], 'paperposition', [0 0 8 12])
subplot(3,1,1)
[simple,fs]= wavread('simple.wav');
DisplaySpecgramQuick(simple,fs);
sound(simple,fs)
title('simple')

subplot(3,1,2)
[samba,fs]= wavread('samba.wav');
DisplaySpecgramQuick(samba,fs);
sound(samba,fs)
title('samba')

subplot(3,1,3)
[bells,fs]= wavread('bells.wav');
DisplaySpecgramQuick(bells,fs);
sound(bells,fs)
title('bells')

saveas(gcf, 'Spectrograms.pdf')