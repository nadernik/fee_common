clear all
close all; 
writevideo = 1; 
Ntime = 150;
Nparticles = 2000; 
Nseeds = 4; 
SideLength = 100;
RefPer = 3;

Radius = 12;

ThreeD = 1;  
JustSlice = 1; 

SliceMin = 0; 
SliceMax = 10; 

Ref = zeros(Ntime,Nparticles);
Saturation = zeros(Ntime,Nparticles);
Dist = zeros(Nparticles, Nparticles); 

if writevideo
    writerObj = VideoWriter(['AUTOMATA','.avi']);
    writerObj.FrameRate = 10;
    open(writerObj)
end
figure; set(gcf, 'Color', [1 1 1])
hold on
axis off; set(gcf, 'Color', [1 1 1])
if ThreeD
    pos = rand(Nparticles, 3)*SideLength;
else
    pos = rand(Nparticles, 2)*SideLength;
end

SlicePs = find((pos(:,3)>SliceMin)&(pos(:,3)<SliceMax));


for i = Nseeds+1:Nparticles
    for j = 1:Nparticles
        Dist(i,j) = norm(pos(i,:)-pos(j,:));
    end
    Neighbors(i,:) = (Dist(i,:)<Radius & 1:Nparticles ~= i);
end
%figure;imagesc(Dist); colormap gray


Saturation(:,1:Nseeds) = rand(Ntime, Nseeds)>.9;

for timei = 1:Ntime-1;
    if ThreeD
        if JustSlice
            scatter(pos(SlicePs,1), pos(SlicePs,2), ...
                'c', 'marker', '.','sizedata', 1000*Ref(timei,SlicePs)+1); hold on
            scatter(pos(SlicePs,1), pos(SlicePs,2),...
                'm', 'marker', '.','sizedata', 1000*Saturation(timei, SlicePs)+1); hold off
        else
            scatter3(pos(:,1), pos(:,2), pos(:,3), 'c', 'marker', '.','sizedata', 1000*Ref(timei,:)+1); hold on
            scatter3(pos(:,1), pos(:,2), pos(:,3), 'm', 'marker', '.','sizedata', 1000*Saturation(timei,:)+1); hold off
        end
    else
        scatter(pos(:,1), pos(:,2), 'c', 'marker', '.','sizedata', 1000*Ref(timei,:)+1); hold on
        scatter(pos(:,1), pos(:,2), 'm', 'marker', '.','sizedata', 1000*Saturation(timei,:)+1); hold off
    end
    for i = Nseeds+1:Nparticles
        if sum(Saturation(timei, find(Neighbors(i,:))))>0 & (Ref(timei,i)==0)
            Saturation(timei+1,i) = 1; 
            Ref((timei+1):(timei+RefPer),i) = 1;
        end
    end
    if writevideo
        V1 = getframe; 
        writeVideo(writerObj, V1);
    end
    pause(.1);
end
if writevideo
    close(writerObj)
end