% this file relies on CorrClips.m to judge the similarity between the tutor
% and yoked and string birds, and a conspecific bird too, and generates a
% plot of the similarity of each syllable.
%% skip this
clear all; close all; clc
Dir = dir('emily/b2783/2590');
Dir = Dir(3:end); % the first two entries in dir are '.' and '..'
for i = 1:size(Dir)
    filenames{i} = Dir(i).name;
end
%% start here
clc; close all; clear all
[tutor, tutorfs] = wavread('EmilyM/CallIntroFast.wav');
T = size(tutor);
%sound(tutor,tutorfs)
% arggg... tutor has different sampling rate from everything else...
tutor = resample(tutor, 44100, tutorfs);
%sound(tutor, 44100);
%
Motif1 = tutor(round((44100/tutorfs)*(90000:128400)));
Motif2 = tutor(round((44100/tutorfs)*(128400:T-1)));

A1 = tutor(round((44100/tutorfs)*(90650:93880)));
B1 = tutor(round((44100/tutorfs)*(93880:96400)));
C1 = tutor(round((44100/tutorfs)*(96400:99110)));
D1 = tutor(round((44100/tutorfs)*(99110:104200)));
E1 = tutor(round((44100/tutorfs)*(104200:109700)));

A2 = tutor(round((44100/tutorfs)*(109700:112600)));
B2 = tutor(round((44100/tutorfs)*(112600:114800)));
C2 = tutor(round((44100/tutorfs)*(114800:118300)));
D2 = tutor(round((44100/tutorfs)*(118300:122900)));
E2 = tutor(round((44100/tutorfs)*(122900:128400)));

%
Vars = {'Tutor', 'Pupil1a', 'Pupil1b', 'Pupil1c', 'Pupil2a', 'Pupil2b', 'Pupil2c', 'Cona', 'Conb', 'Conc'};

VarClips{1} = Motif2;

%brother with no string (2783)
[pupil,fs] = wavread('emily/b2783/2590/13_40962.6078240741_2_23_14_35_16.wav');
VarClips{2} = pupil(70000:100000);

[pupil, fs] = wavread('emily/b2783/2590/13_40962.6063194444_2_23_14_33_6.wav');
VarClips{3} = pupil(40000:80000);

[pupil, fs] = wavread('emily/b2783/2590/13_40962.6072685185_2_23_14_34_28.wav');
VarClips{4} = pupil(30000:70000);

%brother with string (2782)
[pupil,fs] = wavread('emily/b2782/2590/11_40962.4775_2_23_11_27_36.wav');
VarClips{5} = pupil(60000:100000);

[pupil,fs] = wavread('emily/b2782/2590/11_40962.428125_2_23_10_16_30.wav');
VarClips{6} = pupil(30000:70000);

[pupil,fs] = wavread('emily/b2782/2590/11_40962.521875_2_23_12_31_30.wav');
VarClips{7} = pupil(70000:100000);

%conspecific 
[pupil,fs] = wavread('Ofersongs/simple.wav');
VarClips{8} = pupil(1:40001);

[pupil,fs] = wavread('Ofersongs/samba.wav');
VarClips{9} = pupil(1:end);

[pupil,fs] = wavread('Ofersongs/bells.wav');
VarClips{10} = pupil(1:end);

% [pupil,fs] = wavread('emily/b2648/2532/12_40904.541875_12_27_13_0_18.wav');
% VarClips{8} = pupil(70000:10000);
% 
% [pupil,fs] = wavread('emily/b2648/2532/12_40904.376412037_12_27_9_2_2.wav');
% VarClips{9} = pupil(90000:130000);
% 
% [pupil,fs] = wavread('emily/b2648/2532/12_40904.386712963_12_27_9_16_52.wav');
% VarClips{10} = pupil(90000:130000);


%
X = [10 20 20 20 30 30 30 40 40 40];
Syls = {'A', 'B', 'C', 'D', 'E'};
SylClips = {A1 B1 C1 D1 E1};
Colors = lines(5);

for Vari = 1:numel(Vars)
    for Syli = 1:numel(Syls)
        tic
        SS = max(CorrClips(SylClips{Syli}, VarClips{Vari}))
        SimScore.(Syls{Syli}).(Vars{Vari}) = SS;
        toc
        save SimScore SimScore
        %['just did ', Syls{Syli}, Vars{Vari}]
    end
end

%%
figure
for Vari = 1:numel(Vars)
    for Syli = 1:numel(Syls)
        text(X(Vari)+Syli+rand-.5, SimScore.(Syls{Syli}).(Vars{Vari}), Syls(Syli), 'color', Colors(Syli,:));
    end
end
ylabel('Similarity Score')
xlim([0 50])
set(gca, 'Xtick', [13 23 33 43], 'Xticklabel', {'Tutor', 'Yoked', 'String', 'Conspecific'})
set(gcf, 'papersize', [8 6], 'paperposition', [0 0 8 6])
saveas(gcf, 'temp.pdf')
%% 
clc
CorrClips(A1,E1)
