%%
figure; hold all
for i = 1:5
    plot([0 1 2 3 4], ...
        [datenum(I.isolationdate{i}) ...
        datenum(I.firstsongsrecorded{i}) ...
        datenum(I.firstrhythmic{i})...
        datenum(I.veryrhythmic{i})...
        datenum(I.adultsong{i})]...
        -datenum(I.birthdate{i}));
    L{i} = num2str(I.Name{i});
end
set(gca, 'Xtick', [0 1 2 3 4], 'Xticklabel', ...
    {'isolated', 'sings', 'rhythmic', 'very rhythmic', 'adult'}, 'Ygrid', 'on')
ylabel('age (days)')
legend(L, 'location', 'northwest')
%%

ind = 1;
%3646
I.Name{ind} = 3646;
I.birthdate{ind} = '2-26-2013';
I.cage{ind} = 'E31';
I.isolationdate{ind} = '4-2-2013';
I.firstsongsrecorded{ind} = '4-07-2013';
I.firstrhythmic{ind} = '4-13-2013';
I.veryrhythmic{ind} = '4-28-2013';
I.adultsong{ind} = '6-18-2013';
I.to_hotel{ind} = '6-30-2013';
I.notes{ind} = 'rhythmic triplet and long wavering syllable of inconsistent duration';
%3647
ind = ind+1;
I.Name{ind} = 3647;
I.birthdate{ind} = '2-26-2013';
I.cage{ind} = 'E31';
I.isolationdate{ind} = '4-2-2013';
I.firstsongsrecorded{ind} = '4-07-2013';
I.firstrhythmic{ind} = '4-13-2013';
I.veryrhythmic{ind} = '4-20-2013';
I.adultsong{ind} = '6-18-2013';
I.to_hotel{ind} = '6-28-2013';
I.notes{ind} = 'very rhythmic for a while';
%3650
ind = ind+1;
I.Name{ind} = 3650;
I.birthdate{ind} = '3-01-2013';
I.cage{ind} = 'E28';
I.isolationdate{ind} = '4-5-2013';
I.firstsongsrecorded{ind} = '5-07-2013'; 
I.firstrhythmic{ind} = '5-13-2013';
I.veryrhythmic{ind} = '5-25-2013';
I.adultsong{ind} = '6-10-2013';
I.to_hotel{ind} = '6-28-2013';
I.directed{ind} = '3650-2013-09-06-DIRECTED';
I.notes{ind} = 'did not sing much at all early on, not as rhythmic as others, perhaps has several syllable durations, does not seem to have adult motif';
%3651
ind = ind+1;
I.Name{ind} = 3651;
I.birthdate{ind} = '3-01-2013';
I.cage{ind} = 'E28';
I.isolationdate{ind} = '4-5-2013';
I.firstsongsrecorded{ind} = '4-08-2013';
I.firstrhythmic{ind} = '4-13-2013';
I.veryrhythmic{ind} = '4-27-2013';
I.adultsong{ind} = '6-18-2013';
I.to_hotel{ind} = '6-30-2013';
I.directed{ind} = '3651-2013-09-06-DIRECTED';
I.notes{ind} = 'very rhythmic. adult song has motif.';
%3710
ind = ind+1;
I.Name{ind} = 3710;
I.birthdate{ind} = '3-26-2013';
I.cage{ind} = '49';
I.isolationdate{ind} = '5-03-2013';
I.firstsongsrecorded{ind} = '5-14-2013';
I.firstrhythmic{ind} = '5-26-2013';
I.veryrhythmic{ind} = '5-30-2013';
I.adultsong{ind} = '7-03-2013';
I.notes{ind} = 'rhythmic within syllables (triplets), 2 rhythms early on, faster later';

%3747 tutored with AB tutor
% ind = ind+1;
% I.Name{ind} = 3747;
% I.birthdate{ind} = '4-13-2013';
% I.cage{ind} = '35-E';
% I.isolationdate{ind} = '5-17-2013';
% i.directed{ind} = '3747-2013-09-06-DIRECTED';
% I.notes{ind} = 'very rhythmic for a while';

%3770
ind = ind+1;
I.Name{ind} = 3770;
I.birthdate{ind} = '4-24-2013';
I.cage{ind} = 'E37';
I.directed{ind} = '3770-2013-09-06-DIRECTED';
I.isolationdate{ind} = '5-29-2013';

%3808
ind = ind+1;
I.Name{ind} = 3808;
I.birthdate{ind} = '5-12-2013';
I.cage{ind} = 'E41';
I.isolationdate{ind} = '6-17-2013';
%3809
ind = ind+1;
I.Name{ind} = 3809;
I.birthdate{ind} = '5-12-2013';
I.cage{ind} = 'E41';
I.directed{ind} = '3809-2013-09-06-DIRECTED';
I.isolationdate{ind} = '6-17-2013';
%3815
ind = ind+1;
I.Name{ind} = 3815;
I.birthdate{ind} = '5-18-2013';
I.cage{ind} = 'E42';
I.isolationdate{ind} = '6-21-2013';
I.notes{ind} = 'slight chance swapped w 3826';
%3826
ind = ind+1;
I.Name{ind} = 3826;
I.birthdate{ind} = '5-25-2013';
I.cage{ind} = 'unsure';
I.isolationdate{ind} = '6-28-2013';
I.notes{ind} = 'slight chance swapped w 3815';
%3827
ind = ind+1;
I.Name{ind} = 3827;
I.birthdate{ind} = '5-25-2013';
I.cage{ind} = 'unsure';
I.isolationdate{ind} = '6-28-2013';
%3837
ind = ind+1;
I.Name{ind} = 3837;
I.birthdate{ind} = '5-29-2013';
I.cage{ind} = 'E45';
I.isolationdate{ind} = '7-03-2013';
%3838
ind = ind+1;
I.Name{ind} = 3838;
I.birthdate{ind} = '5-29-2013';
I.cage{ind} = 'E45';
I.isolationdate{ind} = '7-03-2013';
%3849
ind = ind+1;
I.Name{ind} = 3849;
I.birthdate{ind} = '5-30-2013';
I.cage{ind} = 'E40';
I.isolationdate{ind} = '7-08-2013';
%3850
ind = ind+1;
I.Name{ind} = 3850;
I.birthdate{ind} = '5-30-2013';
I.cage{ind} = 'E40';
I.isolationdate{ind} = '7-08-2013';
%3861
ind = ind+1;
I.Name{ind} = 3861;
I.birthdate{ind} = '6-09-2013';
I.cage{ind} = 'E40';
I.isolationdate{ind} = '7-15-2013';
%3982
ind = ind+1;
I.Name{ind} = 3982;
I.birthdate{ind} = '7-27-2013';
I.cage{ind} = 'E40';
I.isolationdate{ind} = '9-06-2013';
%4014
ind = ind+1;
I.Name{ind} = 4014;
I.birthdate{ind} = '8-9-2013';
%4031
ind = ind+1;
I.Name{ind} = 4031;
I.birthdate{ind} = '8-14-2013';
%4033
ind = ind+1;
I.Name{ind} = 4033;
I.birthdate{ind} = '8-14-2013';
%4140
ind = ind+1;
I.Name{ind} = 4140;
I.birthdate{ind} = '9-20-2013';
%4141
ind = ind+1;
I.Name{ind} = 4141;
I.birthdate{ind} = '9-20-2013';
%4203
ind = ind+1;
I.Name{ind} = 4203;
I.birthdate{ind} = '10-12-2013';