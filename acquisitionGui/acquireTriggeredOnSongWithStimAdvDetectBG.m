function acquireTriggeredOnSongWithStimAdvDetectBG(exper, stimChan)

timerAcqStart = timer('TimerFcn', {'CBacquireTriggeredOnSongWithStimAdvDetect', exper, stimChan});
startat(timerAcqStart,now+((1/24)/3600));