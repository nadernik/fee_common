function [XLS, Columns] = loadNIfSpreadsheet_elm();

XLS = importdata('C:/Users/emackev/Dropbox (MIT)/MackeviciusLabPresentations/NIfUnits1.xlsx');
XLS.data.Sheet1 = [NaN*ones(1, size(XLS.data.Sheet1,2)); XLS.data.Sheet1]; % add row corresponding to title row, so indices line up./
Columns = XLS.textdata.Sheet1(1,:);