function DoesItFit = MotifCheck(params)
switch params.Method
    case 'labels'
        DoesItFit = isequal(params.CheckTheseLabels, params.WantTheseLabels); 
    case 'times'
        DoesItFit = sum(abs(params.CheckTheseTimes(:) - params.WantTheseTimes(:))) < params.AllowedJitter; 
end