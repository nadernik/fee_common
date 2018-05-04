function filtered = medianFilter(signal, window)
    nFrames = size(signal,2);
    for fi = 1:nFrames
        med(:,fi) = median(signal(:,abs((1:nFrames)-fi)<window),2);
    end
    filtered = signal-med;
%     plot(filtered(1:5:20, 1:200)'); 
end