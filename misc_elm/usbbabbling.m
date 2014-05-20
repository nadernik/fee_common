% segments human babbling data

clear all
close all
DIRids = dir(fullfile('C:\Users\emackev\Documents\BABBLING', '4*'));
agegps = {'12mo' '18mo' '24mo'}; 

% iterate through children
for childi = 1:length(DIRids)
    id = DIRids(childi).name;
    pathname = fullfile('C:\Users\emackev\Documents\BABBLING', id);
    % iterate through ages
    for agei = 1:length(agegps)
        age = agegps{agei}; 
        DIRaudio = dir(fullfile(pathname, ['*', age, '*'])); 
        DIRmeta = dir(fullfile(pathname, [id, '*coding*']));
        wavi = length(DIRaudio); % for 4145 there are two .wavs for 12 mos, use second one
        % get meta data
        META = importdata(fullfile(pathname, DIRmeta.name));
        ages = fields(META.data); 
        WhichField = find(cellfun(@(X) length(regexp(X,age))>0, ages));%, 'UniformOutput', false)
        WhichField = WhichField(end); % in some folders, there are two spreadsheets for a given month
        times = 24*60*60*META.data.(ages{WhichField})(:,1); %in seconds (from days)
        UtteranceType = META.textdata.(ages{WhichField})(:,2);
        Nsyll = META.data.(ages{WhichField})(:,6); 
        Nsyll(isnan(Nsyll)) = 0; 
        [~,fs] = wavread(fullfile(pathname, DIRaudio(wavi).name), 1);
        % get all speech utterances
        inds = intersect(strmatch('S', UtteranceType), find(Nsyll>2)); 
        % make a folder to put the utterances
        mkdir(fullfile(pathname, 'Segmented', age)); 
        % extracting each utterance
        for i = 1:length(inds)
            i = inds(i);
            dur = 8; 
            starttime = max([1/fs,times(i)-1]); 
            endtime = times(i)+dur; 
            timevec = (floor(starttime*fs):ceil(endtime*fs))/fs;
            [temp,fs] = wavread(fullfile(pathname, DIRaudio(wavi).name), ...
                [floor(starttime*fs) ceil(endtime*fs)]);
            % low-pass filter design
            Fc=4000; %cutoff frequency
            [B,A]=butter(4,Fc/(fs/2)); 
            A=filtfilt(B,A,temp);
            A = A*max(abs(temp))/max(abs(A));
            %plot(timevec,temp);shg
            %sound(temp/max(abs(temp)), fs);
            wavwrite(A,fs, ...
                fullfile(pathname, 'Segmented', age, ['ind', num2str(i)]));
            display([id, age, num2str(i)])
        end
    end
end
%%


figure; displaySpecgramQuick(A,fs);