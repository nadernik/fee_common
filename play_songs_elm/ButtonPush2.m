% button push % original code from rotation project

try
    close all
    clear all
    clc

    Nsessions = 30;
    [simple,fs] = wavread('CallIntroFast.wav');
    WhichBox = {[simple zeros(numel(simple),1)] [zeros(numel(simple),1) simple] [simple simple]};
    % one training session:


        dio = digitalio('nidaq','Dev1');
        addline(dio,0,'in');
        addline(dio,1,'in');
        pushed = getvalue(dio);


        N = 40; 
        nplays0 = 0;
        playtimes0 = [];
        nplays1 = 0;
        playtimes1 = [];

        ao = analogoutput('nidaq', 'Dev1');
        addchannel(ao, 0);
        set(ao, 'SampleRate', fs)
        set(ao, 'TriggerType', 'Manual');
        addchannel(ao, 1);
        set(ao, 'SampleRate', fs)
        set(ao, 'TriggerType', 'Manual');
        today = datestr(now)
    while N == 40

        checktoday = datestr(now); 
        while nplays0<N | nplays1<N;


            while pushed(1) == 0 & pushed(2) == 1
                pushed = getvalue(dio);
                pause(.1)
                checktoday = datestr(now); 
            end

            if pushed(1) == 1 & nplays0 <N
                putdata(ao, WhichBox{1})
                start(ao)
                trigger(ao)
                playtimes0 = [playtimes0 now]
                nplays0 = nplays0+1;
                wait(ao,5)
                stop(ao)
                if ~issame(today(1:2),checktoday(1:2))
                    nplays0 = 0; nplays1 = 0;
                    today = datestr(now)
                end
                
                try
                    emailme(['Bird in top box pulled the string for the ', num2str(nplays0), 'th time ', datestr(now)])
                catch 
                end
            end
            if pushed(2) == 0 & nplays1 <N
                putdata(ao, WhichBox{2})
                start(ao)
                trigger(ao)
                playtimes1 = [playtimes1 now]
                nplays1 = nplays1+1;
                wait(ao,5)
                stop(ao)
                if ~issame(today(1:2),checktoday(1:2))
                    nplays0 = 0; nplays1 = 0;
                    today = datestr(now)
                end
                
                try
                    emailme(['Bird in middle box pulled the string for the ', num2str(nplays1), 'th time ', datestr(now)])
                catch
                end
            end
            pushed = getvalue(dio);

            pause(1)
        if ~issame(today(1:2),checktoday(1:2))
            nplays0 = 0; nplays1 = 0;
            today = datestr(now)
        end
        end
        save(['RotationButtonPushNov18andon', num2str(round(now*1000)), '.mat'])
        checktoday = datestr(now); 
        if ~issame(today(1:2),checktoday(1:2))
            nplays0 = 0; nplays1 = 0;
            today = datestr(now)
        end
        pause(3600)
    end

    %figure; plot(simple)
catch 
    A = lasterror;
    save(['RotationButtonPush', num2str(round(now*1000)), '.mat'])
    emailme(['Code errored out ' A.message])
    ButtonPush2
end