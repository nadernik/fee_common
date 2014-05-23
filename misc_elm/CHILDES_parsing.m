% path = 'C:\Users\emackev\Downloads\Davis_Babbling\';
% ChildName = 'Micah';
% DIR = dir(fullfile(path, ChildName, '*.wav'));
% filesize = [];
% fullname = {};
% for i = 1:numel(DIR)
%     filesize(i) = DIR(i).bytes;
%     fullname{i} = fullfile(path, ChildName, (DIR(i).name));
% end
% 
% [~,i] = min(filesize);
% 
% %loading file
% cd(fullfile(path, ChildName));
% [D,fs] = wavread(fullname{i});
% D = mean(D,2);
% cd C:\Users\emackev\Documents\MATLAB\code
% %%
% mini_max_plot((1/fs:1/fs:length(D)/fs)', D); 
% shg
% %% pick what part to look at 
% sound(D((9*60+23)*fs:(9*60+40)*fs),fs)
% %%
% %for willie: D = D((25*60+18)*fs:(25*60+36)*fs);
% %for micah: D = D((9*60)*fs:(9*60+11)*fs);
% %for micah2: 
% %D = D((29*60+46)*fs:(29*60+52)*fs); 
% D = D((33*60+44)*fs:(33*60+59)*fs);
% %% save the part
% %wavwrite(D,fs, 'C:\Users\emackev\Downloads\Micah9minin.wav')
%% load file
%see files dadada1.wav, BabyTalk.wav, Willie25minin, Micah9minin, babybabbling.mp3
filename = 'C:\Users\emackev\Downloads\Micah9minin.wav';
[D,fs] = wavread(filename);
D = mean(D,2);

%% rectify and smooth files
smoothwin = .1;

figure;
g = subplot(2,1,1); 
displaySpecgramQuick(D,fs);% mini_max_plot((1/fs:1/fs:length(D)/fs)', D); 
h = subplot(2,1,2); 
P = conv((D.^2), gausswin(smoothwin*fs), 'same');
mini_max_plot((1:1:length(D))/fs, P);
ylabel('Smoothed power (au)'); xlabel('Time (s)');
linkaxes([h g], 'x')
set(gcf, 'PaperPosition', [0 0 5 4], 'PaperSize', [5 4])
%% compute autocorrelation
maxlag = 2; 
figure;
[A,lags] = xcorr(P, 'coeff');
plot(lags/fs, A); xlim([-maxlag maxlag]);
ylabel('correlation'); xlabel('Lag (s)'); shg
set(gcf, 'PaperPosition', [0 0 5 4], 'PaperSize', [5 4])
