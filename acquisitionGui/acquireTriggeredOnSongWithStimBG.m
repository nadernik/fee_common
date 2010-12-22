function acquireTriggeredOnSongWithStimBG(exper, stimChan)

timerAcqStart = timer('TimerFcn', {'CBacquireTriggeredOnSongWithStim', exper, stimChan});
startat(timerAcqStart,now+((1/24)/3600));