function TI_part2()

% Mypath=mfilename('fullpath');Mypath=Mypath(1:end-8); % this is empty...
% load TIdata.mat; %load([Mypath '\TIdata.mat'])
% button = questdlg('Use default file paths?', 'Choose folders', 'Yes');
% switch button
%     case 'Yes'
%         pathName = 'Y:\TI_data_weeded\Songbirds';
%         TutorpathName = 'Y:\TI_data_weeded\Tutors';
%         str_listBirds = 'TutorMatch.xls';
%         str_pathname = 'Y:\TI_data_weeded';
%     case 'No'
%         pathName = uigetdir('', 'Choose the directory that contains all bird songs');
%         TutorpathName = uigetdir('', 'Choose the directory that contains all Tutor songs');
%         [str_listBirds,str_pathname] = uigetfile({'*.xls; *.xlsx', 'All excel files (*.xls,*.xlsx)'}, 'Choose excel file that contains names of birds and tutors'); 
%     case 'Cancel'
%         disp('Canceled')
% end
% ExcelFileName=[str_pathname '\' str_listBirds];
% [listAll,listAllTXT,listAllAll]=xlsread(ExcelFileName);
% if size(listAll,2)>2
%     indexBirds=find(listAll(:,1))';
% else indexBirds=1:length(listAll); end
% save 'TIdata.mat' pathName TutorpathName listAll* indexBirds ExcelFileName
Mypath=mfilename('fullpath');Mypath=Mypath(1:end-8);
load([Mypath '\TIdata.mat'])

listAllTXT{1,1}='Analyzed?';
listAllTXT{1,2}='Bird name';
listAllTXT{1,3}='Tutor name';
listAllTXT{1,4}='Averaged Imitation';
listAllTXT{1,5}='Averaged Similarity';
listAllTXT{1,6}='Averaged Sequencing';
listAllTXT{1,7}='STD Imitation';
listAllTXT{1,8}='STD Similarity';
listAllTXT{1,9}='STD Sequencing';
listAllTXT{1,10}='number of comparisons';
listAllNew=zeros(size(listAll,1),10)-1;
listAllNew(:,1:3)=listAll;
for i=indexBirds
    birdname=num2str(listAll(i,2))
    Tutorname=num2str(listAll(i,3))
    L=TheFeatureMaker([TutorpathName '/' Tutorname '/motif' ],1.55,0.2,'features.mat');
    TheFeatureMaker([pathName '/' birdname],L*2+0.1, 0.2,'features.mat');
    [Tscores_fin{i}, Sequence_fin{i}, Imitation_fin{i}]=calcSimmilarity([pathName '/' birdname],'features.mat',[TutorpathName '/' Tutorname '/motif' ],'similarity_Motif.mat');
    listAllNew(i,4:10)=[mean(Imitation_fin{i}) mean(Tscores_fin{i}) mean(Sequence_fin{i}) std(Imitation_fin{i})  std(Tscores_fin{i}) std(Sequence_fin{i}) length(Imitation_fin{i})];
end
CelllistAll=[listAllTXT;num2cell(listAllNew)];
cd(pathName)

save 'Tutor_Imitation.mat' Tscores_fin  Sequence_fin Imitation_fin
Dotindex=find(ExcelFileName=='.');
slashindex=max([find(ExcelFileName=='/') find(ExcelFileName=='\')]);if isempty(slashindex) slashindex=0; end
s = size(CelllistAll);
for i = 1:s(1)
    for j = 1:s(2)
        if isempty(CelllistAll{i,j})
            CelllistAll{i,j} = 0; 
        end
    end
end
save([ ExcelFileName(slashindex+1:Dotindex-1) '_output.mat'], 'CelllistAll');
xlswrite([ ExcelFileName(slashindex+1:Dotindex-1) '_output'],(listAllNew));
%xlswrite([ ExcelFileName(slashindex+1:Dotindex-1) '_output'],CelllistAll);
%I think this requires Excel