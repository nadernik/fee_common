function handles = egm_AveryTestbed(handles)
shg;
song = handles.sound;
fs = handles.fs; 
figure; 
DisplaySpecgramQuick(song,fs); 