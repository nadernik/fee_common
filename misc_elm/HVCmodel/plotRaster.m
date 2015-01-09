function plotRaster(xplot,TrainingNeurons,PlottingParams)
%%% use with plotHVCraster_split.m
%%% avoid problems when exporting to .eps
%%% Tatsuo Okubo
%%% 2014/12/15

IsTrain1 = sum(xplot==1+2/64,2)>0;
IsTrain2 = sum(xplot==1+3/64,2)>0; 
IsTrainProto = sum(xplot==1+4/64,2)>0; 

IsTrain = IsTrain1|IsTrain2; 

if isfield(PlottingParams, 'tOffset')
    tOffset = PlottingParams.tOffset; 
else
    tOffset = 0; 
end

for j=1:size(xplot,2) % for all the time steps
    Idx = find(xplot(1:end-1,j)>0); % find the indices of active neurons    
    if ~isempty(Idx)
        for k=1:length(Idx) % for all the active neurons
            Color = IsTrain1(Idx(k))*PlottingParams.Syl1Color + ...
                IsTrain2(Idx(k))*PlottingParams.Syl2Color + ...
                IsTrainProto(Idx(k))*PlottingParams.ProtoSylColor; 
%             if IsTrain(Idx(k)) % check if this neuron is the training neuron
%                 if IsProto % protosyllable stage
%                     Color = PlottingParams.ProtoSylColor;
%                 else % multiple syllable stage
%                     switch i
%                         case 1 % syllable 1
%                             Color = PlottingParams.Syl1Color;
%                         case 2 % sylalble 2
%                             Color = PlottingParams.Syl2Color;
%                     end
%                 end
%             else % other neurons
%                 Color = 'k';
%             end
            h = patch(10*([j-1,j,j,j-1]+tOffset),[Idx(k)-1,Idx(k)-1,Idx(k),Idx(k)],Color,'edgecolor','none');
        end  
    end
end
set(gca,'ydir','reverse')
end