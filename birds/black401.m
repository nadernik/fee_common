%%

Drug.Name          = 'PBS';
Drug.Concentration = 0;
Drug.TimeIn        = datenum([2010 12 18 13 43 00]);
Drug.TimeOut       = Inf;
annodrugs('black401', '2010-12-18', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 2.25e-3;
Drug.TimeIn        = datenum([2010 12 21 11 57 00]);
Drug.TimeOut       = datenum([2010 12 21 23 26 00]);
annodrugs('black401', '2010-12-21', Drug)

Drug.Name          = 'PBS';
Drug.Concentration = 0;
Drug.TimeIn        = datenum([2010 12 22 12 57 00]);
Drug.TimeOut       = Inf;
annodrugs('black401', '2010-12-22', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 2.25e-3;
Drug.TimeIn        = datenum([2010 12 24 11 13 00]);
Drug.TimeOut       = Inf;
annodrugs('black401', '2010-12-24', Drug)

expernames = {'2010-12-17', '2010-12-18', '2010-12-19', '2010-12-20', ...
    '2010-12-21', '2010-12-22', '2010-12-23', '2010-12-24'};
[conc, N] = singingwithdrugs('black401', expernames, 19, 22);
scatter(conc, N)
% drug does not decrease singing

N = singingwithdrugs2('black401',expernames);
plot(N)

%%
