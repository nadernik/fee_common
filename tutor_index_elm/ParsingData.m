clear all
close all
clc
%% imitation scores
load TutorMatch_output_snowday.mat

elm.Names = CelllistAll(2:11,2);

elm.Tutors = cell2mat(CelllistAll(2:11,3));
for i = 1:numel(elm.Names) 
    if elm.Tutors(i) == 1
        elm.Colors(i,:) = [0 0 1];
    else
        elm.Colors(i,:) = [1 0 0];
    end
end
elm.Imitation.Intro = cell2mat(CelllistAll(2:11,4));
elm.Imitation.noIntro = cell2mat(CelllistAll(12:end,4));
elm.Imitation.STDI = cell2mat(CelllistAll(2:11, 7));
elm.Imitation.STDnoI = cell2mat(CelllistAll(12:end, 7));
elm.Similarity.Intro = cell2mat(CelllistAll(2:11,5));
elm.Similarity.noIntro = cell2mat(CelllistAll(12:end,5));
elm.Similarity.STDI = cell2mat(CelllistAll(2:11, 8));
elm.Similarity.STDnoI = cell2mat(CelllistAll(12:end, 8));
elm.Sequencing.Intro = cell2mat(CelllistAll(2:11,6));
elm.Sequencing.noIntro = cell2mat(CelllistAll(12:end,6));
elm.Sequencing.STDI = cell2mat(CelllistAll(2:11, 9));
elm.Sequencing.STDnoI = cell2mat(CelllistAll(12:end, 9));
Scores = {'Imitation', 'Similarity', 'Sequencing'};
for i = 1:numel(elm.Names); 
    if elm.Tutors(i) == 1
        for j = 1:numel(Scores)
            elm.(Scores{j}).SongOne(i) = elm.(Scores{j}).Intro(i);
            elm.(Scores{j}).SongTwo(i) = elm.(Scores{j}).noIntro(i);
            elm.(Scores{j}).STDSongOne(i) = elm.(Scores{j}).STDI(i);
            elm.(Scores{j}).STDSongTwo(i) = elm.(Scores{j}).STDnoI(i);
        end
    else
        for j = 1:numel(Scores)
            elm.(Scores{j}).SongTwo(i) = elm.(Scores{j}).Intro(i);
            elm.(Scores{j}).SongOne(i) = elm.(Scores{j}).noIntro(i);
            elm.(Scores{j}).STDSongTwo(i) = elm.(Scores{j}).STDI(i);
            elm.(Scores{j}).STDSongOne(i) = elm.(Scores{j}).STDnoI(i);
        end
    end
end
% mean subtracting
for j = 1:numel(Scores)
    elm.(Scores{j}).MeanScore.SongOne = mean(elm.(Scores{j}).SongOne);
    elm.(Scores{j}).MeanScore.SongTwo = mean(elm.(Scores{j}).SongTwo);
    for i = 1:numel(elm.Names)
        if elm.Tutors(i) == 1
            elm.(Scores{j}).IMeanSubtract(i) = elm.(Scores{j}).SongOne(i) - elm.(Scores{j}).MeanScore.SongOne;
            elm.(Scores{j}).noIMeanSubtract(i) = elm.(Scores{j}).SongTwo(i) - elm.(Scores{j}).MeanScore.SongTwo;
        else
            elm.(Scores{j}).noIMeanSubtract(i) = elm.(Scores{j}).SongOne(i) - elm.(Scores{j}).MeanScore.SongOne;
            elm.(Scores{j}).IMeanSubtract(i) = elm.(Scores{j}).SongTwo(i) - elm.(Scores{j}).MeanScore.SongTwo;
        end
    end
end

%% maturity index
load MI
elm.MI = MI.scores;
for i = 1:numel(elm.Names)
    elm.meanMI(i) = mean(elm.MI{i});
    elm.stdMI(i) = std(elm.MI{i});
end
%%
save elm elm Scores
%% see GeneratingPlots 

