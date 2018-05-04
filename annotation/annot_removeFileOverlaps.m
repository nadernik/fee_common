function annotation = annot_removeFileOverlaps(annotation)

[filenames, annots] = annot_GetOrderedElements(annotation);
%Get rid of overlapping syllables
for nAnnot = 1:length(annots)-1
    absEndTimesPrev = annots{nAnnot}.segAbsEndTimes;%annots{nAnnot}.segAbsStartTimes + ...
        %(annots{nAnnot}.segFileEndTimes - annots{nAnnot}.segFileStartTimes)/annots{nAnnot}.fs; %%% TO
    if(~isempty(absEndTimesPrev))
        absStartTimesNext = annots{nAnnot+1}.segAbsStartTimes;
        overlap = find(absStartTimesNext < absEndTimesPrev(end));
        if(~isempty(overlap))
            annots{nAnnot+1}.segAbsStartTimes = annots{nAnnot+1}.segAbsStartTimes(overlap(end)+1:end);
            annots{nAnnot+1}.segAbsEndTimes = annots{nAnnot+1}.segAbsEndTimes(overlap(end)+1:end);
            annots{nAnnot+1}.segFileStartTimes = annots{nAnnot+1}.segFileStartTimes(overlap(end)+1:end);
            annots{nAnnot+1}.segFileEndTimes = annots{nAnnot+1}.segFileEndTimes(overlap(end)+1:end);
            annots{nAnnot+1}.segType = annots{nAnnot+1}.segType(overlap(end)+1:end);
            annots{nAnnot+1}.segmentationMethod = annots{nAnnot+1}.segmentationMethod(overlap(end)+1:end);
            annotation.put(filenames{nAnnot+1}, annots{nAnnot+1});
        end
    end
end