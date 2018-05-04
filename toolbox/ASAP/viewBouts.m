function viewBoutsDuringPeriod

%get files in period

%call getSegFile...
    load or compute
    
%if contains any bouts
generateFeats
store filename
store bout times as times of day
store bout lengths
store all bouts

%display bouts
without pause

%print bouts to jpeg

%erase figs

