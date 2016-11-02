function [A1 A2] = Subplot_convert(SubplotNum)
%%% plot PSTH and raster for 2by2
%%% Tatsuo Okubo
%%% 2014/02/18

switch SubplotNum    
    case 1
        A1 = [0.1 0.8 0.35 0.1]; 
        A2 = [0.1 0.55 0.35 0.22];
    case 2
        A1 = [0.1 0.35 0.35 0.1];
        A2 = [0.1 0.1 0.35 0.22];
    case 3
        A1 = [0.55 0.8 0.35 0.1];
        A2 = [0.55 0.55 0.35 0.22];
    case 4
        A1 = [0.55 0.35 0.35 0.1];
        A2 = [0.55 0.1 0.35 0.22];
end