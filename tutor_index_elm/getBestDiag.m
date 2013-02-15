
function [partialScore_syll d1 d2 Next_box Pre_box fin_bordersSon]=getBestDiag(borders,nextBorders,preBorders,tmpMat)
        
matrix=tmpMat(borders(1,1):borders(1,2),borders(2,1):borders(2,2));
[M,N]=size(matrix);
k=0;
if isempty(matrix) || size(matrix,1)==1
    'hold';
end
for i=(-M+1):(N-1)      k=k+1;        d(k,1:2)=[sum(diag(matrix,i)) i];end
[partialScore_syll,index]=max(d(:,1));
partialScore_syll=partialScore_syll;%./(borders(1,2)-borders(1,1));
i=borders(1,1):(borders(1,1)+3000); j=(borders(2,1):(borders(2,1)+3000))+d(index,2);
inx=find(i>=borders(1,1) & i<=borders(1,2) & j>=1 & j<=size(tmpMat,2)); d1=i(inx);d2=j(inx); 
fin_bordersSon=[min(d2) max(d2)];
if length(fin_bordersSon)<2
    'hold';
end

if isempty(preBorders)
    Pre_box=[-1 -1;-1 -1];
else
i=(borders(1,1)-3000):(borders(1,1)+3000); j=((borders(2,1)-3000):(borders(2,1)+3000))+d(index,2);
inx=find(i>=preBorders(1,1) & i<=borders(1,1) & j>=1 & j<=size(tmpMat,2)); i=i(inx);j=j(inx); 
if length(j)<5
    Pre_box=[-1 -1;-1 -1];
else
Pre_box=[preBorders(1,1) preBorders(1,2);max(1,min(j)-50) min(size(tmpMat,2),max(j))]; 
end
end


if isempty(nextBorders)
    Next_box=[-1 -1;-1 -1];
else
i=borders(1,1):(borders(1,1)+3000); j=(borders(2,1):(borders(2,1)+3000))+d(index,2);
inx=find(i>=borders(1,2) & i<=nextBorders(1,2) & j>=1 & j<=size(tmpMat,2)); i=i(inx);j=j(inx); 
if length(j)<5
    Next_box=[-1 -1;-1 -1];
else
Next_box=[nextBorders(1,1) nextBorders(1,2);max(1,min(j)) min(size(tmpMat,2),max(j)+50)]; 
end
end