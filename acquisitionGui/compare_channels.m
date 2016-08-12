function allChannelsMatch = compare_channels(channelsToFind, comparisonChannels)
%fewer channelsToFind must all be there or not in comparisonChannels
nChan = numel(channelsToFind);
channelsMatch = false(nChan, 1);
for chanNo = 1:nChan
    if any(channelsToFind(chanNo) == comparisonChannels)
        channelsMatch(chanNo) = true;
    end
end
if all(channelsMatch)
    allChannelsMatch = true;
elseif any(channelsMatch)
    error('Only some channels match!');
else
    allChannelsMatch = false;
end