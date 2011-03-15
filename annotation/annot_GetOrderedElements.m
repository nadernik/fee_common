function [filenames, annots, filetimes] = annot_GetOrderedElements(annotation)
filenames = annotation.keys;
annots = annotation.elements;

%Sort annotations by file recording time
filetimes = zeros(length(filenames),1);
for nAnnot = 1:length(annots)
    if(~isfield(annots{nAnnot},'recorder') || strcmpi(annots{nAnnot}.recorder, 'Exper'))
        filetimes(nAnnot) = extractTimeFromFilename(annots{nAnnot}.exper, filenames{nAnnot});
    elseif(strcmpi(annots{nAnnot}.recorder, 'SAP'))
        filetimes(nAnnot) = aSAP_extractTimeFromSAPFileName(filenames{nAnnot});
    end
end
[filetimes, sortndx] = sort(filetimes);
filenames = filenames(sortndx);
annots = annots(sortndx);