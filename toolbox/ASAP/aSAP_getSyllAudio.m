function [audio,fs] = aSAP_getSyllAudio(sylls,n)

[audio,fs] = wavread([sylls.filepath{n},filesep,sylls.filename{n}]);
startndx = round((sylls.startTFile(n)*fs) + 1);
endndx = round((sylls.endTFile(n)*fs) + 1);
audio = audio(startndx:endndx);