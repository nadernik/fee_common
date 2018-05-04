function TI_part1()
Mypath=mfilename('fullpath');Mypath=Mypath(1:end-8);
button = questdlg('Use default file paths?', 'Choose folders', 'Yes');
switch button
    case 'Yes'
        initial_path = PlatformPicker('feebox3', 'emily');
        pathName = fullfile(initial_path, 'TI_data_weeded','Songbirds'); 
        TutorpathName = fullfile(initial_path, 'TI_data_weeded', 'Tutors');
        str_listBirds = 'TutorMatch.xls';
        str_pathname = fullfile(initial_path, 'TI_data_weeded');
    case 'No'
        pathName = uigetdir('', 'Choose the directory that contains all bird songs');
        TutorpathName = uigetdir('', 'Choose the directory that contains all Tutor songs');
        [str_listBirds,str_pathname] = uigetfile({'*.xls; *.xlsx', 'All excel files (*.xls,*.xlsx)'}, 'Choose excel file that contains names of birds and tutors'); 
    case 'Cancel'
        disp('Canceled')
end
ExcelFileName=fullfile(str_pathname, str_listBirds);
[listAll,listAllTXT,listAllAll]=xlsread(ExcelFileName);
if size(listAll,2)>2
    indexBirds=find(listAll(:,1))';
else indexBirds=1:length(listAll); end
cd(Mypath);
save 'TIdata.mat' pathName TutorpathName listAll* indexBirds ExcelFileName

%Detect song sections and segment to syllables
for i=indexBirds
    birdname=num2str(listAll(i,2))
    Tutorname=num2str(listAll(i,3))
    Bout_detect(fullfile(TutorpathName, Tutorname, '/motif' )); % elm
    disp(['detecting bouts in: ' pathName filesep birdname])
    Bout_detect(fullfile(pathName, birdname));
end

