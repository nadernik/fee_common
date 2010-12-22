function acquireTriggeredOnSongAdvDetectBG(exper)

timerAcqStart = timer('TimerFcn', {'CBacquireTriggeredOnSongAdvDetect', exper});
startat(timerAcqStart,now+((1/24)/3600));